//
//  QHNetworkResponse.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface QHNetworkResponse : NSObject

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSDictionary * _Nullable responseHeaders;
@property (nonatomic, readonly) NSUInteger responseLength;
@property (nonatomic, readonly) id _Nullable responseObject;


+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary * _Nullable)responseHeaders
                  reponseLength:(NSUInteger)responseLength
                 responseObject:(id _Nullable)responseObject;


@end

NS_ASSUME_NONNULL_END
