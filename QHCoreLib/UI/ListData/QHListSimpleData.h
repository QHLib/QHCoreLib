//
//  QHListSimpleData.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHListDataProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListSimpleData<ListItemType> : NSObject <QHListSimpleData, NSSecureCoding>

@property (nonatomic, weak, nullable) id<QHListSimpleDataDelegate> delegate;

- (instancetype)initWithListData:(NSArray<ListItemType> *)listData NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;
- (void)encodeWithCoder:(NSCoder *)aCoder NS_REQUIRES_SUPER;

#pragma mark -

- (ListItemType)objectAtIndexedSubscript:(NSUInteger)index;

- (void)setObject:(ListItemType)obj atIndexedSubscript:(NSUInteger)index;

#pragma mark -

- (ListItemType _Nullable)listItemAtIndex:(NSUInteger)index;

#pragma mark -

- (void)setListData:(NSArray<ListItemType> *)listData;

- (void)setHeadItem:(id)headItem;

- (void)setFootItem:(id)footItem;

- (void)appendListData:(NSArray<ListItemType> *)listData;

- (void)insertListData:(NSArray<ListItemType> *)listData
               atIndex:(NSUInteger)index;

- (void)deleteListItemAtIndexes:(NSIndexSet *)indexes;

- (void)updateListItemAtIndexes:(NSIndexSet *)indexes;

- (void)setListItemAtIndex:(NSUInteger)index
              withListItem:(ListItemType)listItem;

- (void)moveListItemFromIndex:(NSUInteger)oldIndex
                      toIndex:(NSUInteger)newIndex
                 shouldNotify:(BOOL)shouldNotify;

@end

NS_ASSUME_NONNULL_END
