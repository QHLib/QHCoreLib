//
//  QHNetworkActivityIndicator.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>


@interface QHNetworkActivityIndicator : NSObject

QH_SINGLETON_DEF;

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

@property (nonatomic, assign, readonly) BOOL isVisible;

- (void)setCallback:(void(^)(BOOL isVisible))callback;

@end
