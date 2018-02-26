//
//  QHCoreLibUtilTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHUtil.h"


@interface QHCoreLibUtilTests : XCTestCase

@end

@implementation QHCoreLibUtilTests

- (void)testBundleId
{
    XCTAssertEqualObjects(QHCoreLibBundleId(), @"com.tctony.QHLib.QHCoreLibTests");
}

- (void)testIsMainQueueAndIsMainThread
{

    XCTestExpectation *expect = [self expectationWithDescription:@""];

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

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
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
    
    QHDispatchSyncMainSafe(nilValue());

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

    XCTestExpectation *expect = [self expectationWithDescription:@""];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        __block id object = [NSObject new];
        QHDispatchSyncMainSafe(^{
            object = nil;
        });
        XCTAssertFalse(object);

        [expect fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDispatchAsync
{
    QHDispatchAsyncMain(nilValue());
    QHDispatchAsyncDefault(nilValue());

    XCTestExpectation *expect1 = [self expectationWithDescription:@"AsyncMain"];
    QHDispatchAsyncMain(^{
        XCTAssertTrue(QHIsMainQueue());
        [expect1 fulfill];
    });

    XCTestExpectation *expect2 = [self expectationWithDescription:@"AsyncDefault"];
    QHDispatchAsyncDefault(^{
        XCTAssertTrue(!QHIsMainQueue());
        [expect2 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDispatchDelay
{
    QHDispatchDelayMain(0, nilValue());
    QHDispatchDelayDefault(0, nilValue());
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    XCTestExpectation *expect1 = [self expectationWithDescription:@"DelayMain"];
    QHDispatchDelayMain(0.5, ^{
        XCTAssertTrue(QHIsMainQueue());
        XCTAssertTrue(CFAbsoluteTimeGetCurrent() - start > 0.5);
        [expect1 fulfill];
    });
    
    XCTestExpectation *expect2 = [self expectationWithDescription:@"DelayDefault"];
    QHDispatchDelayDefault(0.5, ^{
        XCTAssertTrue(!QHIsMainQueue());
        XCTAssertTrue(CFAbsoluteTimeGetCurrent() - start > 0.5);
        [expect2 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.6 handler:nil];
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

- (void)testQHRandom
{
    uint32_t r1 = QHRandomNumber();
    uint32_t r2 = QHRandomNumber();
    XCTAssertNotEqual(r1, r2);
}

- (void)testHexStringFromBytes
{
    uint8_t p[8] = { 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef };
    XCTAssertEqualObjects(@"0123456789abcdef", QHHexStringFromBytes(p, sizeof(p)));
}

- (void)testContentTypeOfExtension
{
    XCTAssertEqualObjects(QHContentTypeOfExtension(@"txt"), @"text/plain");
    XCTAssertEqualObjects(QHContentTypeOfExtension(@"png"), @"image/png");
    XCTAssertEqualObjects(QHContentTypeOfExtension(@"jpg"), @"image/jpeg");
}

- (void)testSizeAspectFit
{
    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFitInSize(CGSizeZero, CGSizeMake(1, 1), NO), CGSizeZero));

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFitInSize(CGSizeMake(200, 400), CGSizeMake(100, 100), NO), CGSizeMake(50, 100)));

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFitInSize(CGSizeMake(200, 400), CGSizeMake(800, 800), NO), CGSizeMake(200, 400)));

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFitInSize(CGSizeMake(200, 400), CGSizeMake(800, 800),YES), CGSizeMake(400, 800)));
}

- (void)testSizeAspectFill
{
    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFillInSize(CGSizeZero, CGSizeMake(1, 1), NO), CGSizeZero), @"");

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFillInSize(CGSizeMake(200, 400), CGSizeMake(100, 100), NO), CGSizeMake(100, 200)));

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFillInSize(CGSizeMake(200, 400), CGSizeMake(800, 800), NO), CGSizeMake(200, 400)));

    XCTAssertTrue(CGSizeEqualToSize(QHSizeAspectFillInSize(CGSizeMake(200, 400), CGSizeMake(800, 800),YES), CGSizeMake(800, 1600)));
}

- (void)testTimestamp
{
    NSLog(@"timestamp: %f, %f, %llu, %llu",
          [[NSDate date] timeIntervalSince1970],
          QHTimestampInDouble(),
          QHTimestampInSeconds(),
          QHTimestampInMilliseconds());
    
    XCTAssertTrue(YES, @"ok");
}

- (void)testTimestampFloor
{
    // 1509689148 2017/11/3 14:05:48 星期五
    // 1509638400 2017/11/3 09:00:00 星期五
    XCTAssertEqual(QHTimestampDayFloor(1509689148), 1509638400);

    XCTAssertEqual(QHTimestampWeekFloor(1509689148), 1509638400 - 4 * 86400);
    XCTAssertEqual(QHTimestampWeekFloor(1509689148 - 2 * 86400), 1509638400 - 4 * 86400);
    XCTAssertNotEqual(QHTimestampWeekFloor(1509689148 - 5 * 86400), 1509638400 - 4 * 86400);
}

- (void)testChineseCharacter
{
    NSString *str = @"你好hello123,";
    for (int i = 0; i < str.length; ++i) {
        unichar c = [str characterAtIndex:i];
        XCTAssertEqual(QHCharacterIsChinese(c), i < 2);
        XCTAssertEqual(QHCharacterIsAlphabet(c), i >=2 && i < 7);
        XCTAssertEqual(QHCharacterIsNumber(c), i >=7 && i < 10);
        XCTAssertEqual([[NSCharacterSet punctuationCharacterSet] characterIsMember:c], i >= 10);
    }
}

- (void)testMobilePhoneNumber
{
    // 长度不对
    XCTAssertFalse(QHMobilePhoneNumberCheck(@"133"));
    // 号段不对
    XCTAssertFalse(QHMobilePhoneNumberCheck(@"123"));

    XCTAssertTrue(QHMobilePhoneNumberCheck(@"13800000000"));
}

@end
