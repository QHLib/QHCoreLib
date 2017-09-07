//
//  QHListSimpleDataTestControler.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListSimpleDataTestControler.h"

#import <QHCoreLib/QHCoreLib.h>


@interface QHListSimpleDataTestControler () <QHListSimpleDataDelegate>

@property (nonatomic, strong) QHListSimpleData<NSString *> *listData;

@end

@implementation QHListSimpleDataTestControler

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listData = [[QHListSimpleData alloc] init];
    self.listData.delegate = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.listData setListData:@[ @"", @"", @"" ]];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.numberOfItems;
}

- (void)add
{
    [self.listData p_appendList:@[ @"" ]];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.row];
        [self.listData p_listRemoveAtIndexes:indexSet];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.listData p_listMoveFromIndex:sourceIndexPath.row
                               toIndex:destinationIndexPath.row
                          shouldNotify:NO];
}

@end
