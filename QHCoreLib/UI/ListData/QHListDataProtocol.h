//
//  QHListDataProtocol.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QHListItemChangeType) {
    QHListItemChangeTypeInsert = 1,
    QHListItemChangeTypeDelete = 2,
    QHListItemChangeTypeMove   = 3,
    QHListItemChangeTypeUpdate = 4,
};

@protocol QHListSimpleDataDelegate;

@protocol QHListSimpleData <NSObject>

@property (nonatomic, weak, nullable) id<QHListSimpleDataDelegate> delegate;

- (NSUInteger)numberOfItems;

- (id _Nullable)listItemAtIndex:(NSUInteger)index;

@optional

- (id _Nullable)headItem;
- (id _Nullable)footItem;

@end

@protocol QHListSimpleDataDelegate <NSObject>
@optional

- (void)listSimpleDataReload:(id<QHListSimpleData>)listSimpleData;

- (void)listSimpleDataWillBeginChange:(id<QHListSimpleData>)listSimpleData;

- (void)listSimpleData:(id<QHListSimpleData>)listSimpleData
     didChangeListItem:(id _Nullable)listItem
            changeType:(QHListItemChangeType)changeType
              oldIndex:(NSUInteger)oldIndex
              newIndex:(NSUInteger)newIndex;

- (void)listSimpleDataDidFinishChange:(id<QHListSimpleData>)listSimpleData;

@end


typedef NS_ENUM(NSUInteger, QHListDataRequestType) {
    QHListDataRequestTypeNotLoadYet = 0,
    QHListDataRequestTypeEmptyLoad,         // no cache
    QHListDataRequestTypeDirtyLoad,         // cache expired
    QHListDataRequestTypeReload,            // pull refresh
    QHListDataRequestTypeNext,              // next page
};

@protocol QHListDataLoaderDelegate;
@protocol QHListDataLoader <NSObject>

@property (nonatomic, weak, nullable) id<QHListDataLoaderDelegate> delegate;

- (BOOL)isLoading;

- (QHListDataRequestType)requestType;

- (BOOL)hasMore;

- (void)load;
- (void)dirtyLoad;
- (void)reload;
- (void)loadNext;

- (void)cancel;

@end

@protocol QHListDataLoaderDelegate <NSObject>

- (void)listDataLoaderSucceed:(id<QHListDataLoader>)listDataLoader
                         list:(NSArray *)list
                     userInfo:(NSDictionary * _Nullable)userInfo;

- (void)listDataLoaderFailed:(id<QHListDataLoader>)listDataLoader
                       error:(NSError *)error
                    userInfo:(NSDictionary * _Nullable)userInfo;

@end


typedef NS_ENUM(NSUInteger, QHListSectionChangeType) {
    QHListSectionChangeTypeInsert = 1,
    QHListSectionChangeTypeDelete = 2,
    QHListSectionChangeTypeUpdate = 4,
};

@protocol QHListGroupDataDelegate;

@protocol QHListGroupData <NSObject>

@property (nonatomic, weak, nullable) id<QHListGroupDataDelegate> delegate;

- (NSUInteger)numberOfSections;

- (id<QHListSimpleData>)sectionAtIndex:(NSUInteger)sectionIndex;

- (NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex;

- (id _Nullable)listItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (id _Nullable)headItemForSection:(NSUInteger)sectionIndex;
- (id _Nullable)footItemForSection:(NSUInteger)sectionIndex;

@end

@protocol QHListGroupDataDelegate <NSObject>
@optional

- (void)listGroupDataReloadAll:(id<QHListGroupData>)listGroupData;

- (void)listGroupDataWillBeginChange:(id<QHListGroupData>)listGroupData;

- (void)listGroupData:(id<QHListGroupData>)listGroupData
     didChangeSection:(id<QHListSimpleData> _Nullable)section
           changeType:(QHListSectionChangeType)changeType
             oldIndex:(NSUInteger)oldSectionIndex
             newIndex:(NSUInteger)newSectionIndex;

- (void)listGroupData:(id<QHListGroupData>)listGroupData
    didChangeListItem:(id _Nullable)listItem
           changeType:(QHListItemChangeType)changeType
         oldIndexPath:(NSIndexPath * _Nullable)oldIndexPath
         newIndexPath:(NSIndexPath * _Nullable)newIndexPath;

- (void)listGroupDataDidFinishChange:(id<QHListGroupData>)listGroupData;

@end

NS_ASSUME_NONNULL_END
