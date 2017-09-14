//
//  QHUIWidgetsController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUIWidgetsController.h"
#import <QHCoreLib/QHCoreLib.h>

@interface QHUIWidgetsController ()

@end

@implementation QHUIWidgetsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    QHHintBadge *smallHint = [[QHHintBadge alloc] initWithDiameter:10.0];
    smallHint.origin = CGPointMake(10, 70);
    [self.view addSubview:smallHint];

    QHHintBadge *bigHint = [[QHHintBadge alloc] initWithDiameter:20.0];
    bigHint.origin = CGPointMake(30, 70);
    [self.view addSubview:bigHint];

    QHDispatchDelayMain(3.0, ^{
        [UIView animateWithDuration:0.2 animations:^{
            [bigHint setDiameter:15.0];
        }];
    });

    QHNumberBadgeConfiguration *config = [[QHNumberBadgeConfiguration alloc] init];
    QHNumberBadge *numberBadge = [[QHNumberBadge alloc] initWithConfiguration:config];
    numberBadge.origin = CGPointMake(60, 70);
    [numberBadge setBadgeNumber:1];
    [self.view addSubview:numberBadge];

    QHDispatchDelayMain(1.0, ^{
        [numberBadge setBadgeNumber:99];
    });

    QHDispatchDelayMain(2.0, ^{
        [numberBadge setBadgeNumber:100];
    });
}

@end
