//
//  QHUIAlertViewManager.h
//  QHCoreLib
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHUIAlertViewManager : NSObject

+ (instancetype)managerForAlertView:(UIAlertView *)alertView
                            handler:(void(^)(NSUInteger buttonIndex))clickedButtonAtIndex;

@property (nonatomic, strong, readonly) UIAlertView *alertView;

- (void)autoManage;

- (void)invalidate;

@end
