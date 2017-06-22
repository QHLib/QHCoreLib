//
//  NSObject+QHUserDefaultsProperty.h
//  QHCoreLib
//
//  Created by changtang on 2017/6/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (QHUserDefaultsProperty)

+ (NSString *)qh_userDefaultsKeyForProperty:(NSString *)propertyName;

+ (void)qh_synthesizeBOOLProperty:(NSString *)propertyName
                           forKey:(NSString *)userDefaultsKey
                     defaultValue:(BOOL)defaultValue
                     userDefaults:(NSUserDefaults *)userDefaults;

+ (void)qh_synthesizeIntegerProperty:(NSString *)propertyName
                              forKey:(NSString *)userDefaultsKey
                        defaultValue:(NSInteger)defaultValue
                        userDefaults:(NSUserDefaults *)userDefaults;

+ (void)qh_synthesizeDoubleProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(double)defaultValue
                       userDefaults:(NSUserDefaults *)userDefaults;

+ (void)qh_synthesizeStringProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(NSString * _Nullable)defaultValue
                       userDefaults:(NSUserDefaults *)userDefaults;

+ (void)qh_synthesizeArrayProperty:(NSString *)propertyName
                            forKey:(NSString *)userDefaultsKey
                      defaultValue:(NSArray * _Nullable)defaultValue
                      userDefaults:(NSUserDefaults *)userDefaults;

+ (void)qh_synthesizeDictionaryProperty:(NSString *)propertyName
                                 forKey:(NSString *)userDefaultsKey
                           defaultValue:(NSDictionary * _Nullable)defaultValue
                           userDefaults:(NSUserDefaults *)userDefaults;


// synthesize in standardUserDefaults

+ (void)qh_synthesizeBOOLProperty:(NSString *)propertyName
                           forKey:(NSString *)userDefaultsKey
                     defaultValue:(BOOL)defaultValue;

+ (void)qh_synthesizeIntegerProperty:(NSString *)propertyName
                              forKey:(NSString *)userDefaultsKey
                        defaultValue:(NSInteger)defaultValue;

+ (void)qh_synthesizeDoubleProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(double)defaultValue;

+ (void)qh_synthesizeStringProperty:(NSString *)propertyName
                             forKey:(NSString *)userDefaultsKey
                       defaultValue:(NSString * _Nullable)defaultValue;

+ (void)qh_synthesizeArrayProperty:(NSString *)propertyName
                            forKey:(NSString *)userDefaultsKey
                      defaultValue:(NSArray * _Nullable)defaultValue;

+ (void)qh_synthesizeDictionaryProperty:(NSString *)propertyName
                                 forKey:(NSString *)userDefaultsKey
                           defaultValue:(NSDictionary * _Nullable)defaultValue;

@end

NS_ASSUME_NONNULL_END
