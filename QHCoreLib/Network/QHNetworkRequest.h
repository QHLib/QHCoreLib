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
    QHNetworkResourceFile,
};

@interface QHNetworkRequest : NSObject

@property (nonatomic, strong) NSMutableURLRequest *urlRequest;          // default nil

@property (nonatomic, assign) QHNetworkRequestPriority priority;        // default QHNetworkRequestPriorityDeafult

// [1.0, 0.0]: progressWeight * upload progress + (1 - progressWeight) * download progress
@property (nonatomic, assign) double progressWeight; 

@property (nonatomic, assign) QHNetworkResourceType resourceType;       // default QHNetworkResourceHTTP

@property (nonatomic,   copy) NSString *targetFilePath;                 // might present if resourceType is file

@end

NS_ASSUME_NONNULL_END
