//
//  CGFunctions.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QHCoreLib/QHDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGFunctions : NSObject

@end

QH_EXTERN_C_BEGIN

QH_EXTERN void CGContextAddRoundedRect(CGContextRef cg_nullable context, CGFloat cornerRadius, CGRect rect);

QH_EXTERN CGPoint QHMidPointForPoints(CGPoint p1, CGPoint p2);

QH_EXTERN CGPoint QHControlPointForPoints(CGPoint from, CGPoint to);

QH_EXTERN UIBezierPath *QHBezierPathForPoints(NSArray<NSValue *> *points,
                                              BOOL smoothCurve);

QH_EXTERN_C_END

NS_ASSUME_NONNULL_END

