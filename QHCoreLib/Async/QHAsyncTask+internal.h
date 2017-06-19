//
//  QHAsyncTask+internal.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHAsyncTask_internal_h
#define QHAsyncTask_internal_h

#import <QHCoreLib/QHAsyncTask.h>

#define QH_ASYNC_TASK_IMPL_DIRECT(TASK_TYPE, RESULT_TYPE) \
QH_ASYNC_TASK_IMPL_INDIRECT(TASK_TYPE, RESULT_TYPE, QHAsyncTask, NSObject)

#define QH_ASYNC_TASK_IMPL_INDIRECT(TASK_TYPE, RESULT_TYPE, SUPER_TASK_TYPE, SUPER_RESULT_TYPE) \
- (void)startWithSuccess:(void (^)(TASK_TYPE *task, RESULT_TYPE *result))success \
                    fail:(void (^)(TASK_TYPE *task, NSError *error))fail \
{ \
    [super startWithSuccess:(void (^)(SUPER_TASK_TYPE *api, SUPER_RESULT_TYPE  *result))success \
                       fail:(void (^)(SUPER_TASK_TYPE *api, NSError *error))fail]; \
} \
- (Class)resultClass \
{ \
    @QH_SUBCLASS_MUST_OVERRIDE; \
    return [RESULT_TYPE class]; \
}

@interface QHAsyncTask ()

- (void)p_asyncOnWorkQueue:(dispatch_block_t)block;
- (void)p_asyncOnCompletionQueue:(dispatch_block_t)block;
- (void)p_asyncOnDisposeQueue:(dispatch_block_t)block;

/**
 * subclass implements; called on work queue
 */
- (void)p_doStart;
/**
 * subclass implements; called on any queue
 */
- (void)p_doCancel;
/**
 * collect the resources need to be cleaned before invoking callback on work queue;
 * subclass implementation should call super
 */
- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue NS_REQUIRES_SUPER;
/**
 * subclass implements; called after success, fail or cancel on work quque
 */
- (void)p_doTeardown;
                   
- (void)p_fireSuccess:(NSObject *)result;
- (void)p_fireFail:(NSError *)error;
                   
@end

#endif /* QHAsyncTask_internal_h */
