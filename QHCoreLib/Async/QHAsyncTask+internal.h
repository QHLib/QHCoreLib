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


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHAsyncTaskState) {
    QHAsyncTaskStateInit = 0,

    QHAsyncTaskStateStarted,
    QHAsyncTaskStateLoading,
    QHAsyncTaskStateCallingback,

    QHAsyncTaskStateFinished,
    QHAsyncTaskStateCancelled,
};

@interface QHAsyncTask ()

@property (nonatomic, assign, readonly) QHAsyncTaskState state;

- (void)p_asyncOnWorkQueue:(dispatch_block_t)block;
- (void)p_asyncOnCompletionQueue:(dispatch_block_t)block;
- (void)p_asyncOnDisposeQueue:(dispatch_block_t)block;


/**
 * Start the real job for task. Default implementation invoke `bodyBlock` if 
 * not nil. Subclass overrides with detail base on needs.
 * This method will be called on `workQueue` and guarded by lock. Make sure
 * start the job did not take too long, because calling of `cancel` on another
 * thread might be blocked.
 */
- (void)p_doStart;

/**
 * Clear callback blocks. Default implementation clear 'successBlock' and
 * 'failBlock' and dispose them on `disposeQueue`. Subclass implements detail 
 * base on needs and MUST call super.
 * This method will be called on `workQueue` if task is not cleared or cancelled 
 * somewhere, otherwise on any thread that calls `clear` or `cancel`.
 */
- (void)p_doClear NS_REQUIRES_SUPER;

/**
 * Cancel the task. Default implementation do nothing. Subclass implements
 * detail base on needs.
 * This method could be called on any thread.
 */
- (void)p_doCancel;

/**
 * Clean resources after task is finished or canncelled. Default implementation 
 * collect resources by calling `p_doCollect:` and dispose the resources on 
 * `dispostQueue`. Subclass implementation MUST call super.
 * This method will be called on `workQueue` if task is not cancelled somewhere,
 * otherwise on any thread that calls `cancel`.
 */
- (void)p_doClean NS_REQUIRES_SUPER;

/**
 * Collect the resources need to be cleaned on `disposeQueue`. Default
 * implementaion do nothing. Subclass implements detail base on needs and
 * MUST call super.
 * This method will be called synchronously by `p_doClean`.
 */
- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue NS_REQUIRES_SUPER;


- (void)p_fireProgress:(id<QHAsyncTaskProgress>)progress;

- (void)p_fireSuccess:(NSObject *)result;
- (void)p_fireFail:(NSError *)error;
                   
@end

NS_ASSUME_NONNULL_END

#endif /* QHAsyncTask_internal_h */
