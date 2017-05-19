//
//  QHCoreLibUtilTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHUtil.h"


@interface QHCoreLibUtilTests : XCTestCase

@end

@implementation QHCoreLibUtilTests

- (void)testIsMainQueueAndIsMainThread
{

    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];

    // main queue, main thread
    XCTAssertTrue(QHIsMainQueue());
    XCTAssertTrue(QHIsMainThread());

    dispatch_async(dispatch_get_main_queue(), ^{
        // main queue, main thread
        XCTAssertTrue(QHIsMainQueue());
        XCTAssertTrue(QHIsMainThread());
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // non-main queue, non-main thread
        XCTAssertFalse(QHIsMainQueue());
        XCTAssertFalse(QHIsMainThread());
    });

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // non-main queue, main thread
        // http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
        XCTAssertFalse(QHIsMainQueue());
        XCTAssertTrue(QHIsMainThread());
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });

    [self waitForExpectations:@[ expect ] timeout:1.0];
}


@end
