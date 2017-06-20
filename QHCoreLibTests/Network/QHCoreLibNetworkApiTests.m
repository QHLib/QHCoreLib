//
//  QHCoreLibNetworkApiTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QHCoreLib/QHUtil.h>
#import <QHCoreLib/QHNetwork.h>
#import <QHCoreLib/QHNetworkApi+internal.h>


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
    request.urlRequest.timeoutInterval = 30.0f;
    request.resourceType = QHNetworkResourceJSON;
    return request;
}

QH_NETWORK_API_IMPL_DIRECT(QHNetworkTestApi, QHNetworkTestApiResult);

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
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'https://httpbin.org/ip'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"https://httpbin.org/ip"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];

    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadOnNonMainThread
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'https://httpbin.org/ip'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"https://httpbin.org/ip"];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
            [expect fulfill];
        } fail:^(QHNetworkTestApi *api, NSError *error) {
            NSLog(@"error: %@", error);
            XCTAssert(NO, @"should not be here");
            [expect fulfill];
        }];
    });

    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadFailureAtClient
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://some.where.on.mars/'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"http://some.where.on.mars/"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        [expect fulfill];
    }];

    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadFailureAtServer
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://httpbin.org/status/500'"];
    
    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"http://httpbin.org/status/500"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadHttp
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://tctony.github.io/index.html'"];
    
    QHNetworkHttpApi *api = [[QHNetworkHttpApi alloc] initWithUrl:@"http:/tctony.github.io/index.html"];
    [api startWithSuccess:^(QHNetworkHttpApi *api, QHNetworkHttpApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkHttpApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadHtml
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://tctony.github.io/index.html'"];
    
    QHNetworkHtmlApi *api = [[QHNetworkHtmlApi alloc] initWithUrl:@"http://tctony.github.io/index.html"];
    [api startWithSuccess:^(QHNetworkHtmlApi *api, QHNetworkHtmlApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkHtmlApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadJson
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://httpbin.org/get'"];
    
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadJsonWithQuery
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://httpbin.org/get?t=123'"];
    
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"
                                                        queryDict:@{@"t": @"123"}];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadJsonWithQueryAndBody
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://httpbin.org/post?t=123' with body 'u=456'"];
    
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/post"
                                                        queryDict:@{@"t": @"123"}
                                                         bodyDict:@{@"u": @"456"}];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadJsonWithMultipart
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://httpbin.org/post?t=123' with body 'u=456' and file"];

    NSString *tmpDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *fileUrl = [NSURL fileURLWithPath:[tmpDir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
    [@"content of file" writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSMutableURLRequest *request = [QHNetworkMultipart requestFromUrl:@"http://httpbin.org/post"
                                                            queryDict:@{@"t": @"123"}
                                                             bodyDict:@{@"u": @"456"}
                                                     multipartBuilder:^(id<QHNetworkMultipartBuilder> builder) {
                                                         [builder appendPartWithFileUrl:fileUrl name:@"file" error:nil];
                                                     }];

    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrlRequest:request];

    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];

    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

- (void)testLoadImage
{
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@"load 'http://tctony.github.io/favicon.ico'"];
    
    QHNetworkImageApi *api = [[QHNetworkImageApi alloc] initWithUrl:@"http://tctony.github.io/favicon.ico"];
    [api startWithSuccess:^(QHNetworkImageApi *api, QHNetworkImageApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkImageApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectations:@[ expect ]
                      timeout:api.worker.request.urlRequest.timeoutInterval + 0.1];
}

@end
