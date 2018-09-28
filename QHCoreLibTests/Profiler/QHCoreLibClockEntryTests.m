//
//  QHCoreLibClockEntryTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsserts.h"
#import "QHClockEntry.h"


@interface QHCoreLibClockEntryTests : XCTestCase

@end

@implementation QHCoreLibClockEntryTests

- (void)testClockEntryNormal
{
    QHClockEntry *clock = [[QHClockEntry alloc] init];
    [clock start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSLog(@"elapsed: %d ms", [clock elapsedTimeInMiliseconds]);

        [clock end];

        NSLog(@"spent: %d ms", [clock spentTimeInMiliseconds]);
    });
}

- (void)testClockEntryAbnormal
{
//    QHSetAssertFunction(^(NSString *condition,
//                          NSString *fileName,
//                          NSNumber *lineNumber,
//                          NSString *function,
//                          NSString *message) {
//        @throw [NSException exceptionWithName:@"AssertFailException"
//                                       reason:message
//                                     userInfo:nil];
//    });
//
//    QHClockEntry *clock = [[QHClockEntry alloc] init];
//
//    QH_XCTAssertThrows_On_DEBUG([clock end]);
//    QH_XCTAssertThrows_On_DEBUG([clock elapsedTimeInMiliseconds]);
//    QH_XCTAssertThrows_On_DEBUG([clock spentTimeInMiliseconds]);
//
//    [clock start];
//
//    QH_XCTAssertThrows_On_DEBUG([clock start]);
//    XCTAssertNoThrow([clock elapsedTimeInMiliseconds]);
//    QH_XCTAssertThrows_On_DEBUG([clock spentTimeInMiliseconds]);
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [clock end];
//
//        XCTAssertNoThrow([clock start]);
//        XCTAssertThrows([clock elapsedTimeInMiliseconds]);
//        XCTAssertNoThrow([clock spentTimeInMiliseconds]);
//
//        QHSetAssertFunction(nil);
//    });
}


@end
