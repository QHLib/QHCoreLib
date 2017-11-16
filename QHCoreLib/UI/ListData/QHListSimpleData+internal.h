//
//  QHListSimpleData+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHListSimpleData.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListSimpleData<ListItemType> ()

@property (nonatomic, strong) NSMutableArray *_list;
@property (nonatomic, strong, nullable) id _head;
@property (nonatomic, strong, nullable) id _foot;

#pragma mark - notify methods

- (void)p_listReload;

- (void)p_listBeginUpdate;

- (void)p_listInsertAtIndexes:(NSIndexSet *)indexes;

- (void)p_listUpdateAtIndexes:(NSIndexSet *)indexes;

- (void)p_listDeleteAtIndexes:(NSIndexSet *)indexes;

- (void)p_listMoveFromIndex:(NSUInteger)oldIndex
                    toIndex:(NSUInteger)newIndex;

- (void)p_listEndUpdate;

@end

NS_ASSUME_NONNULL_END
