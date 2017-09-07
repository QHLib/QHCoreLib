//
//  QHListTestTableViewController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListTestTableViewController.h"
#import <QHCoreLib/QHCoreLib.h>

@interface QHListTestTableViewController ()

@end

@implementation QHListTestTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"reuse"];

    self.navigationItem.rightBarButtonItems = ({
        @[
          [[UIBarButtonItem alloc] initWithTitle:@"add"
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(add)],
          [[UIBarButtonItem alloc] initWithTitle:@"edit"
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(edit)],
          ];
    }) ;

}

- (void)add
{

}

- (void)edit
{
    [self.tableView setEditing:!self.tableView.isEditing
                      animated:YES];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];

    cell.textLabel.text = $(@"%d-%d", (int)indexPath.section, (int)indexPath.row);

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{

}

#pragma mark -

- (void)listSimpleDataReload:(id<QHListSimpleData>)listSimpleData
{
    [self.tableView reloadData];
}

- (void)listSimpleDataWillBeginChange:(id<QHListSimpleData>)listSimpleData
{
    [self.tableView beginUpdates];
}

- (void)listSimpleData:(id<QHListSimpleData>)listSimpleData
     didChangeListItem:(id)listItem
            changeType:(QHListItemChangeType)changeType
              oldIndex:(NSUInteger)oldIndex
              newIndex:(NSUInteger)newIndex
{
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    switch (changeType) {
        case QHListItemChangeTypeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath  ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }

        case QHListItemChangeTypeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[ oldIndexPath ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }

        case QHListItemChangeTypeMove: {
            [self.tableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
            break;
        }

        case QHListItemChangeTypeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[ oldIndexPath ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }

        default:
            break;
    }
}

- (void)listSimpleDataDidFinishChange:(id<QHListSimpleData>)listSimpleData
{
    [self.tableView endUpdates];
}

#pragma mark -

@end
