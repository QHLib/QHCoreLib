//
//  QHDefaultValue.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHDefaultValue.h"

#import "QHInternal.h"


NS_ASSUME_NONNULL_BEGIN

#define CHECK_NIL_OR_NULL() \
if (value == nil || [value isKindOfClass:[NSNull class]]) {\
    return defaultValue;\
}

#define WARN_UNEXPECTED(_type, _defaultValue) \
QHCoreLibWarn(@"unexpected %@ when expecting %@, returning default value: %@", value, @ # _type, _defaultValue);

BOOL QHBool(id value, BOOL defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value boolValue];
    }

    WARN_UNEXPECTED(BOOL, @(defaultValue));

    return defaultValue;
}

NSInteger QHInteger(id value, NSInteger defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value integerValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value integerValue];
    }

    WARN_UNEXPECTED(NSInteger, @(defaultValue));

    return defaultValue;
}

double QHDouble(id value, double defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value doubleValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value doubleValue];
    }

    WARN_UNEXPECTED(double, @(defaultValue));

    return defaultValue;
}

NSString * QHString(id value, NSString * _Nullable defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value stringValue];
    }

    WARN_UNEXPECTED(NSString, defaultValue);

    return defaultValue;
}

NSArray * QHArray(id value, NSArray * _Nullable defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSArray class]]) {
        return (NSArray *)value;
    }

    WARN_UNEXPECTED(NSArray, defaultValue);

    return defaultValue;
}

NSDictionary * QHDictionary(id value, NSDictionary * _Nullable defaultValue)
{
    CHECK_NIL_OR_NULL();

    if ([value isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)value;
    }

    WARN_UNEXPECTED(NSDictionary, defaultValue);

    return defaultValue;
}

NS_ASSUME_NONNULL_END
