//
//  Foundation+QHCoreLib.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/24.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "Foundation+QHCoreLib.h"

#import "QHDefines.h"
#import "QHAsserts.h"
#import "QHUtil.h"
#import "QHDefaultValue.h"


QH_DUMMY_CLASS(FoudationQHCoreLib)


@implementation NSArray (QHCoreLib)

- (NSArray *)qh_sliceFromStart:(NSUInteger)start length:(NSUInteger)length
{
    if (start >= self.count) {
        QHCoreLibWarn(@"start(%llu) is out of bound(%llu)\n%@",
                      (uint64_t)start, (uint64_t)self.count, QHCallStackShort());
        start = 0;
        length = 0;
    }

    if (start + length > self.count) {
        QHCoreLibWarn(@"length(%llu) is too long from start(%llu) for bound(%llu)\n%@",
                      (uint64_t)length, (uint64_t)start, (uint64_t)self.count, QHCallStackShort());
        length = self.count - start;
    }

    return [self subarrayWithRange:NSMakeRange(start, length)];
}

- (NSArray *)qh_filteredArrayWithBlock:(BOOL (^)(NSUInteger, id))block
{
    if (block) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self count]];

        [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (block(idx, obj)) {
                [results qh_addObject:obj];
            }
        }];

        return [NSArray arrayWithArray:results];
    }
    else {
        QHCoreLibWarn(@"filtering array with nil block, just return an copy of self\n%@",
                      QHCallStackShort());
        return [NSArray arrayWithArray:self];
    }
}

- (NSArray *)qh_mappedArrayWithBlock:(id (^)(NSUInteger, id))block
{
        if (block) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self count]];

        [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [results qh_addObject:block(idx, obj)];
        }];

        return [NSArray arrayWithArray:results];
    }
    else {
        QHCoreLibWarn(@"mapping array with nil block, just return an copy of self\n%@",
                      QHCallStackShort());
        return [NSArray arrayWithArray:self];
    }
}

- (id)qh_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    else {
        QHCoreLibWarn(@"index %llu is out of bound %llu\n%@",
                      (uint64_t)index, (uint64_t)self.count, QHCallStackShort());
        return nil;
    }
}


- (NSArray *)qh_objectsAtIndexes:(NSIndexSet *)indexes
{
    return [self objectsAtIndexes:[indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        BOOL result = idx < self.count;
        if (result == NO) {
            QHCoreLibWarn(@"index %llu is out of bound %llu\n%@",
                          (uint64_t)index, (uint64_t)self.count, QHCallStackShort());
        }
        return result;
    }]];
}

@end

@implementation NSArray (QHCoreLibDefaultValue)

- (BOOL)qh_boolAtIndex:(NSUInteger)index
{
    return QHBool([self qh_objectAtIndex:index], NO);
}

- (NSInteger)qh_integerAtIndex:(NSUInteger)index
{
    return QHInteger([self qh_objectAtIndex:index], 0);
}

- (double)qh_doubleAtIndex:(NSUInteger)index
{
    return QHDouble([self qh_objectAtIndex:index], 0.0);
}

- (NSString *)qh_stringAtIndex:(NSUInteger)index
{
    return QHString([self qh_objectAtIndex:index], @"");
}

- (NSArray *)qh_arrayAtIndex:(NSUInteger)index
{
    return QHArray([self qh_objectAtIndex:index], @[]);
}

- (NSDictionary *)qh_dictionaryAtIndex:(NSUInteger)index
{
    return QHDictionary([self qh_objectAtIndex:index], @{});
}

@end

@implementation NSMutableArray (QQHouseUtil)

- (void)qh_addObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
    else {
        QHCoreLibWarn(@"add nil object to array\n%@", QHCallStackShort());
    }
}

- (void)qh_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject) {
        if (index > [self count]) {
            QHCoreLibWarn(@"insert at index(%llu) larger than self.count(%llu)\n%@",
                          (uint64_t)index, (uint64_t)self.count, QHCallStackShort());
            index = [self count];
        }
        [self insertObject:anObject atIndex:index];
    }
    else {
        QHCoreLibWarn(@"insert nil object to dictionary\n%@", QHCallStackShort());
    }
}

- (void)qh_removeObjectAtIndex:(NSUInteger)index
{
    if (index < [self count]) {
        [self removeObjectAtIndex:index];
    }
    else {
        QHCoreLibWarn(@"remove index(%llu) out of bound(%llu)\n%@",
                      (uint64_t)index, (uint64_t)self.count, QHCallStackShort());
    }
}

@end

@implementation NSDictionary (QHCoreLib)

- (NSDictionary *)qh_mappedDictionaryWithBlock:(id (^)(id key, id obj))block
{
    if (block) {
        __block NSMutableDictionary *results = [NSMutableDictionary dictionary];
        [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [results qh_setObject:block(key, obj) forKey:key];
        }];
        return results;
    }
    else {
        QHCoreLibWarn(@"mapping dictionary with nil block, just return an copy of self\n%@",
                      QHCallStackShort());
        return [NSDictionary dictionaryWithDictionary:self];
    }
}

@end

@implementation NSDictionary (QHCoreLibDefaultValue)

- (BOOL)qh_boolForKey:(id<NSCopying>)key
{
    return QHBool([self objectForKey:key], NO);
}

- (NSInteger)qh_integerForKey:(id<NSCopying>)key
{
    return QHInteger([self objectForKey:key], 0);
}

- (double)qh_doubleForKey:(id<NSCopying>)key
{
    return QHDouble([self objectForKey:key], 0.0);
}

- (NSString *)qh_stringForKey:(id<NSCopying>)key
{
    return QHString([self objectForKey:key], @"");
}

- (NSArray *)qh_arrayForKey:(id<NSCopying>)key
{
    return QHArray([self objectForKey:key], @[]);
}

- (NSDictionary *)qh_dictionaryForKey:(id<NSCopying>)key
{
    return QHDictionary([self objectForKey:key], @{});
}

@end

@implementation NSMutableDictionary (QHCoreLib)

- (void)qh_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
    else {
        QHCoreLibWarn(@"set object(%@) for key(%@) ignored\n%@",
                      anObject, aKey, QHCallStackShort());
    }
}

@end
