//
//  QHNetworkApi.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHDefines.h>

#import <QHCoreLib/QHNetworkRequest.h>
#import <QHCoreLib/QHNetworkResponse.h>


QH_EXTERN NSString * const QHNetworkApiErrorDomain;

@class QHNetworkApi, QHNetworkApiResult;
typedef void (^QHNetworkApiSuccessBlock)(QHNetworkApi *api, QHNetworkApiResult *result);
typedef void (^QHNetworkApiFailBlock)(QHNetworkApi *api, NSError *error);

#define QH_NETWORK_API_DECL(API_TYPE, RESULT_TYPE) \
- (void)loadWithSuccess:(void (^)(API_TYPE *api, RESULT_TYPE *result))success \
                   fail:(void (^)(API_TYPE *api, NSError *error))fail; \
\
- (Class)resultClass; \

#define QH_NETWORK_API_IMPL_DIRECT(API_TYPE, RESULT_TYPE) \
QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, QHNetworkApi, QHNetworkApiResult)

#define QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, SUPER_API_TYPE, SUPER_RESULT_TYPE) \
- (void)loadWithSuccess:(void (^)(API_TYPE *api, RESULT_TYPE *result))success \
                   fail:(void (^)(API_TYPE *api, NSError *error))fail \
{ \
    [super loadWithSuccess:(void (^)(SUPER_API_TYPE *api, SUPER_RESULT_TYPE *result))success \
                      fail:(void (^)(SUPER_API_TYPE *api, NSError *error))fail]; \
} \
\
- (Class)resultClass \
{ \
    return [RESULT_TYPE class]; \
}

@class QHNetworkApiResult;

@interface QHNetworkApi : NSObject

// subclasses implement
- (QHNetworkRequest *)buildRequest;

QH_NETWORK_API_DECL(QHNetworkApi, QHNetworkApiResult);

- (void)cancel;

@end


#define QH_NETWORK_API_RESULT_DECL(API_TYPE, RESULT_TYPE) \
@property (nonatomic, strong) API_TYPE *api; \
\
+ (RESULT_TYPE *)parse:(QHNetworkResponse *)response \
                 error:(NSError **)error \
                   api:(API_TYPE *)api \
NS_REQUIRES_SUPER;

#define QH_NETWORK_API_RESULT_IMPL_SUPER(API_TYPE, RESULT_TYPE) \
@dynamic api; \
\
+ (RESULT_TYPE *)parse:(QHNetworkResponse *)response \
                 error:(NSError **)error \
                   api:(API_TYPE *)api \
{ \
    RESULT_TYPE *result = (RESULT_TYPE *)[super parse:response error:error api:api]; \
    if (*error != nil) { \
        return nil; \
    } else

#define QH_NETWORK_API_RESULT_IMPL_RETURN    return result; }

@interface QHNetworkApiResult : NSObject

QH_NETWORK_API_RESULT_DECL(QHNetworkApi, QHNetworkApiResult);

@property (nonatomic, readonly) QHNetworkResponse *response;

@end
