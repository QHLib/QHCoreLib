//
//  QHNetworkApi+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHNetworkApi_internal_h
#define QHNetworkApi_internal_h

#import "QHNetworkApi.h"
#import "QHNetworkWorker.h"


@interface QHNetworkApi ()

@property (nonatomic, copy) QHNetworkApiSuccessBlock successBlock;
@property (nonatomic, copy) QHNetworkApiFailBlock failBlock;

@property (nonatomic, strong) QHNetworkWorker *worker;

@end

#endif /* QHNetworkApi_internal_h */
