//
//  QHCoreLibLogTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

@import QHCoreLib.QHLog;


@interface QHCoreLibLogTests : XCTestCase

@end

@implementation QHCoreLibLogTests

- (void)logAll
{
    QHLogError(@"log error");
    QHLogWarn(@"log warn");
    QHLogInfo(@"log info");
    QHLogDebug(@"log debug");
    QHLogVerbose(@"log verbose");
}

- (void)testLog
{
#if DEBUG
    [self logAll];
    // log all
#else
    [self logAll];
    // log info & warn & error
#endif
}

- (void)testSetLogLEvel
{
    DDLogLevel level = QHLogLevel;
    QHSetLogLevel(DDLogLevelWarning);
    [self logAll];
    // log only warn & error

    QHSetLogLevel(level);
}

@end
