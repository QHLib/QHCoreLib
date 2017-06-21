//
//  QHNetworkResponse.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkResponse.h"


NS_ASSUME_NONNULL_BEGIN

@interface QHNetworkResponse ()

@property (nonatomic,   copy, readwrite) NSURL *url;

@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic,   copy, readwrite) NSDictionary * _Nullable responseHeaders;
@property (nonatomic, assign, readwrite) NSUInteger responseLength;
@property (nonatomic, strong, readwrite) id _Nullable responseObject;

@end

@implementation QHNetworkResponse

+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary * _Nullable)responseHeaders
                  reponseLength:(NSUInteger)responseLength
                 responseObject:(id _Nullable)responseObject
{
    QHNetworkResponse *response = [[QHNetworkResponse alloc] init];

    response.url = url;
    response.statusCode = statusCode;
    response.responseHeaders = responseHeaders;
    response.responseLength = responseLength;
    response.responseObject = responseObject;

    return response;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@;", [super description]];
    [desc appendFormat:@" url: %@;", self.url];
    [desc appendFormat:@" statusCode: %d;", (int)self.statusCode];
    [desc appendFormat:@" headers: %@;", self.responseHeaders];
    [desc appendFormat:@" length: %d;", (int)self.responseLength];
    [desc appendFormat:@" object: %@;", self.responseObject];
    [desc appendFormat:@">"];
    return [NSString stringWithString:desc];
}

@end

NS_ASSUME_NONNULL_END
