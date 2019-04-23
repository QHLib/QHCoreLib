//
//  main.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/4.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QHCoreLib/QHCoreLib.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        QHProfilerStart(@"main", @"launch");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
