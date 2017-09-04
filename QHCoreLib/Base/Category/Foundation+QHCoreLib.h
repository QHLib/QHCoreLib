//
//  Foundation+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHDefines.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSObject (QHCoreLib)

+ (instancetype _Nullable)qh_cast:(id)obj; // warnOnFailure:YES

+ (instancetype _Nullable)qh_cast:(id)obj warnOnFailure:(BOOL)warnOnFailure;

@end


@interface NSArray<ObjectType> (QHCoreLib)

- (NSArray<ObjectType> *)qh_sliceFromStart:(NSUInteger)start length:(NSUInteger)length;

- (NSArray<ObjectType> *)qh_filteredArrayWithBlock:(BOOL (^)(NSUInteger idx, ObjectType obj))block;

- (NSArray *)qh_mappedArrayWithBlock:(id (^)(NSUInteger idx, ObjectType obj))block;

- (ObjectType _Nullable)qh_objectAtIndex:(NSUInteger)index;

- (NSArray<ObjectType> *)qh_objectsAtIndexes:(NSIndexSet *)indexes;

@end

@interface NSArray (QHCoreLibDefaultValue)

- (BOOL)qh_boolAtIndex:(NSUInteger)index
          defaultValue:(BOOL)defaultValue;

- (NSInteger)qh_integerAtIndex:(NSUInteger)index
                  defaultValue:(NSInteger)defaultValue;

- (double)qh_doubleAtIndex:(NSUInteger)index
              defaultValue:(double)defaultValue;

- (NSString *)qh_stringAtIndex:(NSUInteger)index
                  defaultValue:(NSString * _Nullable)defaultValue;

- (NSArray *)qh_arrayAtIndex:(NSUInteger)index
                defaultValue:(NSArray * _Nullable)defaultValue;

- (NSDictionary *)qh_dictionaryAtIndex:(NSUInteger)index
                          defaultValue:(NSDictionary * _Nullable)defaultValue;

@end

@interface NSMutableArray<ObjectType> (QHCoreLib)

- (void)qh_addObject:(ObjectType)anObject;

- (void)qh_insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;

- (void)qh_removeObjectAtIndex:(NSUInteger)index;

@end

@interface NSDictionary<KeyType, ObjectType> (QHCoreLib)

- (NSDictionary<KeyType, id> *)qh_mappedDictionaryWithBlock:(id (^)(KeyType key, ObjectType obj))block;

@end

@interface NSDictionary (QHCoreLibDefaultValue)

- (BOOL)qh_boolForKey:(id<NSCopying>)key
         defaultValue:(BOOL)defaultValue;

- (NSInteger)qh_integerForKey:(id<NSCopying>)key
                 defaultValue:(NSInteger)defaultValue;

- (double)qh_doubleForKey:(id<NSCopying>)key
             defaultValue:(double)defaultValue;

- (NSString *)qh_stringForKey:(id<NSCopying>)key
                 defaultValue:(NSString * _Nullable)defaultValue;

- (NSArray *)qh_arrayForKey:(id<NSCopying>)key
               defaultValue:(NSArray * _Nullable)defaultValue;

- (NSDictionary *)qh_dictionaryForKey:(id<NSCopying>)key
                         defaultValue:(NSDictionary * _Nullable)defaultValue;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (QHCoreLib)

- (void)qh_setObject:(ObjectType)anObject forKey:(KeyType)aKey;

@end

@interface NSMutableSet<ObjectType> (QHCoreLib)

- (void)qh_addObject:(ObjectType)object;

@end

@interface NSUserDefaults (QHCoreLib)

- (void)qh_setObject:(id)object forKey:(NSString *)key;

@end

@interface NSException (QHCoreLib)

- (NSString *)qh_description;

@end

@interface NSError (QHCoreLib)

+ (instancetype)qh_errorWithDomain:(NSErrorDomain)domain
                              code:(NSInteger)code
                           message:(NSString * _Nullable)message
                              info:(NSDictionary * _Nullable)info
                              file:(const char *)file
                              line:(int)line;
@end

#define QH_ERROR(_domain, _code, _message, _info) \
[NSError qh_errorWithDomain:(_domain) code:(_code) message:(_message) info:(_info) file:__FILE__ line:__LINE__]

@interface NSBundle (QHCoreLib)

+ (NSString * _Nullable)qh_mainBundle_identifier;
+ (NSString * _Nullable)qh_mainBundle_version;
+ (NSString * _Nullable)qh_mainBundle_shortVersion;
+ (NSString * _Nullable)qh_mainBundle_name;
+ (NSString * _Nullable)qh_mainBundle_displayName;

@end

NS_ASSUME_NONNULL_END
