//
//  QHAsyncTestTasks.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHAsyncTask+internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHSuccessTask : QHAsyncTask

@end


@interface QHFailTask : QHAsyncTask

- (instancetype)initWithInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
