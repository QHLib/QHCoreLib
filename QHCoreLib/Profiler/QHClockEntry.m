//
//  QHClockEntry.m
//  QQHouse
//
//  Created by changtang on 15/12/2.
//
//

#import "QHClockEntry.h"

#import "QHBase+internal.h"

@import QuartzCore;


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHClockEntryState) {
    QHClockEntryStateInited,
    QHClockEntryStateStarted,
    QHClockEntryStateEnded,
};

@interface QHClockEntry ()

@property (nonatomic, assign) QHClockEntryState state;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval endTime;

@end

@implementation QHClockEntry

- (instancetype)init
{
    self = [super init];
    if (self) {
        _state = QHClockEntryStateInited;
        _startTime = CACurrentMediaTime();
        _endTime = _startTime;
    }
    return self;
}

- (void)start
{
    QHAssert(_state != QHClockEntryStateStarted,
             @"invalid calling start when entry is in started state");
    _state = QHClockEntryStateStarted;
    _startTime = CACurrentMediaTime();
}

- (void)end
{
    QHAssert(_state == QHClockEntryStateStarted,
             @"invalid calling stop when entry is not in started state");
    _state = QHClockEntryStateEnded;
    _endTime = CACurrentMediaTime();
}

- (int)elapsedTimeInMiliseconds
{
    QHAssert(_state == QHClockEntryStateStarted,
             @"invalid calling elapsed when entry is not in started state");
    return round((CACurrentMediaTime() - _startTime) * 1000);
}

- (int)spentTimeInMiliseconds
{
    QHAssert(_state == QHClockEntryStateEnded,
             @"invalid calling spent time when entry is not in ended state");
    return round((_endTime - _startTime) * 1000);
}

@end

NS_ASSUME_NONNULL_END
