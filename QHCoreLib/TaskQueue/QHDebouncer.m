//
//  QHDebouncer.m
//  QHCoreLib
//
//  Created by changtang on 2019/7/19.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHDebouncer.h"
#import "QHBlockQueue.h"

@implementation QHDebouncer {
    NSTimeInterval m_delay;
    dispatch_block_t m_action;

    QHBlockQueue *m_queue;

    QHBlockId m_token;
}

- (instancetype)initWithDelay:(NSTimeInterval)delay action:(dispatch_block_t)action {
    self = [super init];
    if (self) {
        QHAssert(delay > 0 && action != nil , @"invalid params");

        m_delay = delay;
        m_action = action;

        [self setBlockQueue:QHBlockMainQueue];
    }
    return self;
}

- (void)setBlockQueue:(QHBlockQueue *)queue {
    QHAssert(queue != nil, @"queue must not be nil");

    m_queue = queue;
}

- (void)reschedule {
    [self cancel];

    @weakify(self);
    m_token = [m_queue pushBlock:^{
        @strongify(self);
        if (self->m_action) {
            self->m_action();
        }
    } delay:m_delay];
}

- (void)cancel {
    if (m_token != QHBlockIdInvalid) {
        [m_queue cancelBlock:m_token];
        m_token = QHBlockIdInvalid;
    }
}

- (void)dealloc {
    [self cancel];
}

@end
