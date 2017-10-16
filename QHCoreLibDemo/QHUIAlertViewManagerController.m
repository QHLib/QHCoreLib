//
//  QHUIAlertViewManagerController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUIAlertViewManagerController.h"
#import "QHUIAlertViewManager.h"

@interface QHUIAlertViewManagerController ()

@end

@implementation QHUIAlertViewManagerController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"test"
                                                        message:@"tessssssst"
                                                       delegate:nil
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"ok1", @"ok2", nil];
    QHUIAlertViewManager *manager = [QHUIAlertViewManager managerForAlertView:alertView
                                                                      handler:^(NSUInteger buttonIndex) {
                                                                          NSLog(@"%d", (int)buttonIndex);
                                                                      }];
    [manager autoManage];
    [manager.alertView show];
}

@end
