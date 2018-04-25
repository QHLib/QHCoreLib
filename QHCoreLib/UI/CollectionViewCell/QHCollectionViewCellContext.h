//
//  QHCollectionViewCellContext.h
//  QHCoreLib
//
//  Created by changtang on 2017/12/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHCollectionViewCellContext : NSObject

+ (instancetype)contextFrom:(UICollectionView *)collectionView
                  indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isLast;

@property (nonatomic, strong) UIViewController * _Nullable controller;

@property (nonatomic, strong) NSNotificationCenter * _Nullable notificationCenter;

// any thing yout want to pass through
@property (nonatomic, strong) id _Nullable opaque;

@end

NS_ASSUME_NONNULL_END

#define QHCollectionViewCellContextMake(_collectionView, _indexPath) \
    [QHCollectionViewCellContext contextFrom:_collectionView indexPath:_indexPath]
