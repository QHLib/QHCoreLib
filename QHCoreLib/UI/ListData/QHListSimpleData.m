//
//  QHListSimpleData.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHListSimpleData.h"
#import "QHListSimpleData+protected.h"

#import "QHBase+internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation QHListSimpleData

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)init
{
    return [self initWithListData:@[]];
}

- (instancetype)initWithListData:(NSArray *)listData
{
    self = [super init];
    if (self) {
        self.list = [NSMutableArray array];
        if (QH_IS_ARRAY(listData)) {
            [self.list addObjectsFromArray:listData];
        } else {
            QHAssert(NO, @"list data is not array: %@", listData);
        }
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *decodedList = [aDecoder decodeObjectOfClass:[NSArray class]
                                                  forKey:@"list"];
    return [self initWithListData:decodedList ?: @[]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.list forKey:@"list"];
}

#pragma mark -

- (NSUInteger)numberOfItems
{
    return self.list.count;
}

- (id _Nullable)listItemAtIndex:(NSUInteger)index
{
    return [self.list qh_objectAtIndex:index];
}

- (id _Nullable)headItem
{
    return nil;
}

- (id _Nullable)footItem
{
    return nil;
}

#pragma mark -

- (id _Nullable)objectInListAtIndex:(NSUInteger)index
{
    return [self listItemAtIndex:index];
}

- (void)p_setList:(NSArray *)list
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(list),
                                @"invalid list: %@\ncall stack: %@",
                                list, QHCallStackShort());

    [self.list removeAllObjects];
    [self.list addObjectsFromArray:list];

    if ([self.delegate respondsToSelector:@selector(listSimpleDataReload:)]) {
        [self.delegate listSimpleDataReload:self];
    }
}

- (void)p_listBeginUpdate
{
    if ([self.delegate respondsToSelector:@selector(listSimpleDataWillBeginChange:)]) {
        [self.delegate listSimpleDataWillBeginChange:self];
    }
}

- (void)p_listInsert:(NSArray *)list
             atIndex:(NSUInteger)index
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(list),
                                @"invalid list: %@\ncall stack: %@",
                                list, QHCallStackShort());
    if (list.count == 0) return;

    QHAssertReturnVoidOnFailure(index <= self.list.count,
                                @"invalid index to insert at: %d/%d\ncall stack: %@",
                                (int)index, (int)self.list.count,
                                QHCallStackShort());

    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, list.count)];
    [self.list insertObjects:list atIndexes:indexes];

    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.delegate listSimpleData:self
                        didChangeListItem:list[idx]
                               changeType:QHListItemChangeTypeInsert
                                 oldIndex:NSNotFound
                                 newIndex:index + idx];
        }];
    }
}

- (void)p_appendList:(NSArray *)list
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(list),
                                @"invalid list: %@\ncall stack: %@",
                                list, QHCallStackShort());

    [self p_listBeginUpdate];
    [self p_listInsert:list atIndex:self.list.count];
    [self p_listEndUpdate];
}

- (void)p_listUpdateAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            QHAssertReturnVoidOnFailure(idx < self.list.count,
                                        @"invalid update index: %d/%d\ncall stack: %@",
                                        (int)idx, (int)self.list.count, QHCallStackShort());

            [self.delegate listSimpleData:self
                        didChangeListItem:self.list[idx]
                               changeType:QHListItemChangeTypeUpdate
                                 oldIndex:idx
                                 newIndex:idx];
        }];
    }
}

- (void)p_listRemoveAtIndexes:(NSIndexSet *)indexes
{
    NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
    NSMutableDictionary *objectsToRemove = [NSMutableDictionary dictionary];

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {

        QHAssertReturnVoidOnFailure(idx < self.list.count,
                                    @"invalid remove index %d/%d\ncall stack: %@",
                                    (int)idx, (int)self.list.count, QHCallStackShort());

        [indexesToRemove addIndex:idx];
        [objectsToRemove setObject:self.list[idx] forKey:@(idx)];
    }];

    [self.list removeObjectsAtIndexes:indexesToRemove];

    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [objectsToRemove enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

            [self.delegate listSimpleData:self
                        didChangeListItem:obj
                               changeType:QHListItemChangeTypeDelete
                                 oldIndex:[key unsignedIntegerValue]
                                 newIndex:NSNotFound];
        }];
    }
}

- (void)p_listMoveFromIndex:(NSUInteger)oldIndex
                    toIndex:(NSUInteger)newIndex
               shouldNotify:(BOOL)shouldNotify
{
    QHAssertReturnVoidOnFailure(oldIndex < self.list.count && newIndex < self.list.count,
                                @"invalid move index pair: %d/%d -> %d/%d\ncall stack: %@",
                                (int)oldIndex, (int)self.list.count, (int)newIndex,
                                (int)self.list.count, QHCallStackShort());

    id obj = self.list[oldIndex];
    [self.list removeObjectAtIndex:oldIndex];
    [self.list insertObject:obj atIndex:newIndex];

    if (shouldNotify) {
        if ([self.delegate respondsToSelector:
             @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {
            [self.delegate listSimpleData:self
                        didChangeListItem:obj
                               changeType:QHListItemChangeTypeMove
                                 oldIndex:oldIndex
                                 newIndex:newIndex];
        }
    }
}

- (void)p_listEndUpdate
{
    if ([self.delegate respondsToSelector:@selector(listSimpleDataDidFinishChange:)]) {
        [self.delegate listSimpleDataDidFinishChange:self];
    }
}

#pragma mark -

- (void)setListData:(NSArray *)listData
{
    [self p_setList:listData];
}

- (void)insertListData:(NSArray *)listData atIndex:(NSUInteger)index
{
    [self p_listInsert:listData atIndex:index];
}

- (void)appendListData:(NSArray *)listData
{
    [self p_appendList:listData];
}

@end

NS_ASSUME_NONNULL_END
