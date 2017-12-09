//
//  QHFlowView.m
//  QHCoreLib
//
//  Created by changtang on 2017/12/6.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHFlowView.h"
#import "QHBase.h"
#import "UIKit+QHCoreLib.h"

#import "QHCoreLib/QHCoreLib-Swift.h"

@interface QHCollectionViewWrapCell : UICollectionViewCell

@property (nonatomic, strong) UIView *targetView;

@end

@interface QHFlowView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readwrite) AlignedCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;

@end

@implementation QHFlowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.flowLayout = [AlignedCollectionViewFlowLayout defaultLayout];
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame
                                                 collectionViewLayout:self.flowLayout];
        [self.collectionView qh_disableContentInsetAdjust];
        self.collectionView.backgroundView = [UIColor clearColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[QHCollectionViewWrapCell class]
                forCellWithReuseIdentifier:@"cell"];
        [self addSubview:self.collectionView];
        
        self.showAll = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    self.collectionView.frame = self.bounds;
}

- (AlignedCollectionViewFlowLayout *)alignedFlowLayout
{
    return (AlignedCollectionViewFlowLayout *)self.flowLayout;
}

- (void)setHorizontalAlign:(QHFlowViewItemHorizontalAlign)horAlign
{
    [self.alignedFlowLayout setHorizontalAlignWithAlign:horAlign];
}

- (void)setVerticalAlign:(QHFlowViewItemVerticalAlign)verAlign
{
    [self.alignedFlowLayout setVerticalAlignWithAlign:verAlign];
}

- (void)setItemViews:(NSArray<UIView *> *)itemViews
{
    _itemViews = itemViews;
    
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    
    if (self.showAll) {
        self.size = self.collectionView.contentSize;
        self.collectionView.size = self.collectionView.contentSize;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemViews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHCollectionViewWrapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                               forIndexPath:indexPath];
    cell.targetView = [self.itemViews qh_objectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.itemViews qh_objectAtIndex:indexPath.row].size;
}

@end

@implementation QHCollectionViewWrapCell

- (void)layoutSubviews
{
    self.targetView.origin = CGPointZero;
}

- (void)prepareForReuse
{
    [_targetView removeFromSuperview];
    _targetView = nil;
}

- (void)setTargetView:(UIView *)targetView
{
    if (_targetView != targetView) {
        [_targetView removeFromSuperview];
        _targetView = targetView;
        [self.contentView addSubview:_targetView];
    }
}

@end
