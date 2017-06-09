//
//  QHNetworkApi.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHNetworkApi.h"
#import "QHNetworkApi+internal.h"

#import "QHDefines.h"
#import "QHAsserts.h"
#import "QHLogUtil.h"


@interface QHNetworkApiResult ()

@property (nonatomic, strong, readwrite) QHNetworkResponse *response;

@end


NSString * const QHNetworkApiErrorDomain = @"QHNetworkApiErrorDomain";


@implementation QHNetworkApi

- (QHNetworkRequest *)buildRequest
{
    QHAssertReturnValueOnFailure(nil, NO, @"subclass implement");
}

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:[super description]];

    NSURLRequest *request = self.worker.request.urlRequest;
    [str appendFormat:@"\n    method: %@", request.HTTPMethod];
    [str appendFormat:@"\n    url   : %@", request.URL.absoluteString];
    NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [str appendFormat:@"\n    body  : %@", body];

    return str;
}

- (void)loadWithSuccess:(void (^)(QHNetworkApi *, QHNetworkApiResult *))success
                   fail:(void (^)(QHNetworkApi *, NSError *))fail
{
    self.successBlock = success;
    self.failBlock = fail;

    QHNetworkRequest *request = [self buildRequest];

    QHAssertReturnVoidOnFailure(request != nil,
                                @"invalid request: %@", request);

    QHAssertReturnVoidOnFailure(self.worker == nil,
                                @"reuse of api object (%@) is not supported", self);

    self.worker = [QHNetworkWorker workerFromRequest:request];

    @weakify(self);
    [self.worker startWithCompletionHandler:^(QHNetworkWorker *worker, QHNetworkResponse *response, NSError *error) {

        @strongify(self);

        if (self == nil || self.worker != worker || worker.isCancelled) {
            [self disposeOnFinish];

            return;
        }

        if (error == nil) {
            QHNetworkApiResult *result = [[self resultClass] parse:response error:&error api:self];

            if (error == nil) {
                QHLogDebug(@"request: %@\nsucceed: %@", self, response.responseObject);
                if (self.successBlock != nil) {
                    self.successBlock(self, result);
                }
            }
            else {
                QHLogDebug(@"request: %@\nfinished: %@", self, (error.localizedFailureReason ?: error.localizedDescription));
                if (self.failBlock != nil) {
                    self.failBlock(self, error);
                }
            }
        }
        else {
            QHLogDebug(@"request: %@\nfailed: %@", self, (error.localizedFailureReason ?: error.localizedDescription));
            if (self.failBlock != nil) {
                self.failBlock(self, error);
            }
        }

        [self disposeOnFinish];
    }];
}

- (Class)resultClass
{
    return [QHNetworkApiResult class];
}

- (void)disposeOnFinish
{
    self.successBlock = nil;
    self.failBlock = nil;
    self.worker = nil;
}

- (void)cancel
{
    self.successBlock = nil;
    self.failBlock = nil;

    [self.worker cancel];
    self.worker = nil;
}

- (void)dealloc
{
    [self cancel];
}

@end


@implementation QHNetworkApiResult

+ (QHNetworkApiResult *)parse:(QHNetworkResponse *)response
                        error:(NSError *__autoreleasing *)error
                          api:(QHNetworkApi *)api
{
    QHNetworkApiResult *result = [[self class] new];
    result.api = api;
    result.response = response;
    return result;
}

@end
