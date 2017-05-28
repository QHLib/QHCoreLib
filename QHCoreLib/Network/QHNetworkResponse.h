//
//  QHNetworkResponse.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import <Foundation/Foundation.h>


@interface QHNetworkResponse : NSObject

@property (nonatomic, readonly) NSURL  *url;

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSUInteger responseLength;
@property (nonatomic, readonly) id responseObject;


+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary *)responseHeaders
                  reponseLength:(NSUInteger)responseLength
                 responseObject:(id)responseObject;


@end
