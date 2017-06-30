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

#import "QHAsyncBlockTask.h"


@interface QHAasyncParallelTaskGroupAggregateOk : QHAsyncParallelTaskGroup

QH_ASYNC_TASK_DECL(QHAasyncParallelTaskGroupAggregateOk, NSString);

@end

@implementation QHAasyncParallelTaskGroupAggregateOk

QH_ASYNC_TASK_IMPL_DIRECT(QHAasyncParallelTaskGroupAggregateOk, NSString);

- (id)p_doAggregateResult:(NSDictionary<QHAsyncTaskId,QHAsyncTask *> *)tasks
                  succeed:(NSSet<QHAsyncTaskId> *)succeed
                   failed:(NSSet<QHAsyncTaskId> *)failed
                  results:(NSDictionary<QHAsyncTaskId,id> *)results
                    error:(NSError *__autoreleasing *)error
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

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
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
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.8] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:0.9 handler:nil];
}

- (void)testFail1
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:1.1] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.2 handler:nil];
}

- (void)testCancel
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [taskGroup cancel];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expect fulfill];
    });

    [self waitForExpectationsWithTimeout:1.2 handler:nil];
}

- (void)testMaxConcurrentCount
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    taskGroup.maxConcurrentCount = 1;
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:2.1 handler:nil];
}

- (void)testResult
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHAsyncBlockTask<NSNumber *> taskWithBlock:^(QHAsyncBlockTaskReporter<NSNumber *> * _Nonnull reporter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [reporter success:@0];
        });
    }] withTaskId:@0];
    [taskGroup addTask:[QHAsyncBlockTask<NSNumber *> taskWithBlock:^(QHAsyncBlockTaskReporter<NSNumber *> * _Nonnull reporter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [reporter success:@1];
        });
    }] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncParallelTaskGroup * _Nonnull task, NSObject * _Nullable result) {
        QH_AS(result, NSDictionary, dict);
        XCTAssertEqualObjects(dict[@0], @0);
        XCTAssertEqualObjects(dict[@1], @1);
        [expect fulfill];
    } fail:^(QHAsyncParallelTaskGroup * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not faile");
    }];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testSubclassAggregateResult
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAasyncParallelTaskGroupAggregateOk *taskGroup = [[QHAasyncParallelTaskGroupAggregateOk alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAasyncParallelTaskGroupAggregateOk *task, NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"ok");
        [expect fulfill];
    } fail:^(QHAasyncParallelTaskGroupAggregateOk *task, NSError *error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

@end
