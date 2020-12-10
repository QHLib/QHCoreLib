//
//  QHNetworkWorkerAFHTTPRequestOperation.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "_QHNetworkWorkerAFHTTPRequestOperation.h"

#import "QHAFHTTPSessionManager.h"

#import "QHBase+internal.h"
#import "QHProfiler.h"
#import "QHNetwork.h"


NS_ASSUME_NONNULL_BEGIN

static QHAFHTTPSessionManager *httpManager;
static QHAFHTTPSessionManager *htmlManager;
static QHAFHTTPSessionManager *jsonManager;
static QHAFHTTPSessionManager *imageManager;

NSString * const QHNetworkWorkerAFHTTPRequestOperationDidReceiveDataNotification
    = @"QHNetworkWorkerAFHTTPRequestOperationDidReceiveDataNotification";

@interface QHNetworkWorkerAFHTTPRequestOperation ()

@property (nonatomic, strong) NSURLSessionTask * _Nullable task;

@end


@implementation QHNetworkWorkerAFHTTPRequestOperation

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        httpManager = [QHAFHTTPSessionManager manager];
        httpManager.responseSerializer = [QHAFHTTPResponseSerializer serializer];

        htmlManager = [QHAFHTTPSessionManager manager];
        htmlManager.responseSerializer = [QHAFHTMLResponseSerializer serializer];

        jsonManager = [QHAFHTTPSessionManager manager];
        [jsonManager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:QHNetworkWorkerAFHTTPRequestOperationDidReceiveDataNotification
                                                                object:dataTask.qh_handy_weakCarry
                                                              userInfo:@{ @"data": data, }];
        }];
        jsonManager.responseSerializer = ({
            // QHAFCompoundResponseSerializer会兜底到QHAFHTTPResponseSerializer
            // 只要返回2xx都算成功，让stream最后能往下走
            // tts stream和json要走同一个session，复用tls连接
            [QHAFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
                [QHAFJSONResponseSerializer serializer],
            ]];
        });

        imageManager = [QHAFHTTPSessionManager manager];
        imageManager.responseSerializer = [[QHAFImageResponseSerializer alloc] init];
    });
}

+ (void)cancelAll
{
    [httpManager.session invalidateAndCancel];
    [htmlManager.session invalidateAndCancel];
    [jsonManager.session invalidateAndCancel];
    [imageManager.session invalidateAndCancel];
}

+ (void)setTrustCerts:(NSArray<NSString *> *)certFiles
{
    NSArray *certs = [certFiles qh_mappedArrayWithBlock:^id _Nonnull(NSUInteger idx,
                                                                     NSString * _Nonnull obj) {
        return [NSData dataWithContentsOfFile:obj];
    }];
    QHAFSecurityPolicy *policy = [QHAFSecurityPolicy policyWithPinningMode:QHAFSSLPinningModeCertificate
                                                    withPinnedCertificates:[NSSet setWithArray:certs]];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = YES;

    httpManager.securityPolicy = policy;
    htmlManager.securityPolicy = policy;
    jsonManager.securityPolicy = policy;
    imageManager.securityPolicy = policy;
}

+ (void)setAllowArbitraryHttps {
    QHAFSecurityPolicy *policy = [QHAFSecurityPolicy defaultPolicy];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;

    httpManager.securityPolicy = policy;
    htmlManager.securityPolicy = policy;
    jsonManager.securityPolicy = policy;
    imageManager.securityPolicy = policy;
}

- (instancetype)initWithRequest:(QHNetworkRequest *)request
{
    self = [super initWithRequest:request];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(p_didReceiveData:)
                                                     name:QHNetworkWorkerAFHTTPRequestOperationDidReceiveDataNotification
                                                   object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, operation: %@>",
            [super description], self.task];
}

- (QHAFHTTPSessionManager *)p_manager
{
    switch (self.request.resourceType) {
        case QHNetworkResourceHTTP:
            return httpManager;
            
        case QHNetworkResourceHTML:
            return htmlManager;

        case QHNetworkResourceJSON:
            return jsonManager;

        case QHNetworkResourceImage:
            return imageManager;

        case QHNetworkResourceFile:
            return httpManager;

        default:
            QHAssert(NO, @"invalid resource type: %d", (int)self.request.resourceType);
            return httpManager;
    }
}

- (void)p_doStart
{
    if (self.request.resourceType != QHNetworkResourceFile) {
        [self p_createNormalTask];
    } else {
        [self p_createDownloadTask];
    }
    self.task.qh_handy_weakCarry = self;

    QHAssertReturnVoidOnFailure(self.task, @"create task failed");

    self.task.priority = [self p_getPriority];

    [self.task resume];
}

- (float)p_getPriority
{
    switch (self.request.priority) {
        case QHNetworkRequestPriorityDeafult:
            return NSURLSessionTaskPriorityDefault;

        case QHNetworkRequestPriorityHigh:
            return NSURLSessionTaskPriorityHigh;

        case QHNetworkRequestPriorityLow:
            return NSURLSessionTaskPriorityLow;

        default:
            return NSURLSessionTaskPriorityDefault;
            break;
    }
}

- (void)p_doCancel
{
    [self.task cancel];
    self.task = nil;
}

#pragma mark - normal task

- (void)p_createNormalTask
{
    static NSDictionary *managerForResourceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerForResourceType = @{
                                   @(QHNetworkResourceHTTP): httpManager,
                                   @(QHNetworkResourceHTML): htmlManager,
                                   @(QHNetworkResourceJSON): jsonManager,
                                   @(QHNetworkResourceImage): imageManager,
                                   };
    });

    QHAFHTTPSessionManager *manager  = managerForResourceType[@(self.request.resourceType)];

    QHAssertReturnVoidOnFailure(manager, @"invalid resource type: %d", (int)self.request.resourceType);

    @weakify(self);
    self.task = [manager dataTaskWithRequest:self.request.urlRequest
                              uploadProgress:({
        ^(NSProgress * _Nonnull uploadProgress) {
            @strongify(self);

            [self p_fireUploadProgress:uploadProgress];
        };
    })
                            downloadProgress:({
        ^(NSProgress * _Nonnull downloadProgress) {
            @strongify(self);

            [self p_fireDownloadProgress:downloadProgress];
        };
    })
                           completionHandler:({
        ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            @strongify(self);
            
            if (self.isCancelled) {
                return;
            }
            
            QH_AS(response, NSHTTPURLResponse, httpResponse);
            QHNetworkResponse *workerResponse = [QHNetworkResponse responseWithURL:httpResponse.URL
                                                                        statusCode:httpResponse.statusCode
                                                                   responseHeaders:httpResponse.allHeaderFields
                                                                     reponseLength:httpResponse.expectedContentLength
                                                                    responseObject:responseObject];
            workerResponse.metrics = [self p_getTaskMetrics];

            [self p_fireCompletionWithResponse:workerResponse
                                         error:error];
        };
    })];
}

- (QHNetworkMetrics * _Nullable)p_getTaskMetrics {
    if (!@available(iOS 10.0, *)) return nil;
    if (!self.task.qh_metrics) return nil;

    NSURLSessionTaskTransactionMetrics *theMetrics = [[self.task.qh_metrics transactionMetrics] lastObject];
    if (!theMetrics) return nil;

    return [QHNetworkMetrics fromURLSessionTaskTransactionMetrics:theMetrics];
}

#pragma mark - download task

- (void)p_createDownloadTask
{
    @weakify(self);
    self.task = [httpManager downloadTaskWithRequest:self.request.urlRequest
                                            progress:({
        ^(NSProgress * _Nonnull downloadProgress) {
            @strongify(self);
            
            [self p_fireDownloadProgress:downloadProgress];
        };
    })
                                         destination:({
        ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            @strongify(self);
            
            if (self.request.targetFilePath) {
                return [NSURL fileURLWithPath:self.request.targetFilePath];
            }
            return targetPath;
        };
    })
                                   completionHandler:({
        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            @strongify(self);
            
            QH_AS(response, NSHTTPURLResponse, httpResponse);
            QHNetworkResponse *workerResponse = [QHNetworkResponse responseWithURL:httpResponse.URL
                                                                        statusCode:httpResponse.statusCode
                                                                   responseHeaders:httpResponse.allHeaderFields
                                                                     reponseLength:httpResponse.expectedContentLength
                                                                    responseObject:filePath];
            
            [self p_fireCompletionWithResponse:workerResponse
                                         error:error];
        };
    })];
}

#pragma mark -

- (void)p_didReceiveData:(NSNotification *)noti {
    NSData *data = [noti.userInfo objectForKey:@"data"];
    QHAssertReturnVoidOnFailure(data != nil, @"data is nil");

    [self p_fireStreamData:data];
}

@end

NS_ASSUME_NONNULL_END
