//
//  QHAsyncTaskRetryWrapper.m
//  QHCoreLib
//
//  Created by changtang on 2018/9/10.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

#import "QHAsyncTaskRetryWrapper.h"
#import "QHAsyncTask+internal.h"
#import "QHLog.h"

@interface QHAsyncTaskRetryWrapper ()

@property (nonatomic,   copy) QHAsyncTaskBuilder builder;

@property (nonatomic, assign) int maxTryCount;
@property (nonatomic, assign) double retryInterval;

@property (nonatomic, assign) int leftRetryCount;
@property (nonatomic, strong) QHAsyncTask *currentTask;

@end

@implementation QHAsyncTaskRetryWrapper

- (instancetype)initWithTaskBuilder:(QHAsyncTaskBuilder)builder
                        maxTryCount:(int)maxTryCount
                      retryInterval:(double)retryInterval
{
    self = [super init];
    if (self) {
        QHAssertReturnValueOnFailure(nil, builder != nil,
                                     @"task builder should not be nil");
        self.builder = builder;
        self.maxTryCount = MAX(1, maxTryCount);
        self.retryInterval = MAX(0, retryInterval);
    }
    return self;
}

- (void)p_doStart
{
    self.leftRetryCount = self.maxTryCount;
    [self p_tryDoTask];
}

- (void)p_doCancel
{
    if (self.currentTask) {
        [self.currentTask cancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [releaseOnDisposeQueue addObject:self.currentTask];
    self.currentTask = nil;
    [super p_doCollect:releaseOnDisposeQueue];
}

- (void)p_tryDoTask
{
    if (self.isLoading == NO) return;

    self.leftRetryCount -= 1;

    self.currentTask = self.builder();
    @weakify(self);
    [self.currentTask startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nonnull result) {
        @strongify(self);
        [self p_fireSuccess:result];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        @strongify(self);
        QHLogError(@"%@ failed with error: %@", task, error);
        if (self.leftRetryCount == 0) {
            [self p_fireFail:error];
        } else {
            QHLogInfo(@"%@ will retry(%dth) %.1fs later",
                      self,
                      (int)(self.maxTryCount - self.leftRetryCount),
                      self.retryInterval);
            [self performSelector:@selector(p_tryDoTask)
                       withObject:nil
                       afterDelay:self.retryInterval];
        }
    }];
}

@end
