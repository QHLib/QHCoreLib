//
//  QHNetworkMultipartBuilder.h
//  QHCoreLib
//
//  Created by changtang on 2017/7/11.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHNetworkMultipartBuilder_h
#define QHNetworkMultipartBuilder_h

#import <Foundation/Foundation.h>

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

- (BOOL)appendPartWithFileUrl:(NSURL *)fileUrl
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error;

- (BOOL)appendPartWithFileUrl:(NSURL *)fileUrl
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

typedef void (^QHNetworkMultipartBuilderBlock)(id<QHNetworkMultipartBuilder> builder);

#endif /* QHNetworkMultipartBuilder_h */
