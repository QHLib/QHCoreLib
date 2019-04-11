//
//  QHCoreLibBlockQueueTests.m
//  QHCoreLibTests
//
//  Created by Tony Tang on 2019/4/11.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHBlockQueue.h"

@interface QHCoreLibBlockQueueTests : XCTestCase

@end

@implementation QHCoreLibBlockQueueTests {
    QHBlockQueue *mainBlockQueue;
//    QHBlockQueue *backgroundBlockQueue;
}

- (void)setUp
{
    mainBlockQueue = [QHBlockQueue main];
//    mainBlockQueue = [QHBlockQueue background];
}

- (void)testMainNoDelay
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"main no delay"];
    [mainBlockQueue pushBlock:^{
        [expect fulfill];
    }];
    [self waitForExpectations:@[ expect ] timeout:0.01];
}

- (void)testMainDelay
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"main delay"];
    [mainBlockQueue pushBlock:^{
        [expect fulfill];
    } delay:0.2];
    [self waitForExpectations:@[ expect ] timeout:0.21];
}

- (void)testMainRepeat
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"main repeat"];
    __block int count = 5;
    [mainBlockQueue pushBlock:^{
        --count;
        NSLog(@"count: %d", count);
        if (count == 0) {
            [expect fulfill];
        }
    } delay:0.2 repeat:YES];
    [self waitForExpectations:@[ expect ] timeout:1.050];
}

- (void)testMainCancel
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"main cancel"];
    __block QHBlockId blockId = [mainBlockQueue pushBlock:^{
        XCTAssert(NO, @"cancelled block should not called");
    } delay:0.2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->mainBlockQueue cancelBlock:blockId];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    [self waitForExpectations:@[ expect ] timeout:0.31];
}

- (void)testMainDelayOrder
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"main order"];
    __block BOOL first = NO;
    __block BOOL second = NO;
    [mainBlockQueue pushBlock:^{
        second = YES;
        if (first && second) {
            [expect fulfill];
        }
    } delay:0.2];
    [mainBlockQueue pushBlock:^{
        first = YES;
        XCTAssertFalse(second);
    } delay:0.1];
    [self waitForExpectations:@[ expect ] timeout:0.21];
}

@end
