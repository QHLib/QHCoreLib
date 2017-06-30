//
//  QHAsyncParallelTaskGroup+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHAsyncParallelTaskGroup_internal_h
#define QHAsyncParallelTaskGroup_internal_h

#import "QHAsyncParallelTaskGroup.h"

@interface QHAsyncParallelTaskGroup ()

/*
 * Report porgress after each task succeed or failed. Default implementation
 * print running state of tasks.
 * @param task the task that succeed or failed this time.
 * This mehtod will be called on `completionQueue`.
 */
- (void)p_doReportProgress:(NSDictionary<QHAsyncTaskId, QHAsyncTask *> *)tasks
                    taskId:(QHAsyncTaskId)taskId
                      task:(QHAsyncTask *)task
                   waiting:(NSSet<QHAsyncTaskId> *)waiting
                   running:(NSSet<QHAsyncTaskId> *)running
                   succeed:(NSSet<QHAsyncTaskId> *)succeed
                    failed:(NSSet<QHAsyncTaskId> *)failed
                   results:(NSDictionary<QHAsyncTaskId, id> *)results;

/*
 * Generate final result from `results` of all `tasks`. Default implementation
 * returns an copy of `results`.
 * This method will be called on `workQueue`.
 */
- (id)p_doAggregateResult:(NSDictionary<QHAsyncTaskId, QHAsyncTask *> *)tasks
                  succeed:(NSSet<QHAsyncTaskId> *)succeed
                   failed:(NSSet<QHAsyncTaskId> *)failed
                  results:(NSDictionary<QHAsyncTaskId, id> *)results
                    error:(NSError * __autoreleasing *)error;

@end


#endif /* QHAsyncParallelTaskGroup_internal_h */
