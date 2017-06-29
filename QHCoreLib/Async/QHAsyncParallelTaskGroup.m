//
//  QHAsyncParallelTaskGroup.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncParallelTaskGroup.h"
#import "QHAsyncParallelTaskGroup+internal.h"
#import "QHAsyncTask+internal.h"

#import "QHLog.h"


NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncParallelTaskGroup ()

@end

@implementation QHAsyncParallelTaskGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tasks = [NSMutableDictionary dictionary];
        self.results = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTask:(QHAsyncTask *)task withTaskId:(id<NSCopying>)taskId
{
    QHAssert(self.state == QHAsyncTaskStateInit, @"add task after started is not allowed");

    [self.tasks qh_setObject:task forKey:taskId];
}

QH_ASYNC_TASK_IMPL_DIRECT(QHAsyncParallelTaskGroup, NSDictionary);

- (void)p_doStart
{
    [self.tasks enumerateKeysAndObjectsUsingBlock:^(id<NSCopying> _Nonnull taskId, QHAsyncTask * _Nonnull obj, BOOL * _Nonnull stop) {
        @weakify(self);
        [obj startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
            @strongify(self);
            @synchronized (self) {
                if (result) {
                    [self.results qh_setObject:result forKey:taskId];
                }
                [self.tasks removeObjectForKey:taskId];

                if (self.tasks.count == 0) {
                    [self p_asyncOnWorkQueue:^{
                        @retainify(self);
                        NSError *error = nil;
                        id result = [self p_doAggregated:&error];

                        if (error == nil) {
                            [self p_fireSuccess:result];
                        } else {
                            [self p_fireFail:error];
                        }
                    }];
                }
            }
        } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
            @strongify(self);
            @synchronized (self) {
                QHLogDebug(@"task[%@](%@) in %@ failed", taskId, task, self);
                [self.tasks removeObjectForKey:taskId];

                [self p_fireFail:error];
                
                [self _cancelAll];
            }
        }];
    }];
}

- (void)_cancelAll
{
    __block NSArray<QHAsyncTask *> *runningTasks = nil;
    @synchronized (self) {
        runningTasks = [self.tasks allValues];
    }

    [runningTasks enumerateObjectsUsingBlock:^(QHAsyncTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
}

- (void)p_doCancel
{
    [self _cancelAll];
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [super p_doCollect:releaseOnDisposeQueue];

    [releaseOnDisposeQueue addObjectsFromArray:[self.tasks allValues]];
    [self.tasks removeAllObjects];

    [releaseOnDisposeQueue addObjectsFromArray:[self.results allValues]];
    [self.results removeAllObjects];
}

#pragma mark -

- (id)p_doAggregated:(NSError *__autoreleasing *)error
{
    return [self.results copy];
}

@end

NS_ASSUME_NONNULL_END
