//
//  QHAsyncTask.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/12.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHBase.h>


NS_ASSUME_NONNULL_BEGIN

QH_EXTERN NSString * const QHAsyncTaskErrorDomain;

typedef NS_ENUM(NSUInteger, QHAsyncTaskError) {
    // common
    QHAsyncTaskErrorInvalidResult = 1000,

    // parallel
    QHAsyncTaskErrorAllParallelTaskFailed = 1200,

    // linked
    QHAsyncTaskErrorInvalidCarry = 1400,
};


typedef id<NSCopying> QHAsyncTaskId;


@protocol QHAsyncTaskProgress <NSObject>
- (CGFloat)currentProgress; // 0.0 ~ 1.0
- (NSTimeInterval)estimatedTime; // to finish the task, in seconds.
@end

@interface QHAsyncTaskProgress : NSObject <QHAsyncTaskProgress>
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, assign) NSTimeInterval estimatedTime;
@end

@interface QHAsyncBlockTaskReporter<ResultType, ProgressType> : NSObject

- (void)success:(ResultType)result;
- (void)progress:(ProgressType)progress;
- (void)fail:(NSError *)error;

@end

@class QHAsyncTask;

typedef void (^QHAsyncBlockTaskBody)(QHAsyncTask *task, QHAsyncBlockTaskReporter<id, id<QHAsyncTaskProgress>> *reporter);

typedef void (^QHAsyncTaskProgressBlock)(QHAsyncTask *task, id<QHAsyncTaskProgress> progress);

typedef void (^QHAsyncTaskSuccessBlock)(QHAsyncTask *task, id result);
typedef void (^QHAsyncTaskFailBlock)(QHAsyncTask *task, NSError *error);


@interface QHAsyncTask<ResultType> : NSObject

+ (instancetype)taskWithBlock:(void (^)(QHAsyncTask *task,
                                        QHAsyncBlockTaskReporter<ResultType, id<QHAsyncTaskProgress>> *reporter))block;

- (void)setBodyBlock:(void (^)(QHAsyncTask *task,
                               QHAsyncBlockTaskReporter<ResultType, id<QHAsyncTaskProgress>> *reporter))bodyBlock;

/**
 * the queue to do the real job,
 * default `nil` which use global queue for `QOS_CLASS_DEFAULT`
 */
@property (nonatomic, strong) dispatch_queue_t _Nullable workQueue;

/**
 * the queue on which callback invoked,
 * default `nil` which use main queue
 */
@property (nonatomic, strong) dispatch_queue_t _Nullable completionQueue;

/**
 * the queue on which the callback blocks disposed,
 * default `nil` which use main queue
 */
@property (nonatomic, strong) dispatch_queue_t _Nullable disposeQueue;

/**
 * Optional task progress report. Default implementation will not report any
 * progress to this block. Subclass may report base on needs.
 * This method will be called on `completionQueue`.
 */
- (void)setProgressBlock:(QHAsyncTaskProgressBlock _Nullable)progressBlock;

- (void)startWithSuccess:(void (^ _Nullable)(QHAsyncTask *task, ResultType result))success
                    fail:(void (^ _Nullable)(QHAsyncTask *task, NSError *error))fail;

- (Class)resultClass;


- (BOOL)isLoading;

/**
 * clear callback blocks but keep task running
 */
- (void)clear;

/**
 * clear callback blocks and stop task running
 */
- (void)cancel;

@end


// subclass macros begin

#define QH_ASYNC_TASK_BLOCK_DECL(TASK_TYPE, RESULT_TYPE_P, PROGRESS_TYPE) \
+ (instancetype)taskWithBlock:(void (^)(TASK_TYPE *task, QHAsyncBlockTaskReporter<RESULT_TYPE_P, PROGRESS_TYPE *> *reporter))block; \
- (void)setBodyBlock:(void (^)(TASK_TYPE *task, QHAsyncBlockTaskReporter<RESULT_TYPE_P, PROGRESS_TYPE *> *reporter))bodyBlock;

#define QH_ASYNC_TASK_BLOCK_IMPL(TASK_TYPE, RESULT_TYPE_P, PROGRESS_TYPE) \
+ (instancetype)taskWithBlock:(void (^)(TASK_TYPE *task, QHAsyncBlockTaskReporter<RESULT_TYPE_P, PROGRESS_TYPE *> *reporter))block \
{ \
    return [super taskWithBlock:(void (^)(QHAsyncTask *task, QHAsyncBlockTaskReporter<id, id<QHAsyncTaskProgress>> *reporter))block]; \
} \
- (void)setBodyBlock:(void (^)(TASK_TYPE *task, QHAsyncBlockTaskReporter<RESULT_TYPE_P, PROGRESS_TYPE *> *reporter))bodyBlock \
{ \
    [super setBodyBlock:(void (^)(QHAsyncTask *task, QHAsyncBlockTaskReporter<id, id<QHAsyncTaskProgress>> *reporter))bodyBlock]; \
}

#define QH_ASYNC_TASK_PROGRESS_DECL(TASK_TYPE, PROGRESS_TYPE) \
- (void)setProgressBlock:(void (^ _Nullable)(TASK_TYPE *task, PROGRESS_TYPE * progress))progressBlock;

#define QH_ASYNC_TASK_PROGRESS_IMPL(TASK_TYPE, PROGRESS_TYPE) \
- (void)setProgressBlock:(void (^ _Nullable)(TASK_TYPE *task, PROGRESS_TYPE * progress))progressBlock \
{ \
    [super setProgressBlock:(void (^ _Nullable)(QHAsyncTask *task, id<QHAsyncTaskProgress> progress))progressBlock]; \
}

#define QH_ASYNC_TASK_DECL(TASK_TYPE, RESULT_TYPE) \
- (void)startWithSuccess:(void (^ _Nullable)(TASK_TYPE *task, RESULT_TYPE *result))success \
                    fail:(void (^ _Nullable)(TASK_TYPE *task, NSError *error))fail; \
- (Class)resultClass;

#define QH_ASYNC_TASK_IMPL_DIRECT(TASK_TYPE, RESULT_TYPE) \
QH_ASYNC_TASK_IMPL_INDIRECT(TASK_TYPE, RESULT_TYPE, QHAsyncTask, NSObject)

#define QH_ASYNC_TASK_IMPL_INDIRECT(TASK_TYPE, RESULT_TYPE, SUPER_TASK_TYPE, SUPER_RESULT_TYPE) \
- (void)startWithSuccess:(void (^ _Nullable)(TASK_TYPE *task, RESULT_TYPE *result))success \
                    fail:(void (^ _Nullable)(TASK_TYPE *task, NSError *error))fail \
{ \
    [super startWithSuccess:(void (^ _Nullable)(SUPER_TASK_TYPE *task, SUPER_RESULT_TYPE *result))success \
                       fail:(void (^ _Nullable)(SUPER_TASK_TYPE *task, NSError *error))fail]; \
} \
- (Class)resultClass \
{ \
    return [RESULT_TYPE class]; \
}

// subclass macros end

NS_ASSUME_NONNULL_END
