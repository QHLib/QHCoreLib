//
//  QHNetworkWorkerAFHTTPRequestOperation.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "_QHNetworkWorkerAFHTTPRequestOperation.h"

#import "AFHTTPRequestOperationManager.h"

#import "QHBase+internal.h"


NS_ASSUME_NONNULL_BEGIN

static AFHTTPRequestOperationManager *httpManager;
static AFHTTPRequestOperationManager *htmlManager;
static AFHTTPRequestOperationManager *jsonManager;
static AFHTTPRequestOperationManager *imageManager;


@interface QHNetworkWorkerAFHTTPRequestOperation ()

@property (nonatomic, strong) AFHTTPRequestOperation * _Nullable operation;

@end


@implementation QHNetworkWorkerAFHTTPRequestOperation

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        AFSecurityPolicy *securityPolicy = ({
            AFSecurityPolicy *policy = [AFSecurityPolicy defaultPolicy];
            policy.validatesCertificateChain = YES;
            policy.allowInvalidCertificates = NO;
            policy.validatesDomainName = YES;
            policy;
        });

        httpManager = [AFHTTPRequestOperationManager manager];
        httpManager.operationQueue = [self sharedNetworkQueue];
        httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpManager.securityPolicy = securityPolicy;
        
        htmlManager = [AFHTTPRequestOperationManager manager];
        htmlManager.operationQueue = [self sharedNetworkQueue];
        htmlManager.responseSerializer = [AFHTMLResponseSerializer serializer];
        htmlManager.securityPolicy = securityPolicy;

        jsonManager = [AFHTTPRequestOperationManager manager];
        jsonManager.operationQueue = [self sharedNetworkQueue];
        jsonManager.responseSerializer = [AFJSONResponseSerializer serializer];
        jsonManager.securityPolicy = securityPolicy;

        imageManager = [AFHTTPRequestOperationManager manager];
        imageManager.operationQueue = [self sharedNetworkQueue];
        imageManager.responseSerializer = [[AFImageResponseSerializer alloc] init];
        imageManager.securityPolicy = securityPolicy;
    });
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
            [super description], self.operation];
}

- (AFHTTPRequestOperationManager *)p_manager
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
    self.operation = [[self p_manager] HTTPRequestOperationWithRequest:self.request.urlRequest
                                                               success:[self successBlock]
                                                               failure:[self failureBlock]];

    self.operation.queuePriority = [self p_getPriority];

    [[[self class] sharedNetworkQueue] addOperation:self.operation];
}

- (NSOperationQueuePriority)p_getPriority
{
    switch (self.request.priority) {
        case QHNetworkRequestPriorityDeafult:
            return NSOperationQueuePriorityNormal;

        case QHNetworkRequestPriorityHigh:
            return NSOperationQueuePriorityHigh;

        case QHNetworkRequestPriorityLow:
            return NSOperationQueuePriorityLow;

        default:
            return NSOperationQueuePriorityNormal;
            break;
    }
}

- (void)p_doCancel
{
    [self.operation cancel];
    self.operation = nil;
}

- (void(^)(AFHTTPRequestOperation *operation, id responseObject))successBlock
{
    @weakify(self);

    return ^(AFHTTPRequestOperation *operation, id responseObject) {

        @strongify(self);

        if (operation.cancelled == YES
            || self == nil || self.operation != operation) {
            return;
        }

        QHNetworkResponse *response = [QHNetworkResponse responseWithURL:operation.request.URL
                                                              statusCode:operation.response.statusCode
                                                         responseHeaders:operation.response.allHeaderFields
                                                           reponseLength:operation.responseData.length
                                                          responseObject:responseObject];

        [self p_doCompletion:self
                    response:response
                       error:nil];
    };
}

- (void(^)(AFHTTPRequestOperation *operation,  NSError *error))failureBlock
{
    @weakify(self);

    return ^(AFHTTPRequestOperation *operation, NSError *error) {

        @strongify(self);

        if (operation.cancelled == YES
            || self == nil || self.operation != operation) {
            return;
        }

        QHNetworkResponse *response = [QHNetworkResponse responseWithURL:operation.request.URL
                                                              statusCode:operation.response.statusCode
                                                         responseHeaders:operation.response.allHeaderFields
                                                           reponseLength:operation.responseData.length
                                                          responseObject:nil];

        [self p_doCompletion:self
                    response:response
                       error:error];
    };
}

- (int)connectCost
{
    return self.operation.getConnectTimeInMiliseconds;
}

- (int)transportCost
{
    return self.operation.getTransportTimeInMiliseconds;
}

- (int)requestCost
{
    return self.operation.getRequestTimeInMiliseconds;
}

@end

NS_ASSUME_NONNULL_END
