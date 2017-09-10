//
//  QHListSimpleDataTestController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListSimpleDataTestController.h"

@interface QHListSimpleDataTestController () <QHListSimpleDataDelegate>

@property (nonatomic, strong) QHListSimpleData<NSString *> *listData;

@end

@implementation QHListSimpleDataTestController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listData = [[QHListSimpleData alloc] init];
    self.listData.delegate = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.listData setListData:@[ [self nextRowId], [self nextRowId], [self nextRowId] ]];
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

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    return $(@"%@, %@",
             [super textForIndexPath:indexPath],
             [self.listData listItemAtIndex:indexPath.row]);
}

- (void)add
{
    [self.listData appendListData:@[ [self nextRowId] ]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.listData[self.listData.numberOfItems - 1] = $(@"%@...", self.listData[self.listData.numberOfItems - 1]);
    });
}

#pragma mark -

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.listData deleteListItemAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.listData moveListItemFromIndex:sourceIndexPath.row
                                 toIndex:destinationIndexPath.row
                            shouldNotify:NO];
}

@end
