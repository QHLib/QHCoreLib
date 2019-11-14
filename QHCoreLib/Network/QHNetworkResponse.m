//
//  QHNetworkResponse.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkResponse.h"
#import "QHBase.h"
#import "QHNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@implementation QHNetworkMetrics

+ (instancetype)fromURLSessionTaskTransactionMetrics:(NSURLSessionTaskTransactionMetrics *)theMetrics {

    QHNetworkMetrics *metrics = [QHNetworkMetrics new];

    metrics.host = ({
        NSString *host = [[theMetrics.request URL] host];
        NSDictionary *headers = [theMetrics.request allHTTPHeaderFields];
        if ([headers objectForKey:@"Host"]) {
            host = [headers objectForKey:@"Host"];
        }
        host;
    });
    metrics.path = [theMetrics.request.URL path];
    metrics.network = [QHNetwork sharedInstance].statusString;

    metrics.hasMetrics = YES;

#define Cost(_from, _to) (uint64_t)(([_to timeIntervalSince1970] - [_from timeIntervalSince1970]) * 1000)

    if  (!theMetrics.fetchStartDate && !theMetrics.responseEndDate) return nil;
    metrics.cost = Cost(theMetrics.fetchStartDate, theMetrics.responseEndDate);

    if (theMetrics.isReusedConnection) {
        metrics.isReuseConnection = YES;
    } else {
        metrics.isReuseConnection = NO;

        if (theMetrics.domainLookupStartDate && theMetrics.domainLookupEndDate) {
            metrics.dnsCost = Cost(theMetrics.domainLookupStartDate, theMetrics.domainLookupEndDate);
        }
        if (theMetrics.connectStartDate && theMetrics.connectEndDate) {
            metrics.tcpCost = Cost(theMetrics.connectStartDate, theMetrics.connectEndDate);
        }
        if (theMetrics.secureConnectionStartDate && theMetrics.secureConnectionEndDate) {
            metrics.isHTTPS = YES;
            metrics.tlsCost = Cost(theMetrics.secureConnectionStartDate, theMetrics.secureConnectionEndDate);
            metrics.tcpCost -= metrics.tlsCost;
            QHAssert(metrics.tcpCost > 0, @"invalid tcp cost");
        } else {
            metrics.tlsCost = 0;
        }
        metrics.connectCost = metrics.dnsCost + metrics.tcpCost + metrics.tlsCost;
    }
    if (theMetrics.isProxyConnection) {
        metrics.isBehindProxy = YES;
    }

    if (theMetrics.requestStartDate && theMetrics.requestEndDate) {
        metrics.writeCost = Cost(theMetrics.requestStartDate, theMetrics.requestEndDate);
    }
    if (theMetrics.requestEndDate && theMetrics.responseStartDate) {
        metrics.waitCost = Cost(theMetrics.requestEndDate, theMetrics.responseStartDate);
    }
    if (theMetrics.responseStartDate && theMetrics.responseEndDate) {
        metrics.readCost = Cost(theMetrics.responseStartDate, theMetrics.responseEndDate);
    }

    if (@available(iOS 13.0, *)) {
        metrics.hasDataSize = YES;

        metrics.requestSize = theMetrics.countOfRequestHeaderBytesSent + theMetrics.countOfRequestBodyBytesSent;
        metrics.requestHeaderSize = theMetrics.countOfRequestHeaderBytesSent;
        metrics.requestBodySize = theMetrics.countOfRequestBodyBytesSent;

        metrics.responseSize = theMetrics.countOfResponseHeaderBytesReceived + theMetrics.countOfResponseBodyBytesReceived;
        metrics.responseHeaderSize = theMetrics.countOfResponseHeaderBytesReceived;
        metrics.responseBodySize = theMetrics.countOfResponseBodyBytesReceived;

        metrics.ip = theMetrics.remoteAddress;
    }

    return metrics;
}

- (NSString *)description {
    return [self qh_description];
}

- (NSMutableArray<NSString *> *)qh_propertyPairs {
    NSMutableArray<NSString *> *pairs = [super qh_propertyPairs];
    [pairs addObject:[NSString stringWithFormat:@"host %@", self.host]];
    [pairs addObject:[NSString stringWithFormat:@"ip %@", self.ip]];
    [pairs addObject:[NSString stringWithFormat:@"path %@", self.path]];
    [pairs addObject:[NSString stringWithFormat:@"network %@", self.network]];
    [pairs addObject:[NSString stringWithFormat:@"hasMetrics %@", self.hasMetrics ? @"YES" : @"NO"]];
    [pairs addObject:[NSString stringWithFormat:@"cost %lld", self.cost]];
    [pairs addObject:[NSString stringWithFormat:@"isReuseConnection %@", self.isReuseConnection ? @"YES" : @"NO"]];
    [pairs addObject:[NSString stringWithFormat:@"connectCost %lld", self.connectCost]];
    [pairs addObject:[NSString stringWithFormat:@"dnsCost %lld", self.dnsCost]];
    [pairs addObject:[NSString stringWithFormat:@"tcpCost %lld", self.tcpCost]];
    [pairs addObject:[NSString stringWithFormat:@"isHTTPS %@", self.isHTTPS ? @"YES" : @"NO"]];
    [pairs addObject:[NSString stringWithFormat:@"tlsCost %lld", self.tlsCost]];
    [pairs addObject:[NSString stringWithFormat:@"isBehindProxy %@", self.isBehindProxy ? @"YES" : @"NO"]];
    [pairs addObject:[NSString stringWithFormat:@"writeCost %lld", self.writeCost]];
    [pairs addObject:[NSString stringWithFormat:@"waitCost %lld", self.waitCost]];
    [pairs addObject:[NSString stringWithFormat:@"readCost %lld", self.readCost]];
    [pairs addObject:[NSString stringWithFormat:@"hasDataSize %@", self.hasDataSize ? @"YES" : @"NO"]];
    [pairs addObject:[NSString stringWithFormat:@"requestSize %lld", self.requestSize]];
    [pairs addObject:[NSString stringWithFormat:@"requestHeaderSize %lld", self.requestHeaderSize]];
    [pairs addObject:[NSString stringWithFormat:@"requestBodySize %lld", self.requestBodySize]];
    [pairs addObject:[NSString stringWithFormat:@"responseSize %lld", self.responseSize]];
    [pairs addObject:[NSString stringWithFormat:@"responseHeaderSize %lld", self.responseHeaderSize]];
    [pairs addObject:[NSString stringWithFormat:@"responseBodySize %lld", self.responseBodySize]];
    return pairs;
}

@end

@interface QHNetworkResponse ()

@property (nonatomic,   copy, readwrite) NSURL *url;

@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic,   copy, readwrite) NSDictionary * _Nullable responseHeaders;
@property (nonatomic, assign, readwrite) long long responseLength;
@property (nonatomic, strong, readwrite) id _Nullable responseObject;

@end

@implementation QHNetworkResponse

+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary * _Nullable)responseHeaders
                  reponseLength:(long long)responseLength
                 responseObject:(id _Nullable)responseObject
{
    QHNetworkResponse *response = [[QHNetworkResponse alloc] init];

    response.url = url;
    response.statusCode = statusCode;
    response.responseHeaders = responseHeaders;
    response.responseLength = responseLength;
    response.responseObject = responseObject;

    return response;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@;", [super description]];
    [desc appendFormat:@" url: %@;", self.url];
    [desc appendFormat:@" statusCode: %d;", (int)self.statusCode];
    [desc appendFormat:@" headers: %@;", self.responseHeaders];
    [desc appendFormat:@" length: %d;", (int)self.responseLength];
    [desc appendFormat:@" object: %@;", self.responseObject];
    [desc appendFormat:@">"];
    return [NSString stringWithString:desc];
}

@end

NS_ASSUME_NONNULL_END
