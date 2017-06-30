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
@interface QHAsyncParallelTaskGroup : QHAsyncTask

/*
 * Add the task to task group. Task should not be touched (start, clear and
 * cancel) after calling this message.
 */
- (void)addTask:(QHAsyncTask *)task withTaskId:(QHAsyncTaskId)taskId;

/*
 * Maximum number of tasks running at the same time. Default is 5.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentCount;

QH_ASYNC_TASK_DECL(QHAsyncParallelTaskGroup, NSObject);

@end

NS_ASSUME_NONNULL_END
