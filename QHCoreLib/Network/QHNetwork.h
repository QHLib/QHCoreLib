//
//  QHNetwork.h
//  QQHouse
//
//  Created by lei on 15-08-11.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QHDefines.h"


QH_EXTERN NSString * const QHNetworkStatusChangedNotification;

typedef NS_ENUM(NSInteger, QHNetworkStatus) {
    QHNetworkStatusNotReachable        = 0,
    QHNetworkStatusUnknown             = 1,
    QHNetworkStatusReachableViaWWAN    = 2,
    QHNetworkStatusReachableViaWiFi    = 3,
};

QH_EXTERN NSString * const kQHNetworkStatusStringNotReachable;
QH_EXTERN NSString * const kQHNetworkStatusStringUnknown;
QH_EXTERN NSString * const kQHNetworkStatusStringWWAN;
QH_EXTERN NSString * const kQHNetworkStatusStringWiFi;

QH_EXTERN NSString * const kQHNetworkStatusStringWWAN2G;
QH_EXTERN NSString * const kQHNetworkStatusStringWWAN3G;
QH_EXTERN NSString * const kQHNetworkStatusStringWWAN4G;


@interface QHNetwork : NSObject

QH_SINGLETON_DEF

@property (nonatomic, readonly) QHNetworkStatus status;

@property (nonatomic, readonly) NSString *statusString;

@property (nonatomic, readonly) BOOL isAvailable;

@property (nonatomic, readonly) BOOL isEnableProxy;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
