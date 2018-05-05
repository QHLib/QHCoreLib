//
//  UICollectionViewCell+QHCollectionViewCell.m
//  QHCoreLib
//
//  Created by changtang on 2017/12/9.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "UICollectionViewCell+QHCollectionViewCell.h"
#import "QHBase+internal.h"

@implementation UICollectionViewCell (QHCollectionViewCell)

static void *kQHCollectionViewCellItemASOKey = &kQHCollectionViewCellItemASOKey;

- (id)qh_data
{
    return objc_getAssociatedObject(self, kQHCollectionViewCellItemASOKey);
}

- (void)setQh_data:(id _Nullable)qh_data
{
    [self willChangeValueForKey:QH_PROPETY_NAME(qh_data)];
    objc_setAssociatedObject(self,
                             kQHCollectionViewCellItemASOKey,
                             qh_data,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:QH_PROPETY_NAME(qh_data)];
}

static void *kQHCollectionViewCellEventBridgeASOKey = &kQHCollectionViewCellEventBridgeASOKey;

- (NSNotificationCenter *)qh_eventBridge
{
    return objc_getAssociatedObject(self,
                                    kQHCollectionViewCellEventBridgeASOKey);
}

- (void)setQh_eventBridge:(NSNotificationCenter * _Nullable)qh_eventBridge
{
    objc_setAssociatedObject(self,
                             kQHCollectionViewCellEventBridgeASOKey,
                             qh_eventBridge,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)qh_configure:(id)data
             context:(QHCollectionViewCellContext *)context
{
    [self setQh_data:data];

    [self setQh_eventBridge:context.notificationCenter];
}

@end
