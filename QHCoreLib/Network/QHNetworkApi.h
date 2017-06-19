//
//  QHNetworkApi.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHBase.h>
#import <QHCoreLib/QHAsync.h>

#import <QHCoreLib/QHNetworkRequest.h>
#import <QHCoreLib/QHNetworkResponse.h>


QH_EXTERN NSString * const QHNetworkApiErrorDomain;

typedef NS_ENUM(NSUInteger, QHNetworkApiError) {
    QHNetworkApiError___ = 2000
};


@class QHNetworkApi, QHNetworkApiResult;
typedef void (^QHNetworkApiSuccessBlock)(QHNetworkApi *api, QHNetworkApiResult *result);
typedef void (^QHNetworkApiFailBlock)(QHNetworkApi *api, NSError *error);

#define QH_NETWORK_API_DECL(API_TYPE, RESULT_TYPE) \
QH_ASYNC_TASK_DECL(API_TYPE, RESULT_TYPE)

@interface QHNetworkApi : QHAsyncTask

// subclasses implement
- (QHNetworkRequest *)buildRequest;

QH_NETWORK_API_DECL(QHNetworkApi, QHNetworkApiResult);

@end

#define QH_NETWORK_API_IMPL_DIRECT(API_TYPE, RESULT_TYPE) \
QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, QHNetworkApi, QHNetworkApiResult)

#define QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, SUPER_API_TYPE, SUPER_RESULT_TYPE) \
QH_ASYNC_TASK_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, SUPER_API_TYPE, SUPER_RESULT_TYPE)

#pragma mark


#define QH_NETWORK_API_RESULT_DECL(API_TYPE, RESULT_TYPE) \
@property (nonatomic, strong) API_TYPE *api; \
\
+ (RESULT_TYPE *)parse:(QHNetworkResponse *)response \
                 error:(NSError **)error \
                   api:(API_TYPE *)api \
NS_REQUIRES_SUPER;

@interface QHNetworkApiResult : NSObject

QH_NETWORK_API_RESULT_DECL(QHNetworkApi, QHNetworkApiResult);

@property (nonatomic, readonly) QHNetworkResponse *response;

@end

#define QH_NETWORK_API_RESULT_IMPL_SUPER(API_TYPE, RESULT_TYPE) \
@dynamic api; \
\
+ (RESULT_TYPE *)parse:(QHNetworkResponse *)response \
                 error:(NSError * __autoreleasing *)error \
                   api:(API_TYPE *)api \
{ \
    RESULT_TYPE *result = (RESULT_TYPE *)[super parse:response error:error api:api]; \
    if (*error != nil) { \
        return nil; \
    } else

#define QH_NETWORK_API_RESULT_IMPL_RETURN \
    return result; \
}

/*
 QH_NETWORK_API_RESULT_IMPL_SUPER(API_TYPE, RESULT_TYPE) {
    // parse logic
 }
 QH_NETWORK_API_RESULT_IMPL_RETURN;
*/
