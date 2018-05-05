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

@property (nonatomic, strong, readonly, nullable) NSNotificationCenter *qh_eventBridge;

- (void)qh_configure:(QHTableViewCellItem * _Nullable)item
             context:(QHTableViewCellContext * _Nullable)context NS_REQUIRES_SUPER;

@end

#define QH_TABLEVIEW_CELL_DATA_DECL(_name, _type) \
- (_type *)_name##Data;

#define QH_TABLEVIEW_CELL_DATA_IMPL(_name, _type) \
- (_type *)_name##Data \
{ \
    QH_AS(self.qh_cellItem.data, _type, data); \
    return data; \
}

NS_ASSUME_NONNULL_END
