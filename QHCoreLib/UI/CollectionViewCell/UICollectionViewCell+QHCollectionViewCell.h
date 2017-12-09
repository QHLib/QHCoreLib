//
//  UICollectionViewCell+QHCollectionViewCell.h
//  QHCoreLib
//
//  Created by changtang on 2017/12/9.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (QHCollectionViewCell)

@property (nonatomic, strong, readonly, nullable) id qh_data;

- (void)qh_configure:(id _Nullable)data NS_REQUIRES_SUPER;

@end

#define QH_COLLECTIONVIEW_CELL_DATA_DECL(_name, _type) \
- (_type *)_name##Data;

#define QH_COLLECTIONVIEW_CELL_DATA_IMPL(_name, _type) \
- (_type *)_name##Data \
{ \
    QH_AS(self.qh_data, _type, data); \
    return data; \
}

NS_ASSUME_NONNULL_END
