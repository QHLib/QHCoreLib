//
//  QHAsyncTaskEngine.h
//  QHCoreLib
//
//  Created by changtang on 2019/11/18.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncTaskEngine<__covariant TASK_TYPE_P, RESULT_TYPE_P> : NSObject

+ (QHAsyncTaskId)runTask:(QHAsyncTask *)task
                 success:(void (^ _Nullable)(QHAsyncTask *task, id result))success
                    fail:(void (^ _Nullable)(QHAsyncTask *task, NSError *error))fail;

+ (QHAsyncTaskId)runTypedTask:(TASK_TYPE_P)task
                      success:(void (^ _Nullable)(TASK_TYPE_P task, RESULT_TYPE_P result))success
                         fail:(void (^ _Nullable)(TASK_TYPE_P task, NSError *error))fail;

+ (void)cancelTask:(QHAsyncTaskId)taskId;

+ (void)cancelAll;

@end

NS_ASSUME_NONNULL_END
