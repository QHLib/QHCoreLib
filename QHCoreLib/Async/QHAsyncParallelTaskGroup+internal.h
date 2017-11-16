//
//  QHAsyncParallelTaskGroup+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#ifndef QHAsyncParallelTaskGroup_internal_h
#define QHAsyncParallelTaskGroup_internal_h

#import "QHAsyncParallelTaskGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncParallelTaskGroup ()

/*
 * Generate final result from `result` of all `tasks`. Default implementation
 * returns the `results` in `result`.
 * This method will be called on `workQueue`.
 */
- (id _Nullable)p_doAggregateResult:(QHAsyncParallelTaskGroupResult *)result
                              error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END

#endif /* QHAsyncParallelTaskGroup_internal_h */
