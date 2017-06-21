//
//  QHNetworkMultipart.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHBase.h>


NS_ASSUME_NONNULL_BEGIN

@protocol QHNetworkMultipartBuilder;

@interface QHNetworkMultipart : NSObject

+ (NSMutableURLRequest *)requestFromUrl:(NSString *)urlString
                              queryDict:(NSDictionary * _Nullable)queryDict
                               bodyDict:(NSDictionary * _Nullable)bodyDict
                       multipartBuilder:(void (^)(id<QHNetworkMultipartBuilder> builder))builderBlock;

@end


@protocol QHNetworkMultipartBuilder <NSObject>

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name;

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         name:(NSString *)name
                         body:(NSData *)body;

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                     mimieType:(NSString *)mimeType;

- (void)appendPartWithFileUrl:(NSURL *)fileUrl
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error;

- (void)appendPartWithFileUrl:(NSURL *)fileUrl
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __autoreleasing *)error;

- (void)appendPartWithInputStream:(NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(uint64_t)length
                         mimeType:(NSString *)mimeType;

@end

NS_ASSUME_NONNULL_END
