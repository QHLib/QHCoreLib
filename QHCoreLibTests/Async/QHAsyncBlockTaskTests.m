//
//  QHAsyncBlockTaskTests.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/29.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsyncTask.h"

@interface QHAsyncTaskBlockSubclassTester : QHAsyncTask
QH_ASYNC_TASK_BLOCK_DECL(QHAsyncTaskBlockSubclassTester, NSNumber *, QHAsyncTaskProgress);
@end

@implementation QHAsyncTaskBlockSubclassTester
QH_ASYNC_TASK_BLOCK_IMPL(QHAsyncTaskBlockSubclassTester, NSNumber *, QHAsyncTaskProgress)
@end


@interface QHAsyncBlockTaskTests : XCTestCase

@end

@implementation QHAsyncBlockTaskTests

- (void)testSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@"block task success"];

    QHAsyncTask<NSString *> *task = ({
        [QHAsyncTask<NSString *> taskWithBlock:
         ^(QHAsyncTask * _Nonnull task, QHAsyncBlockTaskReporter<NSString *, QHAsyncTaskProgress *> * _Nonnull reporter) {
             [reporter success:@"ok"];
         }];
    });

    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nullable result) {
        XCTAssert(QH_IS_STRING(result));
        XCTAssert([(NSString *)result isEqualToString:@"ok"]);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testAsyncSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@"block task success"];

    QHAsyncTask<NSString *> *task = ({
        [QHAsyncTask<NSString *> taskWithBlock:
         ^(QHAsyncTask * _Nonnull task, QHAsyncBlockTaskReporter<NSString *, QHAsyncTaskProgress *> * _Nonnull reporter) {
             QHDispatchDelayDefault(0.5, ^{
                 [reporter success:@"ok"];
             });
         }];
    });

    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nullable result) {
        XCTAssert(QH_IS_STRING(result));
        XCTAssert([(NSString *)result isEqualToString:@"ok"]);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:0.6 handler:nil];
}

- (void)testFail
{
    XCTestExpectation *expect = [self expectationWithDescription:@"block task success"];

    QHAsyncTask<NSString *> *task = ({
        [QHAsyncTask<NSString *> taskWithBlock:
         ^(QHAsyncTask * _Nonnull task, QHAsyncBlockTaskReporter<NSString *, QHAsyncTaskProgress *> * _Nonnull reporter) {
             NSError *error = QH_ERROR(@"", 0, nil, nil);
             [reporter fail:error];
         }];
    });

    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nullable result) {
        XCTAssert(NO, @"should not success");
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testBodyBlock
{
    XCTestExpectation *expect = [self expectationWithDescription:@"block task success"];

    QHAsyncTask<NSString *> *task = [[QHAsyncTask alloc] init];
    [task setBodyBlock:^(QHAsyncTask * _Nonnull task, QHAsyncBlockTaskReporter<NSString *,id<QHAsyncTaskProgress>> * _Nonnull reporter) {
        [reporter success:@"ok"];
    }];

    [task startWithSuccess:^(QHAsyncTask * _Nonnull task, NSString * _Nullable result) {
        XCTAssert(QH_IS_STRING(result));
        XCTAssert([(NSString *)result isEqualToString:@"ok"]);
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task, NSError * _Nonnull error) {
        XCTAssert(NO, @"should not fail");
    }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
