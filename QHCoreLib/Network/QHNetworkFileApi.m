//
//  QHNetworkFileApi.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/11/14.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkFileApi.h"
#import "QHNetworkApi+internal.h"

#import "QHBase+internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation QHNetworkFileApi

QH_NETWORK_API_IMPL_INDIRECT(QHNetworkFileApi, QHNetworkFileApiResult,
                             QHNetworkHttpApi, QHNetworkHttpApiResult);

- (QHNetworkRequest *)buildRequest
{
    QHNetworkRequest *request = [super buildRequest];
    request.urlRequest.timeoutInterval = CGFLOAT_MAX;
    request.progressWeight = 0.0;
    request.resourceType = QHNetworkResourceFile;
    if (!self.targetPath) {
        QHCoreLibWarn(@"target path of file api is nil: %@", self);
    }
    request.targetFilePath = self.targetPath;
    return request;
}

@end

@interface QHNetworkFileApiResult ()

@property (nonatomic, copy, readwrite) NSString * _Nullable filePath;

@end

@implementation QHNetworkFileApiResult

QH_NETWORK_API_RESULT_IMPL_SUPER(QHNetworkFileApi, QHNetworkFileApiResult) {
    QH_AS(response.responseObject, NSURL, fileURL)
    if (fileURL && [fileURL isFileURL]) {
        result.filePath = fileURL.absoluteString;
    }
    else {
        QHCoreLibWarn(@"%@ get file failed: %@\n%@",
                      self,
                      response.responseObject,
                      QHCallStackShort());
        result.filePath = nil;
    }
}
QH_NETWORK_API_RESULT_IMPL_RETURN;

@end

NS_ASSUME_NONNULL_END
