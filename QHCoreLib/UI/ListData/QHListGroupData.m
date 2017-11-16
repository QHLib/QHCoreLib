//
//  QHListGroupData.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListGroupData.h"
#import "QHListGroupData+internal.h"
#import "QHListSimpleData.h"
#import "QHListSimpleData+internal.h"

#import "QHBase+internal.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListGroupData ()

@property (nonatomic, assign) NSUInteger batchCount;

@end

@implementation QHListGroupData

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)init
{
    return [self initWithSections:@[]];
}

- (instancetype)initWithSections:(NSArray *)sections
{
    self = [super init];
    if (self) {
        self._sectionsList = [NSMutableArray array];
        if (QH_IS_ARRAY(sections)) {
            [self._sectionsList addObjectsFromArray:sections];
            [self._sectionsList enumerateObjectsUsingBlock:^(QHListSimpleData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.delegate = self;
            }];
        } else {
            QHAssert(NO, @"sections is  not array: %@", sections);
        }

        self.batchCount = 0;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *decodedSections = [aDecoder decodeObjectOfClass:[NSArray class]
                                                      forKey:@"sectionsList"];
    return [self initWithSections:decodedSections ?: @[]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._sectionsList forKey:@"sectionsList"];
}

#pragma mark -

- (QHListSimpleData *)objectAtIndexedSubscript:(NSUInteger)sectionIndex
{
    return [self sectionAtIndex:sectionIndex];
}

- (void)setObject:(QHListSimpleData *)obj atIndexedSubscript:(NSUInteger)sectionIndex
{
    [self setSectionAtIndex:sectionIndex withSection:obj];
}

#pragma mark -

- (NSUInteger)numberOfSections
{
    return self._sectionsList.count;
}

- (QHListSimpleData *)sectionAtIndex:(NSUInteger)sectionIndex
{
    return [self._sectionsList qh_objectAtIndex:sectionIndex];
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex
{
    return [self._sectionsList qh_objectAtIndex:sectionIndex].numberOfItems;
}

- (id _Nullable)listItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self._sectionsList qh_objectAtIndex:indexPath.section] listItemAtIndex:indexPath.row];
}

- (id _Nullable)headItemForSection:(NSUInteger)sectionIndex
{
    return [[self._sectionsList qh_objectAtIndex:sectionIndex] headItem];
}

- (id _Nullable)footItemForSection:(NSUInteger)sectionIndex
{
    return [[self._sectionsList qh_objectAtIndex:sectionIndex] footItem];
}

#pragma mark -

- (void)p_listReloadAllSections
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupDataReloadAll:)]) {
        [self.delegate listGroupDataReloadAll:self];
    }
}

- (void)p_listBeginUpdate
{
    if (self.batchCount++) return;

    if ([self.delegate respondsToSelector:
         @selector(listGroupDataWillBeginChange:)]) {
        [self.delegate listGroupDataWillBeginChange:self];
    }
}

- (void)p_listInsertSectionAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeSection:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self.delegate listGroupData:self
                        didChangeSection:self[idx]
                              changeType:QHListSectionChangeTypeInsert
                                oldIndex:NSNotFound
                                newIndex:idx];
        }];
    }
}

- (void)p_listDeleteSectionAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeSection:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self.delegate listGroupData:self
                        didChangeSection:self[idx]
                              changeType:QHListSectionChangeTypeDelete
                                oldIndex:idx
                                newIndex:NSNotFound];
        }];
    }
}

- (void)p_listReloadSectionAtIndexes:(NSIndexSet *)indexes
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeSection:changeType:oldIndex:newIndex:)]) {

        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [self.delegate listGroupData:self
                        didChangeSection:self[idx]
                              changeType:QHListSectionChangeTypeUpdate
                                oldIndex:idx
                                newIndex:idx];
        }];
    }
}

- (void)p_listInsertListItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeListItem:changeType:oldIndexPath:newIndexPath:)]) {

        [self.delegate listGroupData:self
                   didChangeListItem:self[indexPath.section][indexPath.row]
                          changeType:QHListItemChangeTypeInsert
                        oldIndexPath:nil
                        newIndexPath:indexPath];
    }
}

- (void)p_listDeleteListItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeListItem:changeType:oldIndexPath:newIndexPath:)]) {

        [self.delegate listGroupData:self
                   didChangeListItem:self[indexPath.section][indexPath.row]
                          changeType:QHListItemChangeTypeDelete
                        oldIndexPath:indexPath
                        newIndexPath:nil];
    }
}

- (void)p_listUpdateListItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeListItem:changeType:oldIndexPath:newIndexPath:)]) {

        [self.delegate listGroupData:self
                   didChangeListItem:self[indexPath.section][indexPath.row]
                          changeType:QHListItemChangeTypeUpdate
                        oldIndexPath:indexPath
                        newIndexPath:indexPath];
    }
}

- (void)p_listMoveListItemFromIndexPath:(NSIndexPath *)oldIndexPath
                            toIndexPath:(NSIndexPath *)newIndexPath
{
    if ([self.delegate respondsToSelector:
         @selector(listGroupData:didChangeListItem:changeType:oldIndexPath:newIndexPath:)]) {

        [self.delegate listGroupData:self
                   didChangeListItem:self[oldIndexPath.section][oldIndexPath.row]
                          changeType:QHListItemChangeTypeMove
                        oldIndexPath:oldIndexPath
                        newIndexPath:newIndexPath];
    }
}

- (void)p_listEndUpdate
{
    if (--self.batchCount) return;

    if ([self.delegate respondsToSelector:
         @selector(listGroupDataDidFinishChange:)]) {
        [self.delegate listGroupDataDidFinishChange:self];
    }
}

#pragma mark -

- (void)setSections:(NSArray *)sections
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(sections),
                                @"invalid sections: %@\ncall stack: %@",
                                sections, QHCallStackShort());
    [self._sectionsList enumerateObjectsUsingBlock:^(QHListSimpleData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = nil;
    }];
    [self._sectionsList removeAllObjects];
    [self._sectionsList addObjectsFromArray:sections];
    [self._sectionsList enumerateObjectsUsingBlock:^(QHListSimpleData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = self;
    }];

    [self p_listReloadAllSections];
}

- (void)appendSections:(NSArray<QHListSimpleData *> *)sections
{
    [self insertSections:sections atIndex:self._sectionsList.count];
}

- (void)insertSections:(NSArray<QHListSimpleData *> *)sections
               atIndex:(NSUInteger)sectionIndex
{
    QHAssertReturnVoidOnFailure(QH_IS_ARRAY(sections),
                                @"invalid sections: %@\ncall stack: %@",
                                sections, QHCallStackShort());
    if (sections.count == 0) return;

    QHAssertReturnVoidOnFailure(sectionIndex <= self._sectionsList.count,
                                @"invalid index to insert at: %d/%d\ncall stack: %@",
                                (int)sectionIndex, (int)self._sectionsList.count,
                                QHCallStackShort());

    [self p_listBeginUpdate];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(sectionIndex, sections.count)];
    [self._sectionsList insertObjects:sections atIndexes:indexes];
    [sections enumerateObjectsUsingBlock:^(QHListSimpleData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = self;
    }];
    [self p_listInsertSectionAtIndexes:indexes];
    [self p_listEndUpdate];
}

- (void)deleteSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    sectionIndexes = [sectionIndexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     idx < self._sectionsList.count,
                                     @"invalid section index to delete: %d/%d\ncall stack: %@",
                                     (int)idx, (int)self._sectionsList.count, QHCallStackShort());
        return YES;
    }];

    [self p_listBeginUpdate];
    [self p_listDeleteSectionAtIndexes:sectionIndexes];
    [[self._sectionsList objectsAtIndexes:sectionIndexes] enumerateObjectsUsingBlock:^(QHListSimpleData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = nil;
    }];
    [self._sectionsList removeObjectsAtIndexes:sectionIndexes];
    [self p_listEndUpdate];
}

- (void)updateSectionsAtIndexes:(NSIndexSet *)sectionIndexes
{
    sectionIndexes = [sectionIndexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     idx < self._sectionsList.count,
                                     @"invalid section index to update: %d/%d\ncall stack: %@",
                                     (int)idx, (int)self._sectionsList.count, QHCallStackShort());
        return YES;
    }];
    
    [self p_listBeginUpdate];
    [self p_listReloadSectionAtIndexes:sectionIndexes];
    [self p_listEndUpdate];
}

- (void)setSectionAtIndex:(NSUInteger)sectionIndex
              withSection:(QHListSimpleData *)section
{
    QHAssertReturnVoidOnFailure(sectionIndex < self._sectionsList.count,
                                @"invalid replace index: %d/%d\ncall stack: %@",
                                (int)sectionIndex, (int)self._sectionsList.count, QHCallStackShort());
    QHAssertReturnVoidOnFailure(section,
                                @"section is nil\ncall stack: %@",
                                QHCallStackShort());

    [self p_listBeginUpdate];
    self[sectionIndex].delegate = nil;
    section.delegate = self;
    [self._sectionsList replaceObjectAtIndex:sectionIndex withObject:section];
    [self p_listReloadSectionAtIndexes:[NSIndexSet indexSetWithIndex:sectionIndex]];
    [self p_listEndUpdate];
}

- (void)setSectionHeadAtIndex:(NSUInteger)sectionIndex withHeadItem:(id)headItem
{
    QHAssertReturnVoidOnFailure(sectionIndex < self._sectionsList.count,
                                @"invalid section index to  set head: %d/%d\ncall stack: %@",
                                (int)sectionIndex, (int)self._sectionsList.count, QHCallStackShort());

    [self p_listBeginUpdate];
    self[sectionIndex].headItem = headItem;
    [self p_listEndUpdate];
}

- (void)setSectionFootAtIndex:(NSUInteger)sectionIndex withFootItem:(id)footItem
{
    QHAssertReturnVoidOnFailure(sectionIndex < self._sectionsList.count,
                                @"invalid section index to set foot: %d/%d\ncall stack: %@",
                                (int)sectionIndex, (int)self._sectionsList.count, QHCallStackShort());
    [self p_listBeginUpdate];
    self[sectionIndex].footItem = footItem;
    [self p_listEndUpdate];
}

#pragma mark - listSimpleDataDelegate

- (void)listSimpleDataReload:(id<QHListSimpleData>)listSimpleData
{
    NSUInteger sectionIndex = [self._sectionsList indexOfObject:(QHListSimpleData *)listSimpleData];
    QHAssertReturnVoidOnFailure(sectionIndex != NSNotFound,
                                @"section %@ not found in section list %@\ncall stack: %@",
                                listSimpleData, self._sectionsList, QHCallStackShort());

    [self p_listReloadSectionAtIndexes:[NSIndexSet indexSetWithIndex:sectionIndex]];
}

- (void)listSimpleDataWillBeginChange:(id<QHListSimpleData>)listSimpleData
{
    NSUInteger sectionIndex = [self._sectionsList indexOfObject:(QHListSimpleData *)listSimpleData];
    QHAssertReturnVoidOnFailure(sectionIndex != NSNotFound,
                                @"section %@ not found in section list %@\ncall stack: %@",
                                listSimpleData, self._sectionsList, QHCallStackShort());

    [self p_listBeginUpdate];
}

- (void)listSimpleData:(id<QHListSimpleData>)listSimpleData
     didChangeListItem:(id _Nullable)listItem
            changeType:(QHListItemChangeType)changeType
              oldIndex:(NSUInteger)oldIndex
              newIndex:(NSUInteger)newIndex
{
    NSUInteger sectionIndex = [self._sectionsList indexOfObject:(QHListSimpleData *)listSimpleData];
    QHAssertReturnVoidOnFailure(sectionIndex != NSNotFound,
                                @"section %@ not found in section list %@\ncall stack: %@",
                                listSimpleData, self._sectionsList, QHCallStackShort());

    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:sectionIndex];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:sectionIndex];

    switch (changeType) {
        case QHListItemChangeTypeInsert: {
            [self p_listInsertListItemAtIndexPath:newIndexPath];
            break;
        }

        case QHListItemChangeTypeDelete: {
            [self p_listDeleteListItemAtIndexPath:oldIndexPath];
            break;
        }

        case QHListItemChangeTypeUpdate: {
            [self p_listUpdateListItemAtIndexPath:oldIndexPath];
            break;
        }

        case QHListItemChangeTypeMove: {
            [self p_listMoveListItemFromIndexPath:oldIndexPath
                                      toIndexPath:newIndexPath];
            break;
        }

        default: {
            QHAssert(NO, @"should not be here");
            break;
        }
    }
}

- (void)listSimpleDataDidFinishChange:(id<QHListSimpleData>)listSimpleData
{
    NSUInteger sectionIndex = [self._sectionsList indexOfObject:(QHListSimpleData *)listSimpleData];
    QHAssertReturnVoidOnFailure(sectionIndex != NSNotFound,
                                @"section %@ listSimpleData, not found in section list %@\ncall stack: %@",
                                listSimpleData, self._sectionsList, QHCallStackShort());

    [self p_listEndUpdate];
}

#pragma mark -

- (void)beginUpdate
{
    QHAssert(self.batchCount == 0,
             @"something wrong!\ncall stack: %@",
             QHCallStackShort());

    [self p_listBeginUpdate];
}

- (void)appendListData:(NSArray *)listData
               atIndex:(NSUInteger)sectionIndex
{
    QHAssertReturnVoidOnFailure(sectionIndex < self._sectionsList.count,
                                @"invalid sectionIndex to append list data: %d/%d\ncall stack: %@",
                                (int)sectionIndex, (int)self._sectionsList.count, QHCallStackShort());

    [self[sectionIndex] appendListData:listData];
}

- (void)insertListData:(NSArray *)listData
           atIndexPath:(NSIndexPath *)indexPath
{
    QHAssertReturnVoidOnFailure(indexPath.section < self._sectionsList.count,
                                @"invalid sectionIndex to append list data: %d/%d\ncall stack: %@",
                                (int)indexPath.section, (int)self._sectionsList.count, QHCallStackShort());

    [self[indexPath.section] insertListData:listData
                                    atIndex:indexPath.row];
}

- (void)deleteListItemAtIndexPathes:(NSSet<NSIndexPath *> *)indexPathes
{
    indexPathes = [indexPathes objectsPassingTest:^BOOL(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     obj.section < self._sectionsList.count,
                                     @"invalid sectionIndex of indexPath to delete: %d/%d\ncall stack: %@",
                                     (int)obj.section, (int)self._sectionsList.count, QHCallStackShort());
        return YES;
    }];

    [indexPathes enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:obj.row];
        [self[obj.section] deleteListItemAtIndexes:indexes];
    }];
}

- (void)updateListItemAtIndexPathes:(NSSet<NSIndexPath *> *)indexPathes
{
    indexPathes = [indexPathes objectsPassingTest:^BOOL(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        QHAssertReturnValueOnFailure(NO,
                                     obj.section < self._sectionsList.count,
                                     @"invalid sectionIndex of indexPath to update: %d/%d\ncall stack: %@",
                                     (int)obj.section, (int)self._sectionsList.count, QHCallStackShort());
        return YES;
    }];

    [indexPathes enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:obj.row];
        [self[obj.section] updateListItemAtIndexes:indexes];
    }];
}

- (void)setListItemAtIndexPath:(NSIndexPath *)indexPath
                  withListItem:(id)listItem
{
    QHAssertReturnVoidOnFailure(indexPath.section < self._sectionsList.count,
                                @"invalid sectionIndex of indexPath to replace: %d/%d\ncall stack: %@",
                                (int)indexPath.section, (int)self._sectionsList.count, QHCallStackShort());

    [self[indexPath.section] setListItemAtIndex:indexPath.row
                                   withListItem:listItem];
}

- (void)endUpdate
{
    QHAssert(self.batchCount == 1,
             @"something wrong!\ncall stack: %@",
             QHCallStackShort());

    [self p_listEndUpdate];
}

- (void)moveListItemFromIndexPath:(NSIndexPath *)oldIndexPath
                      toIndexPath:(NSIndexPath *)newIndexPath
                     shouldNotify:(BOOL)shouldNotify
{
    QHAssertReturnVoidOnFailure(oldIndexPath.section < self._sectionsList.count,
                                @"invalid sectionIndex of oldIndexPath to move: %d/%d\ncall stack: %@",
                                (int)oldIndexPath.section, (int)self._sectionsList.count, QHCallStackShort());
    QHListSimpleData *oldSection = self[oldIndexPath.section];

    QHAssertReturnVoidOnFailure(newIndexPath.section < self._sectionsList.count,
                                @"invalid sectionIndex of indexPath to move: %d/%d\ncall stack: %@",
                                (int)newIndexPath.section, (int)self._sectionsList.count, QHCallStackShort());
    QHListSimpleData *newSection = self[newIndexPath.section];

    if (oldSection == newSection) {
        [oldSection moveListItemFromIndex:oldIndexPath.row
                                  toIndex:newIndexPath.row
                             shouldNotify:shouldNotify];
    } else {
        if (shouldNotify) {
            id listItem = [oldSection._list qh_objectAtIndex:oldIndexPath.row];
            [oldSection deleteListItemAtIndexes:[NSIndexSet indexSetWithIndex:oldIndexPath.row]];
            [newSection insertListData:@[ listItem ] atIndex:newIndexPath.row];
        }
        else {
            QHAssertReturnVoidOnFailure(oldIndexPath.row < oldSection._list.count,
                                        @"invalid row of  oldIndexPath to move: %d/%d\ncall stack: %@",
                                        (int)oldIndexPath.row, (int)oldSection._list.count, QHCallStackShort());

            id listItem = [oldSection._list qh_objectAtIndex:oldIndexPath.row];
            [oldSection._list qh_removeObjectAtIndex:oldIndexPath.row];

            QHAssertReturnVoidOnFailure(newIndexPath.row <= newSection._list.count,
                                        @"invalid row of newIndexPath to move: %d/%d\ncall stack: %@",
                                        (int)newIndexPath.row, (int)newSection._list.count, QHCallStackShort());
            [newSection._list qh_insertObject:listItem atIndex:newIndexPath.row];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
