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

        default:
            QHAssert(NO, @"invalid resource type: %d", (int)self.request.resourceType);
    }
}

- (void)p_doStart
{
    self.task = [[self p_manager] dataTaskWithRequest:self.request.urlRequest
                                    completionHandler:[self taskCompletionHandler]];
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

- (void(^)(NSURLResponse * _Nonnull response,
           id  _Nullable responseObject,
           NSError * _Nullable error))taskCompletionHandler
{
    @weakify(self);

    return ^(NSURLResponse * _Nonnull response,
             id  _Nullable responseObject,
             NSError * _Nullable error) {
        
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
        
        [self p_doCompletion:self
                    response:workerResponse
                       error:error];
    };
}

@end

NS_ASSUME_NONNULL_END
