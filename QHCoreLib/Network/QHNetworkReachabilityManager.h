//
//  QHNetworkReachabilityManager.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/9/3.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


typedef NS_ENUM(NSUInteger, QHNetworkReachabilityStatus) {
    QHNetworkReachabilityStatusUnknown          = -1,
    QHNetworkReachabilityStatusNotReachable     = 0,
    QHNetworkReachabilityStatusReachableViaWWAN = 1,
    QHNetworkReachabilityStatusReachableViaWiFi = 2,
};

@interface QHNetworkReachabilityManager : NSObject

// manager with zero address, which handles both ipv4 & ipv6
+ (instancetype)defaultManager;

+ (instancetype)managerForDomain:(NSString *)domain;

+ (instancetype)managerForAddress:(const void *)address;

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability;


@property (nonatomic, assign, readonly) QHNetworkReachabilityStatus status;

@property (nonatomic, assign, readonly, getter=isReachable) BOOL reachable;

@property (nonatomic, assign, readonly, getter=isReachableViaWiFi) BOOL reachableViaWiFi;

@property (nonatomic, assign, readonly, getter=isReachableViaWWAN) BOOL reachableViaWWAN;


- (void)setReachabilityStatusChangeBlock:(void(^)(QHNetworkReachabilityStatus status))block;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
