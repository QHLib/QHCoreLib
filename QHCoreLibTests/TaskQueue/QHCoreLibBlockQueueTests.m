//
//  QHCoreLibBlockQueueTests.m
//  QHCoreLibTests
//
//  Created by Tony Tang on 2019/4/11.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHBase.h"
#import "QHBlockQueue.h"

@interface QHCoreLibBlockQueueTests : XCTestCase

@end

@implementation QHCoreLibBlockQueueTests {
    QHBlockQueue *m_blockQueue;
}

- (void)setUp
{
    m_blockQueue = [QHBlockQueue sharedMainQueue];
}

- (void)testNoDelay
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"no delay"];
    [m_blockQueue pushBlock:^{
        [expect fulfill];
    }];
    [self waitForExpectations:@[ expect ] timeout:0.01];
}

- (void)testDelay
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"delay"];
    [m_blockQueue pushBlock:^{
        [expect fulfill];
    } delay:0.2];
    [self waitForExpectations:@[ expect ] timeout:0.21];
}

- (void)testRepeat
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"repeat"];
    __block int count = 5;
    [m_blockQueue pushBlock:^{
        --count;
        NSLog(@"count: %d", count);
        if (count == 0) {
            [expect fulfill];
        }
    } delay:0.2 repeat:YES];
    [self waitForExpectations:@[ expect ] timeout:1.050];
}

- (void)testCancel
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"cancel"];
    __block QHBlockId blockId = [m_blockQueue pushBlock:^{
        XCTAssert(NO, @"cancelled block should not called");
    } delay:0.2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->m_blockQueue cancelBlock:blockId];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    [self waitForExpectations:@[ expect ] timeout:0.31];
}

- (void)testDelayOrder
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"order"];
    __block BOOL first = NO;
    __block BOOL second = NO;
    [m_blockQueue pushBlock:^{
        second = YES;
        if (first && second) {
            [expect fulfill];
        }
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        first = YES;
        XCTAssertFalse(second);
    } delay:0.1];
    [self waitForExpectations:@[ expect ] timeout:0.21];
}

- (void)testMultiBlockInOneLock
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"order"];
    __block int count = 0;
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.22 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(count == 5, @"count is %d", count);
        [expect fulfill];
    });
    [self waitForExpectations:@[ expect ] timeout:0.22];
}

- (void)testContextReleasedOnAsyncCallback {
    @autoreleasepool {
        id obj = [NSObject new];
        @weakify(obj);
        QHBlockId blockId = [m_blockQueue pushBlock:^{
            @strongify(obj);
            assert(obj == nil);
            XCTAssert(NO, @"should not be here");
        }];
        [m_blockQueue cancelBlock:blockId];
    }
}

@end
