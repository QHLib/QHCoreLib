//
//  QHCoreLibDebouncerTests.m
//  QHCoreLibTests
//
//  Created by changtang on 2019/7/19.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHBlockQueue.h"
#import "QHDebouncer.h"

@interface QHCoreLibDebouncerTests : XCTestCase

@end

@implementation QHCoreLibDebouncerTests {
    QHBlockQueue *m_blockQueue;
    QHDebouncer *m_debouncer;
}

- (void)setUp
{
    m_blockQueue = [QHBlockQueue blockQueue];
}

- (void)testDebounce
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"debounce"];

    __block int count = 1;
    m_debouncer = [[QHDebouncer alloc] initWithDelay:0.5 action:^{
        XCTAssert(count == 2);
        [expect fulfill];
    }];

    [m_debouncer reschedule];

    QHDispatchDelayMain(0.1, ^{
        ++count;
        [self->m_debouncer reschedule];
    });

    [self waitForExpectations:@[ expect ] timeout:0.8];
}

@end
