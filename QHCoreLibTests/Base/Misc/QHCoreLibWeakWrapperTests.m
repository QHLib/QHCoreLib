//
//  QHCoreLibWeakWrapperTests.m
//  QHCoreLibTests
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHWeakWrapper.h"


@interface QHCoreLibWeakWrapperTests : XCTestCase

@end

@implementation QHCoreLibWeakWrapperTests

- (void)testWeakWrapper
{
    @autoreleasepool {
        id obj = [NSObject new];
        QHWeakWrapper *wrapper = QHWeakWrap(obj);

        XCTAssertEqual(obj, QHWeakUnwrap(wrapper));

        XCTestExpectation *expect = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertNil(QHWeakUnwrap(wrapper));
            [expect fulfill];
        });
    }
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testMissedCount
{
    id obj = [NSObject new];
    QHWeakWrapper *wrapper = QHWeakWrap(obj);

    XCTAssertEqual(0, wrapper.missedCount);
    wrapper.obj = nil;
    XCTAssertNil(QHWeakUnwrap(wrapper.obj));
    XCTAssertNil(wrapper.obj);
    XCTAssertEqual(2, wrapper.missedCount);
}

@end
