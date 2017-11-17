//
//  QHNetworkWorkerAFHTTPRequestOperation.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "_QHNetworkWorkerAFHTTPRequestOperation.h"

#import "AFHTTPSessionManager.h"

#import "QHBase+internal.h"
#import "QHProfiler.h"


NS_ASSUME_NONNULL_BEGIN

static AFHTTPSessionManager *httpManager;
static AFHTTPSessionManager *htmlManager;
static AFHTTPSessionManager *jsonManager;
static AFHTTPSessionManager *imageManager;


@interface QHNetworkWorkerAFHTTPRequestOperation ()

@property (nonatomic, strong) NSURLSessionTask * _Nullable task;

@end


@implementation QHNetworkWorkerAFHTTPRequestOperation

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        httpManager = [AFHTTPSessionManager manager];
        httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        htmlManager = [AFHTTPSessionManager manager];
        htmlManager.responseSerializer = [AFHTMLResponseSerializer serializer];

        jsonManager = [AFHTTPSessionManager manager];
        jsonManager.responseSerializer = [AFJSONResponseSerializer serializer];

        imageManager = [AFHTTPSessionManager manager];
        imageManager.responseSerializer = [[AFImageResponseSerializer alloc] init];
    });
}

+ (void)cancelAll
{
    [httpManager.session invalidateAndCancel];
    [htmlManager.session invalidateAndCancel];
    [jsonManager.session invalidateAndCancel];
    [imageManager.session invalidateAndCancel];
}

- (instancetype)initWithRequest:(QHNetworkRequest *)request
{
    self = [super initWithRequest:request];
    if (self) {
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, operation: %@>",
            [super description], self.task];
}

- (AFHTTPSessionManager *)p_manager
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

    AFHTTPSessionManager *manager  = managerForResourceType[@(self.request.resourceType)];

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
            
            [self p_fireCompletionWithResponse:workerResponse
                                         error:error];
        };
    })];
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

@end

NS_ASSUME_NONNULL_END
