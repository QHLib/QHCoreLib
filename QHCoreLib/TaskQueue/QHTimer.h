//
//  QHTimer.h
//  QHCoreLib
//
//  Created by Tony Tang on 2019/8/30.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHTimer : NSObject

// default values:
// repeat: NO
// queue: main queue

+ (instancetype)timerWithDelay:(NSTimeInterval)delay action:(dispatch_block_t)action;
+ (instancetype)timerWithDelay:(NSTimeInterval)delay repeat:(BOOL)repeat action:(dispatch_block_t)action;

+ (instancetype)timerWithDelay:(NSTimeInterval)delay action:(dispatch_block_t)action onQueue:(dispatch_queue_t)queue;
+ (instancetype)timerWithDelay:(NSTimeInterval)delay repeat:(BOOL)repeat action:(dispatch_block_t)action onQueue:(dispatch_queue_t)queue;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
