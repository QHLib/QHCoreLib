//
//  QHTableViewCellItem.h
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHTableViewCellType) {
    QHTableViewCellTypeStatic = -1,
    QHTableViewCellTypeDefault = 0,
    
    QHTableViewCellTypePlaceholder,
    QHTableViewCellTypeSeperator,

    QHTableViewCellTypeCustomBegin = 100,
    QHTableViewCellTypeCustomEnd = 999999,

    QHTableViewCellTypePrivateBegin = 1000000,
};

@interface QHTableViewCellItem : NSObject

+ (instancetype)itemFromType:(NSInteger)type
                        data:(id _Nullable)data;

@property (nonatomic, assign, readonly) NSInteger type;

@property (nonatomic, strong, readonly) id data;

@end

#define QHTableViewCellItemMake(_type, _data) \
    [QHTableViewCellItem itemFromType:_type data:_data]

NS_ASSUME_NONNULL_END
