//
//  QHTimer.m
//  QHCoreLib
//
//  Created by Tony Tang on 2019/8/30.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHTimer.h"
#import "QHBlockQueue.h"

@interface QHTimer () {
    BOOL m_isRepeat;
    QHBlockId m_timerId;
}

@end

@implementation QHTimer

+ (instancetype)timerWithDelay:(NSTimeInterval)delay action:(dispatch_block_t)action {
    return [self timerWithDelay:delay repeat:NO action:action];
}

+ (instancetype)timerWithDelay:(NSTimeInterval)delay repeat:(BOOL)repeat action:(dispatch_block_t)action {
    return [self timerWithDelay:delay repeat:repeat action:action onQueue:dispatch_get_main_queue()];
}

+ (instancetype)timerWithDelay:(NSTimeInterval)delay action:(dispatch_block_t)action onQueue:(dispatch_queue_t)queue {
    return [self timerWithDelay:delay repeat:NO action:action onQueue:queue];
}

+ (instancetype)timerWithDelay:(NSTimeInterval)delay repeat:(BOOL)repeat action:(dispatch_block_t)action onQueue:(dispatch_queue_t)queue {
    QHAssert(delay >= 0, @"invalid delay: %f", delay);
    QHAssertParam(action);
    QHAssertParam(queue);

    QHTimer *timer = [QHTimer new];
    @weakify(timer);
    timer->m_isRepeat = repeat;
    timer->m_timerId = [QHBlockMainQueue pushBlock:^{
        @strongify(timer);
        if (timer) {
            if (timer->m_isRepeat == NO) {
                timer->m_timerId = QHBlockIdInvalid;
            }
        }
        if (action) {
            action();
        }
    } dispatchQueue:queue delay:delay repeat:repeat];
    return timer;
}

- (void)cancel {
    if (m_timerId != QHBlockIdInvalid) {
        [QHBlockMainQueue cancelBlock:m_timerId];
    }
}

- (void)dealloc {
    [self cancel];
}

@end
