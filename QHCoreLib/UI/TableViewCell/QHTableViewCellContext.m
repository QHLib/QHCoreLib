//
//  QHTableViewCellContext.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellContext.h"

@implementation QHTableViewCellContext

+ (instancetype)contextFrom:(UITableView *)tableView
                  indexPath:(NSIndexPath *)indexPath
{
    QHTableViewCellContext *context = [QHTableViewCellContext  new];

    context.tableView = tableView;
    context.indexPath = indexPath;

    context.isFirst = (indexPath.row == 0);
    context.isLast = (indexPath.row == (([tableView.dataSource tableView:tableView
                                                   numberOfRowsInSection:indexPath.section]) - 1));

    return context;
}

@end
