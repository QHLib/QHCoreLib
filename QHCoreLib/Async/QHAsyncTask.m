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

@implementation QHAsyncTaskProgress

@end

@interface QHAsyncBlockTaskReporter ()

@property (nonatomic, weak) QHAsyncTask *task;

@end

@implementation QHAsyncBlockTaskReporter

- (void)success:(id)result
{
    [self.task p_fireSuccess:result];
}

- (void)progress:(id<QHAsyncTaskProgress>)progress
{
    [self.task p_fireProgress:progress];
}

- (void)fail:(NSError *)error
{
    [self.task p_fireFail:error];
}

@end

@interface QHAsyncTask () {
@private
    QHAsyncTaskState _state;
    dispatch_semaphore_t _stateLock;
    NSRecursiveLock *_lock;
}

@property (nonatomic, copy, setter=_setBodyBlock:) QHAsyncBlockTaskBody _Nullable bodyBlock;

@property (nonatomic, copy, setter=_setProgressBlock:) QHAsyncTaskProgressBlock _Nullable progressBlock;

@property (nonatomic, copy) QHAsyncTaskSuccessBlock _Nullable successBlock;
@property (nonatomic, copy) QHAsyncTaskFailBlock _Nullable failBlock;

@end

@implementation QHAsyncTask

+ (instancetype)taskWithBlock:(QHAsyncBlockTaskBody)block
{
    QHAsyncTask *blockTask = [[self alloc] init];

    blockTask.bodyBlock = block;

    return blockTask;
}

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

- (void)setBodyBlock:(QHAsyncBlockTaskBody)bodyBlock
{
    QHAssert(self.state == QHAsyncTaskStateInit,
             @"progress block should be set before task started: %@", self);

    self.bodyBlock = bodyBlock;
}

- (void)setProgressBlock:(QHAsyncTaskProgressBlock _Nullable)progressBlock
{
    QHAssert(self.state == QHAsyncTaskStateInit,
             @"progress block should be set before task started: %@", self);

    self.progressBlock = progressBlock;
}

- (void)startWithSuccess:(void (^ _Nullable)(QHAsyncTask *, id))success
                    fail:(void (^ _Nullable)(QHAsyncTask *, NSError *))fail
{
    QHNSLock(_lock, ^{
        @retainify(self);
        
        if (self.state == QHAsyncTaskStateInit) {
            self.state = QHAsyncTaskStateStarted;
            
            self.successBlock = success;
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
    if (self.bodyBlock) {
        QH_BLOCK_INVOKE(^{
            QHAsyncBlockTaskReporter *reporter = [QHAsyncBlockTaskReporter new];
            reporter.task = self;
            self.bodyBlock(self, reporter);
        });
    }
    else {
        // subclass implements detail
    }
}

- (void)p_doClear
{
    [self _clearBlocks];
}

- (void)p_doCancel
{
    // do nothing, subclass implements detail
}

- (void)p_doClean
{
    @autoreleasepool {
        __block NSMutableArray *resources = [NSMutableArray array];

        if (self.bodyBlock) {
            [resources addObject:self.bodyBlock];
            self.bodyBlock = nil;
        }

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

- (void)_clearBlocks
{
    __block QHAsyncTaskProgressBlock progress = self.progressBlock;
    self.progressBlock = nil;

    __block QHAsyncTaskSuccessBlock success = self.successBlock;
    self.successBlock = nil;

    __block QHAsyncTaskFailBlock fail = self.failBlock;
    self.failBlock =  nil;

    if (progress || success || fail) {
        [self p_asyncOnDisposeQueue:^{
            progress = nil;
            success = nil;
            fail = nil;
        }];
    }
}

- (void)p_fireProgress:(id<QHAsyncTaskProgress>)progress
{
    __block QHAsyncTaskProgressBlock progressBlockRef = self.progressBlock;

    if (progressBlockRef) {
        [self p_asyncOnCompletionQueue:^{
            @retainify(self);

            if (progressBlockRef) {
                progressBlockRef(self, progress);
            }

            [self p_asyncOnDisposeQueue:^{
                progressBlockRef = nil;
            }];
        }];
    }
}

- (void)p_fireSuccess:(NSObject *)result
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

- (void)_fireSuccess:(NSObject *)result
{
    if (self.state != QHAsyncTaskStateLoading) {
        return;
    }

    QHNSLock(_lock, ^{
        @retainify(self);
        
        if (self.state == QHAsyncTaskStateLoading) {
            self.state = QHAsyncTaskStateCallingback;

            __block QHAsyncTaskSuccessBlock success = self.successBlock;

            [self _clearBlocks];

            if (success) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if (self.state == QHAsyncTaskStateCallingback) {
                        self.state = QHAsyncTaskStateFinished;

                        success(self, result);

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
            
            [self _clearBlocks];
            
            if (fail) {
                [self p_asyncOnCompletionQueue:^{
                    @retainify(self);

                    if (self.state == QHAsyncTaskStateCallingback) {
                        self.state = QHAsyncTaskStateFinished;

                        fail(self, error);

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
