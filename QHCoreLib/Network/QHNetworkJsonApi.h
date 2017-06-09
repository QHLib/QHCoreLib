//
//  QHNetworkJsonApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHNetworkHttpApi.h>

@class QHNetworkJsonApiResult;

@interface QHNetworkJsonApi : QHNetworkHttpApi

QH_NETWORK_API_DECL(QHNetworkJsonApi, QHNetworkJsonApiResult);

@end

@interface QHNetworkJsonApiResult : QHNetworkHttpApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkJsonApi, QHNetworkJsonApiResult);

@property (nonatomic, readonly) NSString *json;

@end
