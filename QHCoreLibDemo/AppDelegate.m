//
//  AppDelegate.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AppDelegate.h"

#import <QHCoreLib/QHCoreLib.h>

#import "EntranceViewController.h"
#import "QHListDataEntranceController.h"
#import "QHUIWidgetsController.h"
#import "QHUIAlertViewManagerController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = ({
        EntranceViewController *entranceController = [EntranceViewController new];
        entranceController.controllerTitles = [NSArray arrayWithObjects:
                                               @"QHList",
                                               @"QHUIWidgets",
                                               @"QHUIAlertViewManager",
                                               nil];
        entranceController.controllerClasses = [NSArray arrayWithObjects:
                                                [QHListDataEntranceController class],
                                                [QHUIWidgetsController class],
                                                [QHUIAlertViewManagerController class],
                                                nil];
        
        [[UINavigationController alloc] initWithRootViewController:entranceController];
    });
    [self.window makeKeyAndVisible];

    [QHNetwork sharedInstance];

    NSDate *date = [NSDate date];
    NSLog(@"weekNumber: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekNumber]);
    NSLog(@"weekStringShort: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringShort]);
    NSLog(@"weekStringLong: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringLong]);

#if 0
#warning testing network indicator with polling
    [self p_testNetworkIndicator];
#endif

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[QHNetwork sharedInstance] startMonitoring];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[QHNetwork sharedInstance] stopMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

#pragma mark -

- (void)p_testNetworkIndicator
{
    [QHNetworkActivityIndicator sharedInstance].enabled = YES;
    [[QHNetworkActivityIndicator sharedInstance] setCallback:^(BOOL isVisible) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isVisible];
    }];

    [self p_sendReqeust];
}

- (void)p_sendReqeust
{
    QHNetworkApi *testApi = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"];
    [testApi startWithSuccess:^(QHNetworkApi * _Nonnull api, QHNetworkApiResult * _Nonnull result) {
        QHLogDebug(@"%@ succeed", testApi);

        {
            QHNetworkApi *testApi = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"];
            [testApi startWithSuccess:^(QHNetworkApi * _Nonnull api, QHNetworkApiResult * _Nonnull result) {
                QHLogDebug(@"%@ succeed", testApi);
            } fail:^(QHNetworkApi * _Nonnull api, NSError * _Nonnull error) {
                QHLogDebug(@"%@ error: %@", testApi, error);
            }];
        }
    } fail:^(QHNetworkApi * _Nonnull api, NSError * _Nonnull error) {
        QHLogDebug(@"%@ error: %@", testApi, error);
    }];

    [self performSelector:@selector(p_sendReqeust) withObject:nil afterDelay:3.0];
}

@end
