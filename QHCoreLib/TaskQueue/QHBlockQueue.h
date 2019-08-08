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

+ (instancetype)sharedMainQueue;

+ (instancetype)blockQueue;

// the dispatch queue which block will be dispatched
// default to main queue
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (QHBlockId)pushBlock:(dispatch_block_t)block;

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay;

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay
                repeat:(BOOL)repeat;

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(dispatch_queue_t)dispatchQueue
                 delay:(NSTimeInterval)delay;

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(dispatch_queue_t)dispatchQueue
                 delay:(NSTimeInterval)delay
                repeat:(BOOL)repeat;

- (void)cancelBlock:(QHBlockId)blockId;

- (void)cancelAllBlocks;

@end

#define QHBlockMainQueue [QHBlockQueue sharedMainQueue]
#define QHBlockQueueAssertSelfNotNil QHAssertReturnVoidOnFailure(self != nil, @"self is nil, and block is executed some how, maybe you forgot to cancel block on dealloc?")

NS_ASSUME_NONNULL_END
