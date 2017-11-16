//
//  NSObject+QHUserDefaultsProperty.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//


#import "NSObject+QHUserDefaultsProperty.h"

#import <objc/runtime.h>

#import "QHInternal.h"
#import "Foundation+QHCoreLib.h"


NS_ASSUME_NONNULL_BEGIN

#define DISABLE_DEBUG_LOG 1

#if (QH_DEBUG && DISABLE_DEBUG_LOG)
#   undef QHCoreLibDebug
#   define QHCoreLibDebug(...)
#endif


@implementation NSObject (QHUserDefaultsProperty)

+ (NSString *)qh_userDefaultsKeyForProperty:(NSString *)propertyName
{
    return [NSString stringWithFormat:@"QHUserDefaultPropertyKey-%@-%@",
            NSStringFromClass([self class]),
            propertyName];
}

+ (void)qh_synthesizeBOOLProperty:(NSString *)propertyName
                           forKey:(NSString *)userDefaultsKey
                     defaultValue:(BOOL)defaultValue
                     userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^BOOL (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSNumber class]]) {
                QHCoreLibDebug(@"get bool value %@ for %@", value, userDefaultsKey);
                return [value boolValue];
            }
            QHCoreLibDebug(@"get bool value(default) %d for %@", defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(BOOL)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, BOOL value) {
            QHCoreLibDebug(@"set bool value %d for %@", value, userDefaultsKey);
            [userDefaults qh_setObject:[NSNumber numberWithBool:value] forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(BOOL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

+ (void)qh_synthesizeIntegerProperty:(NSString *)propertyName
                              forKey:(NSString *)userDefaultsKey
                        defaultValue:(NSInteger)defaultValue
                        userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^NSInteger (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSNumber class]]) {
                QHCoreLibDebug(@"get integer value %@ for %@", value, userDefaultsKey);
                return [value integerValue];
            }
            QHCoreLibDebug(@"get integer value(default) %ld for %@", (long)defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(NSInteger)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, NSInteger value) {
            QHCoreLibDebug(@"set integer value %ld for %@", (long)value, userDefaultsKey);
            [userDefaults qh_setObject:[NSNumber numberWithInteger:value] forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(NSInteger)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

+ (void)qh_synthesizeDoubleProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(double)defaultValue
                       userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^double (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSNumber class]]) {
                QHCoreLibDebug(@"get double value %@ for %@", value, userDefaultsKey);
                return [value doubleValue];
            }
            QHCoreLibDebug(@"get double value(default) %f for %@", defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(NSInteger)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, double value) {
            QHCoreLibDebug(@"set double value %f for %@", value, userDefaultsKey);
            [userDefaults qh_setObject:[NSNumber numberWithDouble:value] forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(NSInteger)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

+ (void)qh_synthesizeStringProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(NSString * _Nullable)defaultValue
                       userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^NSString * (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSString class]]) {
                QHCoreLibDebug(@"get string value %@ for %@", value, userDefaultsKey);
                return value;
            }
            QHCoreLibDebug(@"get string value(default) %@ for %@", defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(NSString *)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, NSString *value) {
            QHCoreLibDebug(@"set string value %@ for %@", value, userDefaultsKey);
            if (![value isKindOfClass:[NSString class]]) { return; }
            [userDefaults qh_setObject:value forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(NSString *)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

+ (void)qh_synthesizeArrayProperty:(NSString *)propertyName
                            forKey:(NSString *)userDefaultsKey
                      defaultValue:(NSArray * _Nullable)defaultValue
                      userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^NSArray * (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSArray class]]) {
                QHCoreLibDebug(@"get array value %@ for %@", value, userDefaultsKey);
                return value;
            }
            QHCoreLibDebug(@"get array value(default) %@ for %@", defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(NSArray *)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, NSArray *value) {
            QHCoreLibDebug(@"set array value %@ for %@", value, userDefaultsKey);
            if (![value isKindOfClass:[NSArray class]]) { return; }
            [userDefaults qh_setObject:value forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(NSArray *)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

+ (void)qh_synthesizeDictionaryProperty:(NSString *)propertyName
                                 forKey:(NSString *)userDefaultsKey
                           defaultValue:(NSDictionary * _Nullable)defaultValue
                           userDefaults:(NSUserDefaults *)userDefaults
{
    if (!QH_IS_STRING(propertyName)
        || !QH_IS_STRING(userDefaultsKey)
        || !QH_IS(userDefaults, NSUserDefaults)) {
        return;
    }

    // getter
    {
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@", propertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^NSDictionary * (id _self) {
            id value = [userDefaults objectForKey:userDefaultsKey];
            if ([value isKindOfClass:[NSDictionary class]]) {
                QHCoreLibDebug(@"get dictionary value %@ for %@", value, userDefaultsKey);
                return value;
            }
            QHCoreLibDebug(@"get dictionary value(default) %@ for %@", defaultValue, userDefaultsKey);
            return defaultValue;
        });
        const char *encoding = (const char []){
            @encode(NSDictionary *)[0],
            @encode(id)[0],
            @encode(SEL)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property getter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }

    // setter
    {
        NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[propertyName substringToIndex:1] uppercaseString]];

        SEL sel = sel_registerName([[NSString stringWithFormat:@"set%@:", capitalizedPropertyName] UTF8String]);
        IMP imp = imp_implementationWithBlock(^(id _self, NSDictionary *value) {
            QHCoreLibDebug(@"set dictionary value %@ for %@", value, userDefaultsKey);
            if (![value isKindOfClass:[NSDictionary class]]) { return; }
            [userDefaults qh_setObject:value forKey:userDefaultsKey];
        });
        const char *encoding = (const char []){
            @encode(void)[0],
            @encode(id)[0],
            @encode(SEL)[0],
            @encode(NSDictionary *)[0],
        };
        IMP old_imp = class_replaceMethod(self, sel, imp, encoding);
        if (old_imp) {
            QHCoreLibFatal(@"duplicate synthesize user defaults property setter: %@ in %@",
                           NSStringFromSelector(sel),
                           NSStringFromClass(self));
        }
    }
}

#pragma mark -

+ (void)qh_synthesizeBOOLProperty:(NSString *)propertyName
                           forKey:(NSString *)userDefaultsKey
                     defaultValue:(BOOL)defaultValue
{
    [self qh_synthesizeBOOLProperty:propertyName
                             forKey:userDefaultsKey
                       defaultValue:defaultValue
                       userDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (void)qh_synthesizeIntegerProperty:(NSString *)propertyName
                              forKey:(NSString *)userDefaultsKey
                        defaultValue:(NSInteger)defaultValue
{
    [self qh_synthesizeIntegerProperty:propertyName
                                forKey:userDefaultsKey
                          defaultValue:defaultValue
                          userDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (void)qh_synthesizeDoubleProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(double)defaultValue
{
    [self qh_synthesizeDoubleProperty:propertyName
                               forKey:userDefaultsKey
                         defaultValue:defaultValue
                         userDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (void)qh_synthesizeStringProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(NSString * _Nullable)defaultValue
{
    [self qh_synthesizeStringProperty:propertyName
                               forKey:userDefaultsKey
                         defaultValue:defaultValue
                         userDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (void)qh_synthesizeArrayProperty:(NSString *)propertyName
                            forKey:(NSString *)userDefaultsKey
                      defaultValue:(NSArray * _Nullable)defaultValue
{
    [self qh_synthesizeArrayProperty:propertyName
                              forKey:userDefaultsKey
                        defaultValue:defaultValue
                        userDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (void)qh_synthesizeDictionaryProperty:(NSString *)propertyName
                                 forKey:(NSString *)userDefaultsKey
                           defaultValue:(NSDictionary * _Nullable)defaultValue
{
    [self qh_synthesizeDictionaryProperty:propertyName
                                   forKey:userDefaultsKey
                             defaultValue:defaultValue
                             userDefaults:[NSUserDefaults standardUserDefaults]];
}

@end

NS_ASSUME_NONNULL_END
