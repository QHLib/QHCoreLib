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

@property (nonatomic, assign) NSInteger rowId;

@end

@implementation QHListTestTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rowId = 0;

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
          [[UIBarButtonItem alloc] initWithTitle:@"delete"
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(delete)],
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

- (void)delete
{
    
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

    cell.textLabel.text = [self textForIndexPath:indexPath];

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

- (NSString *)nextRowId
{
    return $(@"r%d", (int)self.rowId++);
}

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    return $(@"%d-%d", (int)indexPath.section, (int)indexPath.row);
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

- (void)listGroupDataReloadAll:(id<QHListGroupData>)listGroupData
{
    [self.tableView reloadData];
}

- (void)listGroupDataWillBeginChange:(id<QHListGroupData>)listGroupData
{
    [self.tableView beginUpdates];
}

- (void)listGroupData:(id<QHListGroupData>)listGroupData
     didChangeSection:(id<QHListSimpleData> _Nullable)section
           changeType:(QHListSectionChangeType)changeType
             oldIndex:(NSUInteger)oldSectionIndex
             newIndex:(NSUInteger)newSectionIndex
{
    switch (changeType) {
        case QHListSectionChangeTypeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newSectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case QHListSectionChangeTypeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:oldSectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }

        case QHListSectionChangeTypeUpdate: {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:oldSectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }

        default:
            break;
    }
}

- (void)listGroupData:(id<QHListGroupData>)listGroupData
    didChangeListItem:(id)listItem
           changeType:(QHListItemChangeType)changeType
         oldIndexPath:(NSIndexPath * _Nullable)oldIndexPath
         newIndexPath:(NSIndexPath * _Nullable)newIndexPath
{
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

- (void)listGroupDataDidFinishChange:(id<QHListGroupData>)listGroupData
{
    [self.tableView endUpdates];
}

@end
