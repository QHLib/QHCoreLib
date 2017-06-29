//
//  QHAsyncTestTasks.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncTestTasks.h"


NS_ASSUME_NONNULL_BEGIN

#warning todo p_doStart should be quick
@implementation QHSuccessTask

- (void)p_doStart
{
    [NSThread sleepForTimeInterval:1.0];
    [self p_fireSuccess:nil];
}

@end


@interface QHFailTask () {
    NSTimeInterval _interval;
}
@end

@implementation QHFailTask

- (instancetype)init
{
    return [self initWithInterval:1.0];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
{
    self = [super init];
    if (self) { _interval = interval; }
    return self;
}

- (void)p_doStart
{
    [NSThread sleepForTimeInterval:_interval];
    [self p_fireFail:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
}

@end

NS_ASSUME_NONNULL_END
