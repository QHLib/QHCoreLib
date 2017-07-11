//
//  QHAsyncLinkedTaskGroup.h
//  QHCoreLib
//
//  Created by changtang on 2017/7/1.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncLinkedTaskNode<InType, OutType> : NSObject

/**
 * `task` must accept `carry` of type 'InType'.
 * Use it carefully.
 */
+ (QHAsyncLinkedTaskNode<InType, OutType> *)nodeFromTask:(QHAsyncTask<OutType> *)task;

/**
 * `task` must accept `carry` of type 'InType' and yield `result` of type 'InType'.
 * Use it carefully.
 */
- (QHAsyncLinkedTaskNode<InType, OutType> *)nodeByPrependTask:(QHAsyncTask<InType> *)task;

/**
 * `task` must accept `carry` of type 'OutType' and yield `result` of type 'OutType'.
 * Use it carefully.
 */
- (QHAsyncLinkedTaskNode<InType, id> *)nodeByAppendTask:(QHAsyncTask<id> *)task;

@end

@interface QHAsyncLinkedTaskLinker<InType, ViaType, OutType> : NSObject

+ (QHAsyncLinkedTaskNode<InType, OutType> *)linkNode:(QHAsyncLinkedTaskNode<InType, ViaType> *)first
                                            withNode:(QHAsyncLinkedTaskNode<ViaType, OutType> *)second;

/**
 * `task` must accept `carry` of type 'InType' and yield `result` of type 'ViaType'.
 * Use it carefully.
 */
+ (QHAsyncLinkedTaskNode<InType, OutType> *)prependTask:(QHAsyncTask<ViaType> *)task
                                                 toNode:(QHAsyncLinkedTaskNode<ViaType, OutType> *)node;

/**
 * `task` must accept `carry` of type 'ViaType' and yield `result` of type 'OutType'.
 * Use it carefully.
 */
+ (QHAsyncLinkedTaskNode<InType, OutType> *)appendTask:(QHAsyncTask<OutType> *)task
                                                toNode:(QHAsyncLinkedTaskNode<InType, ViaType> *)node;

@end

@interface QHAsyncTask<ResultType> (LinkedTaskGroup)

// subclass may declare proper `InType` which use `id` here
- (QHAsyncLinkedTaskNode<id, ResultType> *)node;

/**
 * Carry must be checked before use.
 */
@property (nonatomic, strong) id carry;

- (NSError *)p_invalidCarryError;

@end

/*
 * Progress that reported after each task succeed or failed.
 */
@interface QHAsyncLinkedTaskGroupProgress : NSObject<QHAsyncTaskProgress>

// mark as unavailable, because not implemented
- (NSTimeInterval)estimatedTime NS_UNAVAILABLE;

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *results;

@end

@interface QHAsyncLinkedTaskGroup<InType, ResultType> : QHAsyncTask<ResultType>

/**
 * All tasks inside `head` should not be touched after calling this method.
 */
- (void)setTaskList:(QHAsyncLinkedTaskNode<InType, ResultType> *)head;

/*
 * Default value [NSNull null].
 */
@property (nonatomic, strong) InType carry;

QH_ASYNC_TASK_PROGRESS_DECL(QHAsyncTask, QHAsyncLinkedTaskGroupProgress);

@end


#define QH_ASYNC_LINKED_TASK_NODE_DECL(IN_TYPE_P, OUT_TYPE_P) \
- (QHAsyncLinkedTaskNode<IN_TYPE_P, OUT_TYPE_P> *)node; \
@property (nonatomic, strong) IN_TYPE_P carry;

#define QH_ASYNC_LINKED_TASK_NODE_IMPL(IN_TYPE_P, OUT_TYPE_P) \
@dynamic carry; \
- (QHAsyncLinkedTaskNode *)node \
{ \
    return [super node]; \
}

#define QH_ASYNC_LINKED_TASK_LINK(IN_TYPE_P, TASK_FIRST, VIA_TYPE_P, TASK_SECOND, OUT_TYPE_P) \
[QHAsyncLinkedTaskLinker<IN_TYPE_P, VIA_TYPE_P, OUT_TYPE_P> linkNode:({ \
    ([QHAsyncLinkedTaskNode<IN_TYPE_P, VIA_TYPE_P> nodeFromTask:TASK_FIRST]); \
}) withNode:({ \
    ([QHAsyncLinkedTaskNode<VIA_TYPE_P, OUT_TYPE_P> nodeFromTask:TASK_SECOND]); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_3(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_3> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_4(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_4> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_3(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_5(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_5> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_4(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_6(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, \
    TASK_5, TYPE_P_6) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_6> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_5(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, TASK_5, TYPE_P_6)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_7(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, \
    TASK_5, TYPE_P_6, TASK_6, TYPE_P_7) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_7> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_6(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, TASK_5, TYPE_P_6, \
        TASK_6, TYPE_P_7)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_8(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, \
    TASK_5, TYPE_P_6, TASK_6, TYPE_P_7, TASK_7, TYPE_P_8) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_8> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_7(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, TASK_5, TYPE_P_6, \
        TASK_6, TYPE_P_7, TASK_7, TYPE_P_8)); \
})]

#define QH_ASYNC_LINKED_TASK_LINK_9(TYPE_P_0, TASK_0, TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, \
    TASK_5, TYPE_P_6, TASK_6, TYPE_P_7, TASK_7, TYPE_P_8, TASK_8, TYPE_P_9) \
[QHAsyncLinkedTaskLinker<TYPE_P_0, TYPE_P_1, TYPE_P_9> linkNode:({ \
    ([QHAsyncLinkedTaskNode<TYPE_P_0, TYPE_P_1> nodeFromTask:TASK_0]); \
}) withNode:({ \
    (QH_ASYNC_LINKED_TASK_LINK_8(TYPE_P_1, TASK_1, TYPE_P_2, TASK_2, TYPE_P_3, TASK_3, TYPE_P_4, TASK_4, TYPE_P_5, TASK_5, TYPE_P_6, \
        TASK_6, TYPE_P_7, TASK_7, TYPE_P_8, TASK_8, TYPE_P_9)); \
})]

NS_ASSUME_NONNULL_END
