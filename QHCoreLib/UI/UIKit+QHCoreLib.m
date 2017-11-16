//
//  UIKit+QHCoreLib.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "UIKit+QHCoreLib.h"
#import "QHBase+internal.h"

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
        Method old_setter = class_getInstanceMethod([UIView class], @selector(setBackgroundColor:));
        Method new_setter = class_getInstanceMethod([UIView class], @selector(qh_setBackgroundColor_inject:));
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

@implementation UIColor (QHCoreLib)

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

- (UIColor *)qh_blendWithColor:(UIColor *)color alpha:(CGFloat)alpha2
{
    alpha2 = MIN(1.0, MAX(0.0, alpha2));
    CGFloat beta = 1.0 - alpha2;
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat red     = r1 * beta + r2 * alpha2;
    CGFloat green   = g1 * beta + g2 * alpha2;
    CGFloat blue    = b1 * beta + b2 * alpha2;
    CGFloat alpha   = a1 * beta + a2 * alpha2;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithColor:(UIColor *)color alpha:(CGFloat)alpha
{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat al = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&al];
    
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
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

- (UIImage *)resizeImageToSize:(CGSize)imageSize
{
    if (self.size.width == 0 || self.size.height == 0) return nil;

    CGFloat widthRatio = imageSize.width / self.size.width;
    CGFloat heightRatio = imageSize.height / self.size.height;
    CGFloat ratio = MAX(widthRatio, heightRatio);

    CGRect frame = CGRectMake(0,
                              0,
                              self.size.width * ratio,
                              self.size.height * ratio);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.scale);
    [self drawInRect:frame];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end

@implementation QHTableViewCellSeperatorLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self qh_lockBackgroundColor];
    }
    return self;
}

- (void)qh_setLockedBackgroundColor:(UIColor *)backgroundColor
{
    [super qh_setBackgroundColor_inject:backgroundColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

@end

@implementation UIScrollView (QHCoreLib)

- (void)qh_disableContentInsetAdjust
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
#endif
}

@end

@implementation UITableViewCell (QHCoreLib)

+ (NSString *)qh_reuseIdentifier
{
    return NSStringFromClass(self);
}

+ (NSString *)qh_reuseIdentifierWithPostfix:(NSString *)postfix
{
    return $(@"%@_%@", [self qh_reuseIdentifier], postfix);
}

static const void * kQHTableViewCellSeperatorLineHeightKVOKey = &kQHTableViewCellSeperatorLineHeightKVOKey;

- (CGFloat)qh_seperatorLineHeight
{
    NSNumber *height = objc_getAssociatedObject(self, kQHTableViewCellSeperatorLineHeightKVOKey);
    return height ? [height floatValue] : (1.0 / [UIScreen mainScreen].scale);
}

- (void)setQh_seperatorLineHeight:(CGFloat)qh_seperatorLineHeight
{
    objc_setAssociatedObject(self,
                             kQHTableViewCellSeperatorLineHeightKVOKey,
                             @(qh_seperatorLineHeight),
                             OBJC_ASSOCIATION_RETAIN);

    [self qh_layoutSeperatorLines];
}

#pragma mark - top

static const void * kQHTableViewCellTopSeperatorLineKVOKey = &kQHTableViewCellTopSeperatorLineKVOKey;

- (QHTableViewCellSeperatorLine *)qh_topSeperatorLine
{
    QHTableViewCellSeperatorLine *view = objc_getAssociatedObject(self, kQHTableViewCellTopSeperatorLineKVOKey);
    if (view == nil) {
        UIEdgeInsets insets = self.qh_topSeperatorLineInsets;
        view = [[QHTableViewCellSeperatorLine alloc] initWithFrame:CGRectMake(insets.left,
                                                                              -[self qh_seperatorLineHeight],
                                                                              self.width - insets.left - insets.right,
                                                                              [self qh_seperatorLineHeight])];
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

    [self qh_layoutTopSeperatorLine];
}

- (void)qh_layoutTopSeperatorLine
{
    UIEdgeInsets insets = self.qh_topSeperatorLineInsets;
    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellTopSeperatorLineKVOKey);
    if (view) {
        view.frame = CGRectMake(insets.left,
                                - [self qh_seperatorLineHeight] / 2.0,
                                self.width - insets.left - insets.right,
                                [self qh_seperatorLineHeight]);
    }
}

#pragma mark - bottom

static const void * kQHTableViewCellBottomSeperatorLineKVOKey = &kQHTableViewCellBottomSeperatorLineKVOKey;

- (QHTableViewCellSeperatorLine *)qh_bottomSeperatorLine
{
    QHTableViewCellSeperatorLine *view = objc_getAssociatedObject(self, kQHTableViewCellBottomSeperatorLineKVOKey);
    if (view == nil) {
        UIEdgeInsets insets = self.qh_bottomSeperatorLineInsets;
        view = [[QHTableViewCellSeperatorLine alloc] initWithFrame:CGRectMake(insets.left,
                                                                              self.height,
                                                                              self.width - insets.left - insets.right,
                                                                              [self qh_seperatorLineHeight])];
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

    [self qh_layoutBottomSeperatorLine];
}

- (void)qh_layoutBottomSeperatorLine
{
    UIEdgeInsets insets = self.qh_bottomSeperatorLineInsets;
    UIView *view = objc_getAssociatedObject(self, kQHTableViewCellBottomSeperatorLineKVOKey);
    if (view) {
        view.frame = CGRectMake(insets.left,
                                self.height - [self qh_seperatorLineHeight] / 2.0,
                                self.width - insets.left - insets.right,
                                [self qh_seperatorLineHeight]);
    }
}

- (void)qh_layoutSeperatorLines
{
    [self qh_layoutTopSeperatorLine];
    [self qh_layoutBottomSeperatorLine];
}

@end

@implementation UICollectionViewCell (QHCoreLib)

+ (NSString *)qh_reuseIdentifier
{
    return NSStringFromClass(self);
}

+ (NSString *)qh_reuseIdentifierWithPostfix:(NSString *)postfix
{
    return $(@"%@_%@", [self qh_reuseIdentifier], postfix);
}

@end

@interface UIAlertView_qhDelegate : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, copy) void(^handler)(NSUInteger buttonIndex);
@end

@implementation UIAlertView_qhDelegate
- (void)dealloc
{
    QHCoreLibInfo(@"%@ deallocing", self);
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.handler) {
        self.handler(buttonIndex);
    }
}
@end

@implementation UIAlertView (QHCoreLib)

- (void)showWithHandler:(void (^)(NSUInteger))clickedButtonAtIndex
{
    UIAlertView_qhDelegate *delegate = [[UIAlertView_qhDelegate alloc] init];
    delegate.alertView = self;
    @weakify(delegate);
    delegate.handler = ^(NSUInteger buttonIndex) {
        @strongify(delegate);
        if (clickedButtonAtIndex) {
            clickedButtonAtIndex(buttonIndex);
        }
        delegate.alertView.qh_handy_carry = nil; // break retain cycle
    };

    self.delegate = delegate;
    self.qh_handy_carry = delegate;        // create retain cycle here
    [self show];
}

@end

@implementation UIAlertAction (QHCoreLib)

- (void)qh_setTitleColor:(UIColor *)color
{
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_3) {
        [self setValue:color forKey:@"titleTextColor"];
    } else {
        // set action title color would not work below 8.3
    }
}

@end
