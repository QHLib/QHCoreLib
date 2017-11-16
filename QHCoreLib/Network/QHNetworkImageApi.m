//
//  QHNetworkImageApi.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/8.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkImageApi.h"
#import "QHNetworkApi+internal.h"

#import <UIKit/UIKit.h>

#import "QHBase+internal.h"


NS_ASSUME_NONNULL_BEGIN

@implementation QHNetworkImageApi

- (QHNetworkRequest *)buildRequest
{
    QHNetworkRequest *request = [super buildRequest];
    request.urlRequest.timeoutInterval = 30.0f;
    request.resourceType = QHNetworkResourceImage;
    return request;
}

QH_NETWORK_API_IMPL_INDIRECT(QHNetworkImageApi, QHNetworkImageApiResult,
                             QHNetworkHttpApi, QHNetworkHttpApiResult);

@end


@interface QHNetworkImageApiResult ()

@property (nonatomic, strong, readwrite) UIImage * _Nullable image;

@end

@implementation QHNetworkImageApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkImageApi, QHNetworkImageApiResult) {
    if (QH_IS(response.responseObject, UIImage)) {
        result.image = (UIImage *)response.responseObject;
    }
    else {
        QHCoreLibWarn(@"%@ get image failed: %@\n%@",
                      self,
                      response.responseObject,
                      QHCallStackShort());
        result.image = nil;
    }
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end

NS_ASSUME_NONNULL_END
