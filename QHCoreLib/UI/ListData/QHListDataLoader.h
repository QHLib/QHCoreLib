//
//  QHListDataLoader.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHListDataProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListDataLoader : NSObject <QHListDataLoader>

@property (nonatomic, weak, nullable) id<QHListDataLoaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
