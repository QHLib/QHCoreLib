//
//  Foundation+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (QHCoreLib)

- (NSArray *)qh_sliceFromStart:(NSUInteger)start length:(NSUInteger)length;

- (NSArray *)qh_filteredArrayWithBlock:(BOOL (^)(NSUInteger idx, id obj))block;

- (NSArray *)qh_mappedArrayWithBlock:(id (^)(NSUInteger idx, id obj))block;

- (id)qh_objectAtIndex:(NSUInteger)index;

- (NSArray *)qh_objectsAtIndexes:(NSIndexSet *)indexes;

@end

@interface NSArray (QHCoreLibDefaultValue)

- (BOOL)qh_boolAtIndex:(NSUInteger)index;

- (NSInteger)qh_integerAtIndex:(NSUInteger)index;

- (double)qh_doubleAtIndex:(NSUInteger)index;

- (NSString *)qh_stringAtIndex:(NSUInteger)index;

- (NSArray *)qh_arrayAtIndex:(NSUInteger)index;

- (NSDictionary *)qh_dictionaryAtIndex:(NSUInteger)index;

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

- (BOOL)qh_boolForKey:(id<NSCopying>)key;

- (NSInteger)qh_integerForKey:(id<NSCopying>)key;

- (double)qh_doubleForKey:(id<NSCopying>)key;

- (NSString *)qh_stringForKey:(id<NSCopying>)key;

- (NSArray *)qh_arrayForKey:(id<NSCopying>)key;

- (NSDictionary *)qh_dictionaryForKey:(id<NSCopying>)key;

@end

@interface NSMutableDictionary (QHCoreLib)

- (void)qh_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@interface NSException (QHCoreLib)

- (NSString *)qh_description;

@end
