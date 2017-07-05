//
//  QHNetworkHttpApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHNetworkApi.h>


NS_ASSUME_NONNULL_BEGIN

@class QHNetworkHttpApiResult;

@interface QHNetworkHttpApi : QHNetworkApi

QH_NETWORK_API_DECL(QHNetworkHttpApi, QHNetworkHttpApiResult);

// GET url
- (instancetype)initWithUrl:(NSString *)url;

// GET url with query
- (instancetype)initWithUrl:(NSString *)url
                  queryDict:(NSDictionary *)queryDict;

// POST url with query and body
- (instancetype)initWithUrl:(NSString *)url
                  queryDict:(NSDictionary * _Nullable)queryDict
                   bodyDict:(NSDictionary *)bodyDict;

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSDictionary *queryDict;
@property (nonatomic, readonly) NSDictionary *bodyDict;


- (instancetype)initWithUrlRequest:(NSURLRequest *)urlRequest;

@end

@interface QHNetworkHttpApiResult : QHNetworkApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkHttpApi, QHNetworkHttpApiResult);

@end

NS_ASSUME_NONNULL_END
