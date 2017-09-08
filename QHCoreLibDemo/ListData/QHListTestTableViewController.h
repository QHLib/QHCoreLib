//
//  QHListTestTableViewController.h
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QHCoreLib/QHCoreLib.h>

@interface QHListTestTableViewController : UITableViewController <QHListSimpleDataDelegate, QHListGroupDataDelegate>

- (NSString *)nextRowId;

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath;

@end
