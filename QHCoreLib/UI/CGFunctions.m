//
//  CGFunctions.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "CGFunctions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CGFunctions

@end

 void CGContextAddRoundedRect(CGContextRef cg_nullable context, CGFloat cornerRadius, CGRect rect)
{
    CGFloat left = rect.origin.x;
    CGFloat top = rect.origin.y;
    CGFloat right = rect.origin.x + rect.size.width;
    CGFloat bottom = rect.origin.y + rect.size.height;

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, left + cornerRadius, top);
    CGContextAddLineToPoint(context, right - cornerRadius, top);
    CGContextAddArcToPoint(context, right, top, right, top + cornerRadius, cornerRadius);
    CGContextAddLineToPoint(context, right, bottom - cornerRadius);
    CGContextAddArcToPoint(context, right, bottom, right - cornerRadius, bottom, cornerRadius);
    CGContextAddLineToPoint(context, left + cornerRadius, bottom);
    CGContextAddArcToPoint(context, left, bottom, left, bottom - cornerRadius, cornerRadius);
    CGContextAddLineToPoint(context, left, top + cornerRadius);
    CGContextAddArcToPoint(context, left, top, left + cornerRadius, top, cornerRadius);
    CGContextClosePath(context);
}

NS_ASSUME_NONNULL_END
