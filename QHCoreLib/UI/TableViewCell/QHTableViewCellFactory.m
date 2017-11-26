//
//  QHTableViewCellFactory.m
//  QHCoreLib
//
//  Created by changtang on 2017/11/24.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellFactory.h"
#import "QHBase+internal.h"
#import "UIKit+QHCoreLib.h"
#import "QHTableViewSeperatorCell.h"

typedef Class(^QHTableViewCellClassResolver)(QHTableViewCellItem *,
                                             QHTableViewCellContext *);

@interface QHTableViewCellFactory ()

@property (nonatomic, strong) NSMutableDictionary *type2Class;
@property (nonatomic, strong) NSMutableArray<QHTableViewCellClassResolver> *resolvers;

@end

@implementation QHTableViewCellFactory

QH_SINGLETON_IMP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type2Class = [NSMutableDictionary dictionary];
        self.resolvers = [NSMutableArray array];
        
        [self registryCellClass:[QHTableViewSeperatorCell class]
                        forType:QHTableViewCellTypeSeperator];
    }
    return self;
}

- (void)registryCellClass:(Class)cellClass forType:(NSInteger)type
{
    QHAssertReturnVoidOnFailure(cellClass != nil && type > 0,
                                @"invalid pair: %@, %d", cellClass, (int)type);
    
    Class previous = [self.type2Class objectForKey:@(type)];
    if (previous && previous != cellClass) {
        QHCoreLibWarn(@"overwriting registry on type: %d with class: %@, previouse class: %@",
                      (int)type, NSStringFromClass(cellClass), previous);
    }
    
    [self.type2Class setObject:cellClass forKey:@(type)];
}

- (void)registryCellClassResolver:(QHTableViewCellClassResolver)resolver
{
    QHAssertReturnVoidOnFailure(resolver,
                                @"resolver should not be nil");
    
    [self.resolvers addObject:resolver];
}

- (Class)cellClassForItem:(QHTableViewCellItem *)item
                  context:(QHTableViewCellContext *)context
{
    __block Class cellClass = NULL;

    if (item.type == QHTableViewCellTypeStatic) {
        cellClass = [context.opaque class];
    }
    else if (item.type == QHTableViewCellTypeDefault) {
        cellClass = [UITableViewCell class];
    }
    else {
        cellClass = [self.type2Class objectForKey:@(item.type)];

        if (!cellClass) {
            [self.resolvers enumerateObjectsWithOptions:NSEnumerationReverse
                                             usingBlock:({
                ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    cellClass = ((QHTableViewCellClassResolver)obj)(item, context);
                    if (cellClass) {
                        *stop = YES;
                    }
                };
            })];
        }
    }

    if (!cellClass ) {
        NSCAssert(NO, @"no cell class found for type: %d", (int)item.type);
        cellClass = [UITableViewCell class];
    }

    return cellClass;
}

- (CGFloat)heightForItem:(QHTableViewCellItem *)item
                 context:(QHTableViewCellContext *)context
{
    if (item.type == QHTableViewCellTypeStatic) {
        QH_AS(context.opaque, UITableViewCell, staticCell);
        return staticCell.height;
    } else {
        Class cellClass = [self cellClassForItem:item context:context];
        return [cellClass qh_heightForItem:item context:context];
    }
}

- (UITableViewCell *)cellForItem:(QHTableViewCellItem *)item
                         context:(QHTableViewCellContext *)context
{
    UITableViewCell *cell = nil;
    
    if (item.type == QHTableViewCellTypeStatic) {
        QH_AS(context.opaque, UITableViewCell, staticCell);
        cell = staticCell;
    } else  {
        Class cellClass = [self cellClassForItem:item context:context];
        
        NSString *reuseIdentifier = ((context.reuseIdentifier
                                      && ((id)context.reuseIdentifier != (id)[NSNull null]))
                                     ? context.reuseIdentifier
                                     : [cellClass qh_reuseIdentifier]);
        cell = [context.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:reuseIdentifier];
        }
    }
    
    if (!cell) {
        cell = [context.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"defaultCell"];
    }
    
    [cell qh_configure:item context:context];

    return cell;
}

@end
