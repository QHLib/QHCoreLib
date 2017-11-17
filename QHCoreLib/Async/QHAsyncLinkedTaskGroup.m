//
//  QHAsyncLinkedTaskGroup.m
//  QHCoreLib
//
//  Created by changtang on 2017/7/1.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHAsyncLinkedTaskGroup.h"
#import "QHAsyncTask+internal.h"


NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncLinkedTaskNode ()

@property (nonatomic, strong) QHAsyncTask *task;

@property (nonatomic, strong) QHAsyncLinkedTaskNode *first;
@property (nonatomic, strong) QHAsyncLinkedTaskNode *second;

@end

@implementation QHAsyncLinkedTaskNode

+ (QHAsyncLinkedTaskNode *)nodeFromTask:(QHAsyncTask *)task
{
    return [task node];
}

- (QHAsyncLinkedTaskNode *)nodeByPrependTask:(QHAsyncTask *)task
{
    return [QHAsyncLinkedTaskLinker linkNode:[task node]
                                    withNode:self];
}

- (QHAsyncLinkedTaskNode *)nodeByAppendTask:(QHAsyncTask<id> *)task
{
    return [QHAsyncLinkedTaskLinker linkNode:self
                                    withNode:[task node]];
}

@end

@implementation QHAsyncLinkedTaskLinker

+ (QHAsyncLinkedTaskNode *)linkNode:(QHAsyncLinkedTaskNode *)first
                           withNode:(QHAsyncLinkedTaskNode *)second
{
    QHAsyncLinkedTaskNode *node = [[QHAsyncLinkedTaskNode alloc] init];
    node.first = first;
    node.second = second;
    return node;
}

+ (QHAsyncLinkedTaskNode *)prependTask:(QHAsyncTask *)task
                                toNode:(QHAsyncLinkedTaskNode *)node
{
    return [self linkNode:[task node]
                 withNode:node];
}

+ (QHAsyncLinkedTaskNode *)appendTask:(QHAsyncTask *)task
                               toNode:(QHAsyncLinkedTaskNode *)node
{
    return [self linkNode:node
                 withNode:[task node]];
}

@end

@implementation QHAsyncLinkedTaskGroupProgress

- (uint64_t)totalCount
{
    return self.tasks.count;
}

- (uint64_t)completedCount
{
    return self.results.count;
}

- (CGFloat)currentProgress
{
    QHAssert(self.tasks.count > 0, @"empty tasks in %@", self);
    
    return (self.results.count) / (CGFloat)self.tasks.count;
}

- (NSTimeInterval)estimatedTime
{
    QHAssert(NO, @"not implemented");
    return 0.0;
}

@end

@implementation QHAsyncTask (LinkedTaskGroup)

- (QHAsyncLinkedTaskNode *)node
{
    QHAsyncLinkedTaskNode *node = [[QHAsyncLinkedTaskNode alloc] init];
    node.task = self;
    return node;
}

static void *QHAsyncTaskCarryASOKey = &QHAsyncTaskCarryASOKey;

- (void)setCarry:(id)carry
{
    objc_setAssociatedObject(self, QHAsyncTaskCarryASOKey,
                             carry, OBJC_ASSOCIATION_RETAIN);
}

- (id)carry
{
    return objc_getAssociatedObject(self, QHAsyncTaskCarryASOKey);
}

- (NSError *)p_invalidCarryError
{
    return QH_ERROR(QHAsyncTaskErrorDomain,
                    QHAsyncTaskErrorInvalidCarry,
                    $(@"%@ invalid carry: %@", self, self.carry),
                    nil);
}

@end

@interface QHAsyncLinkedTaskGroup () {
@private
    NSRecursiveLock *_subTaskLock;
}

@property (nonatomic, strong) QHAsyncLinkedTaskNode * _Nullable head;

@property (nonatomic, strong) NSMutableArray<QHAsyncTask *> *tasks;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray<id> *results;

@end

@implementation QHAsyncLinkedTaskGroup

@dynamic carry;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subTaskLock = [[NSRecursiveLock alloc] init];

        self.tasks = [NSMutableArray array];
        self.currentIndex = 0;
        self.results = [NSMutableArray array];

        self.carry = [NSNull null];
    }
    return self;
}

- (void)setTaskList:(QHAsyncLinkedTaskNode *)head
{
    QHAssert(self.state == QHAsyncTaskStateInit,
             @"head of linked task list should not be changed after started: %@", self);
    
    self.head = head;
}

QH_ASYNC_TASK_PROGRESS_IMPL(QHAsyncTask, QHAsyncLinkedTaskGroupProgress);

#pragma mark -

- (void)_extractTasks
{
    QHAssert(self.head != nil, @"head of linked task list is nil: %@", self);

    void (^preorder_traversal)(QHAsyncLinkedTaskNode *);

    __block __weak typeof(preorder_traversal) preorder_traversal_weak = preorder_traversal;

    preorder_traversal = ^(QHAsyncLinkedTaskNode *node) {
        if (node.task) {
            [self.tasks addObject:node.task];
        }
        else {
            if (node.first) {
                preorder_traversal_weak(node.first);
            }
            if (node.second) {
                preorder_traversal_weak(node.second);
            }
        }
    };

    preorder_traversal_weak = preorder_traversal;

    preorder_traversal(self.head);

    self.head = nil;
}

- (void)p_doStart
{
    [self _extractTasks];

    QHAssert(self.tasks.count > 0,
             @"no task found: %@", self);

    QHNSLock(_subTaskLock, ^{
        @retainify(self);

        [self _runNextTask:self.carry];
    });
}

- (void)_runNextTask:(id)carry
{
    QHAsyncTask *task = [self.tasks qh_objectAtIndex:self.currentIndex];
    task.carry = carry;

    @weakify(self);
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nonnull result) {
        @strongify(self);

        QHNSLock(self->_subTaskLock, ^{
            @retainify(self);

            [self.results addObject:result];

            [self _reportOneFinished];

            self.currentIndex++;
            if (self.currentIndex != [self.tasks count]) {
                [self _runNextTask:result];
            }
            else {
                [self _taskGroupSuccess];
            }
        });
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        @strongify(self);

        QHNSLock(self->_subTaskLock, ^{
            @retainify(self);

            [self.results qh_addObject:error];

            [self _reportOneFinished];

            [self _taskGroupFail:error];
        });
    }];
}

- (void)_reportOneFinished
{
    QHAsyncLinkedTaskGroupProgress *progress = [[QHAsyncLinkedTaskGroupProgress alloc] init];
    progress.tasks = self.tasks;
    progress.currentIndex = self.currentIndex;
    progress.results = self.results;

    [self p_fireProgress:progress];
}

- (void)_taskGroupSuccess
{
    [self p_fireSuccess:[self.results lastObject]];
}

- (void)_taskGroupFail:(NSError *)error
{
    [self p_fireFail:error];
}

- (void)p_doClear
{
    [super p_doClear];
}

- (void)p_doCancel
{
    QHNSLock(_subTaskLock, ^{
        @retainify(self);

        QHAsyncTask *task = [self.tasks qh_objectAtIndex:self.currentIndex];
        [task cancel];
    });
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [super p_doCollect:releaseOnDisposeQueue];

    [releaseOnDisposeQueue addObjectsFromArray:self.tasks];
    [self.tasks removeAllObjects];

    [releaseOnDisposeQueue addObjectsFromArray:self.results];
    [self.results removeAllObjects];
}

#pragma mark -

@end

NS_ASSUME_NONNULL_END
