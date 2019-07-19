//
//  QHBlockQueue.m
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/10.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHBlockQueue.h"
#import "QHBase+internal.h"

@interface QHBlockQueueItem : NSObject

@property (nonatomic, assign) QHBlockId blockId;
@property (nonatomic,   copy) dispatch_block_t block;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) NSTimeInterval scheduledAt;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) NSTimeInterval interval;

@end

@implementation QHBlockQueueItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %u, %@, %@, %f, %d, %f>",
            NSStringFromClass([self class]),
            self,
            self.blockId,
            self.block,
            self.queue,
            self.scheduledAt - QHTimestampInDouble(),
            self.repeat ? 1 : 0,
            self.interval];
}

@end

QHBlockId QHBlockIdInvalid = 0;

#define QHBlockQueueMaxCount 0x7fffffff

@interface QHBlockQueue () {
    QHMutex *m_lock;

    uint32_t m_nextBlockId;
    NSMutableDictionary<NSNumber *, QHBlockQueueItem *> *m_map;
    NSMutableArray<NSNumber *> *m_waitingArray;
    NSMutableSet<NSNumber *> *m_cancelledSet;

    BOOL m_hasSentWorkerWakeUp;
    BOOL m_workerIsWorking;
    dispatch_semaphore_t m_workerLock;
}

@end

@implementation QHBlockQueue

+ (instancetype)sharedMainQueue
{
    static QHBlockQueue *blockQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockQueue = [[QHBlockQueue alloc] init];
    });
    return blockQueue;
}

+ (instancetype)blockQueue
{
    QHBlockQueue *blockQueue = [[QHBlockQueue alloc] init];
    return blockQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_lock = [QHMutex new];
        
        m_nextBlockId = QHBlockIdInvalid + 1;
        m_map = [NSMutableDictionary dictionary];
        m_map[@(QHBlockIdInvalid)] = [QHBlockQueueItem new]; // 占位
        m_waitingArray = [NSMutableArray array];
        m_cancelledSet = [NSMutableSet set];
        
        m_hasSentWorkerWakeUp = NO;
        m_workerIsWorking = NO;
        m_workerLock = dispatch_semaphore_create(0);
        [NSThread detachNewThreadSelector:@selector(workerThread:)
                                 toTarget:self
                               withObject:nil];
        
        self.dispatchQueue = dispatch_get_main_queue();
    }
    return self;
}

#pragma mark -

- (QHBlockId)pushBlock:(dispatch_block_t)block
{
    return [self pushBlock:block
             dispatchQueue:self.dispatchQueue
                     delay:0
                    repeat:NO];
}

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay
{
    return [self pushBlock:block
             dispatchQueue:self.dispatchQueue
                     delay:delay
                    repeat:NO];
}

- (QHBlockId)pushBlock:(dispatch_block_t)block
                 delay:(NSTimeInterval)delay
                repeat:(BOOL)repeat
{
    return [self pushBlock:block
             dispatchQueue:self.dispatchQueue
                     delay:delay
                    repeat:repeat];
}

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    return [self pushBlock:block
             dispatchQueue:dispatchQueue
                     delay:0
                    repeat:NO];
}

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(dispatch_queue_t)dispatchQueue
                 delay:(NSTimeInterval)delay
{
    return [self pushBlock:block
             dispatchQueue:dispatchQueue
                     delay:delay
                    repeat:NO];
}

- (QHBlockId)pushBlock:(dispatch_block_t)block
         dispatchQueue:(nonnull dispatch_queue_t)dispatchQueue
                 delay:(NSTimeInterval)delay
                repeat:(BOOL)repeat
{
    if (delay < 0) {
        QHCoreLibWarn(@"invalid delay: %f", delay);
        return QHBlockIdInvalid;
    }
    
    [m_lock lock];
    
    QHBlockId blockId = QHBlockIdInvalid;
    
    if (m_map.count >= QHBlockQueueMaxCount) {
        QHCoreLibWarn(@"Push block failed, block queue is full.");
        return QHBlockIdInvalid;
    }
    
    while([m_map objectForKey:@(m_nextBlockId)] != nil) {
        m_nextBlockId++;
    }
    blockId = m_nextBlockId++;
    
    QHBlockQueueItem *item = [[QHBlockQueueItem alloc] init];
    item.blockId = blockId;
    item.block = block;
    item.queue = dispatchQueue;
    item.scheduledAt = QHTimestampInDouble() + delay;
    item.repeat = repeat;
    item.interval = delay;
    m_map[@(blockId)] = item;
    
    NSUInteger index = 0;
    while (index < m_waitingArray.count
           && m_map[m_waitingArray[index]].scheduledAt <= item.scheduledAt) {
        ++index;
    }
    [m_waitingArray insertObject:@(blockId) atIndex:index];
    
    if (index == 0 && !m_hasSentWorkerWakeUp) {
        m_hasSentWorkerWakeUp = NO;
        QHCoreLibInfo(@"singal worker");
        dispatch_semaphore_signal(m_workerLock);
    }
    
    [m_lock unlock];

    return blockId;
}

- (void)cancelBlock:(QHBlockId)blockId
{
    [m_lock lock];
    
    if (m_map[@(blockId)] != nil) {
        [m_cancelledSet addObject:@(blockId)];
    } else {
        QHCoreLibWarn(@"invalid blockId %u to cancel", blockId);
    }
    
    [m_lock unlock];
}

- (void)cancelAllBlocks
{
    [m_lock lock];
    
    [m_cancelledSet addObjectsFromArray:m_waitingArray];
    
    [m_lock unlock];
}

#pragma mark -

- (void)workerThread:(id)object
{
    NSString *threadName = [NSString stringWithFormat:@"%@-Worker", self];
    [[NSThread currentThread] setName:threadName];
    while (true) {
        if (!m_workerIsWorking) {
            [self->m_lock lock];
            QHCoreLibInfo(@"worker start");
            m_workerIsWorking = YES;
        }
        
        // handle cancelled blocks
        if (m_cancelledSet.count) {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
           
            [self->m_cancelledSet enumerateObjectsUsingBlock:
             ^(NSNumber * _Nonnull blockId, BOOL * _Nonnull stop) {
                 if ([self->m_map objectForKey:blockId]) {
                     [self->m_map removeObjectForKey:blockId];
                 }
                 else {
                     QHCoreLibWarn(@"invalid blockId %@ for block map", blockId);
                 }
                 NSUInteger index = [self->m_waitingArray indexOfObject:blockId];
                 if (index != NSNotFound) {
                     [indexSet addIndex:index];
                 } else {
                     QHCoreLibWarn(@"invalid blockId %@ for block waiting array", blockId);
                 }
             }];
            
            if (indexSet.count) {
                [self->m_waitingArray removeObjectsAtIndexes:indexSet];
            }
            
            [self->m_cancelledSet removeAllObjects];
        }
        
        // handle waiting blocks
        QHBlockQueueItem *first = ({
            self->m_waitingArray.count > 0
            ? self->m_map[self->m_waitingArray[0]]
            : nil;
        });
        QHBlockQueueItem *current = ({
            first.scheduledAt <= QHTimestampInDouble()
            ? first
            : nil;
        });

        if (current) {
            [m_map removeObjectForKey:@(current.blockId)];
            [m_waitingArray removeObjectAtIndex:0];

            QHCoreLibInfo(@"dispatch block: %@", current);
            dispatch_async(current.queue, current.block);
            
            if (current.repeat == YES) {
                QHBlockQueueItem *next = current;
                next.scheduledAt = QHTimestampInDouble() + next.interval;
                self->m_map[@(next.blockId)] = next;
                
                NSUInteger index = 0;
                while (index < self->m_waitingArray.count
                       && self->m_map[self->m_waitingArray[index]].scheduledAt <= next.scheduledAt) {
                    ++index;
                }
                [self->m_waitingArray insertObject:@(next.blockId) atIndex:index];
            }
            
            // 不做unlock，可能下一个block也需要马上执行
        }
        else {
            m_hasSentWorkerWakeUp = NO;
            m_workerIsWorking = NO;
            [m_lock unlock];
            
            if (first) {
                QHCoreLibInfo(@"wait for next block: %@", first);
                NSTimeInterval delay = MAX(0, first.scheduledAt - QHTimestampInDouble());
                dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
                long ret = dispatch_semaphore_wait(m_workerLock, waitTime);
                QHCoreLibInfo(@"awake: %ld", ret);
                QH_UNUSED_VAR(ret);
            }
            else  {
                QHCoreLibInfo(@"wait for blocks");
                dispatch_semaphore_wait(m_workerLock, DISPATCH_TIME_FOREVER);
            }
        }
    }
}

@end
