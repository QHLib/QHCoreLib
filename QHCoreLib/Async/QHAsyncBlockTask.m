//
//  QHAsyncBlockTask.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHAsyncBlockTask.h"
#import "QHAsyncTask+internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHAsyncBlockTaskReporter ()

@property (nonatomic, weak) QHAsyncBlockTask *task;

@end

@implementation QHAsyncBlockTaskReporter

- (void)success:(id _Nullable)result
{
    [self.task p_fireSuccess:result];
}

- (void)fail:(NSError *)error
{
    [self.task p_fireFail:error];
}

@end

@interface QHAsyncBlockTask ()

@property (nonatomic, copy) QHAsyncBlockTaskBody block;

@end

@implementation QHAsyncBlockTask

+ (instancetype)taskWithBlock:(QHAsyncBlockTaskBody)block
{
    QHAsyncBlockTask *blockTask = [[QHAsyncBlockTask alloc] init];
    
    blockTask.block = block;
    
    return blockTask;
}

- (void)p_doStart
{
    QHAssert(self.block != nil, @"block task body is nil: %@", self);
    
    QH_BLOCK_INVOKE(^{
        QHAsyncBlockTaskReporter *reporter = [QHAsyncBlockTaskReporter new];
        reporter.task = self;
        self.block(reporter);
    });
}

@end

NS_ASSUME_NONNULL_END
