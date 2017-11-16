//
//  QHNetworkApi+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/23.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#ifndef QHNetworkApi_internal_h
#define QHNetworkApi_internal_h

#import <QHCoreLib/QHNetworkApi.h>
#import <QHCoreLib/QHAsyncTask+internal.h>
#import <QHCoreLib/QHNetworkWorker.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHNetworkApi ()

@property (nonatomic, strong) QHNetworkWorker * _Nullable worker;

@end

NS_ASSUME_NONNULL_END

#endif /* QHNetworkApi_internal_h */
