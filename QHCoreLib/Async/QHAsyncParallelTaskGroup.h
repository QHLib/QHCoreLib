//
//  QHAsyncParallelTaskGroup.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHAsyncParallelTaskSuccessStrategy) {
    /*
     * Task group success if all tasks success.
     */
    QHAsyncParallelTaskSuccessStrategyAll = 0,
    /*
     * Task group fail if all tasks fail.
     */
    QHAsyncParallelTaskSuccessStrategyAny,
    /*
     * Task group success even all tasks fail.
     */
    QHAsyncParallelTaskSuccessStrategyAlways,
};

/*
 * Progress that reported after each task succeed or failed.
 * @param task the task that succeed or failed this time.
 */
@interface QHAsyncParallelTaskGroupProgress : NSObject<QHAsyncTaskProgress>

// mark as unavailable, because not implemented
- (NSTimeInterval)estimatedTime NS_UNAVAILABLE;

@property (nonatomic, strong) QHAsyncTaskId taskId;
@property (nonatomic, strong) QHAsyncTask *task;
@property (nonatomic, strong) NSDictionary<QHAsyncTaskId, QHAsyncTask *> * tasks;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> * waiting;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> * running;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> * succeed;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> * failed;
@property (nonatomic, strong) NSDictionary<QHAsyncTaskId, id> * results;

@end

@interface QHAsyncParallelTaskGroupResult : NSObject

@property (nonatomic, strong) NSDictionary<QHAsyncTaskId, QHAsyncTask *> *tasks;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> *succeed;
@property (nonatomic, strong) NSSet<QHAsyncTaskId> *failed;
@property (nonatomic, strong) NSDictionary<QHAsyncTaskId, id> *results;

@end

/*
 * Run several tasks parallelly and return result after all task have finished.
 */
@interface QHAsyncParallelTaskGroup<ResultType> : QHAsyncTask<ResultType>

/*
 * Add the task to task group. Task should not be touched (start, clear and
 * cancel) after calling this message.
 */
- (void)addTask:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId;

/*
 * See `QHAsyncParallelTaskSuccessStrategy`.
 * Default is `QHAsyncParallelTaskSuccessStrategyAll`.
 */
@property (nonatomic, assign) QHAsyncParallelTaskSuccessStrategy successStrategy;

/*
 * Maximum number of tasks running at the same time. Default is 5.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentCount;

QH_ASYNC_TASK_PROGRESS_DECL(QHAsyncTask, QHAsyncParallelTaskGroupProgress);

typedef id _Nullable (^QHAsyncParallelTaskGroupResultAggregationBlock)
(QHAsyncParallelTaskGroupResult *result, NSError * __autoreleasing *error);

/*
 * Optional aggregate the final result. Default implementation returns the
 * `results` in `result`.
 */
- (void)setResultAggregationBlock:(ResultType _Nullable (^ _Nullable)
                                   (QHAsyncParallelTaskGroupResult *result, NSError * __autoreleasing *error)
                                   )aggregateBlock;

@end


NS_ASSUME_NONNULL_END
