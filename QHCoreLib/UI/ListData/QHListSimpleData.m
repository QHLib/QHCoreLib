//
//  QHListSimpleData.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListSimpleData.h"
#import "QHListSimpleData+internal.h"

#import "QHBase+internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHListSimpleData ()

@end

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
        self._list = [NSMutableArray array];
        if (QH_IS_ARRAY(listData)) {
            [self._list addObjectsFromArray:listData];
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
    [aCoder encodeObject:self._list forKey:@"list"];
}

#pragma mark -

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self listItemAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index
{
    [self setListItemAtIndex:index withListItem:obj];
}

#pragma mark -

- (NSUInteger)numberOfItems
{
    return self._list.count;
}

- (id _Nullable)listItemAtIndex:(NSUInteger)index
{
    return [self._list qh_objectAtIndex:index];
}

- (id _Nullable)headItem
{
    return self._head;
}

- (id _Nullable)footItem
{
    return self._foot;
}

#pragma mark -

- (void)p_listReload
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleDataReload:)]) {
        [self.delegate listSimpleDataReload:self];
    }
}

- (void)p_listBeginUpdate
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleDataWillBeginChange:)]) {
        [self.delegate listSimpleDataWillBeginChange:self];
    }
}

- (void)p_listInsertAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self.delegate listSimpleData:self
                        didChangeListItem:self[idx]
                               changeType:QHListItemChangeTypeInsert
                                 oldIndex:NSNotFound
                                 newIndex:idx];
        }];
    }
}

- (void)p_listUpdateAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {

            [self.delegate listSimpleData:self
                        didChangeListItem:self._list[idx]
                               changeType:QHListItemChangeTypeUpdate
                                 oldIndex:idx
                                 newIndex:idx];
        }];
    }
}

- (void)p_listDeleteAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {

            [self.delegate listSimpleData:self
                        didChangeListItem:self[idx]
                               changeType:QHListItemChangeTypeDelete
                                 oldIndex:idx
                                 newIndex:NSNotFound];
        }];
    }
}

- (void)p_listMoveFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex
{
    if ([self.delegate respondsToSelector:
         @selector(listSimpleData:didChangeListItem:changeType:oldIndex:newIndex:)]) {

        [self.delegate listSimpleData:self
                    didChangeListItem:self[oldIndex]
                           changeType:QHListItemChangeTypeMove
                             oldIndex:oldIndex
                             newIndex:newIndex];
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
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(listData),
                                @"invalid listData: %@\ncall stack: %@",
                                listData, QHCallStackShort());

    [self._list removeAllObjects];
    [self._list addObjectsFromArray:listData];

    [self p_listReload];
}

- (void)setHeadItem:(id)headItem
{
    self._head = headItem;
    [self p_listReload];
}

- (void)setFootItem:(id)footItem
{
    self._foot = footItem;
    [self p_listReload];
}

- (void)insertListData:(NSArray *)listData atIndex:(NSUInteger)index
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(listData),
                                @"invalid list data: %@\ncall stack: %@",
                                listData, QHCallStackShort());
    if (listData.count == 0) return;

    QHAssertReturnVoidOnFailure(index <= self._list.count,
                                @"invalid index to insert at: %d/%d\ncall stack: %@",
                                (int)index, (int)self._list.count,
                                QHCallStackShort());
    [self p_listBeginUpdate];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, listData.count)];
    [self._list insertObjects:listData atIndexes:indexes];
    [self p_listInsertAtIndexes:indexes];
    [self p_listEndUpdate];
}

- (void)appendListData:(NSArray *)listData
{
    [self insertListData:listData atIndex:self._list.count];
}

- (void)deleteListItemAtIndexes:(NSIndexSet *)indexes
{
    indexes = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     idx < self._list.count,
                                     @"invalid delete index: %d/%d\ncall stack: %@",
                                     (int)idx, (int)self._list.count, QHCallStackShort());
        return YES;
    }];

    [self p_listBeginUpdate];
    [self p_listDeleteAtIndexes:indexes];
    [self._list removeObjectsAtIndexes:indexes];
    [self p_listEndUpdate];
}

- (void)updateListItemAtIndexes:(NSIndexSet *)indexes
{
    indexes = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     idx < self._list.count,
                                     @"invalid update index: %d/%d\ncall stack: %@",
                                     (int)idx, (int)self._list.count, QHCallStackShort());
        return YES;
    }];
    
    [self p_listBeginUpdate];
    [self p_listUpdateAtIndexes:indexes];
    [self p_listEndUpdate];
}

- (void)setListItemAtIndex:(NSUInteger)index withListItem:(id)listItem
{
    QHAssertReturnVoidOnFailure(index < self._list.count,
                                @"invalid replace index: %d/%d\ncall stack: %@",
                                (int)index, (int)self._list.count, QHCallStackShort());

    QHAssertReturnVoidOnFailure(listItem,
                                @"list item is nil\ncall stack: %@",
                                QHCallStackShort());

    [self p_listBeginUpdate];
    [self._list replaceObjectAtIndex:index withObject:listItem];
    [self p_listUpdateAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    [self p_listEndUpdate];
}

- (void)moveListItemFromIndex:(NSUInteger)oldIndex
                      toIndex:(NSUInteger)newIndex
                 shouldNotify:(BOOL)shouldNotify
{
    QHAssertReturnVoidOnFailure(oldIndex < self._list.count && newIndex < self._list.count,
                                @"invalid move index pair: %d/%d -> %d/%d\ncall stack: %@",
                                (int)oldIndex, (int)self._list.count, (int)newIndex,
                                (int)self._list.count, QHCallStackShort());

    id obj = self[oldIndex];
    if (shouldNotify) {
        [self p_listBeginUpdate];
        [self p_listMoveFromIndex:oldIndex toIndex:newIndex];
        [self._list removeObjectAtIndex:oldIndex];
        [self._list insertObject:obj atIndex:newIndex];
        [self p_listEndUpdate];
    }
    else {
        [self._list removeObjectAtIndex:oldIndex];
        [self._list insertObject:obj atIndex:newIndex];
    }
}

@end

NS_ASSUME_NONNULL_END
