//
//  QHTableViewSeperatorCell.h
//  QHCoreLib
//
//  Created by Tony Tang on 2017/11/26.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHTableViewSeperatorConfig : NSObject

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@interface QHTableViewSeperatorCell : UITableViewCell

@end
