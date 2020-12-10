//
//  QHNetworkStreamApi.m
//  QHCoreLib
//
//  Created by changtang on 2020/12/10.
//  Copyright © 2020 TCTONY. All rights reserved.
//

#import "QHNetworkStreamApi.h"

#import "QHNetworkApi+internal.h"

#import "QHBase+internal.h"


@implementation QHNetworkStreamApi

- (QHNetworkRequest *)buildRequest
{
    QHNetworkRequest *request = [super buildRequest];
    request.resourceType = QHNetworkResourceTTSStream;
    return request;
}

QH_NETWORK_API_IMPL_INDIRECT(QHNetworkStreamApi, QHNetworkStreamApiResult,
                             QHNetworkHttpApi, QHNetworkHttpApiResult);

@end


@interface QHNetworkStreamApiResult ()

@end

@implementation QHNetworkStreamApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkStreamApi, QHNetworkStreamApiResult) {
    // do nothing
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end
