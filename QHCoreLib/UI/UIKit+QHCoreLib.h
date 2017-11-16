//
//  UIKit+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QHCoreLib/QHDefines.h>

@interface UIView (QHCoreLib)

+ (void)qh_disableAnimationDuringBlock:(dispatch_block_t)block;

@property (nonatomic, assign) BOOL needsCalculateSize;

@end

@interface UIView (Frame)

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@end

@interface UIView (backgroundColorLocker)

- (void)qh_lockBackgroundColor;
- (void)qh_unlockBackgroundColor;

@end

@interface UIColor (QHCoreLib)

+ (UIColor *)colorWithHex:(NSUInteger)hex;

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

- (UIColor *)qh_blendWithColor:(UIColor *)color alpha:(CGFloat)alpha;

+ (UIColor *)colorWithColor:(UIColor *)color alpha:(CGFloat)alpha;

@end

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)resizeImageToSize:(CGSize)imageSize;

@end

@interface QHTableViewCellSeperatorLine : UIImageView

- (void)qh_setLockedBackgroundColor:(UIColor *)backgroundColor;
- (void)setBackgroundColor:(UIColor *)backgroundColor QH_DEPRECATED("use `qh_setLockedBackgroundColor:`");

@end

@interface UIScrollView (QHCoreLib)

- (void)qh_disableContentInsetAdjust;

@end

@interface UITableViewCell (QHCoreLib)

+ (NSString *)qh_reuseIdentifier;
+ (NSString *)qh_reuseIdentifierWithPostfix:(NSString *)postfix;

@property (nonatomic, assign) CGFloat qh_seperatorLineHeight;

@property (nonatomic, readonly) QHTableViewCellSeperatorLine *qh_topSeperatorLine;
@property (nonatomic, assign) UIEdgeInsets qh_topSeperatorLineInsets;

@property (nonatomic, readonly) QHTableViewCellSeperatorLine *qh_bottomSeperatorLine;
@property (nonatomic, assign) UIEdgeInsets qh_bottomSeperatorLineInsets;

- (void)qh_layoutSeperatorLines;

@end

@interface UICollectionViewCell (QHCoreLib)

+ (NSString *)qh_reuseIdentifier;
+ (NSString *)qh_reuseIdentifierWithPostfix:(NSString *)postfix;

@end

@interface UIAlertView (QHCoreLib)

- (void)showWithHandler:(void(^)(NSUInteger buttonIndex))clickedButtonAtIndex;

@end

@interface UIAlertAction (QHCoreLib)

- (void)qh_setTitleColor:(UIColor *)color;

@end
