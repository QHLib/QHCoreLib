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


@interface QHAasyncParallelTaskGroupSubClassTester : QHAsyncParallelTaskGroup

QH_ASYNC_TASK_DECL(QHAasyncParallelTaskGroupSubClassTester, NSString);

@end

@implementation QHAasyncParallelTaskGroupSubClassTester

QH_ASYNC_TASK_IMPL_DIRECT(QHAasyncParallelTaskGroupSubClassTester, NSString);

- (void)p_doReportProgress:(NSDictionary<QHAsyncTaskId,QHAsyncTask *> *)tasks
                    taskId:(QHAsyncTaskId)taskId
                      task:(QHAsyncTask *)task
                   waiting:(NSSet<QHAsyncTaskId> *)waiting
                   running:(NSSet<QHAsyncTaskId> *)running
                   succeed:(NSSet<QHAsyncTaskId> *)succeed
                    failed:(NSSet<QHAsyncTaskId> *)failed
                   results:(NSDictionary<QHAsyncTaskId,id> *)results
{
    NSLog(@"[%@] %@ result: %@", taskId, task, [results objectForKey:taskId]);
}

- (id _Nullable)p_doAggregateResult:(NSDictionary<QHAsyncTaskId,QHAsyncTask *> *)tasks
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

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, id  _Nullable result) {
        QH_AS(result, NSDictionary, dict);
        XCTAssertEqualObjects(dict[@0], @0);
        XCTAssertEqualObjects(dict[@1], @1);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not faile");
    }];

    [self waitForExpectationsWithTimeout:0.5 handler:nil];
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

- (void)testBlockProgressAggregate
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncParallelTaskGroup<NSNumber *> *taskGroup = [[QHAsyncParallelTaskGroup alloc] init];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@0];
    [taskGroup addTask:[QHSuccessTask new] withTaskId:@1];

    [taskGroup setReportProgressBlock:^(NSDictionary<QHAsyncTaskId,QHAsyncTask *> * _Nonnull tasks,
                                        QHAsyncTaskId  _Nonnull taskId,
                                        QHAsyncTask * _Nonnull task,
                                        NSSet<QHAsyncTaskId> * _Nonnull waiting,
                                        NSSet<QHAsyncTaskId> * _Nonnull running,
                                        NSSet<QHAsyncTaskId> * _Nonnull succeed,
                                        NSSet<QHAsyncTaskId> * _Nonnull failed,
                                        NSDictionary<QHAsyncTaskId,id> * _Nonnull results) {
        NSLog(@"[%@] %@ result: %@", taskId, task, [results objectForKey:taskId]);
    }];

    [taskGroup setAggregateResultBlock:^NSNumber * _Nullable(NSDictionary<QHAsyncTaskId,QHAsyncTask *> * _Nonnull tasks,
                                                             NSSet<QHAsyncTaskId> * _Nonnull succeed,
                                                             NSSet<QHAsyncTaskId> * _Nonnull failed,
                                                             NSDictionary<QHAsyncTaskId,id> * _Nonnull results,
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

    [taskGroup setAggregateResultBlock:^NSNumber * _Nullable(NSDictionary<QHAsyncTaskId,QHAsyncTask *> * _Nonnull tasks,
                                                             NSSet<QHAsyncTaskId> * _Nonnull succeed,
                                                             NSSet<QHAsyncTaskId> * _Nonnull failed,
                                                             NSDictionary<QHAsyncTaskId,id> * _Nonnull results,
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

@end
