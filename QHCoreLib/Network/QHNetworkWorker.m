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

@property (nonatomic, copy) QHNetworkWorkerCompletionHandler _Nullable completionHandler;

@end

@implementation QHNetworkWorker

+ (NSOperationQueue *)sharedNetworkQueue
{
    static NSOperationQueue *networkQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkQueue = [[NSOperationQueue alloc] init];
        networkQueue.name = @"com.tencent.QHLib.QHCoreLib.networkqueue";
        networkQueue.maxConcurrentOperationCount = 4;
    });
    return networkQueue;
}

+ (void)cancelAll
{
    [[self sharedNetworkQueue] cancelAllOperations];
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

        self.completionHandler = nil;

        [self p_doCancel];
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

- (void)p_doCompletion:(QHNetworkWorker *)worker
              response:(QHNetworkResponse * _Nullable)response
                 error:(NSError * _Nullable)error
{
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        @retainify(self);

        QHNSLock(self.lock, ^{
            self.state = QHNetworkWorkerStateFinished;

            [self p_checkSlowRequest];

            if (self.completionHandler) {
                self.completionHandler(worker, response, error);

                self.completionHandler = nil;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkWorkerDidFinishNotification
                                                                object:self];
        });
    });
}

- (int)connectCost
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
    return 0;
}

- (int)transportCost
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
    return 0;
}

- (int)requestCost
{
    @QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
    return 0;
}

#pragma mark 

- (void)p_checkSlowRequest
{
    NSTimeInterval threshold = ([QHNetwork sharedInstance].status == QHNetworkStatusReachableViaWiFi
                                ? 3.0 : 10.0f);
    if ([self requestCost] > threshold * 1000) {
        QHLogWarn(@"slow request %@ cost %d ms",
                  self.request.urlRequest.URL.absoluteString,
                  [self requestCost]);
    }
}

@end

NS_ASSUME_NONNULL_END
