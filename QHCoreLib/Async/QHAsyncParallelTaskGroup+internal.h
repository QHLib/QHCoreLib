//
//  QHAsyncParallelTaskGroup+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHAsyncParallelTaskGroup_internal_h
#define QHAsyncParallelTaskGroup_internal_h

#import "QHAsyncParallelTaskGroup.h"

@interface QHAsyncParallelTaskGroup ()

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, QHAsyncTask *> *tasks;

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, id> *results;

/*
 * Generate final result from `results` of all `tasks`. Default implementation
 * returns an copy of `results`.
 * This method will be called on `workQueue`.
 */
- (id)p_doAggregated:(NSError * __autoreleasing *)error;

@end


#endif /* QHAsyncParallelTaskGroup_internal_h */
