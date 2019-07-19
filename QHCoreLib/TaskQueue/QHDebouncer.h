//
//  QHDebouncer.h
//  QHCoreLib
//
//  Created by changtang on 2019/7/19.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QHBlockQueue;

@interface QHDebouncer : NSObject

- (instancetype)initWithDelay:(NSTimeInterval)delay
                       action:(dispatch_block_t)action;

- (void)setBlockQueue:(QHBlockQueue *)queue;

- (void)reschedule;

@end

NS_ASSUME_NONNULL_END
