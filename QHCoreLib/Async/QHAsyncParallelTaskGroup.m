//
//  QHAsyncParallelTaskGroup.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncParallelTaskGroup.h"
#import "QHAsyncParallelTaskGroup+internal.h"
#import "QHAsyncTask+internal.h"


NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncParallelTaskGroup () {
@private
    NSRecursiveLock *_taskLock;
}

// should not be changed after started
@property (nonatomic, strong) NSMutableDictionary<QHAsyncTaskId, QHAsyncTask *> *tasks;

@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *waitingTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *runningTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *succeedTasks;
@property (nonatomic, strong) NSMutableSet<QHAsyncTaskId> *failedTasks;

// value is the result or error of each task
@property (nonatomic, strong) NSMutableDictionary<QHAsyncTaskId, id> *results;

@property (nonatomic, copy) QHAsyncParallelTaskGroupReportProgressBlock _Nullable progressBlock;

@property (nonatomic, copy) QHAsyncParallelTaskGroupAggregateResultBlock _Nullable aggregateBlock;

@end

@implementation QHAsyncParallelTaskGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskLock = [[NSRecursiveLock alloc] init];

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
    QHAssert(self.state == QHAsyncTaskStateInit, @"add task after started is not allowed");

    [self.tasks qh_setObject:task forKey:taskId];
}

- (void)setReportProgressBlock:(QHAsyncParallelTaskGroupReportProgressBlock _Nullable)progressBlock
{
    self.progressBlock = progressBlock;
}

- (void)setAggregateResultBlock:(id _Nullable (^ _Nullable)
                                 (
                                     NSDictionary<QHAsyncTaskId,QHAsyncTask *> * _Nonnull,
                                     NSSet<QHAsyncTaskId> * _Nonnull,
                                     NSSet<QHAsyncTaskId> * _Nonnull,
                                     NSDictionary<QHAsyncTaskId,id> * _Nonnull,
                                     NSError * _Nullable __autoreleasing * _Nullable)
                                 )aggregateBlock
{
    self.aggregateBlock = aggregateBlock;
}

#pragma mark -

- (void)p_doStart
{
    QHAssert(self.tasks.count > 0, @"start empty parallel task group: %@", self);

    QHNSLock(_taskLock, ^{
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

        QHNSLock(self->_taskLock, ^{
            @retainify(self);

            [self.runningTasks removeObject:taskId];
            [self.succeedTasks qh_addObject:taskId];
            if (result) {
                [self.results qh_setObject:result forKey:taskId];
            }

            [self _reportOneFinished:task withTaskId:taskId];

            [self _tryStartNextTask];

            if (self.runningTasks.count == 0) {

                __block QHAsyncParallelTaskGroupAggregateResultBlock aggregateBlockRef = self.aggregateBlock;

                [self _clearProgressAggregateBlocks];

                [self p_asyncOnWorkQueue:^{
                    @retainify(self);

                    NSError *error = nil;
                    id result = nil;

                    if (aggregateBlockRef) {
                        result = aggregateBlockRef(self.tasks,
                                                   self.succeedTasks,
                                                   self.failedTasks,
                                                   self.results,
                                                   &error);

                        [self p_asyncOnDisposeQueue:^{
                            aggregateBlockRef = nil;
                        }];
                    }
                    else {
                        result = [self p_doAggregateResult:self.tasks
                                                   succeed:self.succeedTasks
                                                    failed:self.failedTasks
                                                   results:self.results
                                                     error:&error];
                    }

                    if (error == nil) {
                        [self p_fireSuccess:result];
                    } else {
                        [self p_fireFail:error];
                    }
                }];
            }
        });
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        @strongify(self);

        QHNSLock(self->_taskLock, ^{
            @retainify(self);

            [self.runningTasks removeObject:taskId];
            [self.failedTasks qh_addObject:taskId];
            [self.results qh_setObject:error forKey:taskId];

            [self _reportOneFinished:task withTaskId:taskId];

            [self _clearProgressAggregateBlocks];

            [self p_fireFail:error];

            [self _cancelAllTasks];
        });
    }];
}

- (void)_reportOneFinished:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId
{
    NSMutableSet<QHAsyncTaskId> *waiting = [self.waitingTasks copy];
    NSMutableSet<QHAsyncTaskId> *running = [self.runningTasks copy];
    NSMutableSet<QHAsyncTaskId> *succeed = [self.succeedTasks copy];
    NSMutableSet<QHAsyncTaskId> *failed  = [self.failedTasks copy];
    NSMutableDictionary<QHAsyncTaskId, id> *results = [self.results copy];

    __block QHAsyncParallelTaskGroupReportProgressBlock progressBlockRef = self.progressBlock;

    [self p_asyncOnCompletionQueue:^{
        @retainify(self);

        if (progressBlockRef) {
            progressBlockRef(self.tasks,
                             taskId,
                             task,
                             waiting,
                             running,
                             succeed,
                             failed,
                             results);

            [self p_asyncOnDisposeQueue:^{
                progressBlockRef = nil;
            }];
        }

        [self p_doReportProgress:self.tasks
                          taskId:taskId
                            task:task
                         waiting:waiting
                         running:running
                         succeed:succeed
                          failed:failed
                         results:results];
    }];
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

- (void)_clearProgressAggregateBlocks
{
    __block QHAsyncParallelTaskGroupReportProgressBlock progress = self.progressBlock;
    self.progressBlock =  nil;

    __block QHAsyncParallelTaskGroupAggregateResultBlock aggregate = self.aggregateBlock;
    self.aggregateBlock = nil;

    if (progress || aggregate) {
        [self p_asyncOnDisposeQueue:^{
            progress = nil;
            aggregate = nil;
        }];
    }
}

- (void)_cancelAllTasks
{
    [self.runningTasks enumerateObjectsUsingBlock:^(QHAsyncTaskId _Nonnull task, BOOL * _Nonnull stop) {
        [self.tasks[task] cancel];
    }];
}

- (void)p_doClear
{
    [super p_doClear];

    QHNSLock(_taskLock, ^{
        @retainify(self);

        [self _clearProgressAggregateBlocks];
    });
}

- (void)p_doCancel
{
    QHNSLock(_taskLock, ^{
        @retainify(self);

        [self _cancelAllTasks];
    });
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [super p_doCollect:releaseOnDisposeQueue];

    [releaseOnDisposeQueue addObjectsFromArray:[self.tasks allValues]];
    [self.tasks removeAllObjects];

    [releaseOnDisposeQueue addObjectsFromArray:[_results allValues]];
    [_results removeAllObjects];
}

#pragma mark -

- (void)p_doReportProgress:(NSDictionary<QHAsyncTaskId,QHAsyncTask *> *)tasks
                    taskId:(QHAsyncTaskId)taskId
                      task:(QHAsyncTask *)task
                   waiting:(NSSet<QHAsyncTaskId> *)waiting
                   running:(NSSet<QHAsyncTaskId> *)running
                  succeed:(NSSet<QHAsyncTaskId> *)succeed
                    failed:(NSSet<QHAsyncTaskId> *)failed
                   results:(NSDictionary<QHAsyncTaskId,id> *)results
{

}

- (id _Nullable)p_doAggregateResult:(NSDictionary<QHAsyncTaskId,QHAsyncTask *> *)tasks
                            succeed:(NSSet<QHAsyncTaskId> *)succeed
                             failed:(NSSet<QHAsyncTaskId> *)failed
                            results:(NSDictionary<QHAsyncTaskId, id> *)results
                              error:(NSError *__autoreleasing *)error
{
    return [_results copy];
}

@end

NS_ASSUME_NONNULL_END
