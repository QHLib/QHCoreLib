//
//  UIKit+QHCoreLib.m
//  QHCoreLib
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UIKit+QHCoreLib.h"
#import "QHBase.h"

@implementation UIView (QHUILib)

+ (void)qh_disableAnimationDuringBlock:(dispatch_block_t)block
{
    BOOL savedAnimated = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    QH_BLOCK_INVOKE(block);
    [UIView setAnimationsEnabled:savedAnimated];
}

@end
