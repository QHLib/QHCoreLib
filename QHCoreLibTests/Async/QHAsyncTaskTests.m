//
//  QHAsyncTaskTests.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/21.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsyncTask.h"
#import "QHAsyncTask+internal.h"

#import "QHAsyncTestTasks.h"


@interface QHCancelTask : QHAsyncTask
@end
@implementation QHCancelTask
- (void)p_doStart
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_fireSuccess:nil];
    });
}
- (void)start:(dispatch_block_t)assertFailBlock
{
    [self startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        assertFailBlock();
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        assertFailBlock();
    }];
}
- (void)cancelOnState:(QHAsyncTaskState)state
{
    NSAssert(state == self.state,
             @"expect state: %d, current state: %d",
             (int)state, (int)self.state);
    [self cancel];
}
@end

@interface QHCancelBlockByDoStartTask : QHAsyncTask
@end
@implementation QHCancelBlockByDoStartTask
- (void)p_doStart
{
    [NSThread sleepForTimeInterval:1.0];
    [self p_fireSuccess:nil];
}
@end

@interface QHAsyncTask ()
- (void)p_clearBlocks;
@end
@interface QHCancelOnCallingbackTask : QHCancelTask
@end
@implementation QHCancelOnCallingbackTask
- (void)p_clearBlocks
{
    static BOOL cleared = NO;

    [super p_clearBlocks];

    if (cleared == YES) return;

    cleared = YES;

    [self p_asyncOnWorkQueue:^{
        [self cancelOnState:QHAsyncTaskStateCallingback];
    }];
}
@end


@interface QHAsyncTaskTests : XCTestCase

@end

@implementation QHAsyncTaskTests

- (void)testSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@"succss task"];
                                 
    QHSuccessTask *task = [[QHSuccessTask alloc] init];
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];
    
    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@"fail task"];
    
    QHFailTask *task = [[QHFailTask alloc] init];
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testCancelOnStarted
{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
    });
    
    QHCancelTask *task = [[QHCancelTask alloc] init];
    task.workQueue = queue;
    [task start:^{
        XCTAssert(NO, @"cancelled task should not get callbacked");
    }];
    [task cancelOnState:QHAsyncTaskStateStarted];

    XCTAssert(task.state == QHAsyncTaskStateCancelled);

    XCTestExpectation *expect = [self expectationWithDescription:@"wait for task"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    [self waitForExpectationsWithTimeout:2.2 handler:nil];
}

- (void)testCancelBlockByDoStart
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHCancelBlockByDoStartTask *task = [[QHCancelBlockByDoStartTask alloc] init];

    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        [task cancel];
        CFAbsoluteTime cost = CFAbsoluteTimeGetCurrent() - startTime;
        XCTAssert(cost > 0.8, @"cancel cost: %f", cost);

        [expect fulfill];
    });

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testCancelOnLoading
{
    QHCancelTask *task = [[QHCancelTask alloc] init];

    [task start:^{
        XCTAssert(NO, @"cancelled task should not get callbacked");
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [task cancelOnState:QHAsyncTaskStateLoading];

        XCTAssert(task.state == QHAsyncTaskStateCancelled);
    });

    XCTestExpectation *expect = [self expectationWithDescription:@"wait for task"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    [self waitForExpectationsWithTimeout:1.2 handler:nil];
}

- (void)testCancelOnCallingback
{
    QHCancelOnCallingbackTask *task = [[QHCancelOnCallingbackTask alloc] init];
    [task start:^{
        XCTAssert(NO, @"cancelled task should not get callbacked");
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(task.state == QHAsyncTaskStateCancelled);
    });

    XCTestExpectation *expect = [self expectationWithDescription:@"wait for task"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    [self waitForExpectationsWithTimeout:1.3 handler:nil];
}

@end
