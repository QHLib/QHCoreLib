//
//  QHDefaultValue.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHDefines.h>


NS_ASSUME_NONNULL_BEGIN

QH_EXTERN BOOL QHBool(id value, BOOL defaultValue);

QH_EXTERN NSInteger QHInteger(id value, NSInteger defaultValue);

QH_EXTERN double QHDouble(id value, double defaultValue);

QH_EXTERN NSString * QHString(id value, NSString *defaultValue);

QH_EXTERN NSArray * QHArray(id value, NSArray *defaultValue);

QH_EXTERN NSDictionary * QHDictionary(id value, NSDictionary *defaultValue);

NS_ASSUME_NONNULL_END
