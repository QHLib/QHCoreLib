//
//  QHTableViewCellFactory.h
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>
#import <QHCoreLib/UITableViewCell+QHTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHTableViewCellFactory : NSObject

QH_SINGLETON_DEF

- (void)registryCellClass:(Class)cellClass
                  forType:(NSInteger)type;

- (void)registryCellClassResolver:(Class _Nullable(^)(QHTableViewCellItem *item,
                                                      QHTableViewCellContext *context))resolver;

- (CGFloat)heightForItem:(QHTableViewCellItem *)item
                 context:(QHTableViewCellContext *)context;

- (UITableViewCell *)cellForItem:(QHTableViewCellItem *)item
                         context:(QHTableViewCellContext *)context;

@end

NS_ASSUME_NONNULL_END
