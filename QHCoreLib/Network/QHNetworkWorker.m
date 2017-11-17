//
//  QHNetworkWorker.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkWorker.h"

#import "QHBase+internal.h"
#import "QHLog.h"

#import "QHNetwork.h"

#import "_QHNetworkWorker+subclass.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHNetworkWorkerDidStartNotification = @"QHNetworkWorkerDidStartNotification";
NSString * const QHNetworkWorkerDidFinishNotification = @"QHNetworkWorkerDidFinishNotification";

typedef NS_ENUM(NSUInteger, QHNetworkWorkerState) {
    QHNetworkWorkerStateNone,
    QHNetworkWorkerStateLoading,
    QHNetworkWorkerStateCancelled,
    QHNetworkWorkerStateFinished,
};

@interface QHNetworkWorker () {
@private
    QHNetworkWorkerState _state;
    dispatch_semaphore_t _stateLock;
    NSRecursiveLock *_lock;
}

@property (nonatomic, assign, readwrite) QHNetworkWorkerState state;
@property (nonatomic, readonly) NSRecursiveLock *lock;

@property (nonatomic, copy) void(^ _Nullable uploadProgressHandler)(NSProgress *) ;
@property (nonatomic, copy) void(^ _Nullable downloadProgressHandler)(NSProgress *);
@property (nonatomic, copy) QHNetworkWorkerCompletionHandler _Nullable completionHandler;

@end

@implementation QHNetworkWorker

+ (void)cancelAll
{
    [QHNetworkWorkerAFHTTPRequestOperation cancelAll];
}

+ (QHNetworkWorker *)workerFromRequest:(QHNetworkRequest *)request
{
    return [[QHNetworkWorkerAFHTTPRequestOperation alloc] initWithRequest:request];
}

- (instancetype)initWithRequest:(QHNetworkRequest *)request
{
    self = [super init];
    if (self) {
        _state = QHNetworkWorkerStateNone;
        _stateLock = dispatch_semaphore_create(1);
        _lock = [[NSRecursiveLock alloc] init];

        self.request = request;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@(%p), request: %@, state: %lu>",
            NSStringFromClass([self class]),
            self,
            self.request,
            (unsigned long)self.state];
}

@dynamic state;

- (QHNetworkWorkerState)state
{
    __block QHNetworkWorkerState state = QHNetworkWorkerStateNone;
    QHDispatchSemaphoreLock(_stateLock, ^{
        @retainify(self);
        state = self->_state;
    });
    return state;
}

- (void)setState:(QHNetworkWorkerState)state
{
    QHDispatchSemaphoreLock(_stateLock, ^{
        @retainify(self);
        self->_state = state;
    });
}

@dynamic lock;

- (NSRecursiveLock *)lock
{
    return _lock;
}

- (void)startWithCompletionHandler:(QHNetworkWorkerCompletionHandler)completionHandler
{
    QHNSLock(_lock, ^{
        @retainify(self);

        QHAssertReturnVoidOnFailure(self.state == QHNetworkWorkerStateNone,
                                    @"reuse of worker is not supported, call stack: %@",
                                    QHCallStackShort());

        self.state = QHNetworkWorkerStateLoading;

        self.completionHandler = completionHandler;
        
        [self p_doStart];

        [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkWorkerDidStartNotification
                                                            object:self];
    });
}

- (void)cancel
{
    QHNSLock(_lock, ^{
        @retainify(self);

        self.state = QHNetworkWorkerStateCancelled;

        self.uploadProgressHandler = nil;
        self.downloadProgressHandler = nil;
        self.completionHandler = nil;

        [self p_doCancel];

        [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkWorkerDidFinishNotification
                                                            object:self];
    });
}

- (BOOL)isLoading
{
    return (self.state == QHNetworkWorkerStateLoading);
}

- (BOOL)isCancelled
{
    return (self.state == QHNetworkWorkerStateCancelled);
}

- (void)p_doStart
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
}

- (void)p_doCancel
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
}

- (void)p_fireUploadProgress:(NSProgress *)progress
{
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        @retainify(self);
        
        QHNSLock(self.lock, ^{
            if (self.uploadProgressHandler) {
                self.uploadProgressHandler(progress);
            }
        });
    });
}

- (void)p_fireDownloadProgress:(NSProgress *)progress
{
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        @retainify(self);
        
        QHNSLock(self.lock, ^{
            if (self.downloadProgressHandler) {
                self.downloadProgressHandler(progress);
            }
        });
    });
}

- (void)p_fireCompletionWithResponse:(QHNetworkResponse * _Nullable)response
                               error:(NSError * _Nullable)error
{
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        @retainify(self);

        QHNSLock(self.lock, ^{
            self.state = QHNetworkWorkerStateFinished;

            if (self.completionHandler) {
                self.completionHandler(self, response, error);
                
                self.uploadProgressHandler = nil;
                self.downloadProgressHandler = nil;
                self.completionHandler = nil;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkWorkerDidFinishNotification
                                                                object:self];
        });
    });
}

@end

NS_ASSUME_NONNULL_END
