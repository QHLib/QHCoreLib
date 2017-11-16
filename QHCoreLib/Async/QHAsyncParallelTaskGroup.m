//
//  QHAsyncParallelTaskGroup.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHAsyncParallelTaskGroup.h"
#import "QHAsyncParallelTaskGroup+internal.h"
#import "QHAsyncTask+internal.h"


NS_ASSUME_NONNULL_BEGIN

@implementation QHAsyncParallelTaskGroupProgress

- (CGFloat)currentProgress
{
    QHAssert(self.tasks.count > 0, @"empty tasks in %@", self);

    return (self.succeed.count + self.failed.count) / (CGFloat)self.tasks.count;
}

- (NSTimeInterval)estimatedTime
{
    QHAssert(NO, @"not implemented");
    return 0.0;
}

@end

@implementation QHAsyncParallelTaskGroupResult

@end

@interface QHAsyncParallelTaskGroup () {
@private
    NSRecursiveLock *_subTaskLock;
}

// should not be changed after started
@property (nonatomic, strong) NSMutableDictionary<QHAsyncTaskId, QHAsyncTask *> *tasks;

@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *waitingTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *runningTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *succeedTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *failedTasks;

// value is the result or error of each task
@property (nonatomic, strong) NSMutableDictionary<QHAsyncTaskId, id> *results;

@property (nonatomic, copy) QHAsyncParallelTaskGroupResultAggregationBlock _Nullable aggregateBlock;

@end

@implementation QHAsyncParallelTaskGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subTaskLock = [[NSRecursiveLock alloc] init];

        self.tasks = [NSMutableDictionary dictionary];

        self.waitingTasks = [NSMutableSet set];
        self.runningTasks = [NSMutableSet set];
        self.succeedTasks = [NSMutableSet set];
        self.failedTasks  = [NSMutableSet set];

        self.results = [NSMutableDictionary dictionary];

        self.maxConcurrentCount = 5;
    }
    return self;
}

- (void)addTask:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId
{
    QHAssert(self.state == QHAsyncTaskStateInit,
             @"add task after started is not allowed: %@", self);

    [self.tasks qh_setObject:task forKey:taskId];
}

QH_ASYNC_TASK_PROGRESS_IMPL(QHAsyncTask, QHAsyncParallelTaskGroupProgress);

- (void)setResultAggregationBlock:(id _Nullable (^ _Nullable)
                                   (QHAsyncParallelTaskGroupResult *result, NSError * __autoreleasing *error)
                                   )aggregateBlock
{
    QHAssert(self.state == QHAsyncTaskStateInit,
             @"result aggregation block should be set before task started: %@", self);

    self.aggregateBlock = aggregateBlock;
}

#pragma mark -

- (void)p_doStart
{
    QHAssert(self.tasks.count > 0, @"start empty parallel task group: %@", self);

    QHNSLock(_subTaskLock, ^{
        @retainify(self);

        [self.tasks enumerateKeysAndObjectsUsingBlock:^(QHAsyncTaskId _Nonnull taskId, QHAsyncTask * _Nonnull task, BOOL * _Nonnull stop) {

            if ([self.runningTasks count] < self.maxConcurrentCount) {
                [self.runningTasks qh_addObject:taskId];
                [self _startTask:task withTaskId:taskId];
            } else {
                [self.waitingTasks qh_addObject:taskId];
            }
        }];
    });
}

- (void)_startTask:(QHAsyncTask *)taskToStart withTaskId:(QHAsyncTaskId)taskId
{
    @weakify(self);
    [taskToStart startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        @strongify(self);

        QHNSLock(self->_subTaskLock, ^{
            @retainify(self);

            [self.runningTasks removeObject:taskId];
            [self.succeedTasks qh_addObject:taskId];
            if (result) {
                [self.results qh_setObject:result forKey:taskId];
            }

            [self _reportOneFinished:task withTaskId:taskId];

            if (self.successStrategy == QHAsyncParallelTaskSuccessStrategyAny) {
                [self _taskGroupSuccess];

                [self _cancelRunningTasks];
            }
            else {
                [self _tryStartNextTask];

                if (self.runningTasks.count == 0) {
                    [self _taskGroupSuccess];
                }
            }
        });
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        @strongify(self);

        QHNSLock(self->_subTaskLock, ^{
            @retainify(self);

            [self.runningTasks removeObject:taskId];
            [self.failedTasks qh_addObject:taskId];
            [self.results qh_setObject:error forKey:taskId];

            [self _reportOneFinished:task withTaskId:taskId];

            if (self.successStrategy == QHAsyncParallelTaskSuccessStrategyAll) {
                [self _taskGroupFail:error];

                [self _cancelRunningTasks];
            }
            else {
                [self _tryStartNextTask];

                if (self.runningTasks.count == 0) {

                    if (self.successStrategy == QHAsyncParallelTaskSuccessStrategyAlways
                        || self.succeedTasks.count > 0) {
                        [self _taskGroupSuccess];
                    }
                    else {
                        NSString *message = $(@"all parallel tasks failed in %@", self);
                        NSError *error = QH_ERROR(QHAsyncTaskErrorDomain,
                                                  QHAsyncTaskErrorAllParallelTaskFailed,
                                                  message,
                                                  nil);
                        [self _taskGroupFail:error];
                    }
                }
            }
        });
    }];
}

- (void)_reportOneFinished:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId
{
    QHAsyncParallelTaskGroupProgress *progress = [[QHAsyncParallelTaskGroupProgress alloc] init];

    progress.taskId = taskId;
    progress.task = task;
    progress.tasks = self.tasks;
    progress.waiting = [self.waitingTasks copy];
    progress.running = [self.runningTasks copy];
    progress.succeed = [self.succeedTasks copy];
    progress.failed = [self.failedTasks copy];
    progress.results = [self.results copy];

    [self p_fireProgress:progress];
}

- (void)_tryStartNextTask
{
    if (self.waitingTasks.count > 0) {
        QHAsyncTaskId nextTaskId = [self.waitingTasks anyObject];
        [self.waitingTasks removeObject:nextTaskId];
        [self.runningTasks qh_addObject:nextTaskId];

        [self p_asyncOnWorkQueue:^{
            @retainify(self);

            [self _startTask:self.tasks[nextTaskId] withTaskId:nextTaskId];
        }];
    }
}

- (void)_taskGroupSuccess
{
    __block QHAsyncParallelTaskGroupResultAggregationBlock aggregateBlockRef = self.aggregateBlock;

    [self _clearParallelBlocks];

    [self p_asyncOnWorkQueue:^{
        @retainify(self);

        QHAsyncParallelTaskGroupResult *result = [[QHAsyncParallelTaskGroupResult alloc] init];
        result.tasks = self.tasks;
        result.succeed = self.succeedTasks;
        result.failed = self.failedTasks;
        result.results = self.results;

        NSError *error = nil;
        id finalResult = nil;

        if (aggregateBlockRef) {
            finalResult = aggregateBlockRef(result, &error);

            [self p_asyncOnDisposeQueue:^{
                aggregateBlockRef = nil;
            }];
        }
        else {
            finalResult = [self p_doAggregateResult:result error:&error];
        }

        if (error == nil) {
            [self p_fireSuccess:finalResult];
        } else {
            [self p_fireFail:error];
        }
    }];
}

- (void)_taskGroupFail:(NSError *)error
{
    [self _clearParallelBlocks];

    [self p_fireFail:error];
}

- (void)_clearParallelBlocks
{
    __block QHAsyncParallelTaskGroupResultAggregationBlock aggregate = self.aggregateBlock;
    self.aggregateBlock = nil;

    if (aggregate) {
        [self p_asyncOnDisposeQueue:^{
            aggregate = nil;
        }];
    }
}

- (void)_cancelRunningTasks
{
    [self.runningTasks enumerateObjectsUsingBlock:^(QHAsyncTaskId _Nonnull task, BOOL * _Nonnull stop) {
        [self.tasks[task] cancel];
    }];
}

- (void)p_doClear
{
    [super p_doClear];

    QHNSLock(_subTaskLock, ^{
        @retainify(self);

        [self _clearParallelBlocks];
    });
}

- (void)p_doCancel
{
    QHNSLock(_subTaskLock, ^{
        @retainify(self);

        [self _cancelRunningTasks];
    });
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [super p_doCollect:releaseOnDisposeQueue];

    [releaseOnDisposeQueue addObjectsFromArray:[self.tasks allValues]];
    [self.tasks removeAllObjects];

    [releaseOnDisposeQueue addObjectsFromArray:[self.results allValues]];
    [self.results removeAllObjects];
}

#pragma mark -

- (id _Nullable)p_doAggregateResult:(QHAsyncParallelTaskGroupResult *)result
                              error:(NSError * _Nullable __autoreleasing *)error
{
    return result.results;
}

@end

NS_ASSUME_NONNULL_END
