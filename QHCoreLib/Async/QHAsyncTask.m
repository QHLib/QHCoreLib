//
//  QHAsyncTask.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/12.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncTask.h"
#import "QHAsyncTask+internal.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHAsyncTaskErrorDomain = @"QHAsyncTaskErrorDomain";

@interface QHAsyncTask () {
@private
    QHAsyncTaskState _state;
    dispatch_semaphore_t _stateLock;
    NSRecursiveLock *_lock;
}

@property (nonatomic, copy) QHAsyncTaskSuccessBlock _Nullable successBlock;
@property (nonatomic, copy) QHAsyncTaskFailBlock _Nullable failBlock;

@end

@implementation QHAsyncTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _state = QHAsyncTaskStateInit;
        _stateLock = dispatch_semaphore_create(1);
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
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

- (void)startWithSuccess:(void (^ _Nullable)(QHAsyncTask *, id _Nullable))success
                    fail:(void (^ _Nullable)(QHAsyncTask *, NSError *))fail
{
    QHNSLock(_lock, ^{
        @retainify(self);
        
        if (self.state == QHAsyncTaskStateInit) {
            self.state = QHAsyncTaskStateStarted;
            
            self.successBlock =  success;
            self.failBlock = fail;
            
            @weakify(self);
            [self p_asyncOnWorkQueue:^{
                @strongify(self);

                if (self.state == QHAsyncTaskStateStarted) {
                    QHNSLock(self->_lock, ^{
                        @retainify(self);

                        if (self.state == QHAsyncTaskStateStarted) {
                            self.state = QHAsyncTaskStateLoading;
                            [self p_doStart];
                        }
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
    QHAsyncTaskState state = self.state;
    return (state != QHAsyncTaskStateInit &&
            state != QHAsyncTaskStateCancelled &&
            state != QHAsyncTaskStateFinished);
}

- (void)clear
{
    QHNSLock(_lock, ^{
        @retainify(self);
        [self p_doClear];
    });
}

- (void)cancel
{
    if ([self isLoading] == NO) {
        return;
    }

    QHNSLock(_lock, ^{
        @retainify(self);

        if ([self isLoading]) {
            self.state = QHAsyncTaskStateCancelled;
            [self p_doClear];
            [self p_doCancel];
            [self p_doClean];
        }
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
    // do nothing, subclass implements detail
}

- (void)p_doClear
{
    [self _clearSuccessFailBlocks];
}

- (void)p_doCancel
{
    // do nothing, subclass implements detail
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
    // do nothing, subclass implements detail
}

#pragma mark -

- (void)_clearSuccessFailBlocks
{
    __block QHAsyncTaskSuccessBlock success = self.successBlock;
    self.successBlock = nil;

    __block QHAsyncTaskFailBlock fail = self.failBlock;
    self.failBlock =  nil;

    if (success || fail) {
        [self p_asyncOnDisposeQueue:^{
            success = nil;
            fail = nil;
        }];
    }
}

- (void)p_fireSuccess:(NSObject * _Nullable)result
{
    [self p_asyncOnWorkQueue:^{
        @retainify(self);
        
        if (result != nil) {
            Class resultClass = [self resultClass];
            if (resultClass && ![result isKindOfClass:resultClass]) {
                NSString *message = $(@"invalid result: %@, should be kind of %@", result, NSStringFromClass(resultClass));
                [self _fireFail:QH_ERROR(QHAsyncTaskErrorDomain,
                                         QHAsyncTaskErrorInvalidResult,
                                         message,
                                         nil)];
                return;
            }
        }
        
        [self _fireSuccess:result];
    }];
}

- (void)_fireSuccess:(NSObject * _Nullable)result
{
    if (self.state != QHAsyncTaskStateLoading) {
        return;
    }

    QHNSLock(_lock, ^{
        @retainify(self);
        
        if (self.state == QHAsyncTaskStateLoading) {
            self.state = QHAsyncTaskStateCallingback;

            __block QHAsyncTaskSuccessBlock success = self.successBlock;

            [self _clearSuccessFailBlocks];

            if (success) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if (self.state == QHAsyncTaskStateCallingback) {
                        success(self, result);

                        self.state = QHAsyncTaskStateFinished;

                        [self p_asyncOnDisposeQueue:^{
                            success = nil;
                        }];

                        [self p_asyncOnWorkQueue:^{
                            @retainify(self);
                            [self p_doClean];
                        }];
                    }
                }];
            }
            else {
                self.state = QHAsyncTaskStateFinished;

                [self p_doClean];
            }
        }
    });
}

- (void)p_fireFail:(NSError *)error
{
    [self p_asyncOnWorkQueue:^{
        @retainify(self);
        [self _fireFail:error];
    }];
}

- (void)_fireFail:(NSError *)error
{
    QHNSLock(_lock, ^{
        @retainify(self);

        if (self.state == QHAsyncTaskStateLoading) {
            self.state = QHAsyncTaskStateCallingback;

            __block QHAsyncTaskFailBlock fail = self.failBlock;
            
            [self _clearSuccessFailBlocks];
            
            if (fail) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if (self.state == QHAsyncTaskStateCallingback) {
                        fail(self, error);

                        self.state = QHAsyncTaskStateFinished;

                        [self p_asyncOnDisposeQueue:^{
                            fail = nil;
                        }];

                        [self p_asyncOnWorkQueue:^{
                            @retainify(self);
                            [self p_doClean];
                        }];
                    }
                }];
            }
            else {
                self.state = QHAsyncTaskStateFinished;

                [self p_doClean];
            }
        }
    });
}

@end

NS_ASSUME_NONNULL_END
