//
//  EntranceViewController.h
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntranceViewController : UITableViewController

@property (nonatomic, strong) NSArray<NSString *> *controllerTitles;
@property (nonatomic, strong) NSArray<Class> *controllerClasses;

@end
