//
//  QHNetworkApiManager.h
//  QHCoreLib
//
//  Created by changtang on 2017/10/23.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>
#import <QHCoreLib/QHNetworkApi.h>

NS_ASSUME_NONNULL_BEGIN

QH_EXTERN NSString * const QHNetworkApiManagerApiSucceedNotification;
QH_EXTERN NSString * const QHNetworkApiManagerApiFailedNotification;
QH_EXTERN NSString * const QHNetworkApiManagerUserInfoApiKey;
QH_EXTERN NSString * const QHNetworkApiManagerUserInfoResultKey;
QH_EXTERN NSString * const QHNetworkApiManagerUserInfoErrorKey;

@interface QHNetworkApiManager : NSObject

+ (void)cancelAll;

+ (void)addApi:(QHNetworkApi *)api;

@end

NS_ASSUME_NONNULL_END
