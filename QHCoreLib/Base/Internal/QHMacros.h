//
//  QHMacros.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/8.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHMacros_h
#define QHMacros_h

#import "QHDefines.h"
#import "QHAsserts.h"

#define QHCoreLibFatal(...)         NSLog(@"QHCoreLibFatal: " __VA_ARGS__); QHAssert(NO, @"Fatal error occurs, see above!!!")

#define QHCoreLibWarn(...)          NSLog(@"QHCoreLibWarn: " __VA_ARGS__)

#if QH_DEBUG
#   define QHCoreLibDebug(...)      NSLog(@"QHCoreLibDebug: " __VA_ARGS__)
#else
#   define QHCoreLibDebug(...)
#endif

#endif /* QHMacros_h */
