//
//  QHNetworkApiManager.m
//  QHCoreLib
//
//  Created by changtang on 2017/10/23.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkApiManager.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const QHNetworkApiManagerApiSucceedNotification = @"QHNetworkApiManagerApiSucceedNotification";
NSString * const QHNetworkApiManagerApiFailedNotification = @"QHNetworkApiManagerApiFailedNotification";
NSString * const QHNetworkApiManagerUserInfoApiKey = @"QHNetworkApiManagerUserInfoApiKey";
NSString * const QHNetworkApiManagerUserInfoResultKey = @"QHNetworkApiManagerUserInfoResultKey";
NSString * const QHNetworkApiManagerUserInfoErrorKey = @"QHNetworkApiManagerUserInfoErrorKey";

static NSMutableSet<QHNetworkApi *> *apiHolder = nil;

QH_EXTERN NSString * const UIApplicationDidEnterBackgroundNotification;

@implementation QHNetworkApiManager

+ (void)initialize
{
    apiHolder = [NSMutableSet set];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [QHNetworkApiManager cancelAll];
                                                  }];
}

+ (void)cancelAll
{
    [apiHolder enumerateObjectsUsingBlock:^(QHNetworkApi * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [apiHolder removeAllObjects];
}

+ (void)addApi:(QHNetworkApi *)api
{
    QHAssertReturnVoidOnFailure(api != nil, @"api must not be nil");

    [apiHolder addObject:api];
    [api startWithSuccess:^(QHNetworkApi * _Nonnull api, QHNetworkApiResult * _Nonnull result) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo qh_setObject:api forKey:QHNetworkApiManagerUserInfoApiKey];
        [userInfo qh_setObject:result forKey:QHNetworkApiManagerUserInfoResultKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkApiManagerApiSucceedNotification
                                                            object:nil];
        [apiHolder removeObject:api];
    } fail:^(QHNetworkApi * _Nonnull api, NSError * _Nonnull error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo qh_setObject:api forKey:QHNetworkApiManagerUserInfoApiKey];
        [userInfo qh_setObject:error forKey:QHNetworkApiManagerUserInfoErrorKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkApiManagerApiFailedNotification
                                                            object:nil];
        [apiHolder removeObject:api];
    }];
}

@end

NS_ASSUME_NONNULL_END
