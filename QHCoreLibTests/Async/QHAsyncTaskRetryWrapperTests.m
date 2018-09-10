//
//  QHAsyncTaskRetryWrapperTests.m
//  QHCoreLibTests
//
//  Created by changtang on 2018/9/10.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QHAsyncTaskRetryWrapper.h"
#import "QHAsyncTask+internal.h"

@interface QHAsyncTestTask: QHAsyncTask

@end

static int count = 3;

@implementation QHAsyncTestTask

- (void)p_doStart
{
    if (--count > 0) {
        QHDispatchDelayDefault(.1, ^{
            [self p_fireFail:QH_ERROR(@"QHAsyncTaskRetryWrapperTests",
                                      count,
                                      @"",
                                      nil)];
        });
    } else {
        QHDispatchDelayMain(.1, ^{
            [self p_fireSuccess:@0];
        });
    }
}

@end

@interface QHAsyncTaskRetryWrapperTests : XCTestCase

@property (nonatomic, strong) QHAsyncTaskRetryWrapper *testTask;

@end

@implementation QHAsyncTaskRetryWrapperTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWrapperFail
{
    XCTestExpectation *expect = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    count = 3;
    self.testTask = [[QHAsyncTaskRetryWrapper alloc] initWithTaskBuilder:^QHAsyncTask *{
        return [[QHAsyncTestTask alloc] init];
    } maxTryCount:2 retryInterval:5.0];
    [self.testTask startWithSuccess:^(QHAsyncTask * _Nonnull task,
                                      id  _Nonnull result) {
        XCTAssert(NO, @"should not be here");
    } fail:^(QHAsyncTask * _Nonnull task,
             NSError * _Nonnull error) {
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:6 handler:nil];
}

- (void)testWrapperSucceed
{
    XCTestExpectation *expect = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    count = 3;
    self.testTask = [[QHAsyncTaskRetryWrapper alloc] initWithTaskBuilder:^QHAsyncTask *{
        return [[QHAsyncTestTask alloc] init];
    } maxTryCount:3 retryInterval:5.0];
    [self.testTask startWithSuccess:^(QHAsyncTask * _Nonnull task,
                                      id  _Nonnull result) {
        [expect fulfill];
    } fail:^(QHAsyncTask * _Nonnull task,
             NSError * _Nonnull error) {
        XCTAssert(NO, @"should not be here");
    }];

    [self waitForExpectationsWithTimeout:11 handler:nil];
}

@end
