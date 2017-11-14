//
//  QHCoreLibNetworkApiTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHUtil.h"
#import "QHNetwork.h"
#import "QHNetworkApi+internal.h"


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

@class QHNetworkTestFinalApiResult;

@interface QHNetworkTestFinalApi : QHNetworkApi

QH_NETWORK_API_DECL_FINAL(QHNetworkTestFinalApi, QHNetworkTestFinalApiResult);

@end

@interface QHNetworkTestFinalApiResult : QHNetworkApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkTestFinalApi, QHNetworkTestFinalApiResult);

@end

@implementation QHNetworkTestFinalApi

QH_NETWORK_API_IMPL_DIRECT(QHNetworkTestFinalApi, QHNetworkTestFinalApiResult);

@end

@implementation QHNetworkTestFinalApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkTestFinalApi, QHNetworkTestFinalApiResult) {
    // do nothing
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end


@interface QHCoreLibNetworkApiTests : XCTestCase

@end

@implementation QHCoreLibNetworkApiTests

- (void)testLoadSucceed
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'https://httpbin.org/ip'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"https://httpbin.org/ip"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadOnNonMainThread
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'https://httpbin.org/ip'"];

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

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadFailureAtClient
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://9.9.9.9'"];

    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"http://9.9.9.9/"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadFailureAtServer
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/status/500'"];
    
    QHNetworkTestApi *api = [[QHNetworkTestApi alloc] initWithUrl:@"http://httpbin.org/status/500"];
    [api startWithSuccess:^(QHNetworkTestApi *api, QHNetworkTestApiResult *result) {
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    } fail:^(QHNetworkTestApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadHttp
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/'"];
    
    QHNetworkHttpApi *api = [[QHNetworkHttpApi alloc] initWithUrl:@"http://httpbin.org/"];
    [api startWithSuccess:^(QHNetworkHttpApi *api, QHNetworkHttpApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkHttpApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadHtml
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/'"];
    
    QHNetworkHtmlApi *api = [[QHNetworkHtmlApi alloc] initWithUrl:@"http://httpbin.org/"];
    [api startWithSuccess:^(QHNetworkHtmlApi *api, QHNetworkHtmlApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkHtmlApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadJson
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/get'"];
    
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadInvalidJson
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/status/400'"];

    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/status/400"];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadJsonWithQuery
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/get?t=123'"];
    
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/get"
                                                        queryDict:@{@"t": @"123"}];
    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadJsonWithQueryAndBody
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/post?t=123' with body 'u=456'"];
    
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
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadJsonWithMultipart
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/post?t=123' with body 'u=456' and file"];

    NSString *tmpDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *fileUrl = [NSURL fileURLWithPath:[tmpDir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
    [@"content of file" writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];

    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrl:@"http://httpbin.org/post"
                                                        queryDict:@{@"t": @"123"}
                                                         bodyDict:@{@"u": @"456"}
                                                 multipartBuilder:^(id<QHNetworkMultipartBuilder> builder) {
                                                     [builder appendPartWithFileUrl:fileUrl name:@"file" error:nil];
                                                 }];

    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadJsonWithUrlRequest
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://httpbin.org/get"];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.org/get"]];
    QHNetworkJsonApi *api = [[QHNetworkJsonApi alloc] initWithUrlRequest:urlRequest];

    [api startWithSuccess:^(QHNetworkJsonApi *api, QHNetworkJsonApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkJsonApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];

    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testLoadImage
{
    XCTestExpectation *expect = [self expectationWithDescription:@"load 'http://tctony.github.io/favicon.ico'"];

    QHNetworkImageApi *api = [[QHNetworkImageApi alloc] initWithUrl:@"http://tctony.github.io/favicon.ico"];
    [api startWithSuccess:^(QHNetworkImageApi *api, QHNetworkImageApiResult *result) {
        [expect fulfill];
    } fail:^(QHNetworkImageApi *api, NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssert(NO, @"should not be here");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:api.worker.request.urlRequest.timeoutInterval + 0.1
                                 handler:nil];
}

- (void)testFinal
{
    // should warn not available
//    QHNetworkTestFinalApi *api = [[QHNetworkTestFinalApi alloc] initWithUrl:@""];
}

@end
