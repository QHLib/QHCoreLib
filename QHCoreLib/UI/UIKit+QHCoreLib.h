//
//  UIKit+QHCoreLib.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (QHCoreLib)

+ (void)qh_disableAnimationDuringBlock:(dispatch_block_t)block;

@end
