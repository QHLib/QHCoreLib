//
//  AppDelegate.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"

#import <QHCoreLib/QHCoreLib.h>


@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;

    [QHNetwork sharedInstance];

    [self p_testNetworkIndicator];

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


#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
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
