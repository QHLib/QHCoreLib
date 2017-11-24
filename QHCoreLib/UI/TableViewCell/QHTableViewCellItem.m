//
//  QHTableViewCellItem.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellItem.h"

@interface QHTableViewCellItem ()

@property (nonatomic, assign, readwrite) QHTableViewCellType type;

@property (nonatomic, strong, readwrite) id data;

@end

@implementation QHTableViewCellItem

+ (instancetype)itemFromType:(QHTableViewCellType)type
                        data:(id)data
{
    QHTableViewCellItem *item = [QHTableViewCellItem new];

    item.type = type;
    item.data = data;
    // TODO: might be safer if we do a check
    // on whether the type matches with the data

    return item;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] == NO) {
        return NO;
    }

    typeof(self) other = (typeof(self))object;

    if (self.type != other.type) {
        return NO;
    }

    return  [self.data isEqual:other.data];
}

@end
