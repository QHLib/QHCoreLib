//
//  QHNetworkFileApi.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/11/14.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHNetworkHttpApi.h>

NS_ASSUME_NONNULL_BEGIN

@class QHNetworkFileApiResult;

@interface QHNetworkFileApi : QHNetworkHttpApi

QH_NETWORK_API_DECL(QHNetworkFileApi, QHNetworkFileApiResult);

@property (nonatomic, copy) NSString *targetPath;

@end

@interface QHNetworkFileApiResult : QHNetworkHttpApiResult

QH_NETWORK_API_RESULT_DECL(QHNetworkFileApi, QHNetworkHttpApi);

@property (nonatomic, copy, readonly) NSString * _Nullable filePath;

@end

NS_ASSUME_NONNULL_END
