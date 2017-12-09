//
//  QHFlowView.h
//  QHCoreLib
//
//  Created by changtang on 2017/12/6.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QHFlowViewItemHorizontalAlign) {
    QHFlowViewItemHorizontalAlignJustified = 0,
    QHFlowViewItemHorizontalAlignLeft,
    QHFlowViewItemHorizontalAlignRight,
};

typedef NS_ENUM(NSUInteger, QHFlowViewItemVerticalAlign) {
    QHFlowViewItemVerticalAlignCenter = 0,
    QHFlowViewItemVerticalAlignTop,
    QHFlowViewItemVerticalAlignBottom,
};


@interface QHFlowView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readonly) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

- (void)setHorizontalAlign:(QHFlowViewItemHorizontalAlign)horAlign;

- (void)setVerticalAlign:(QHFlowViewItemVerticalAlign)verAlign;

// if YES, size will be set to content size to show all item views after setItemViews:
// default YES
@property (nonatomic, assign) BOOL showAll;

@property (nonatomic, strong) NSArray<UIView *> *itemViews;

@end
