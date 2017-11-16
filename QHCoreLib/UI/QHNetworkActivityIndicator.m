//
//  QHNetworkActivityIndicator.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkActivityIndicator.h"
#import "QHNetwork.h"

static const NSTimeInterval kQHNetworkActivityIndicatorInvisibilityDelay = 0.17;

@interface QHNetworkActivityIndicator ()

@property (nonatomic, assign) NSInteger activityCount;

@property (nonatomic, strong) NSTimer *delayTimer;

@property (nonatomic, copy) void (^callback)(BOOL isVisible);

@end

@implementation QHNetworkActivityIndicator

QH_SINGLETON_IMP;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkWorkerDidStart:)
                                                     name:QHNetworkWorkerDidStartNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkWorkerDidFinish:)
                                                     name:QHNetworkWorkerDidFinishNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.delayTimer invalidate];
}

- (void)networkWorkerDidStart:(NSNotification *)notification
{
    [self p_increaseActivityCount];
}

- (void)networkWorkerDidFinish:(NSNotification *)notification
{
    [self p_decreaseActivityCount];
}

#pragma mark -

- (BOOL)isVisible
{
    return self.activityCount > 0;
}

+ (NSSet *)keyPathsForValuesAffectingIsVisible
{
    return [NSSet setWithObject:QH_PROPETY_NAME(activityCount)];
}

- (void)setActivityCount:(NSInteger)activityCount
{
    @synchronized (self) {
        _activityCount = activityCount;
    }

    QHDispatchAsyncMain(^{
        [self p_delayUpdateVisibility];
    });
}

- (void)p_increaseActivityCount
{
    [self willChangeValueForKey:QH_PROPETY_NAME(activityCount)];
    @synchronized (self) {
        _activityCount++;
    }
    [self didChangeValueForKey:QH_PROPETY_NAME(activityCount)];

    QHDispatchAsyncMain(^{
        [self p_delayUpdateVisibility];
    });
}

- (void)p_decreaseActivityCount
{
    [self willChangeValueForKey:QH_PROPETY_NAME(activityCount)];
    @synchronized (self) {
        if (self.activityCount) {
            _activityCount--;
        }
    }
    [self didChangeValueForKey:QH_PROPETY_NAME(activityCount)];

    QHDispatchAsyncMain(^{
        [self p_delayUpdateVisibility];
    });
}

- (void)p_delayUpdateVisibility
{
    if (self.enabled) {
        if ([self isVisible]) {
            [self performSelectorOnMainThread:@selector(p_updateVisibility)
                                   withObject:nil
                                waitUntilDone:NO
                                        modes:@[ NSRunLoopCommonModes ]];
        }
        else {
            [self.delayTimer invalidate];
            self.delayTimer = [NSTimer timerWithTimeInterval:kQHNetworkActivityIndicatorInvisibilityDelay
                                                      target:self
                                                    selector:@selector(p_updateVisibility)
                                                    userInfo:nil
                                                     repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.delayTimer
                                      forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)p_updateVisibility
{
    if (self.callback) {
        self.callback(self.isVisible);
    }
}

@end
