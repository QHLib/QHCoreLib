//
//  QHNetworkUtil.h
//  QQHouse
//
//  Created by changtang on 16/12/21.
//
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHBase.h>


NS_ASSUME_NONNULL_BEGIN

QH_EXTERN NSString * const QHNetWorkHttpMethodGet;
QH_EXTERN NSString * const QHNetWorkHttpMethodPost;

typedef NS_ENUM(NSUInteger, QHNetworkQueryKeyOrder) {
    QHNetworkQueryKeyOrderNone,
    QHNetworkQueryKeyOrderAscending,
    QHNetworkQueryKeyOrderDescending,
};

@interface QHNetworkUtil : NSObject

+ (NSString *)appendQuery:(NSDictionary<NSString *, NSString *> *)dict
                    toUrl:(NSString *)url;

// sort by key order
+ (NSString *)appendQuery:(NSDictionary<NSString *, NSString *> *)dict
                    toUrl:(NSString *)url
                sortByKey:(QHNetworkQueryKeyOrder)order;

+ (NSMutableURLRequest *)requestFromURL:(NSString *)urlString;

+ (NSMutableURLRequest *)requestFromMethod:(NSString *)method
                                       url:(NSString *)urlString
                                 queryDict:(NSDictionary * _Nullable)queryDict
                                  bodyDict:(NSDictionary * _Nullable)bodyDict;

@end

NS_ASSUME_NONNULL_END
