//
//  QHListSimpleData.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHListDataProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListSimpleData<ListItemType> : NSObject <QHListSimpleData, NSSecureCoding>

@property (nonatomic, weak,  nullable) id<QHListSimpleDataDelegate> delegate;

- (instancetype)initWithListData:(NSArray<ListItemType> *)listData NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;
- (void)encodeWithCoder:(NSCoder *)aCoder NS_REQUIRES_SUPER;

- (ListItemType _Nullable)listItemAtIndex:(NSUInteger)index;

- (void)setListData:(NSArray<ListItemType> *)listData NS_REQUIRES_SUPER;

- (void)insertListData:(NSArray<ListItemType> *)listData
               atIndex:(NSUInteger)index NS_REQUIRES_SUPER;

- (void)appendListData:(NSArray<ListItemType> *)listData NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
