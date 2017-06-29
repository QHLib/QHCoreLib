//
//  QHAsyncParallelTaskGroup.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHAsync.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * Run several tasks parallelly and return result after all task have finished.
 */
@interface QHAsyncParallelTaskGroup : QHAsyncTask

- (void)addTask:(QHAsyncTask *)task withTaskId:(id<NSCopying>)taskId;

QH_ASYNC_TASK_DECL(QHAsyncParallelTaskGroup, NSDictionary);

@end

NS_ASSUME_NONNULL_END
