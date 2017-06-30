//
//  QHAsyncParallelTaskGroup.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHAsyncDefines.h>
#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * Run several tasks parallelly and return result after all task have finished.
 */
@interface QHAsyncParallelTaskGroup<RESULT_TYPE> : QHAsyncTask<RESULT_TYPE>

/*
 * Add the task to task group. Task should not be touched (start, clear and
 * cancel) after calling this message.
 */
- (void)addTask:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId;

/*
 * Maximum number of tasks running at the same time. Default is 5.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentCount;

typedef void (^QHAsyncParallelTaskGroupReportProgressBlock)
(
    NSDictionary<QHAsyncTaskId, QHAsyncTask *> * tasks,
    QHAsyncTaskId taskId,
    QHAsyncTask *task,
    NSSet<QHAsyncTaskId> * waiting,
    NSSet<QHAsyncTaskId> * running,
    NSSet<QHAsyncTaskId> * succeed,
    NSSet<QHAsyncTaskId> * failed,
    NSDictionary<QHAsyncTaskId, id> * results
);

- (void)setReportProgressBlock:(QHAsyncParallelTaskGroupReportProgressBlock _Nullable)progressBlock;

typedef id _Nullable (^QHAsyncParallelTaskGroupAggregateResultBlock)
(
    NSDictionary<QHAsyncTaskId, QHAsyncTask *> *tasks,
    NSSet<QHAsyncTaskId> *succeed,
    NSSet<QHAsyncTaskId> *failed,
    NSDictionary<QHAsyncTaskId, id> *results,
    NSError * __autoreleasing *error
);

- (void)setAggregateResultBlock:(RESULT_TYPE _Nullable (^ _Nullable)
                                 (
                                     NSDictionary<QHAsyncTaskId, QHAsyncTask *> *tasks,
                                     NSSet<QHAsyncTaskId> *succeed,
                                     NSSet<QHAsyncTaskId> *failed,
                                     NSDictionary<QHAsyncTaskId, id> *results,
                                     NSError * __autoreleasing *error)
                                 )aggregateBlock;

@end

NS_ASSUME_NONNULL_END
