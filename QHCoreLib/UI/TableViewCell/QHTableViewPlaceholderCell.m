//
//  QHTableViewPlaceholderCell.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/28.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewPlaceholderCell.h"
#import "UITableViewCell+QHTableViewCell.h"
#import "QHBase.h"

@implementation QHTableViewPlaceholderCell

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item
                    context:(QHTableViewCellContext *)context
{
    QH_AS(item.data, NSNumber, height);
    return height ? [height doubleValue] : 44.0;
}

- (void)qh_configure:(QHTableViewCellItem *)item
             context:(QHTableViewCellContext *)context
{
    [super qh_configure:item context:context];

    QH_AS(item.data, NSNumber, height);

    self.textLabel.text = $(@"cell %d-%d, heigth: %f",
                            (int)context.indexPath.section,
                            (int)context.indexPath.row,
                            height ? [height doubleValue] : 44.0);
    [self.textLabel sizeToFit];
}

@end
