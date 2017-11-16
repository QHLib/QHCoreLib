//
//  QHDefines.h
//  QHCommon
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#ifndef QHDefines_h
#define QHDefines_h

#import <Foundation/Foundation.h>

#import <libextobjc/extobjc.h>

#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef QH_DEBUG
#   if DEBUG
#       define QH_DEBUG 1
#   else
#       define QH_DEBUG 0
#   endif
#endif


#if defined(__cplusplus)
#   define QH_EXTERN           extern "C"
#   define QH_EXTERN_C_BEGIN   extern "C" {
#   define QH_EXTERN_C_END     }
#else
#   define QH_EXTERN           extern
#   define QH_EXTERN_C_BEGIN
#   define QH_EXTERN_C_END
#endif


#define QH_UNUSED_VAR(var) ((void)(var))

#define QH_IS(obj, cls)                                 (obj != nil && [obj isKindOfClass:[cls class]])

#define QH_IS_STRING(obj)                               (QH_IS(obj, NSString))
#define QH_IS_NUMBER(obj)                               (QH_IS(obj, NSNumber))
#define QH_IS_ARRAY(obj)                                (QH_IS(obj, NSArray))
#define QH_IS_DICTIONARY(obj)                           (QH_IS(obj, NSDictionary))
#define QH_IS_SET(obj)                                  (QH_IS(obj, NSSet))
#define QH_IS_DATA(obj)                                 (QH_IS(obj, NSData))

#define QH_IS_VALID_STRING(obj)                       (QH_IS_STRING(obj) && [obj length])
#define QH_IS_VALID_NUMBER(obj)                       (QH_IS_NUMBER(obj))
#define QH_IS_VALID_ARRAY(obj)                        (QH_IS_ARRAY(obj) && [obj count])
#define QH_IS_VALID_DICTIONARY(obj)                   (QH_IS_DICTIONARY(obj) && [obj count])
#define QH_IS_VALID_SET(obj)                          (QH_IS_SET(obj) && [obj count])
#define QH_IS_VALID_DATA(obj)                         (QH_IS_DATA(obj) && [obj length])
#define QH_IS_VALID_DELEGATE(d, s)                    (d && [d respondsToSelector:s])

#define QH_AS(obj, cls, var)                            cls *var = nil; if (QH_IS(obj, cls)) var = (cls *)obj;

#define QH_DUMMY_CLASS(_name) \
@interface QHDummyClass ## _name : NSObject \
@end \
@implementation QHDummyClass ## _name \
@end

#define QH_SINGLETON_DEF \
+ (instancetype)sharedInstance;

#define QH_SINGLETON_IMP \
+ (instancetype)sharedInstance \
{ \
    static dispatch_once_t once; \
    static id __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
    return __singleton__; \
}

#define retainify(...) \
    ext_keywordify \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    metamacro_foreach(ext_retainify_,, __VA_ARGS__) \
    _Pragma("clang diagnostic pop")

#define ext_retainify_(INDEX, VAR) \
    __strong __typeof__(VAR) metamacro_concat(VAR, _retain_) = VAR; \
    __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _retain_);

#if __has_attribute(deprecated)
#   define QH_DEPRECATED(_msg) __attribute__((deprecated(_msg)))
#else
#   define QH_DEPRECATED(_msg)
#endif

#define QH_C_ARRAY_SIZE(array, type) (sizeof(array)/sizeof(type))

/**
 * Concat two literals. Supports macro expansions,
 * e.g. QH_CONCAT(foo, __FILE__).
 */
#define _QH_CONCAT(A, B)    A ## B
#define QH_CONCAT(A, B)     _QH_CONCAT(A, B)


#define QH_SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING_BEGIN \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \

#define QH_SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING_END \
    _Pragma("clang diagnostic pop") \
} while (0);


#define QH_msgSendFunc_void_void(_name) QH_msgSendFunc_void_value(_name, void)
#define QH_msgSendFunc_void_value(_name, _returnType) \
_returnType(*_name)(id, SEL) = (_returnType(*)(id, SEL))objc_msgSend

#define QH_msgSendFunc_params_void(_name, ...) QH_msgSendFunc_params_value(_name, void, __VA_ARGS__)
#define QH_msgSendFunc_params_value(_name, _returnType, ...) \
_returnType(*_name)(id, SEL, __VA_ARGS__) = (_returnType(*)(id, SEL, __VA_ARGS__))objc_msgSend


#define QH_PROPETY_NAME(_property) NSStringFromSelector(@selector(_property))

#define stringify(_name) @#_name

#define $(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

#define QH_NSCODING_DECODE(_decoder, _type, _key) \
((_type *)[_decoder decodeObjectOfClass:[_type class] forKey:(_key)])

#define QH_NSCODING_ENCODE(_coder, _object, _key) \
[_coder encodeObject:_object forKey:(_key)]

NS_ASSUME_NONNULL_END

#endif /* QHDefines_h */
