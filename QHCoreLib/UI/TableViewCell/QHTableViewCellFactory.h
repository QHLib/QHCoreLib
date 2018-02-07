//
//  QHTableViewCellFactory.h
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>
#import <QHCoreLib/QHTableViewCellItem.h>
#import <QHCoreLib/QHTableViewCellContext.h>
#import <QHCoreLib/UITableViewCell+QHTableViewCell.h>
#import <QHCoreLib/QHTableViewPlaceholderCell.h>
#import <QHCoreLib/QHTableViewSeperatorCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHTableViewCellFactory : NSObject

QH_SINGLETON_DEF

+ (instancetype)privateFactory;

- (void)registryCellClass:(Class)cellClass
                  forType:(NSInteger)type;

- (void)registryCellClassResolver:(Class _Nullable(^)(QHTableViewCellItem *item,
                                                      QHTableViewCellContext *context))resolver;

- (CGFloat)heightForItem:(QHTableViewCellItem *)item
                 context:(QHTableViewCellContext *)context;

- (UITableViewCell *)cellForItem:(QHTableViewCellItem *)item
                         context:(QHTableViewCellContext *)context;

@end

#define QHTableViewCellFactoryRegistry(_class, _type) \
    [[QHTableViewCellFactory sharedInstance] registryCellClass:_class \
                                                       forType:_type];

NS_ASSUME_NONNULL_END
