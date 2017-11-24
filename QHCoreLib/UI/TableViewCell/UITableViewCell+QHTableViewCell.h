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

#define QH_TABLEVIEWCELL_DATA_DECL(_TYPE) \
- (_TYPE *)qh_cellData;

#define QH_TABLEVIEWCELL_DATA_IMPL(_TYPE) \
- (_TYPE *)qh_cellData \
{ \
    return self.qh_cellItem.data; \
}

NS_ASSUME_NONNULL_END
