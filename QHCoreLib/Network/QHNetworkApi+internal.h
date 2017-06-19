//
//  QHNetworkApi+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHNetworkApi_internal_h
#define QHNetworkApi_internal_h

#import <QHCoreLib/QHNetworkApi.h>
#import <QHCoreLib/QHAsyncTask+internal.h>
#import <QHCoreLib/QHNetworkWorker.h>

#define QH_NETWORK_API_IMPL_DIRECT(API_TYPE, RESULT_TYPE) \
QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, QHNetworkApi, QHNetworkApiResult)

#define QH_NETWORK_API_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, SUPER_API_TYPE, SUPER_RESULT_TYPE) \
QH_ASYNC_TASK_IMPL_INDIRECT(API_TYPE, RESULT_TYPE, SUPER_API_TYPE, SUPER_RESULT_TYPE)

@interface QHNetworkApi ()

@property (nonatomic, strong) QHNetworkWorker *worker;

@end

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

#define QH_NETWORK_API_RESULT_IMPL_RETURN \
    return result; \
}

#endif /* QHNetworkApi_internal_h */
