//
//  UITableViewCell+QHTableViewCell.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "UITableViewCell+QHTableViewCell.h"
#import "QHBase+internal.h"

@implementation UITableViewCell (QHTableViewCell)

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item
                    context:(QHTableViewCellContext *)context
{
    return 44.0f;
}

static void *kQHTableViewCellItemASOKey = &kQHTableViewCellItemASOKey;

- (QHTableViewCellItem *)qh_cellItem
{
    return objc_getAssociatedObject(self, kQHTableViewCellItemASOKey);
}

- (void)setQh_cellItem:(QHTableViewCellItem * _Nullable)qh_cellItem
{
    [self willChangeValueForKey:QH_PROPETY_NAME(qh_cellItem)];
    objc_setAssociatedObject(self,
                             kQHTableViewCellItemASOKey,
                             qh_cellItem,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:QH_PROPETY_NAME(qh_cellItem)];
}

static void *kQHTableViewCellEventBridgeASOKey = &kQHTableViewCellEventBridgeASOKey;

- (NSNotificationCenter *)qh_eventBridge
{
    return objc_getAssociatedObject(self,
                                    kQHTableViewCellEventBridgeASOKey);
}

- (void)setQh_eventBridge:(NSNotificationCenter * _Nullable)qh_eventBridge
{
    objc_setAssociatedObject(self,
                             kQHTableViewCellEventBridgeASOKey,
                             qh_eventBridge,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)qh_configure:(QHTableViewCellItem * )item
             context:(QHTableViewCellContext *)context
{
    [self setQh_cellItem:item];

    [self setQh_eventBridge:context.notificationCenter];
}

@end
