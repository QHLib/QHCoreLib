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
