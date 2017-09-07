//
//  QHListSimpleData+protected.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <QHCoreLib/QHListSimpleData.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListSimpleData<ListItemType> ()// (protected)

@property (nonatomic, strong) NSMutableArray<ListItemType> *list;

- (ListItemType _Nullable)objectInListAtIndex:(NSUInteger)index;

- (void)p_setList:(NSArray<ListItemType> *)list;

- (void)p_listBeginUpdate;

- (void)p_listInsert:(NSArray<ListItemType> *)list
             atIndex:(NSUInteger)index;

- (void)p_appendList:(NSArray<ListItemType> *)list;

- (void)p_listUpdateAtIndexes:(NSIndexSet *)indexes;

- (void)p_listRemoveAtIndexes:(NSIndexSet *)indexes;

- (void)p_listMoveFromIndex:(NSUInteger)oldIndex
                    toIndex:(NSUInteger)newIndex
               shouldNotify:(BOOL)shouldNotify;

- (void)p_listEndUpdate;

@end

NS_ASSUME_NONNULL_END
