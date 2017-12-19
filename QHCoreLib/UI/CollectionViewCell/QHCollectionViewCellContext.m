//
//  QHCollectionViewCellContext.m
//  QHCoreLib
//
//  Created by changtang on 2017/12/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHCollectionViewCellContext.h"

@implementation QHCollectionViewCellContext

+ (instancetype)contextFrom:(UICollectionView *)collectionView
                  indexPath:(NSIndexPath *)indexPath
{
    QHCollectionViewCellContext *context = [QHCollectionViewCellContext  new];

    context.collectionView = collectionView;
    context.indexPath = indexPath;

    context.isFirst = (indexPath.row == 0);
    context.isLast = (indexPath.row == ([collectionView.dataSource collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1));

    return context;
}

@end
