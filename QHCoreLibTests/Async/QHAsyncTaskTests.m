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


@interface QHSuccessTask : QHAsyncTask
@end
@implementation QHSuccessTask
- (void)p_doStart
{
    [NSThread sleepForTimeInterval:1.0];
    [self p_fireSuccess:nil];
}
@end

@interface QHFailTask : QHAsyncTask
@end
@implementation QHFailTask
- (void)p_doStart
{
    [NSThread sleepForTimeInterval:1.0];
    [self p_fireFail:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
}
@end

@interface QHCancelTask : QHAsyncTask
@property (nonatomic, assign) int counter;
@property (nonatomic, copy) void(^onCancel)(int counter);
@end
@implementation QHCancelTask
- (void)p_doStart
{
    self.counter++;
}
- (void)p_doCancel
{
    self.onCancel(self.counter);
}
- (void)p_doTeardown
{
    self.onCancel = nil;
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
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@"fail task"];
    
    QHFailTask *task = [[QHFailTask alloc] init];
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testCancelBefore_doStart
{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
    });
    
    QHCancelTask *task = [[QHCancelTask alloc] init];
    task.workQueue = queue;
    task.onCancel = ^(int counter) {
        XCTAssert(counter == 0);
    };
    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];
    [task cancel];
}

- (void)testCancelDuring_doStart
{
    
}

- (void)testCancelAfter_doStart // success
{
    
}

@end
