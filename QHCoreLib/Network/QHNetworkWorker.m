//
//  QHNetworkWorker.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkWorker.h"

#import "QHUtil.h"
#import "QHAsserts.h"
#import "QHLogUtil.h"

#import "QHNetwork.h"

#import "_QHNetworkWorker+subclass.h"


@interface QHNetworkWorker () {
    @private
    dispatch_semaphore_t stateLock;
    NSRecursiveLock *actionLock;
}

@property (nonatomic, copy) QHNetworkWorkerCompletionHandler completionHandler;

@end

@implementation QHNetworkWorker

@synthesize state=_state;

+ (NSOperationQueue *)sharedNetworkQueue
{
    static NSOperationQueue *networkQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkQueue = [[NSOperationQueue alloc] init];
        networkQueue.name = @"com.tencent.QHLib.QHCoreLib.networkqueue";
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
        self.request = request;
        stateLock = dispatch_semaphore_create(1);
        actionLock = [[NSRecursiveLock alloc] init];
        self.state = QHNetworkWorkerStateNone;
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

- (QHNetworkWorkerState)state
{
    __block QHNetworkWorkerState state = QHNetworkWorkerStateNone;

    QHDispatchSemaphoreLock(stateLock, ^{
        state = self->_state;
    });

    return state;
}

- (void)setState:(QHNetworkWorkerState)state
{
    QHDispatchSemaphoreLock(stateLock, ^{
        self->_state = state;
    });
}

- (void)startWithCompletionHandler:(QHNetworkWorkerCompletionHandler)completionHandler
{
    QHNSLock(actionLock, ^{
        QHAssertReturnVoidOnFailure(self.state == QHNetworkWorkerStateNone,
                                    @"reuse of worker is not supported, call stack: %@",
                                    QHCallStackShort());

        self.state = QHNetworkWorkerStateLoading;

        self.completionHandler = completionHandler;
        
        [self p_doStart];
    });
}

- (void)cancel
{
    QHNSLock(actionLock, ^{
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
    QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
}

- (void)p_doCancel
{
    QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
}

- (void)p_doCompletion:(QHNetworkWorker *)worker response:(QHNetworkResponse *)response error:(NSError *)error
{
    dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
        QHNSLock(actionLock, ^{
            self.state = QHNetworkWorkerStateFinished;

            [self p_checkSlowRequest];

            if (self.completionHandler) {
                self.completionHandler(worker, response, error);

                self.completionHandler = nil;
            }
        });
    });
}

- (int)connectCost
{
    QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
    return 0;
}

- (int)transportCost
{
    QH_SUBCLASS_MUST_OVERRIDE;
    NSAssert(NO, @"subclass should implement");
    return 0;
}

- (int)requestCost
{
    QH_SUBCLASS_MUST_OVERRIDE;
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
