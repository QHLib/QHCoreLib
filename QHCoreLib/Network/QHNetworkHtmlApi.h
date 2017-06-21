//
//  QHNetworkHtmlApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/9.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHNetworkHttpApi.h>


NS_ASSUME_NONNULL_BEGIN

@class QHNetworkHtmlApiResult;

@interface QHNetworkHtmlApi : QHNetworkHttpApi

QH_NETWORK_API_DECL(QHNetworkHtmlApi, QHNetworkHtmlApiResult);

@end

@interface QHNetworkHtmlApiResult : QHNetworkHttpApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkHtmlApi, QHNetworkHtmlApiResult);

@property (nonatomic, readonly) NSString * _Nullable html;

@end

NS_ASSUME_NONNULL_END
