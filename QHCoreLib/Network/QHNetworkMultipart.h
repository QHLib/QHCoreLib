//
//  QHNetworkMultipart.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHNetworkMultipartBuilder.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QHNetworkMultipartBuilder;

@interface QHNetworkMultipart : NSObject

+ (NSMutableURLRequest *)requestFromUrl:(NSString *)urlString
                              queryDict:(NSDictionary * _Nullable)queryDict
                               bodyDict:(NSDictionary * _Nullable)bodyDict
                       multipartBuilder:(QHNetworkMultipartBuilderBlock)builderBlock;

@end

NS_ASSUME_NONNULL_END
