//
//  QHNetworkApi.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkApi.h"
#import "QHNetworkApi+internal.h"

#import "QHLog.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHNetworkApiErrorDomain = @"QHNetworkApiErrorDomain";


@implementation QHNetworkProgress

- (NSTimeInterval)estimatedTime
{
    QHAssert(NO, @"not implemented yet");
    return 0.0;
}

@end

@interface QHNetworkApi ()

@property (nonatomic, strong) NSProgress * _Nullable upoloadProgress;
@property (nonatomic, strong) NSProgress * _Nullable downloadProgress;

@end

@implementation QHNetworkApi

- (QHNetworkRequest *)buildRequest
{
    QHAssertReturnValueOnFailure([QHNetworkRequest new], NO, @"subclass implement");
}

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:[super description]];

    NSURLRequest *request = self.worker.request.urlRequest;
    [str appendFormat:@"\n    method: %@", request.HTTPMethod];
    [str appendFormat:@"\n    url   : %@", request.URL.absoluteString];
    NSString *body = (request.HTTPBodyStream ? [request.HTTPBodyStream description] :
                      request.HTTPBody ? [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] :
                      @"");
    [str appendFormat:@"\n    body  : %@", body];

    return str;
}

QH_ASYNC_TASK_PROGRESS_IMPL(QHNetworkApi, QHNetworkProgress);

- (void)startWithSuccess:(void (^ _Nullable)(QHNetworkApi *, QHNetworkApiResult *))success
                    fail:(void (^ _Nullable)(QHNetworkApi *, NSError *))fail
{
    QHNetworkRequest *request = [self buildRequest];

    QHAssertReturnVoidOnFailure(request != nil, @"build request for %@ failed", self);

    self.worker = [QHNetworkWorker workerFromRequest:request];
    
    @weakify(self);
    [self.worker setUploadProgressHandler:^(NSProgress * _Nonnull progress) {
        @strongify(self);
        self.upoloadProgress = progress;
        [self p_updateWorkerProgress];
    }];
    [self.worker setDownloadProgressHandler:^(NSProgress * _Nonnull progress) {
        @strongify(self);
        self.downloadProgress = progress;
        [self p_updateWorkerProgress];
    }];

    [super startWithSuccess:(QHAsyncTaskSuccessBlock)success
                       fail:(QHAsyncTaskFailBlock)fail];
}

- (Class)resultClass
{
    return [QHNetworkApiResult class];
}

- (void)p_doStart
{
    @weakify(self);
    [self.worker startWithCompletionHandler:^(QHNetworkWorker *worker, QHNetworkResponse *response, NSError *error) {
        @strongify(self);

        if (self == nil || self.worker != worker || worker.isCancelled) {
            QHLogDebug(@"ignore callback from a flying worker: %@", worker);
            return;
        }

        if (error == nil) {
            QHNetworkApiResult *result = [[self resultClass] parse:response error:&error api:self];

            if (error == nil) {
                QHLogDebug(@"request: %@\nsucceed: %@", self, response.responseObject);
                [self p_fireSuccess:result];
            }
            else {
                QHLogDebug(@"request: %@\nfinished: %@\nwith error: %@", self, response.responseObject, error);
                [self p_fireFail:error];
            }
        }
        else {
            QHLogDebug(@"request: %@\nfailed: %@", self, [error description]);
            [self p_fireFail:error];
        }
    }];
}

- (void)p_doCancel
{
    [self.worker cancel];
}

- (void)p_updateWorkerProgress
{
    QHNetworkProgress *progress = [[QHNetworkProgress alloc] init];
    
    CGFloat uploadWeight = self.worker.request.progressWeight;
    uploadWeight = QHClamp(uploadWeight, 1.0, 0.0);
    
    progress.totalCount = (uint64_t)(uploadWeight * self.upoloadProgress.totalUnitCount);
    progress.completedCount = (uint64_t)(uploadWeight * self.upoloadProgress.completedUnitCount);
    
    if (self.downloadProgress) {
        progress.totalCount += (uint64_t)((1.0 - uploadWeight) * self.downloadProgress.totalUnitCount);
        progress.completedCount += (uint64_t)((1.0 - uploadWeight) * self.downloadProgress.completedUnitCount);
    } else {
        // assume downloadProgress.totalUnitCount equals upoloadProgress.totalUnitCount
        progress.totalCount += (uint64_t)((1.0 - uploadWeight) * self.upoloadProgress.totalUnitCount);
        progress.completedCount += 0;
    }
    
    [self p_fireProgress:progress];
}

- (void)p_doCollect:(NSMutableArray *)releaseOnDisposeQueue
{
    [super p_doCollect:releaseOnDisposeQueue];
    
    if (self.upoloadProgress) {
        [releaseOnDisposeQueue qh_addObject:self.upoloadProgress];
        self.upoloadProgress = nil;
    }
    if (self.downloadProgress) {
        [releaseOnDisposeQueue qh_addObject:self.downloadProgress];
        self.downloadProgress = nil;
    }
    if (self.worker) {
        [releaseOnDisposeQueue qh_addObject:self.worker];
        self.worker = nil;
    }
}

@end


@interface QHNetworkApiResult ()

@property (nonatomic, strong, readwrite) QHNetworkResponse *response;

@end

@implementation QHNetworkApiResult

+ (QHNetworkApiResult * _Nullable)parse:(QHNetworkResponse *)response
                                  error:(NSError *__autoreleasing *)error
                                    api:(QHNetworkApi *)api
{
    QHNetworkApiResult *result = [[self class] new];
    result.api = api;
    result.response = response;
    return result;
}

@end

NS_ASSUME_NONNULL_END
