//
//  QHNetworkUtil.m
//  QQHouse
//
//  Created by changtang on 16/12/21.
//
//

#import "QHNetworkUtil.h"


NS_ASSUME_NONNULL_BEGIN

NSString * const QHNetWorkHttpMethodGet =   @"GET";
NSString * const QHNetWorkHttpMethodPost =  @"POST";

@implementation QHNetworkUtil

+ (NSString *)appendQuery:(NSDictionary<NSString *, NSString *> *)dict
                    toUrl:(NSString *)url
{
    return [self appendQuery:dict toUrl:url sortByKey:QHNetworkQueryKeyOrderNone];
}

+ (NSString *)appendQuery:(NSDictionary<NSString *, NSString *> *)dict
                    toUrl:(NSString *)url
                sortByKey:(QHNetworkQueryKeyOrder)order
{
    static NSCharacterSet *allowedCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    });

    if (QH_IS_DICTIONARY(dict) == NO || dict.count == 0) return url;
    if (url == nil) url = @"";

    NSMutableString *query = [NSMutableString string];

    NSArray *sortedKeys = [dict allKeys];

    if (order != QHNetworkQueryKeyOrderNone) {
        sortedKeys = [sortedKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            QHAssertReturnValueOnFailure(NSOrderedSame,
                                         QH_IS(obj1, NSString) && QH_IS(obj2, NSString),
                                         @"keys should be string: %@ %@",
                                         obj1, obj2);

            NSString *str1 = obj1, *str2 = obj2;
            return ((order == QHNetworkQueryKeyOrderAscending ? 1 : -1) * [str1 compare:str2]);
        }];
    }
    
    [sortedKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id obj = dict[key];
        QHAssertReturnVoidOnFailure(QH_IS(key, NSString) && QH_IS(obj, NSString),
                                    @"key and value both should be string: %@ %@",
                                    key, obj);

        [query appendFormat:@"&%@=%@",
         [key stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet],
         [obj stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet]];
    }];

    if (url.length == 0) {
        [query replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    else if ([url rangeOfString:@"?"].location == NSNotFound) {
        [query replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
    }

    return [url stringByAppendingString:query];
}

+ (NSMutableURLRequest *)requestFromURL:(NSString *)urlString
{
    return [self requestFromMethod:QHNetWorkHttpMethodGet
                               url:urlString
                         queryDict:nil
                          bodyDict:nil];
}

+ (NSMutableURLRequest *)requestFromMethod:(NSString *)method
                                       url:(NSString *)urlString
                                 queryDict:(NSDictionary * _Nullable)queryDict
                                  bodyDict:(NSDictionary * _Nullable)bodyDict
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.HTTPMethod = method;

    urlString = [self appendQuery:queryDict toUrl:urlString sortByKey:QHNetworkQueryKeyOrderAscending];
    request.URL = [NSURL URLWithString:urlString];

    if ([method isEqualToString:QHNetWorkHttpMethodPost]) {
        NSString *bodyString = [self appendQuery:bodyDict toUrl:@"" sortByKey:QHNetworkQueryKeyOrderAscending];
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }

    return request;
}

@end

NS_ASSUME_NONNULL_END
