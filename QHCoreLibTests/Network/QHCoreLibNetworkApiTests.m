//
//  QHCoreLibNetworkApiTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QHCoreLib/QHNetwork.h>


@class QHNetworkTestApiResult;

@interface QHNetworkTestApi : QHNetworkApi

QH_NETWORK_API_DECL(QHNetworkTestApi, QHNetworkTestApiResult);

- (instancetype)initWithUrl:(NSString *)url;

@property (nonatomic, copy) NSString *url;

@end

@interface QHNetworkTestApiResult : QHNetworkApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkTestApi, QHNetworkTestApiResult);

@end

@implementation QHNetworkTestApi

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (QHNetworkRequest *)buildRequest
{
    QHNetworkRequest *request = [[QHNetworkRequest alloc] init];
    request.urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    request.urlRequest.timeoutInterval = 2.8f;
    request.resourceType = QHNetworkResourceJSON;
    return request;
}

QH_NETWORK_API_IMPL(QHNetworkTestApi, QHNetworkTestApiResult);

@end

@implementation QHNetworkTestApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkTestApi, QHNetworkTestApiResult) {
    // do nothing
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end


@interface QHCoreLibNetworkApiTests : XCTestCase

@end

@implementation QHCoreLibNetworkApiTests

- (void)testLoadSucceed
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://http.tctony.xyz/test_json'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"http://http.tctony.xyz/test_json"];
    [api loadWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
    }];

    [self waitForExpectations:@[ expect ] timeout:3.0];
}

- (void)testLoadFailed
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'https://some.where.on.mars/'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"https://some.where.on.mars/"];
    [api loadWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        XCTAssert(NO, @"should not be here");
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        [expect fulfill];
    }];

    [self waitForExpectations:@[ expect ] timeout:3.0];
}


@end
