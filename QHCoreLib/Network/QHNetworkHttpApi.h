//
//  QHNetworkHttpApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHNetworkApi.h>
#import <QHCoreLib/QHNetworkMultipartBuilder.h>

NS_ASSUME_NONNULL_BEGIN

@class QHNetworkHttpApiResult;

@interface QHNetworkHttpApi : QHNetworkApi

QH_NETWORK_API_DECL(QHNetworkHttpApi, QHNetworkHttpApiResult);

- (instancetype)init NS_UNAVAILABLE;

// GET url
- (instancetype)initWithUrl:(NSString *)url;

// GET url with query
- (instancetype)initWithUrl:(NSString *)url
                  queryDict:(NSDictionary *)queryDict NS_DESIGNATED_INITIALIZER;

// POST url with query and body
- (instancetype)initWithUrl:(NSString *)url
                  queryDict:(NSDictionary * _Nullable)queryDict
                   bodyDict:(NSDictionary *)bodyDict NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSDictionary * _Nullable queryDict;
@property (nonatomic, readonly) NSDictionary * _Nullable bodyDict;


// POST multipart to url with query and body
- (instancetype)initWithUrl:(NSString *)url
                  queryDict:(NSDictionary * _Nullable)queryDict
                   bodyDict:(NSDictionary * _Nullable)bodyDict
           multipartBuilder:(QHNetworkMultipartBuilderBlock)builderBlock NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) QHNetworkMultipartBuilderBlock _Nullable builderBlock;


// send request with arbitrary url request
- (instancetype)initWithUrlRequest:(NSURLRequest *)urlRequest NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSURLRequest * _Nullable request;

@end

#define QH_NETWORK_API_DECL_FINAL(API_TYPE, RESULT_TYPE) \
QH_NETWORK_API_DECL(API_TYPE, RESULT_TYPE) \
- (instancetype)initWithUrl:(NSString *)url NS_UNAVAILABLE; \
- (instancetype)initWithUrl:(NSString *)url queryDict:(NSDictionary *)queryDict NS_UNAVAILABLE; \
- (instancetype)initWithUrl:(NSString *)url queryDict:(NSDictionary * _Nullable)queryDict bodyDict:(NSDictionary *)bodyDict NS_UNAVAILABLE; \
- (instancetype)initWithUrl:(NSString *)url queryDict:(NSDictionary * _Nullable)queryDict bodyDict:(NSDictionary * _Nullable)bodyDict multipartBuilder:(void (^)(id<QHNetworkMultipartBuilder>))builderBlock NS_UNAVAILABLE; \
- (instancetype)initWithUrlRequest:(NSURLRequest *)urlRequest NS_UNAVAILABLE;

@interface QHNetworkHttpApiResult : QHNetworkApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkHttpApi, QHNetworkHttpApiResult);

@end

NS_ASSUME_NONNULL_END
