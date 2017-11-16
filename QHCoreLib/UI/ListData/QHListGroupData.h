//
//  QHListGroupData.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHListDataProtocol.h>
#import <QHCoreLib/QHListSimpleData.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListGroupData<ListItemType> : NSObject<QHListGroupData, NSSecureCoding>

@property (nonatomic, weak, nullable) id<QHListGroupDataDelegate> delegate;

- (instancetype)initWithSections:(NSArray<QHListSimpleData<ListItemType> *> *)sections;

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;
- (void)encodeWithCoder:(NSCoder *)aCoder NS_REQUIRES_SUPER;

#pragma mark -

- (QHListSimpleData<ListItemType> *)objectAtIndexedSubscript:(NSUInteger)sectionIndex;

- (void)setObject:(QHListSimpleData<ListItemType> *)obj atIndexedSubscript:(NSUInteger)sectionIndex;

#pragma mark -

- (QHListSimpleData<ListItemType> *)sectionAtIndex:(NSUInteger)sectionIndex;

- (ListItemType _Nullable)listItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark -

- (void)setSections:(NSArray<QHListSimpleData<ListItemType> *> *)sections;

- (void)appendSections:(NSArray<QHListSimpleData<ListItemType> *> *)sections;

- (void)insertSections:(NSArray<QHListSimpleData<ListItemType> *> *)sections
               atIndex:(NSUInteger)sectionIndex;

- (void)deleteSectionsAtIndexes:(NSIndexSet *)sectionIndexes;

- (void)updateSectionsAtIndexes:(NSIndexSet *)sectionIndexes;

- (void)setSectionAtIndex:(NSUInteger)sectionIndex
              withSection:(QHListSimpleData<ListItemType> *)section;

- (void)setSectionHeadAtIndex:(NSUInteger)sectionIndex
                 withHeadItem:(id)headItem;

- (void)setSectionFootAtIndex:(NSUInteger)sectionIndex
                 withFootItem:(id)footItem;

#pragma mark -

// these list item actions should be wrapped between `beginUpdate` and `endUpdate`
- (void)beginUpdate;

- (void)appendListData:(NSArray<ListItemType> *)listData
               atIndex:(NSUInteger)sectionIndex;

- (void)insertListData:(NSArray<ListItemType> *)listData
           atIndexPath:(NSIndexPath *)indexPath;

- (void)deleteListItemAtIndexPathes:(NSSet<NSIndexPath *> *)indexPathes;

- (void)updateListItemAtIndexPathes:(NSSet<NSIndexPath *> *)indexPathes;

- (void)setListItemAtIndexPath:(NSIndexPath *)indexPath
                  withListItem:(ListItemType)listItem;

- (void)endUpdate;
// end

- (void)moveListItemFromIndexPath:(NSIndexPath *)oldIndexPath
                      toIndexPath:(NSIndexPath *)newIndexPath
                     shouldNotify:(BOOL)shouldNotify;

@end

NS_ASSUME_NONNULL_END
