//
//  QHTableViewCellFactory.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellFactory.h"

@interface QHTableViewCellFactory ()

@property (nonatomic, strong) NSMutableDictionary *

@end

@implementation QHTableViewCellFactory

QH_SINGLETON_IMP

- (Class)cellClassForItem:(QHTableViewCellItem *)item
                  context:(QHTableViewCellContext *)context
{
    Class cellClass = NULL;

    if (item.type == QHTableViewCellTypeStatic) {
        cellClass = [context.opaque class];
    }
    else if (item.type == QHTableViewCellTypeDefault) {
        cellClass = [UITableViewCell class];
    }
    else {
        
    }

    if (cellClass == NULL) {
        NSCAssert(NO, @"no cell class found for type: %d", (int)item.type);
        cellClass = [UITableViewCell class];
    }

    return cellClass;
}

- (CGFloat)heightForItem:(QHTableViewCellItem *)item
                 context:(QHTableViewCellContext *)context
{
    Class cellClass = [self cellClassForItem:item context:context];

    return [cellClass qh_heightForItem:item context:context];
}

- (UITableViewCell *)cellForItem:(QHTableViewCellItem *)item
                         context:(QHTableViewCellContext *)context
{
    Class cellClass = [self cellClassForItem:item context:context];

    NSString *reuseIdentifier = ((context.reuseIdentifier
                                  && ((void *)context.reuseIdentifier != (void *)[NSNull null]))
                                 ? context.reuseIdentifier
                                 : [cellClass qh_reuseIdentifier]);
    UITableViewCell *cell = [context.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:reuseIdentifier];
    }

    [cell qh_configure:item context:context];

    return cell;
}

@end
