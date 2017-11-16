//
//  QHNetworkImageApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/8.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHNetworkHttpApi.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@class QHNetworkImageApiResult;

@interface QHNetworkImageApi : QHNetworkHttpApi

QH_NETWORK_API_DECL(QHNetworkImageApi, QHNetworkImageApiResult);

@end

@interface QHNetworkImageApiResult : QHNetworkHttpApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkImageApi, QHNetworkImageApiResult);

@property (nonatomic, readonly) UIImage * _Nullable image;

@end

NS_ASSUME_NONNULL_END
