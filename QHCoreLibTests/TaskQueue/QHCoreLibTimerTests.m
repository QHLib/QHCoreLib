//
//  QHCoreLibTimerTests.m
//  QHCoreLibTests
//
//  Created by Tony Tang on 2019/8/31.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QHTimer.h"

@interface QHCoreLibTimerTests : XCTestCase {
    QHTimer *m_timer;
}

@end

@implementation QHCoreLibTimerTests

- (void)testDelay {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];

    m_timer = [QHTimer timerWithDelay:0.2 action:^{
        [expect fulfill];
    }];

    [self waitForExpectations:@[ expect ] timeout:0.22];
}

- (void)testRepeat {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];

    __block int count = 0;
    m_timer = [QHTimer timerWithDelay:0.2 repeat:YES action:^{
        count++;
        NSLog(@"count: %d", count);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(count == 5);
        [expect fulfill];
    });

    [self waitForExpectations:@[ expect ] timeout:1.2];
}

- (void)testCancelOnRelease {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];

    [QHTimer timerWithDelay:0.2 action:^{
        XCTAssert(NO, @"should not be here");
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });

    [self waitForExpectations:@[ expect ] timeout:0.4];
}
@end
