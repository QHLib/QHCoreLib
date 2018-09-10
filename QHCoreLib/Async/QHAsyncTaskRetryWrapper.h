//
//  QHAsyncTaskRetryWrapper.h
//  QHCoreLib
//
//  Created by changtang on 2018/9/10.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncTaskRetryWrapper<ResultType> : QHAsyncTask<ResultType>

- (instancetype)initWithTaskBuilder:(QHAsyncTaskBuilder)builder
                        maxTryCount:(int)maxTryCount
                      retryInterval:(double)retryInterval;

@end

NS_ASSUME_NONNULL_END
