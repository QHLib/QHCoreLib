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

@interface NSMutableArray (QHCoreLib)

- (void)qh_addObject:(id)anObject;

- (void)qh_insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)qh_removeObjectAtIndex:(NSUInteger)index;

@end

@interface NSDictionary (QHCoreLib)

- (NSDictionary *)qh_mappedDictionaryWithBlock:(id (^)(id key, id obj))block;

@end

@interface NSMutableDictionary (QHCoreLib)

- (void)qh_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
