//
//  QHListCommonData.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHListSimpleData.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListCommonData<ListItemType> : QHListSimpleData<ListItemType> <QHListDataLoader>

@property (nonatomic, weak, nullable) id<QHListSimpleDataDelegate, QHListDataLoaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
