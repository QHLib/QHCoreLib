//
//  QHInternal.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/6/21.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#ifndef QHInternal_h
#define QHInternal_h

NS_ASSUME_NONNULL_BEGIN

#define _QHCoreLibFatalActionAbort      0
#define _QHCoreLibFatalActionThrow      1
#define _QHCoreLibFatalActionContinue   2

#if DEBUG
#   ifndef _QHCoreLibFatalAction
#       define _QHCoreLibFatalAction _QHCoreLibFatalActionAbort
#   endif
#else
#   ifdef _QHCoreLibFatalAction
#       undef _QHCoreLibFatalAction
#   endif
#   define _QHCoreLibFatalAction _QHCoreLibFatalActionContinue
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


#if DEBUG
#   define QHCoreLibDebug(...)      NSLog(@"QHCoreLibDebug: " __VA_ARGS__)
#else
#   define QHCoreLibDebug(...)
#endif

#if _QHCoreLibDebug
#   define QHCoreLibInfo(...)      NSLog(@"QHCoreLibInfo: " __VA_ARGS__)
#else
#   define QHCoreLibInfo(...)
#endif

NS_ASSUME_NONNULL_END

#endif /* QHInternal_h */
