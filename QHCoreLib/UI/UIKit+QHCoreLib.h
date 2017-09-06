//
//  UIKit+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (QHCoreLib)

+ (void)qh_disableAnimationDuringBlock:(dispatch_block_t)block;

@end

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@end

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(NSUInteger)hex;

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

@end

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
