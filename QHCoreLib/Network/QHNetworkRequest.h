//
//  QHNetworkRequest.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHNetworkRequestPriority) {
    QHNetworkRequestPriorityDeafult = 0,
    QHNetworkRequestPriorityHigh,
    QHNetworkRequestPriorityLow,
};

typedef NS_ENUM(NSUInteger, QHNetworkResourceType) {
    QHNetworkResourceHTTP,
    QHNetworkResourceHTML,
    QHNetworkResourceJSON,
    QHNetworkResourceImage,
};

@interface QHNetworkRequest : NSObject

@property (nonatomic, strong) NSMutableURLRequest *urlRequest;          // default nil

@property (nonatomic, assign) QHNetworkRequestPriority priority;        // default QHNetworkRequestPriorityDeafult

@property (nonatomic, assign) QHNetworkResourceType resourceType;       // default QHNetworkResourceHTTP

@end

NS_ASSUME_NONNULL_END
