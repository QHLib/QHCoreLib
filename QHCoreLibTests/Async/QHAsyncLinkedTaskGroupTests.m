//
//  QHAsyncLinkedTaskGroupTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/7/1.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsyncLinkedTaskGroup.h"
#import "QHAsyncTask+internal.h"


@interface QHStringToNumberTask : QHAsyncTask<NSNumber *>
QH_ASYNC_LINKED_TASK_NODE_DECL(NSString *, NSNumber *);
@end
@implementation QHStringToNumberTask
QH_ASYNC_LINKED_TASK_NODE_IMPL(NSString *, NSNumber *);
- (void)p_doStart
{
    QH_AS(self.carry, NSString, stringValue);
    QHAssert(stringValue != nil, @"invalid carry %@ for %@", self.carry, self);

    QHDispatchDelayDefault(0.1, ^{
        [self p_fireSuccess:@([stringValue integerValue])];
    });
}
@end

@interface QHNumberIncrementTask : QHAsyncTask<NSNumber *>
@end
@implementation QHNumberIncrementTask
- (void)p_doStart
{
    QH_AS(self.carry, NSNumber, numberValue);
    QHAssert(numberValue != nil, @"invalid carry %@ for %@", self.carry, self);

    QHDispatchDelayDefault(0.1, ^{
        [self p_fireSuccess:@([numberValue integerValue] + 1)];
    });
}
@end

@interface QHNumberToStringTask : QHAsyncTask<NSString *>
@end
@implementation QHNumberToStringTask
- (void)p_doStart
{
    QH_AS(self.carry, NSNumber, numberValue);
    QHAssert(numberValue != nil, @"invalid carry %@ for %@", self.carry, self);

    QHDispatchDelayDefault(0.1, ^{
        [self p_fireSuccess:[numberValue stringValue]];
    });
}
@end


@interface QHAsyncLinkedTaskGroupTests : XCTestCase

@end

@implementation QHAsyncLinkedTaskGroupTests

- (QHAsyncLinkedTaskNode<NSString *, NSNumber *> *)stringToNumberNode
{
    return [QHAsyncLinkedTaskNode<NSString *, NSNumber *> nodeFromTask:({
        [QHAsyncTask<NSNumber *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                 QHAsyncBlockTaskReporter<NSNumber *,id<QHAsyncTaskProgress>> * _Nonnull reporter) {
            QH_AS(task.carry, NSString, stringValue);
            QHAssert(stringValue != nil, @"invalid carry %@ for %@", task.carry, task);

            QHDispatchDelayDefault(0.1, ^{
                [reporter success:@([stringValue integerValue])];
            });
        }];
    })];
}

- (QHAsyncLinkedTaskNode<NSNumber *, NSNumber *> *)numberIncrementNode
{
    return [QHAsyncLinkedTaskNode<NSNumber *, NSNumber *> nodeFromTask:({
        [QHAsyncTask<NSNumber *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                 QHAsyncBlockTaskReporter<NSNumber *,id<QHAsyncTaskProgress>> * _Nonnull reporter) {
            QH_AS(task.carry, NSNumber, numberValue);
            QHAssert(numberValue != nil, @"invalid carry %@ for %@", task.carry, task);

            QHDispatchDelayDefault(0.1, ^{
                [reporter success:@([numberValue integerValue] + 1)];
            });
        }];
    })];
}

- (QHAsyncLinkedTaskNode<NSNumber *, NSNumber *> *)numberIncrementFailNode
{
    return [QHAsyncLinkedTaskNode<NSNumber *, NSNumber *> nodeFromTask:({
        [QHAsyncTask<NSNumber *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                 QHAsyncBlockTaskReporter<NSNumber *,id<QHAsyncTaskProgress>> * _Nonnull reporter) {
            QH_AS(task.carry, NSNumber, numberValue);
            QHAssert(numberValue != nil, @"invalid carry %@ for %@", task.carry, task);

            QHDispatchDelayDefault(0.1, ^{
                [reporter fail:QH_ERROR(@"", 0, nil, nil)];
            });
        }];
    })];
}

- (QHAsyncLinkedTaskNode<NSNumber *, NSString *> *)numberToStringNode
{
    return [QHAsyncLinkedTaskNode<NSNumber *, NSString *> nodeFromTask:({
        [QHAsyncTask<NSString *> taskWithBlock:^(QHAsyncTask * _Nonnull task,
                                                 QHAsyncBlockTaskReporter<NSString *,id<QHAsyncTaskProgress>> * _Nonnull reporter) {
            QH_AS(task.carry, NSNumber, numberValue);
            QHAssert(numberValue != nil, @"invalid carry %@ for %@", task.carry, task);

            QHDispatchDelayDefault(0.1, ^{
                [reporter success:[numberValue stringValue]];
            });
        }];
    })];
}

- (void)testSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncLinkedTaskGroup<NSString *, NSString *> *taskGroup = [[QHAsyncLinkedTaskGroup alloc] init];

    [taskGroup setTaskList:({
        [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSString *> linkNode:({
            [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSNumber *> linkNode:({
                [self stringToNumberNode];
            }) withNode:[self numberIncrementNode]];
        }) withNode:[self numberToStringNode]];
    })];

    taskGroup.carry = @"99";

    [taskGroup setProgressBlock:^(QHAsyncTask * _Nonnull task, QHAsyncLinkedTaskGroupProgress * _Nonnull progress) {
        NSLog(@"progress: %.2f%%, (%d/%d) [%d] %@ finished with result: %@",
              progress.currentProgress * 100,
              (int)progress.results.count, (int)progress.tasks.count,
              (int)progress.currentIndex, progress.tasks[progress.currentIndex],
              progress.results[progress.currentIndex]);
    }];

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nonnull result) {
        XCTAssertEqualObjects(result, @"100");
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncLinkedTaskGroup<NSString *, NSString *> *taskGroup = [[QHAsyncLinkedTaskGroup alloc] init];

    [taskGroup setTaskList:({
        [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSString *> linkNode:({
            [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSNumber *> linkNode:({
                [self stringToNumberNode];
            }) withNode:[self numberIncrementFailNode]];
        }) withNode:[self numberToStringNode]];
    })];

    taskGroup.carry = @"99";

    [taskGroup setProgressBlock:^(QHAsyncTask * _Nonnull task, QHAsyncLinkedTaskGroupProgress * _Nonnull progress) {
        NSLog(@"progress: %.2f%%, (%d/%d) [%d] %@ finished with result: %@",
              progress.currentProgress * 100,
              (int)progress.results.count, (int)progress.tasks.count,
              (int)progress.currentIndex, progress.tasks[progress.currentIndex],
              progress.results[progress.currentIndex]);
    }];
    
    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nonnull result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testPrepend
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncLinkedTaskGroup<NSString *, NSString *> *taskGroup = [[QHAsyncLinkedTaskGroup alloc] init];

    [taskGroup setTaskList:({
        [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSString *> prependTask:({
            [[QHStringToNumberTask alloc] init];
        }) toNode:[QHAsyncLinkedTaskNode<NSNumber *, NSString *> nodeFromTask:({
            [[QHNumberToStringTask alloc] init];
        })]];
    })];

    taskGroup.carry = @"99";

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nonnull result) {
        XCTAssertEqualObjects(result, @"99");
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testAppend
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncLinkedTaskGroup<NSString *, NSString *> *taskGroup = [[QHAsyncLinkedTaskGroup alloc] init];

    [taskGroup setTaskList:({
        [QHAsyncLinkedTaskLinker<NSString *, NSNumber *, NSString *> appendTask:({
            [[QHNumberToStringTask alloc] init];
        }) toNode:[QHAsyncLinkedTaskNode<NSString *, NSNumber *> nodeFromTask:({
            [[QHStringToNumberTask alloc] init];
        })]];
    })];

    taskGroup.carry = @"99";

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nonnull result) {
        XCTAssertEqualObjects(result, @"99");
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testLinkMacro
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];

    QHAsyncLinkedTaskGroup<NSString *, NSString *> *taskGroup = [[QHAsyncLinkedTaskGroup alloc] init];

    [taskGroup setTaskList:({
        QH_ASYNC_LINKED_TASK_LINK_9(NSString *, [[QHStringToNumberTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberIncrementTask alloc] init],
                                    NSNumber *, [[QHNumberToStringTask alloc] init],
                                    NSString *);
    })];


    taskGroup.carry = @"99";

    [taskGroup startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nonnull result) {
        XCTAssertEqualObjects(result, @"106");
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
