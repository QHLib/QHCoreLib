//
//  QHNetworkReachabilityManager.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/9/3.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHNetworkReachabilityManager.h"

#import "QHBase.h"
#import "QHLog.h"

#import <netinet/in.h>


typedef void(^QHNetworkReachabilityStatusBlock)(QHNetworkReachabilityStatus status);

static QHNetworkReachabilityStatus QHNetworkReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags)
{
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    QHNetworkReachabilityStatus status = QHNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = QHNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = QHNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = QHNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void QHNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info)
{
    QHNetworkReachabilityStatus status = QHNetworkReachabilityStatusFromFlags(flags);
    QHNetworkReachabilityStatusBlock block = (__bridge QHNetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }
}

static const void *QHNetworkReachabilityContextRetain(const void *info)
{
    return Block_copy(info);
}

static void QHNetworkReachabilityContextRelease(const void *info)
{
    if (info) {
        Block_release(info);
    }
}


@interface QHNetworkReachabilityManager ()

@property (nonatomic, unsafe_unretained) SCNetworkReachabilityRef scReachability;

@property (nonatomic, assign, readwrite) QHNetworkReachabilityStatus status;

@property (nonatomic, copy) QHNetworkReachabilityStatusBlock statusBlock;

@end

@implementation QHNetworkReachabilityManager

+ (instancetype)defaultManager
{
    static QHNetworkReachabilityManager *manager;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         This monitors the address 0.0.0.0, which reachability treats as a special
         token that causes it to actually monitor the general routing status of the
         device, both IPv4 and IPv6.
         see ReadeMe.md from
         https://developer.apple.com/library/content/samplecode/Reachability/Introduction/Intro.html
         */
        struct sockaddr_in zeroAddress;
        memset(&zeroAddress, 0, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;

        manager = [self managerForAddress:(const void *)&zeroAddress];
    });

    return manager;
}

+ (instancetype)managerForDomain:(NSString *)domain
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    QHNetworkReachabilityManager *manager = [[QHNetworkReachabilityManager alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    
    QHNetworkReachabilityManager *manager  = [[QHNetworkReachabilityManager alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability
{
    self = [super init];
    if (self) {
        self.scReachability = reachability;
        CFRetain(reachability);
        
        self.status = QHNetworkReachabilityStatusUnknown;
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
    
    if (self.scReachability) {
        CFRelease(self.scReachability);
        self.scReachability = nil;
    }
}

#pragma mark -

- (BOOL)isReachable
{
    return [self isReachableViaWiFi] || [self isReachableViaWWAN];
}

- (BOOL)isReachableViaWiFi
{
    return self.status == QHNetworkReachabilityStatusReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN
{
    return self.status == QHNetworkReachabilityStatusReachableViaWWAN;
}

#pragma mark  -

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"reachable"]
        || [key isEqualToString:@"reachableViaWiFi"]
        || [key isEqualToString:@"reachableViaWWAN"]) {
        return [NSSet setWithObject:@"status"];
    }
    return [super keyPathsForValuesAffectingValueForKey:key];
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(QHNetworkReachabilityStatusBlock)block
{
    self.statusBlock = block;
}

- (void)startMonitoring
{
    [self stopMonitoring];
    
    if (!self.scReachability) {
        return;
    }
    
    @weakify(self);
    QHNetworkReachabilityStatusBlock callback = ^(QHNetworkReachabilityStatus status) {
        @strongify(self);
        
        self.status = status;
        if (self.statusBlock) {
            self.statusBlock(status);
        }
    };
    
    SCNetworkReachabilityContext context = {
        0,
        (__bridge void *)callback,
        QHNetworkReachabilityContextRetain,
        QHNetworkReachabilityContextRelease,
        NULL
    };
    SCNetworkReachabilitySetCallback(self.scReachability, QHNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.scReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    QHDispatchSyncMainSafe(^{
        SCNetworkReachabilityFlags flags;
        if (!SCNetworkReachabilityGetFlags(self.scReachability, &flags)) {
            QHLogInfo(@"get network status initial value failed");
            return;
        }
        QHNetworkReachabilityStatus status = QHNetworkReachabilityStatusFromFlags(flags);
        callback(status);
    });
}

-  (void)stopMonitoring
{
    if (!self.scReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.scReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

@end
