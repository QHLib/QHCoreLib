//
//  CGFunctions.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "CGFunctions.h"
#import "QHBase+internal.h"

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

CGPoint QHMidPointForPoints(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);
}

CGPoint QHControlPointForPoints(CGPoint from, CGPoint to)
{
    CGPoint midPoint = QHMidPointForPoints(from, to);
    midPoint.y += (from.y - to.y) / 2.0;
    return midPoint;
}

UIBezierPath *QHBezierPathForPoints(NSArray<NSValue *> *points,
                                    BOOL smoothCurve)
{
    QHAssert(points.count >= 2, @"invalid points");

    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint p1 = [points[0] CGPointValue];
    [path moveToPoint:p1];

    for (int i = 1; i < points.count; ++i) {
        CGPoint p2 = [points[i] CGPointValue];

        if (!smoothCurve)  {
            [path addLineToPoint:p2];
        } else {
            CGPoint midPoint = QHMidPointForPoints(p1, p2);
            [path addQuadCurveToPoint:midPoint controlPoint:QHControlPointForPoints(p1, midPoint)];
            [path addQuadCurveToPoint:p2 controlPoint:QHControlPointForPoints(p2, midPoint)];
        }
        p1 = p2;
    }

    return path;
}

NS_ASSUME_NONNULL_END

