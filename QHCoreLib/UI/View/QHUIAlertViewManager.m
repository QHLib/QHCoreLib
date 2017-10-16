//
//  QHUIAlertViewManager.m
//  QHCoreLib
//
//  Created by changtang on 2017/10/16.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUIAlertViewManager.h"
#import "QHBase.h"

@interface QHUIAlertViewManager () <UIAlertViewDelegate>

@property (nonatomic, strong, readwrite) UIAlertView *alertView;
@property (nonatomic, copy) void (^clickedButtonAtIndex)(NSUInteger buttonIndex);
@property (nonatomic, assign) BOOL autoManaged;

@end

@implementation QHUIAlertViewManager

+ (instancetype)managerForAlertView:(UIAlertView *)alertView
                            handler:(void (^)(NSUInteger))clickedButtonAtIndex
{
    QHUIAlertViewManager *manager = [[QHUIAlertViewManager alloc] init];

    alertView.delegate = manager;
    manager.alertView = alertView;
    
    @weakify(manager);
    manager.clickedButtonAtIndex = ^(NSUInteger buttonAtIndex) {
        @strongify(manager);
        if (clickedButtonAtIndex) {
            clickedButtonAtIndex(buttonAtIndex);
        }
        if (manager.autoManaged) {
            [manager invalidate];
        }
    };

    return manager;
}

- (void)dealloc
{
#if _QHCoreLibDebug
    NSLog(@"dealloc %@", self);
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickedButtonAtIndex) {
        self.clickedButtonAtIndex(buttonIndex);
    }
}

- (void)autoManage
{
    self.autoManaged = YES;
    self.alertView.qh_handy_carry = self; // retain cycle here
}

- (void)invalidate
{
    self.autoManaged = NO;
    self.alertView.qh_handy_carry = nil;
}

@end
