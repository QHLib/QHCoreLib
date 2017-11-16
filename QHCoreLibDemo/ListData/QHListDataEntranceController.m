//
//  QHListDataEntranceController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/8.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListDataEntranceController.h"
#import "QHListSimpleDataTestController.h"
#import "QHListDataLoaderTestController.h"
#import "QHListCommonDataTestController.h"
#import "QHListGroupDataTestController.h"

@interface QHListDataEntranceController ()

@end

@implementation QHListDataEntranceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controllerTitles = [NSArray arrayWithObjects:
                             @"QHListSimpleData",
                             @"QHListDataLoader",
                             @"QHListCommonData",
                             @"QHListGroupData",
                             nil];
    self.controllerClasses= [NSArray arrayWithObjects:
                             [QHListSimpleDataTestController class],
                             [QHListDataLoaderTestController class],
                             [QHListCommonDataTestController class],
                             [QHListGroupDataTestController class],
                             nil];
}

@end
