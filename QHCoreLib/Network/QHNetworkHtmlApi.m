//
//  QHNetworkHtmlApi.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/9.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkHtmlApi.h"
#import "QHNetworkApi+internal.h"

#import "QHBase+internal.h"


NS_ASSUME_NONNULL_BEGIN

@implementation QHNetworkHtmlApi

QH_NETWORK_API_IMPL_INDIRECT(QHNetworkHtmlApi, QHNetworkHtmlApiResult,
                             QHNetworkHttpApi, QHNetworkHttpApiResult);

- (QHNetworkRequest *)buildRequest
{
    QHNetworkRequest *request = [super buildRequest];
    request.resourceType = QHNetworkResourceHTML;
    return request;
}

@end

@interface QHNetworkHtmlApiResult ()

@property (nonatomic, copy, readwrite) NSString * _Nullable html;

@end

@implementation QHNetworkHtmlApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkHtmlApi, QHNetworkHtmlApiResult) {
    if (QH_IS_STRING(response.responseObject)) {
        result.html = (NSString *)response.responseObject;
    }
    else {
        QHCoreLibWarn(@"%@ get html failed: %@\n%@",
                      self,
                      response.responseObject,
                      QHCallStackShort());
        result.html = nil;
    }
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end

NS_ASSUME_NONNULL_END
