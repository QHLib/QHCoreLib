//
//  QHNetworkStreamApi.h
//  QHCoreLib
//
//  Created by changtang on 2020/12/10.
//  Copyright © 2020 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHNetworkHttpApi.h>

NS_ASSUME_NONNULL_BEGIN

@class QHNetworkStreamApiResult;

@interface QHNetworkStreamApi : QHNetworkHttpApi

QH_NETWORK_API_DECL(QHNetworkStreamApi, QHNetworkStreamApiResult);

@end

@interface QHNetworkStreamApiResult : QHNetworkHttpApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkStreamApi, QHNetworkStreamApiResult);

// caller should aggregate data with streamDataBlock

@end

NS_ASSUME_NONNULL_END
