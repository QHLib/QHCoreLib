//
//  QHStackView.h
//  QQHouse
//
//  Created by changtang on 16/9/23.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHStackViewAlign) {
    QHStackViewAlignVertical,
    QHStackViewAlignHorizontal,
};

typedef NS_ENUM(NSUInteger, QHStackViewVerticalAlign) {
    QHStackViewVerticalAlignTop,
    QHStackViewVerticalAlignCenter,
    QHStackViewVerticalAlignBottom,
};

typedef NS_ENUM(NSUInteger, QHStackViewHorizontalAlign) {
    QHStackViewHorizontalAlignLeft,
    QHStackViewHorizontalAlignCenter,
    QHStackViewHorizontalAlignRight,
};

// 从左往右横向依次排列，以spacing为间隔
@interface QHStackView : UIView

// automatic update stack view length to: all itemViews width + (itemViews - 1) * spacing
@property (nullable, nonatomic, strong) NSArray<__kindof UIView *> *itemViews;

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) QHStackViewAlign viewAlign; // default horizontal
@property (nonatomic, assign) QHStackViewVerticalAlign verticalAlign; // default center
@property (nonatomic, assign) QHStackViewHorizontalAlign horizontalAlign; // default center

@property (nonatomic, assign) BOOL extendItemTouchArea; // default NO
@property (nonatomic, assign) CGFloat extendPadding; // default 0

- (CGSize)wrappedSize;

@end

NS_ASSUME_NONNULL_END
