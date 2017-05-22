//
//  QHAsserts.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/18.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QHDefines.h"


#ifndef NS_BLOCK_ASSERTIONS
#   define QHAssert(condition, ...) \
do { \
    if ((condition) == 0) { \
        _QHAssertFormat(#condition, __FILE__, __LINE__, __func__, __VA_ARGS__); \
    } \
} while (false)
#else
#   define QHAssert(condition, ...) do {} while (false)
#endif

QH_EXTERN void _QHAssertFormat(const char *condition,
                               const char *fileName,
                               int lineNumber,
                               const char *function,
                               NSString *format,
                               ...) NS_FORMAT_FUNCTION(5, 6);

typedef void (^QHAssertFunction)(NSString *condition,
                                 NSString *fileName,
                                 NSNumber *lineNumber,
                                 NSString *function,
                                 NSString *message);

QH_EXTERN void QHSetAssertFunction(QHAssertFunction assertFunction);
QH_EXTERN QHAssertFunction QHGetAssertFunction();


QH_EXTERN BOOL QHIsMainQueue();

#define QHAssertMainQueue() QHAssert(QHIsMainQueue(), \
    @"this method must be called on main queue")

#define QHAssertNotMainQueue() QHAssert(!QHIsMainQueue(), \
    @"this method must not be called on main queue")

#define QHAssertParam(name) QHAssert(name, \
    @"'%s' is a required parameter", #name)

#define QHAssertReturnVoidOnFailure(_cond, ...) \
do { \
    QHAssert((_cond), __VA_ARGS__); \
    if (!(_cond)) { \
        return; \
    } \
} while(0)

#define QHAssertReturnValueOnFailure(_value, _cond, ...) \
do { \
    QHAssert((_cond), __VA_ARGS__); \
    if (!(_cond)) { \
        return (_value); \
    } \
} while(0)

#define QH_NOT_IMPLEMENTED(method) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmissing-method-return-type\"") \
_Pragma("clang diagnostic ignored \"-Wunused-parameter\"") \
QH_EXTERN NSException *_QHNotImplementedException(SEL, Class); \
method NS_UNAVAILABLE { @throw _QHNotImplementedException(_cmd, [self class]); } \
_Pragma("clang diagnostic pop")
