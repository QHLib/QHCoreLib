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
    
    self.view.backgroundColor = [[UIColor whiteColor] qh_blendWithColor:[UIColor blackColor] alpha:0.5];

    {
        QHHintBadge *smallHint = [[QHHintBadge alloc] initWithDiameter:10.0];
        smallHint.origin = CGPointMake(10, 100);
        [self.view addSubview:smallHint];

        QHHintBadge *bigHint = [[QHHintBadge alloc] initWithDiameter:20.0];
        bigHint.origin = CGPointMake(30, 100);
        [self.view addSubview:bigHint];

        QHDispatchDelayMain(3.0, ^{
            [UIView animateWithDuration:0.2 animations:^{
                [bigHint setDiameter:15.0];
            }];
        });

        QHNumberBadgeConfiguration *config = [[QHNumberBadgeConfiguration alloc] init];
        QHNumberBadge *numberBadge = [[QHNumberBadge alloc] initWithConfiguration:config];
        numberBadge.origin = CGPointMake(60, 100);
        [numberBadge setBadgeNumber:1];
        [self.view addSubview:numberBadge];

        QHDispatchDelayMain(1.0, ^{
            [numberBadge setBadgeNumber:99];
        });

        QHDispatchDelayMain(2.0, ^{
            [numberBadge setBadgeNumber:100];
        });
    }

    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 20, 20)];
        [self.view addSubview:view];
        view.backgroundColor = [UIColor redColor];
        QHDispatchDelayMain(1.0, ^{
            view.backgroundColor = [UIColor greenColor];
            [view qh_lockBackgroundColor];
        });

        QHDispatchDelayMain(2.0, ^{
            view.backgroundColor = [UIColor blueColor];
            NSLog(@"background color is still green: %@",
                  @(view.backgroundColor == [UIColor greenColor]));
        });

        QHDispatchDelayMain(3.0, ^{
            [view qh_unlockBackgroundColor];
            view.backgroundColor = [UIColor blueColor];
        });
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"test"
                                                        message:@"tessssssst"
                                                       delegate:nil
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"ok1", @"ok2", nil];
    [alertView showWithHandler:^(NSUInteger buttonIndex) {
        NSLog(@"clicked at index: %d", (int)buttonIndex);
    }];
}

@end
