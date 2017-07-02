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


@interface QHAasyncParallelTaskGroupSubClassTester : QHAsyncParallelTaskGroup

QH_ASYNC_TASK_DECL(QHAasyncParallelTaskGroupSubClassTester, NSString);

@end

@implementation QHAasyncParallelTaskGroupSubClassTester

QH_ASYNC_TASK_IMPL_DIRECT(QHAasyncParallelTaskGroupSubClassTester, NSString);

- (id _Nullable)p_doAggregateResult:(QHAsyncParallelTaskGroupResult *)result
                              error:(NSError * _Nullable __autoreleasing *)error
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:2.1 handler:nil];
}

- (void)testResult
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHAsyncTask<NSNumber *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                                QHAsyncBlockTaskReporter<NSNumber *, QHAsyncTaskProgress *> * _Nonnull reporter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [reporter success:@0];
        });
    }] withTaskId:@0];
    [taskGroup addTask:[QHAsyncTask<NSNumber *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                                QHAsyncBlockTaskReporter<NSNumber *, QHAsyncTaskProgress *> * _Nonnull reporter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [reporter success:@1];
        });
    }] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        QH_AS(result, NSDictionary, results);
        XCTAssertEqualObjects(results[@0], @0);
        XCTAssertEqualObjects(results[@1], @1);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not faile");
    }];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

- (void)testProgress
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup<NSNumber *> *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup setProgressBlock:^(QHAsyncTask * _Nonnull task, QHAsyncParallelTaskGroupProgress * _Nullable progress) {
        NSLog(@"progress: %.2f%%, (%d/%d) [%@] %@ finished with result: %@",
              progress.currentProgress * 100,
              (int)(progress.succeed.count + progress.failed.count),
              (int)progress.tasks.count,
              progress.taskId,
              progress.task,
              [progress.results objectForKey:progress.taskId]);
    }];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSNumber * _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testSubclass
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAasyncParallelTaskGroupSubClassTester *taskGroup = [[QHAasyncParallelTaskGroupSubClassTester alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAasyncParallelTaskGroupSubClassTester *task, NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"ok");
        [expect fulfill];
    } fail:^(QHAasyncParallelTaskGroupSubClassTester *task, NSError *error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testBlockAggregate
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup<NSNumber *> *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup setResultAggregationBlock:^NSNumber * _Nullable(QHAsyncParallelTaskGroupResult * _Nonnull result,
                                                               NSError * _Nullable __autoreleasing * _Nullable error) {
        return @3;
    }];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSNumber * _Nullable result) {
        XCTAssertEqualObjects(result, @3);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testBlockAggregateFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup<NSNumber *> *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup setResultAggregationBlock:^NSNumber * _Nullable(QHAsyncParallelTaskGroupResult * _Nonnull result,
                                                               NSError * _Nullable __autoreleasing * _Nullable error) {
        *error = QH_ERROR(@"", 0, nil, nil);
        return nil;
    }];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSNumber * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testStrategyAnySuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    taskGroup.successStrategy = QHAsyncParallelTaskSuccessStrategyAny;

    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.8] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testStrategyAnyFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    taskGroup.successStrategy = QHAsyncParallelTaskSuccessStrategyAny;

    [taskGroup addTask:[QHFailTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.8] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testStrategyAlwaysPartFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    taskGroup.successStrategy = QHAsyncParallelTaskSuccessStrategyAlways;

    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.8] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

- (void)testStrategyAlwaysAllFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    taskGroup.successStrategy = QHAsyncParallelTaskSuccessStrategyAlways;

    [taskGroup addTask:[QHFailTask new] withTaskId:@0];
    [taskGroup addTask:[[QHFailTask alloc] initWithInterval:0.8] withTaskId:@1];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.1 handler:nil];
}

@end
