//
//  QHAsyncTask.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/12.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncTask.h"
#import "QHAsyncTask+internal.h"

#import "QHLog.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHAsyncTaskErrorDomain = @"QHAsyncTaskErrorDomain";

@interface QHAsyncTask () {
@private
    QHAsyncTaskState _state;
    dispatch_semaphore_t _stateLock;
    NSRecursiveLock *_lock;
}

@property (nonatomic, assign, readwrite) QHAsyncTaskState state;
@property (nonatomic, readonly) NSRecursiveLock *lock;

@property (nonatomic, copy) QHAsyncTaskSuccessBlock _Nullable successBlock;
@property (nonatomic, copy) QHAsyncTaskFailBlock _Nullable failBlock;

@end

@implementation QHAsyncTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stateLock = dispatch_semaphore_create(1);
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    QHNSLock(_lock, ^{
        @retainify(self);
        [self p_doClean];
    });
}

@dynamic state;

- (QHAsyncTaskState)state
{
    __block QHAsyncTaskState state;
    QHDispatchSemaphoreLock(_stateLock, ^{
        @retainify(self);
        state = self->_state;
    });
    return state;
}

- (void)setState:(QHAsyncTaskState)state
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

- (void)startWithSuccess:(void (^ _Nullable)(QHAsyncTask *, NSObject * _Nullable))success
                    fail:(void (^ _Nullable)(QHAsyncTask *, NSError *))fail
{
    QHNSLock(_lock, ^{
        @retainify(self);
        
        if (self.state == QHAsyncTaskStateNone) {
            self.state = QHAsyncTaskStateLoading;
            
            self.successBlock =  success;
            self.failBlock = fail;
            
            @weakify(self);
            [self p_asyncOnWorkQueue:^{
                @strongify(self);

#warning check this lock for racing with cancel on different thread
                if (self.state != QHAsyncTaskStateCancelled) {
                    QHNSLock(self.lock, ^{
                        [self p_doStart];
                    });
                }
            }];
        }
        else {
            QHAssert(NO, @"async task must not be reused: %@", self);
        }
    });
}

- (Class)resultClass
{
    return [NSObject class];
}

- (BOOL)isLoading
{
    return self.state == QHAsyncTaskStateLoading;
}

- (void)clear
{
    QHNSLock(_lock, ^{
        @retainify(self);
        [self p_doClean];
    });
}

- (void)cancel
{
    QHNSLock(_lock, ^{
        @retainify(self);
        [self p_doClean];
        [self p_doCancel];
        self.state = QHAsyncTaskStateCancelled;
        [self p_doTeardown];
    });
}

#pragma mark -

- (void)p_asyncOnWorkQueue:(dispatch_block_t)block
{
    if (block == nil) return;
    
    dispatch_queue_t queue = (self.workQueue ?:
                              dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0));
    dispatch_async(queue, ^{
        QH_BLOCK_INVOKE(block);
    });
}

- (void)p_asyncOnCompletionQueue:(dispatch_block_t)block
{
    if (block == nil) return;
    
    dispatch_queue_t queue = (self.completionQueue ?:
                              dispatch_get_main_queue());
    dispatch_async(queue, ^{
        QH_BLOCK_INVOKE(block);
    });
}

- (void)p_asyncOnDisposeQueue:(dispatch_block_t)block
{
    if (block == nil) return;
    
    dispatch_queue_t queue = (self.disposeQueue ?:
                              dispatch_get_main_queue());
    dispatch_async(queue, ^{
        QH_BLOCK_INVOKE(block);
    });
}

#pragma mark -

- (void)p_doStart
{
    // subclass implements
}

- (void)p_doCancel
{
    // subclass implements
}

- (void)p_doClean
{
    @autoreleasepool {
        __block NSMutableArray *resources = [NSMutableArray array];
        [self p_doCollect:resources];
        
        if (resources.count > 0) {
            [self p_asyncOnDisposeQueue:^{
                resources = nil;
            }];
        }
    }
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    if (self.successBlock) {
        [releaseOnDisposeQueue qh_addObject:self.successBlock];
        self.successBlock = nil;
    }
    
    if (self.failBlock) {
        [releaseOnDisposeQueue qh_addObject:self.failBlock];
        self.failBlock = nil;
    }
}

- (void)p_doTeardown
{
    // subclass implements
}

#pragma mark -

- (void)p_fireSuccess:(NSObject * _Nullable)result
{
    [self p_asyncOnWorkQueue:^{
        @retainify(self);
        
        if (result != nil) {
            Class resultClass = [self resultClass];
            if (resultClass && ![result isKindOfClass:resultClass]) {
                NSString *message = $(@"invalid result: %@, should be kind of %@", result, NSStringFromClass(resultClass));
                [self locked_fireFail:QH_ERROR(QHAsyncTaskErrorDomain,
                                               QHAsyncTaskErrorInvalidResult,
                                               message,
                                               nil)];
                return;
            }
        }
        
        [self locked_fireSuccess:result];
    }];
}

- (void)locked_fireSuccess:(NSObject * _Nullable)result
{
    QHNSLock(_lock, ^{
        @retainify(self);
        
        if ([self p_canInvokeCallback]) {
            __block QHAsyncTaskSuccessBlock success = self.successBlock;
            
            [self p_doClean];
            
            if (success) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if ([self p_canInvokeCallback]) {
                        success(self, result);
                    }
                    
                    [self p_asyncOnDisposeQueue:^{
                        success = nil;
                    }];
                    
                    [self p_asyncOnWorkQueue:^{
                        @retainify(self);
                        [self p_doTeardown];
                    }];
                }];
            }
            else {
                [self p_doTeardown];
            }
        }
    });
}

- (BOOL)p_canInvokeCallback
{
    return self.state == QHAsyncTaskStateLoading || self.state == QHAsyncTaskStateFinished;
}

- (void)p_fireFail:(NSError *)error
{
    [self p_asyncOnWorkQueue:^{
        @retainify(self);
        [self locked_fireFail:error];
    }];
}

- (void)locked_fireFail:(NSError *)error
{
    QHNSLock(_lock, ^{
        @retainify(self);
        
        if ([self p_canInvokeCallback]) {
            __block QHAsyncTaskFailBlock fail = self.failBlock;
            
            [self p_doClean];
            
            if (fail) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if ([self p_canInvokeCallback]) {
                        fail(self, error);
                    }
                    
                    [self p_asyncOnDisposeQueue:^{
                        fail = nil;
                    }];
                    
                    [self p_asyncOnWorkQueue:^{
                        @retainify(self);
                        [self p_doTeardown];
                    }];
                }];
            }
            else {
                [self p_doTeardown];
            }
        }
    });
}

@end

NS_ASSUME_NONNULL_END
