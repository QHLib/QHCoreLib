//
//  QHWeakWrapper.m
//  QHCoreLib
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHWeakWrapper.h"

@interface QHWeakWrapper ()

@property (nonatomic, weak) id wrapped_obj;

@end

@implementation QHWeakWrapper

+ (instancetype)wrapObject:(id)obj
{
    QHWeakWrapper *wrapper = [[QHWeakWrapper alloc] init];
    [wrapper setObj:obj];
    return wrapper;
}

- (id)obj
{
    if (self.wrapped_obj == nil) {
        self.missedCount++;
    }
    return self.wrapped_obj;
}

- (void)setObj:(id)obj
{
    self.wrapped_obj = obj;
    self.missedCount = 0;
}

@end
