//
//  TableViewController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "TableViewController.h"
#import "QHListSimpleDataTestControler.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray<NSString *> *controllerTitles;
@property (nonatomic, strong) NSArray<Class> *controllerClasses;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.controllerTitles = [NSArray arrayWithObjects:
                             @"QHListSimpleData",
                             nil];
    self.controllerClasses= [NSArray arrayWithObjects:
                             [QHListSimpleDataTestControler class],
                             nil];

    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"reuse"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.controllerTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.controllerTitles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class controllerClass = [self.controllerClasses objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[controllerClass new]
                                         animated:YES];
}

@end
