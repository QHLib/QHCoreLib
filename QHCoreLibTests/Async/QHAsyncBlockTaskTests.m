//
//  QHAsyncBlockTaskTests.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/29.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QHAsyncBlockTask.h"

@interface QHAsyncBlockTaskTests : XCTestCase

@end

@implementation QHAsyncBlockTaskTests

- (void)testSuccess
{
    XCTestExpectation *expect = [self expectationWithDescription:@"block task success"];
    
    QHAsyncBlockTask<NSString *> *task = ({
        [QHAsyncBlockTask<NSString *> taskWithBlock:
         ^(QHAsyncBlockTaskReporter<NSString *> * _Nonnull reporter) {
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
    
    QHAsyncBlockTask<NSString *> *task = ({
        [QHAsyncBlockTask<NSString *> taskWithBlock:
         ^(QHAsyncBlockTaskReporter<NSString *> * _Nonnull reporter) {
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
    
    QHAsyncBlockTask<NSString *> *task = ({
        [QHAsyncBlockTask<NSString *> taskWithBlock:
         ^(QHAsyncBlockTaskReporter<NSString *> * _Nonnull reporter) {
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

@end
