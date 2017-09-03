//
//  QHNetwork.m
//  QQHouse
//
//  Created by leis on 15-08-11.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "QHNetwork.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "QHNetworkReachabilityManager.h"

#import "QHLog.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHNetworkStatusChangedNotification = @"QHNetworkStatusChangedNotification";

NSString * const kQHNetworkStatusStringNotReachable = @"NotReachable";
NSString * const kQHNetworkStatusStringUnknown      = @"Unknown";
NSString * const kQHNetworkStatusStringWWAN         = @"WWAN";
NSString * const kQHNetworkStatusStringWiFi         = @"WiFi";

NSString * const kQHNetworkStatusStringWWAN2G       = @"2G";
NSString * const kQHNetworkStatusStringWWAN3G       = @"3G";
NSString * const kQHNetworkStatusStringWWAN4G       = @"4G";


@interface QHNetwork ()

@property (nonatomic, assign) QHNetworkStatus networkStatus;

@property (nonatomic, strong) CTTelephonyNetworkInfo *wwanInfo;

@property (nonatomic, assign) BOOL hasProxySettings;

@end

@implementation QHNetwork

QH_SINGLETON_IMP

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_initForStatus];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - status


- (void)p_initForStatus
{
    _networkStatus = QHNetworkStatusUnknown;
    _wwanInfo = [[CTTelephonyNetworkInfo alloc] init];

    QHNetworkReachabilityManager *manager = [QHNetworkReachabilityManager defaultManager];
    [manager setReachabilityStatusChangeBlock:^(QHNetworkReachabilityStatus status) {
        switch (status) {
            case QHNetworkReachabilityStatusUnknown:
                self.networkStatus = QHNetworkStatusUnknown;
                break;
            case QHNetworkReachabilityStatusNotReachable:
                self.networkStatus = QHNetworkStatusNotReachable;
                break;
            case QHNetworkReachabilityStatusReachableViaWWAN:
                self.networkStatus = QHNetworkStatusReachableViaWWAN;
                break;
            case QHNetworkReachabilityStatusReachableViaWiFi:
                self.networkStatus = QHNetworkStatusReachableViaWiFi;
                break;
            default:
                QHLogWarn(@"Unknown network status from QHNetworkReachabilityManager : %d", (int)status);
                break;
        }

        [self reloadProxyStatus];
    }];
    [manager startMonitoring];
}

- (void)reloadProxyStatus
{
    CFDictionaryRef settingsRef = CFNetworkCopySystemProxySettings();
    if (settingsRef) {
        NSDictionary *settings = CFBridgingRelease(settingsRef);
        NSInteger hasHTTPProxy = QHInteger(settings[(__bridge NSString *)kCFNetworkProxiesHTTPEnable], 0);
        NSInteger hasAutoProxy = QHInteger(settings[(__bridge NSString *)kCFNetworkProxiesProxyAutoConfigEnable], 0);
        BOOL hasProxy = hasHTTPProxy != 0 || hasAutoProxy != 0;
        self.hasProxySettings = hasProxy;

        QHLogInfo(@"proxy setting: http %zd, auto %zd", hasHTTPProxy, hasAutoProxy);
    } else {
        self.hasProxySettings = NO;

        QHLogInfo(@"no proxy settings");
    }
}

- (void)setNetworkStatus:(QHNetworkStatus)networkStatus
{
    if (networkStatus == _networkStatus) {
        return;
    }

    QHLogInfo(@"Network status changed from %@ to %@", [self p_statusStringFromStatus:_networkStatus], [self p_statusStringFromStatus:networkStatus]);
    
    QHNetworkStatus oldStatus = _networkStatus;
    _networkStatus = networkStatus;
    
    if (oldStatus != QHNetworkStatusUnknown) {

        [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkStatusChangedNotification
                                                            object:nil];
    }
}

- (NSString *)p_wwanStatusString
{
    if (self.wwanInfo.currentRadioAccessTechnology != nil) {
        return [@{ CTRadioAccessTechnologyGPRS          : kQHNetworkStatusStringWWAN2G,
                   CTRadioAccessTechnologyEdge          : kQHNetworkStatusStringWWAN2G,

                   CTRadioAccessTechnologyWCDMA         : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyHSDPA         : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyHSUPA         : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyCDMA1x        : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyCDMAEVDORev0  : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyCDMAEVDORevA  : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyCDMAEVDORevB  : kQHNetworkStatusStringWWAN3G,
                   CTRadioAccessTechnologyeHRPD         : kQHNetworkStatusStringWWAN3G,

                   CTRadioAccessTechnologyLTE           : kQHNetworkStatusStringWWAN4G,
                   } objectForKey:(self.wwanInfo.currentRadioAccessTechnology ?: @"")];
    }
    
    return kQHNetworkStatusStringWWAN;
}

- (NSString *)p_statusStringFromStatus:(QHNetworkStatus)status
{
    static NSArray *statusStringArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statusStringArray = @[ kQHNetworkStatusStringNotReachable,
                               kQHNetworkStatusStringUnknown,
                               kQHNetworkStatusStringWWAN,
                               kQHNetworkStatusStringWiFi,
                               ];
    });

    if (status < 0 || status >= statusStringArray.count) {
        return @"";
    }

    NSString *statusString = statusStringArray[status];

    if ([statusString isEqualToString:kQHNetworkStatusStringWWAN]) {
        statusString = [self p_wwanStatusString];
    }

    if (!statusString) {
        statusString = @"";
        QHLogError(@"Invalid status %d for status string", (int)status);
    }
    
    return statusString;
}

- (QHNetworkStatus)status
{
    return self.networkStatus;
}

- (NSString *)statusString
{
    return [self p_statusStringFromStatus:self.networkStatus];
}

- (BOOL)isAvailable
{
    return self.networkStatus != QHNetworkStatusNotReachable;
}

- (BOOL)isEnableProxy
{
    return self.hasProxySettings;
}

- (void)startMonitoring
{
    [[QHNetworkReachabilityManager defaultManager] startMonitoring];
}

- (void)stopMonitoring
{
    [[QHNetworkReachabilityManager defaultManager] stopMonitoring];
}

- (void)cancelAll
{
    [QHNetworkWorker cancelAll];
}

@end

NS_ASSUME_NONNULL_END
