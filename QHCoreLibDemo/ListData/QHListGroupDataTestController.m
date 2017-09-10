//
//  QHListGroupDataTestController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListGroupDataTestController.h"

#import <QHCoreLib/QHCoreLib.h>

@interface QHListGroupDataTestController ()

@property (nonatomic, strong) QHListGroupData<NSString *> *listData;

@end

@implementation QHListGroupDataTestController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listData = [QHListGroupData new];
    self.listData.delegate = self;
}

- (void)add
{
    if ([self.tableView isEditing] == NO) {
        NSArray *listData = @[ @"aaa", @"bbb", @"ccc" ];

        QHListSimpleData *list = [[QHListSimpleData alloc] initWithListData:listData];
        [self.listData appendSections:@[ list ]];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.listData setSectionAtIndex:self.listData.numberOfSections - 1
                                 withSection:({
                QHListSimpleData *newListData = [[QHListSimpleData alloc] initWithListData:({
                    [listData qh_mappedArrayWithBlock:^id _Nonnull(NSUInteger idx, id  _Nonnull obj) {
                        return $(@"%@...", obj);
                    }];
                })];
                [newListData setHeadItem:@"hhhhh"];
                [newListData setFootItem:@"fffff"];
                newListData;
            })];
        });
    }
    else {
        QHListSimpleData *lastSection = [self.listData sectionAtIndex:self.listData.numberOfSections - 1];
        [self.listData beginUpdate];
        [lastSection insertListData:@[ @"-----" ] atIndex:0];
        [lastSection appendListData:@[ @"_____"] ];
        [self.listData endUpdate];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [lastSection setListItemAtIndex:0 withListItem:@"----------...."];
        });
    }
}

- (void)delete
{
    if ([self.tableView isEditing] == NO) {
        if (self.listData.numberOfSections) {
            [self.listData deleteSectionsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    else {
        QHListSimpleData *lastSection = [self.listData sectionAtIndex:self.listData.numberOfSections - 1];
        if (lastSection.numberOfItems) {
            [self.listData beginUpdate];
            [lastSection deleteListItemAtIndexes:[NSIndexSet indexSetWithIndex:0]];
            [self.listData endUpdate];
        }
    }
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.listData numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listData numberOfRowsInSection:section];
}

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    return $(@"%@, %@",
             [super textForIndexPath:indexPath],
             [self.listData listItemAtIndexPath:indexPath]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *head = [self.listData headItemForSection:section];
    if (head) {
        UILabel *label = [[UILabel alloc] init];
        label.text = head;
        [label sizeToFit];
        return label;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *foot = [self.listData footItemForSection:section];
    if (foot) {
        UILabel *label = [[UILabel alloc] init];
        label.text = foot;
        [label sizeToFit];
        return label;
    }
    return nil;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.listData beginUpdate];
        [self.listData deleteListItemAtIndexPathes:[NSSet setWithObject:indexPath]];
        [self.listData endUpdate];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.listData moveListItemFromIndexPath:sourceIndexPath
                                 toIndexPath:destinationIndexPath
                                shouldNotify:NO];
}

@end
