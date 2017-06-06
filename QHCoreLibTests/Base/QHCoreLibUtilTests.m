//
//  QHCoreLibUtilTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QHCoreLib/QHUtil.h>


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

- (void)testCallStack
{
    NSArray *array = QHCallStackShort();
    NSArray *array2 = QHCallStackShort();

    XCTAssertEqualObjects([array qh_sliceFromStart:2 length:array.count - 2],
                          [array2 qh_sliceFromStart:2 length:array2.count - 2]);
}

- (void)testDispatchSyncMainSafe
{
    QHDispatchSyncMainSafe(nil);

    {
        __block id object = [NSObject new];
        QHDispatchSyncMainSafe(^{
            XCTAssertTrue(QHIsMainQueue());
            object = nil;
        });
        XCTAssertNil(object);
    }

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block id object = [NSObject new];
        QHDispatchSyncMainSafe(^{
            XCTAssertTrue(!QHIsMainQueue());
            XCTAssertTrue(QHIsMainThread());
            object = nil;
        });
        XCTAssertNil(object);
    });

    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        __block id object = [NSObject new];
        QHDispatchSyncMainSafe(^{
            object = nil;
        });
        XCTAssertFalse(object);

        [expect fulfill];
    });
    [self waitForExpectations:@[ expect ]
                      timeout:1.0];
}

- (void)testDispatchAsync
{
    QHDispatchAsyncMain(nil);
    QHDispatchAsyncDefault(nil);

    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@"AsyncMain"];
    QHDispatchAsyncMain(^{
        XCTAssertTrue(QHIsMainQueue());
        [expect1 fulfill];
    });

    XCTestExpectation *expect2 = [[XCTestExpectation alloc] initWithDescription:@"AsyncDefault"];
    QHDispatchAsyncDefault(^{
        XCTAssertTrue(!QHIsMainQueue());
        [expect2 fulfill];
    });

    [self waitForExpectations:@[ expect1, expect2 ]
                      timeout:1.0];
}

- (void)testBlockInvoke
{
    dispatch_block_t block = ^{
        @throw [NSException exceptionWithName:@"ShouldThrow"
                                       reason:@"Unittest"
                                     userInfo:nil];
    };

#if DEBUG
    XCTAssertThrows(QH_BLOCK_INVOKE(block));
#else
    XCTAssertFalse(QH_BLOCK_INVOKE(block));
#endif
}

@end
