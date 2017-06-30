//
//  QHAsyncBlockTask.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHAsyncTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncBlockTaskReporter<RESULT_TYPE> : NSObject

- (void)success:(RESULT_TYPE _Nullable)result;
- (void)fail:(NSError *)error;

@end

typedef void (^QHAsyncBlockTaskBody)(QHAsyncBlockTaskReporter<id> *reporter);

@interface QHAsyncBlockTask<RESULT_TYPE> : QHAsyncTask<RESULT_TYPE>

+ (instancetype)taskWithBlock:(void (^)(QHAsyncBlockTaskReporter<RESULT_TYPE> *reporter))block;

@end

NS_ASSUME_NONNULL_END
