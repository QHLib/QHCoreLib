//
//  QHTableViewSeperatorCell.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/11/26.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewSeperatorCell.h"
#import "UITableViewCell+QHTableViewCell.h"
#import "UIKit+QHCoreLib.h"

@implementation QHTableViewSeperatorConfig

@end

@interface QHTableViewSeperatorCell ()

@property (nonatomic, strong) UIView *sepView;

QH_TABLEVIEW_CELL_DATA_DECL(config, QHTableViewSeperatorConfig)

@end

@implementation QHTableViewSeperatorCell

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item
                    context:(QHTableViewCellContext *)context
{
    QH_AS(item.data, QHTableViewSeperatorConfig, config);
    return config.height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.sepView = [[UIView alloc] init];
        [self.contentView addSubview:self.sepView];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat width = (self.width - self.configData.insets.left
                     - self.configData.insets.right);
    CGFloat height = (self.height - self.configData.insets.top
                      - self.configData.insets.bottom);
    
    if (width < 0 || height < 0) {
        self.sepView.frame = CGRectZero;
    } else {
        self.sepView.frame = CGRectMake(self.configData.insets.left,
                                        self.configData.insets.top,
                                        width,
                                        height);
    }
}

QH_TABLEVIEW_CELL_DATA_IMPL(config, QHTableViewSeperatorConfig)

- (void)qh_configure:(QHTableViewCellItem *)item
             context:(QHTableViewCellContext *)context
{
    [super qh_configure:item context:context];
    
    self.sepView.backgroundColor = self.configData.backgroundColor;

    [self setNeedsLayout];
}

@end
