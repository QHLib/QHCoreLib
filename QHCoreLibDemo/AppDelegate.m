//
//  AppDelegate.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "AppDelegate.h"

#import <QHCoreLib/QHCoreLib.h>

#import "EntranceViewController.h"
#import "QHListDataEntranceController.h"
#import "QHUIWidgetsController.h"
#import "QHTableViewCellTestController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    QH_SUBCLASS_MUST_OVERRIDE_CHECK;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = ({
        EntranceViewController *entranceController = [EntranceViewController new];
        entranceController.controllerTitles = [NSArray arrayWithObjects:
                                               @"QHList",
                                               @"QHUIWidgets",
                                               @"QHTableViewCell",
                                               nil];
        entranceController.controllerClasses = [NSArray arrayWithObjects:
                                                [QHListDataEntranceController class],
                                                [QHUIWidgetsController class],
                                                [QHTableViewCellTestController class],
                                                nil];
        
        [[UINavigationController alloc] initWithRootViewController:entranceController];
    });
    [self.window makeKeyAndVisible];

    [QHNetwork sharedInstance];
#if 0
#warning testing network indicator with polling
    [self p_testNetworkIndicator];
#endif

    {
        NSDate *date = [NSDate date];
        NSLog(@"weekNumber: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekNumber]);
        NSLog(@"weekStringShort: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringShort]);
        NSLog(@"weekStringLong: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringLong]);
    }

    NSLog(@"launch image is %@", [UIImage qh_lanchImage]);

    NSLog(@"%@", [QHPathUtil filePathInDocument:@"aaa"]);
    NSLog(@"%@", [QHPathUtil filePathInLibrary:@"bbb"]);
    NSLog(@"%@", [QHPathUtil filePathInCache:@"bbb"]);
    NSLog(@"%@", [QHPathUtil filePathInTemp:@"ccc"]);

    // 单元测试跑不起来，先暂时放这里。
    // 长度不对
    QHAssert(QHMobilePhoneNumberCheck(@"133") == NO, @"");
    // 号段不对
    QHAssert(QHMobilePhoneNumberCheck(@"123") == NO, @"");

    QHAssert(QHMobilePhoneNumberCheck(@"13800000000") == YES, @"");

    NSLog(@"%@", [QHNetworkUtil appendQuery:@{ @"a": @"b?c=123" }
                                      toUrl:@"http://hhhh"]);

//    [self p_testHttpsCertTrust];

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

- (void)p_testHttpsCertTrust
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"der"];
    [[QHNetwork sharedInstance] setTrustCerts:@[ filePath ]];
    static QHNetworkHtmlApi *api = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://server-domain"]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:15];
    api = [[QHNetworkHtmlApi alloc] initWithUrlRequest:request];
    [api startWithSuccess:^(QHNetworkHtmlApi * _Nonnull api, QHNetworkHtmlApiResult * _Nonnull result) {
        NSLog(@"html: %@", result.html);
    } fail:^(QHNetworkHttpApi * _Nonnull api, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

@end
