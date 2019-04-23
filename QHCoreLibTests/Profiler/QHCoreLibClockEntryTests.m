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
#import "QHClockChecker.h"


@interface QHCoreLibClockEntryTests : XCTestCase

@end

@implementation QHCoreLibClockEntryTests

- (void)testClockEntryNormal
{
    XCTestExpectation *expect = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    QHClockEntry *clock = [[QHClockEntry alloc] init];
    [clock start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSLog(@"elapsed: %d ms", [clock elapsedTimeInMiliseconds]);

        [clock end];

        NSLog(@"spent: %d ms", [clock spentTimeInMiliseconds]);

        [expect fulfill];
    });

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testClockEntryAbnormal
{
    XCTestExpectation *expect = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    QHSetAssertFunction(^(NSString *condition,
                          NSString *fileName,
                          NSNumber *lineNumber,
                          NSString *function,
                          NSString *message) {
        @throw [NSException exceptionWithName:@"AssertFailException"
                                       reason:message
                                     userInfo:nil];
    });

    QHClockEntry *clock = [[QHClockEntry alloc] init];

    QH_XCTAssertThrows_On_DEBUG([clock end]);
    QH_XCTAssertThrows_On_DEBUG([clock elapsedTimeInMiliseconds]);
    QH_XCTAssertThrows_On_DEBUG([clock spentTimeInMiliseconds]);

    [clock start];

    QH_XCTAssertThrows_On_DEBUG([clock start]);
    XCTAssertNoThrow([clock elapsedTimeInMiliseconds]);
    QH_XCTAssertThrows_On_DEBUG([clock spentTimeInMiliseconds]);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [clock end];

        XCTAssertNoThrow([clock start]);
        XCTAssertNoThrow([clock elapsedTimeInMiliseconds]);
        XCTAssertThrows([clock spentTimeInMiliseconds]);

        QHSetAssertFunction(nil);

        [expect fulfill];
    });

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testProfiler {
    static int count = 0;
    [QHClockChecker setCollector:^(QHClockCheckItem * _Nonnull item) {
        ++count;
        NSLog(@"QHProfiler check: %@-%@-%@, since last check: %dms, total: %.dms",
              item.module, item.event, item.point, item.interval, item.total);
    }];

    NSString *module = @"test";
    NSString *event = @"test";
    QHProfilerStart(module, event);
    sleep(1);
    QHProfilerCheck(module, event, @"1");
    sleep(1);
    QHProfilerCheck(module, event, @"2");
    sleep(1);
    QHProfilerCheck(module, event, @"3");
    sleep(1);
    QHProfilerCheck(module, event, @"4");
    sleep(1);
    QHProfilerEnd(module, event);

    XCTAssert(count == 5);
}


@end
