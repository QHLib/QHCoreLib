//
//  UITableViewCell+QHTableViewCell.h
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QHCoreLib/QHTableViewCellItem.h>
#import <QHCoreLib/QHTableViewCellContext.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (QHTableViewCell)

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem * _Nullable)item
                    context:(QHTableViewCellContext * _Nullable)context;

@property (nonatomic, strong, readonly, nullable) QHTableViewCellItem *qh_cellItem;

- (void)qh_configure:(QHTableViewCellItem *)item
             context:(QHTableViewCellContext *)context NS_REQUIRES_SUPER;

@end

#define QH_TABLEVIEW_CELL_DATA_DECL_(_name, _type) \
- (_type *)_name##Data;

#define QH_TABLEVIEW_CELL_DATA_IMPL_(_name, _type) \
- (_type *)_name##Data \
{ \
    QH_AS(self.qh_cellItem, _type, data); \
    return data; \
}

#define QH_TABLEVIEW_CELL_DATA_DECL(_type) \
    QH_TABLEVIEW_CELL_DATA_DECL_(qh_cell, _type)

#define QH_TABLEVIEW_CELL_DATA_IMPL(_type) \
    QH_TABLEVIEW_CELL_DATA_IMPL_(qh_cell, _type)

NS_ASSUME_NONNULL_END
