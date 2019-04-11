//
//  QHBlockQueue.h
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/10.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>

NS_ASSUME_NONNULL_BEGIN

typedef uint32_t QHBlockId;

QH_EXTERN QHBlockId QHBlockIdInvalid;

/**
 * Handle delay and repeat of blocks.
 */
@interface QHBlockQueue : NSObject

+ (instancetype)main;           // on main queue
+ (instancetype)background;     // on default queue

+ (instancetype)fromDispatchQueue:(dispatch_queue_t)queue;

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

- (QHBlockId)pushBlock:(dispatch_block_t)block;

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay;

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay
                repeat:(BOOL)repeat;

- (void)cancelBlock:(QHBlockId)blockId;

- (void)cancelAllBlocks;

@end

NS_ASSUME_NONNULL_END
