//
//  Foundation+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (QHCoreLib)

+ (instancetype)qh_cast:(id)obj; // warnOnFailure:YES

+ (instancetype)qh_cast:(id)obj warnOnFailure:(BOOL)warnOnFailure;

@end


@interface NSArray (QHCoreLib)

- (NSArray *)qh_sliceFromStart:(NSUInteger)start length:(NSUInteger)length;

- (NSArray *)qh_filteredArrayWithBlock:(BOOL (^)(NSUInteger idx, id obj))block;

- (NSArray *)qh_mappedArrayWithBlock:(id (^)(NSUInteger idx, id obj))block;

- (id)qh_objectAtIndex:(NSUInteger)index;

- (NSArray *)qh_objectsAtIndexes:(NSIndexSet *)indexes;

@end

@interface NSArray (QHCoreLibDefaultValue)

- (BOOL)qh_boolAtIndex:(NSUInteger)index
          defaultValue:(BOOL)defaultValue;

- (NSInteger)qh_integerAtIndex:(NSUInteger)index
                  defaultValue:(NSInteger)defaultValue;

- (double)qh_doubleAtIndex:(NSUInteger)index
              defaultValue:(double)defaultValue;

- (NSString *)qh_stringAtIndex:(NSUInteger)index
                  defaultValue:(NSString *)defaultValue;

- (NSArray *)qh_arrayAtIndex:(NSUInteger)index
                defaultValue:(NSArray *)defaultValue;

- (NSDictionary *)qh_dictionaryAtIndex:(NSUInteger)index
                          defaultValue:(NSDictionary *)defaultValue;

@end

@interface NSMutableArray (QHCoreLib)

- (void)qh_addObject:(id)anObject;

- (void)qh_insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)qh_removeObjectAtIndex:(NSUInteger)index;

@end

@interface NSDictionary (QHCoreLib)

- (NSDictionary *)qh_mappedDictionaryWithBlock:(id (^)(id key, id obj))block;

@end

@interface NSDictionary (QHCoreLibDefaultValue)

- (BOOL)qh_boolForKey:(id<NSCopying>)key
         defaultValue:(BOOL)defaultValue;

- (NSInteger)qh_integerForKey:(id<NSCopying>)key
                 defaultValue:(NSInteger)defaultValue;

- (double)qh_doubleForKey:(id<NSCopying>)key
             defaultValue:(double)defaultValue;

- (NSString *)qh_stringForKey:(id<NSCopying>)key
                 defaultValue:(NSString *)defaultValue;

- (NSArray *)qh_arrayForKey:(id<NSCopying>)key
               defaultValue:(NSArray *)defaultValue;

- (NSDictionary *)qh_dictionaryForKey:(id<NSCopying>)key
                         defaultValue:(NSDictionary *)defaultValue;

@end

@interface NSMutableDictionary (QHCoreLib)

- (void)qh_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@interface NSMutableSet (QHCoreLib)

- (void)qh_addObject:(id)object;

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
                           message:(NSString *)message
                              info:(NSDictionary *)info
                              file:(const char *)file
                              line:(int)line;
@end

#define QH_ERROR(_domain, _code, _message, _info) \
[NSError qh_errorWithDomain:(_domain) code:(_code) message:(_message) info:(_info) file:__FILE__ line:__LINE__]

