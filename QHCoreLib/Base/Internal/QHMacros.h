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


#define _QHCoreLibFatalActionAbort      0
#define _QHCoreLibFatalActionThrow      1
#define _QHCoreLibFatalActionContinue   2

#ifndef _QHCoreLibFatalAction
#   ifdef QH_DEBUG
#       define _QHCoreLibFatalAction _QHCoreLibFatalActionAbort
#   else
#       define _QHCoreLibFatalAction _QHCoreLibFatalActionContinue
#   endif
#endif

#define _QHCoreLibFatal(...)        NSLog(@"QHCoreLibFatal: " __VA_ARGS__); NSLog(@"FATAL ERROR OCCURS, SEE ABOVE!!!\n\n\n")

#if   _QHCoreLibFatalAction == _QHCoreLibFatalActionAbort
#   define QHCoreLibFatal(...)      _QHCoreLibFatal(__VA_ARGS__); abort()
#elif _QHCoreLibFatalAction == _QHCoreLibFatalActionThrow
#   define QHCoreLibFatal(...)      _QHCoreLibFatal(__VA_ARGS__); \
                                    @throw [NSException exceptionWithName:@"QHCoreLibFatal" reason:@"FATAL ERROR OCCURS" userInfo:nil]
#elif _QHCoreLibFatalAction == _QHCoreLibFatalActionContinue
#   define QHCoreLibFatal(...)      _QHCoreLibFatal(__VA_ARGS__);
#endif


#define QHCoreLibWarn(...)          NSLog(@"QHCoreLibWarn: " __VA_ARGS__)


#if QH_DEBUG
#   define QHCoreLibDebug(...)      NSLog(@"QHCoreLibDebug: " __VA_ARGS__)
#else
#   define QHCoreLibDebug(...)
#endif

#endif /* QHMacros_h */
