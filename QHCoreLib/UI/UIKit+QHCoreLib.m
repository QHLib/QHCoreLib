//
//  UIKit+QHCoreLib.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UIKit+QHCoreLib.h"
#import "QHBase.h"

@implementation UIView (QHUILib)

+ (void)qh_disableAnimationDuringBlock:(dispatch_block_t)block
{
    BOOL savedAnimated = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    QH_BLOCK_INVOKE(block);
    [UIView setAnimationsEnabled:savedAnimated];
}

static const void * kNeedsCalculateSizeASOKey = &kNeedsCalculateSizeASOKey;

- (BOOL)needsCalculateSize
{
    return [objc_getAssociatedObject(self,
                                     kNeedsCalculateSizeASOKey) boolValue];
}

- (void)setNeedsCalculateSize:(BOOL)needsCalculateSize
{
    objc_setAssociatedObject(self,
                             kNeedsCalculateSizeASOKey,
                             @(needsCalculateSize),
                             OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UIView (Frame)

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setTop:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)bottom
{
    CGRect frame = self.frame;
    return frame.origin.y + frame.size.height;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)right
{
    CGRect frame = self.frame;
    return frame.origin.x + frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

@end


@implementation UIView (lockBackgroundColor)

static const void * kLockedBackgroundColorKVOKey = &kLockedBackgroundColorKVOKey;

- (void)qh_setBackgroundColor_inject:(UIColor *)color
{
    BOOL locked = [objc_getAssociatedObject(self,
                                            kLockedBackgroundColorKVOKey) boolValue];
    if (locked) {
        return;
    }
    else {
        [self qh_setBackgroundColor_inject:color];
    }
}

- (void)qh_lockBackgroundColor;
{
    objc_setAssociatedObject(self,
                             kLockedBackgroundColorKVOKey,
                             @(YES),
                             OBJC_ASSOCIATION_RETAIN);

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method old_setter = class_getInstanceMethod([self class], @selector(setBackgroundColor:));
        Method new_setter = class_getInstanceMethod([self class], @selector(qh_setBackgroundColor_inject:));
        method_exchangeImplementations(old_setter, new_setter);
    });
}

- (void)qh_unlockBackgroundColor
{
    objc_setAssociatedObject(self,
                             kLockedBackgroundColorKVOKey,
                             @(NO),
                             OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSUInteger)hex
{
    return [UIColor colorWithHex:hex alpha:1.0f];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    NSUInteger red = ((hex & 0xff0000) >> 16);
    NSUInteger green = ((hex & 0xff00) >> 8);
    NSUInteger blue = (hex & 0xff);
    CGFloat r = (CGFloat)red / 255.0f;
    CGFloat g = (CGFloat)green  / 255.0f;
    CGFloat b = (CGFloat)blue / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

@end

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0,0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

@implementation UITableViewCell (QHCoreLib)

- (CGFloat)qh_seperatorLineDefaultHeight
{
 static CGFloat height = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = 1.0 / [UIScreen mainScreen].scale;
    });
    return height;
}

#pragma mark - top

static const void * kQHTableViewCellTopSeperatorLineKVOKey = &kQHTableViewCellTopSeperatorLineKVOKey;

- (UIView *)qh_topSeperatorLine
{
    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellTopSeperatorLineKVOKey);
    if (view == nil) {
        UIEdgeInsets insets = self.qh_topSeperatorLineInsets;
        view = [[UIView alloc] initWithFrame:CGRectMake(insets.left,
                                                        -[self qh_seperatorLineDefaultHeight],
                                                        self.width - insets.left - insets.right,
                                                        [self qh_seperatorLineDefaultHeight])];
        objc_setAssociatedObject(self,
                                 kQHTableViewCellTopSeperatorLineKVOKey,
                                 view,
                                 OBJC_ASSOCIATION_RETAIN);
        [self.contentView addSubview:view];
    }
    return view;
}

static const void * kQHTableViewCellTopSeperatorLineInsetsKVOKey = &kQHTableViewCellTopSeperatorLineInsetsKVOKey;

- (UIEdgeInsets)qh_topSeperatorLineInsets
{
    NSValue *value = objc_getAssociatedObject(self, kQHTableViewCellTopSeperatorLineInsetsKVOKey);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setQh_topSeperatorLineInsets:(UIEdgeInsets)qh_topSeperatorLineInsets
{
    objc_setAssociatedObject(self,
                             kQHTableViewCellTopSeperatorLineInsetsKVOKey,
                             [NSValue valueWithUIEdgeInsets:qh_topSeperatorLineInsets],
                             OBJC_ASSOCIATION_RETAIN);

    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellTopSeperatorLineKVOKey);
    if (view) {
        [self qh_layoutTopSeperatorLine];
    }
}

- (void)qh_layoutTopSeperatorLine
{
    UIEdgeInsets insets = self.qh_topSeperatorLineInsets;
    self.qh_topSeperatorLine.frame = CGRectMake(insets.left,
                                                - [self qh_seperatorLineDefaultHeight] / 2.0,
                                                self.width - insets.left - insets.right,
                                                [self qh_seperatorLineDefaultHeight]);
}

#pragma mark - bottom

static const void * kQHTableViewCellBottomSeperatorLineKVOKey = &kQHTableViewCellBottomSeperatorLineKVOKey;

- (UIView *)qh_bottomSeperatorLine
{
    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellBottomSeperatorLineKVOKey);
    if (view == nil) {
        UIEdgeInsets insets = self.qh_bottomSeperatorLineInsets;
        view = [[UIView alloc] initWithFrame:CGRectMake(insets.left,
                                                        self.height,
                                                        self.width - insets.left - insets.right,
                                                        [self qh_seperatorLineDefaultHeight])];
        objc_setAssociatedObject(self,
                                 kQHTableViewCellBottomSeperatorLineKVOKey,
                                 view,
                                 OBJC_ASSOCIATION_RETAIN);
        [self.contentView addSubview:view];
    }
    return view;
}

static const void * kQHTableViewCellBottomSeperatorLineInsetsKVOKey = &kQHTableViewCellBottomSeperatorLineInsetsKVOKey;

- (UIEdgeInsets)qh_bottomSeperatorLineInsets
{
    NSValue *value = objc_getAssociatedObject(self, kQHTableViewCellBottomSeperatorLineInsetsKVOKey);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setQh_bottomSeperatorLineInsets:(UIEdgeInsets)qh_bottomSeperatorLineInsets
{
    objc_setAssociatedObject(self,
                             kQHTableViewCellBottomSeperatorLineInsetsKVOKey,
                             [NSValue valueWithUIEdgeInsets:qh_bottomSeperatorLineInsets],
                             OBJC_ASSOCIATION_RETAIN);

    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellBottomSeperatorLineKVOKey);
    if (view) {
        [self qh_layoutBottomSeperatorLine];
    }
}

- (void)qh_layoutBottomSeperatorLine
{
    UIEdgeInsets insets = self.qh_bottomSeperatorLineInsets;
    self.qh_bottomSeperatorLine.frame = CGRectMake(insets.left,
                                                   self.height - [self qh_seperatorLineDefaultHeight] / 2.0,
                                                   self.width - insets.left - insets.right,
                                                   [self qh_seperatorLineDefaultHeight]);
}

- (void)qh_layoutSeperatorLines
{
    [self qh_layoutTopSeperatorLine];
    [self qh_layoutBottomSeperatorLine];
}

@end
