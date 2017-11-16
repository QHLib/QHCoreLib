//
//  QHWeakWrapper.h
//  QHCoreLib
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHWeakWrapper : NSObject

+ (instancetype)wrapObject:(id)obj;

- (id)obj;
- (void)setObj:(id)obj;

// remvoe wrapper from associated storage if missedCount is too big
@property (nonatomic, assign) NSUInteger missedCount;

@end

#define QHWeakWrap(_obj) [QHWeakWrapper wrapObject:_obj]
#define QHWeakUnwrap(_wrapper) [_wrapper obj]
