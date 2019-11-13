//
//  QHNetworkResponse.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

// all cost are in ms
// all data size are in byte
@interface QHNetworkMetrics : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *network;

@property (nonatomic, assign) BOOL hasMetrics;
@property (nonatomic, assign) int64_t cost;

@property (nonatomic, assign) BOOL isReuseConnection; // if YES, connection metrics would be 0
@property (nonatomic, assign) int64_t connectCost;
@property (nonatomic, assign) int64_t dnsCost;
@property (nonatomic, assign) int64_t tcpCost;

@property (nonatomic, assign) BOOL isHTTPS; // if YES, tlsCost would be 0
@property (nonatomic, assign) int64_t tlsCost;

@property (nonatomic, assign) BOOL isBehindProxy;

@property (nonatomic, assign) int64_t writeCost;

@property (nonatomic, assign) int64_t waitCost;

@property (nonatomic, assign) int64_t readCost;

@property (nonatomic, assign) BOOL hasDataSize;
@property (nonatomic, assign) int64_t requestSize; // header + body
@property (nonatomic, assign) int64_t requestHeaderSize;
@property (nonatomic, assign) int64_t requestBodySize;
@property (nonatomic, assign) int64_t responseSize; // header + body
@property (nonatomic, assign) int64_t responseHeaderSize;
@property (nonatomic, assign) int64_t responseBodySize;

@end

@interface QHNetworkResponse : NSObject

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSDictionary * _Nullable responseHeaders;
@property (nonatomic, readonly) long long responseLength;
@property (nonatomic, readonly) id _Nullable responseObject;


+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary * _Nullable)responseHeaders
                  reponseLength:(long long)responseLength
                 responseObject:(id _Nullable)responseObject;

@property (nonatomic, strong) QHNetworkMetrics *metrics;


@end

NS_ASSUME_NONNULL_END
