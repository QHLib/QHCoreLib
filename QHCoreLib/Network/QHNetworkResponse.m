//
//  QHNetworkResponse.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkResponse.h"


@interface QHNetworkResponse ()

@property (nonatomic, assign, readwrite) NSURL  *url;

@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic, assign, readwrite) NSDictionary *responseHeaders;
@property (nonatomic, assign, readwrite) NSUInteger responseLength;
@property (nonatomic, assign, readwrite) id responseObject;

@end

@implementation QHNetworkResponse

+ (instancetype)responseWithURL:(NSURL *)url
                     statusCode:(NSInteger)statusCode
                responseHeaders:(NSDictionary *)responseHeaders
                  reponseLength:(NSUInteger)responseLength
                 responseObject:(id)responseObject
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
