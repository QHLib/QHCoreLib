//
//  QHListDataEntranceController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListDataEntranceController.h"
#import "QHListSimpleDataTestController.h"
#import "QHListDataLoaderTestController.h"
#import "QHListCommonDataTestController.h"

@interface QHListDataEntranceController ()

@end

@implementation QHListDataEntranceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controllerTitles = [NSArray arrayWithObjects:
                             @"QHListSimpleData",
                             @"QHListDataLoader",
                             @"QHListCommonData",
                             nil];
    self.controllerClasses= [NSArray arrayWithObjects:
                             [QHListSimpleDataTestController class],
                             [QHListDataLoaderTestController class],
                             [QHListCommonDataTestController class],
                             nil];
}

@end
