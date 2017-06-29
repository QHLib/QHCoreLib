//
//  QHAsyncParallelTaskGroupTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsyncTestTasks.h"

#import "QHAsyncParallelTaskGroup.h"
#import "QHAsyncParallelTaskGroup+internal.h"


@interface QHParallelTaskGroup : QHAsyncParallelTaskGroup

QH_ASYNC_TASK_DECL(QHParallelTaskGroup, NSString);

@end

@implementation QHParallelTaskGroup

QH_ASYNC_TASK_IMPL_DIRECT(QHParallelTaskGroup, NSString);

- (id)p_doAggregated:(NSError *__autoreleasing *)error
{
    return @"ok";
}

@end


@interface QHAsyncParallelTaskGroupTests : XCTestCase

@end

@implementation QHAsyncParallelTaskGroupTests

- (void)testSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSDictionary * _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testFail0
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.95] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSDictionary * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.05 handler:nil];
}

- (void)testFail1
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:1.1] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSDictionary * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.2 handler:nil];
}

- (void)testSubclass
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHParallelTaskGroup *taskGroup = [[QHParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHParallelTaskGroup *task, NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"ok");
        [expect fulfill];
    } fail:^(QHParallelTaskGroup *task, NSError *error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

@end
