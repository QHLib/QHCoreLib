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
    QHTableViewCellTypeStatic = -999999,
    QHTableViewCellTypeDefault = 0,
};

@interface QHTableViewCellItem : NSObject

+ (instancetype)itemFromType:(QHTableViewCellType)type
                        data:(id)data;

@property (nonatomic, assign, readonly) QHTableViewCellType type;

@property (nonatomic, strong, readonly) id data;


@end

NS_ASSUME_NONNULL_END
