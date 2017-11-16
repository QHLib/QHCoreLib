//
//  QHListGroupData+internal.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <QHCoreLib/QHListGroupData.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHListGroupData () <QHListSimpleDataDelegate>

@property (nonatomic, strong) NSMutableArray<QHListSimpleData *> *_sectionsList;

#pragma mark - notify methods

- (void)p_listReloadAllSections;

- (void)p_listBeginUpdate;

- (void)p_listInsertSectionAtIndexes:(NSIndexSet *)indexes;
- (void)p_listDeleteSectionAtIndexes:(NSIndexSet *)indexes;
- (void)p_listReloadSectionAtIndexes:(NSIndexSet *)indexes;

- (void)p_listInsertListItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)p_listDeleteListItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)p_listUpdateListItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)p_listMoveListItemFromIndexPath:(NSIndexPath *)oldIndexPath
                            toIndexPath:(NSIndexPath *)newIndexPath;

- (void)p_listEndUpdate;

@end

NS_ASSUME_NONNULL_END
