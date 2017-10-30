//
//  CGFunctions.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/24.
//  Copyright © 2017年 Tencent. All rights reserved.
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

CGPoint QHControlPointForPoints(CGPoint p1, CGPoint p2, CGPoint p3)
{
    CGPoint lefMidPoint = QHMidPointForPoints(p1, p2);
    CGPoint rightMidPoint = QHMidPointForPoints(p2, p3);
    // mirror point of rightMidPoint relative to p2
    CGPoint mirrorPoint = CGPointMake(p2.x + (p2.x - rightMidPoint.x),
                                      p2.y + (p2.y - rightMidPoint.y));

    CGPoint controlPoint = QHMidPointForPoints(lefMidPoint, mirrorPoint);
    controlPoint.y = QHClamp(controlPoint.y, lefMidPoint.y, mirrorPoint.y);

    CGFloat flippedP3y = p2.y + (p2.y - p3.y);
    controlPoint.y = QHClamp(controlPoint.y , p2.y, flippedP3y);

    controlPoint.x = QHClamp(controlPoint.x, p1.x, p2.x);

    return controlPoint;
}

UIBezierPath *QHBezierPathForPoints(NSArray<NSValue *> *points,
                                    BOOL smoothCurve)
{
    QHAssert(points.count >= 2, @"invalid points");

    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint p1 = [points[0] CGPointValue];
    [path moveToPoint:p1];
    CGPoint oldControlPoint = p1;

    for (int i = 1; i < points.count; ++i) {
        CGPoint p2 = [points[i] CGPointValue];

        if (!smoothCurve)  {
            [path addLineToPoint:p2];
        } else {
            CGPoint p3 = CGPointZero;
            if (i + 1 < points.count) {
                p3 = [points[i+1] CGPointValue];
                CGPoint newControlPoint = QHControlPointForPoints(p1, p2, p3);
                [path addCurveToPoint:p2 controlPoint1:oldControlPoint controlPoint2:newControlPoint];
                oldControlPoint = CGPointMake(p2.x + (p2.x - newControlPoint.x),
                                              p2.y + (p2.y - newControlPoint.y));
            } else {
                [path addLineToPoint:p2];
            }
        }
        p1 = p2;
    }

    return path;
}

NS_ASSUME_NONNULL_END
