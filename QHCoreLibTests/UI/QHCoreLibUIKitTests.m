//
//  QHCoreLibUIKitTests.m
//  QHCoreLibTests
//
//  Created by changtang on 2017/9/12.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <QHCoreLib/QHUI.h>

@interface QHCoreLibUIKitTests : XCTestCase

@end

@implementation QHCoreLibUIKitTests

- (void)testUIDefines
{
    NSLog(@"screen scale: %f", QH_SCREEN_SCALE);
    NSLog(@"screen width: %f", QH_SCREEN_WIDTH);
    NSLog(@"screen height: %f", QH_SCREEN_HEIGHT);
    NSLog(@"screen portrait width: %f", QH_SCREEN_PORTRAIT_WIDTH);
    NSLog(@"screen portrait height: %f", QH_SCREEN_PORTRAIT_HEIGHT);

    XCTAssertTrue(QH_DP_320(320) == QH_SCREEN_PORTRAIT_WIDTH);
    XCTAssertTrue(QH_DP_375(375) == QH_SCREEN_PORTRAIT_WIDTH);
    XCTAssertTrue(QH_DP_414(414) == QH_SCREEN_PORTRAIT_WIDTH);

    XCTAssertTrue(QH_DP(375) == QH_SCREEN_PORTRAIT_WIDTH);

    NSLog(@"status bar height: %f", QH_STATUSBAR_HEIGHT);
    NSLog(@"navigation bar height: %f", QH_NAVIGATIONBAR_HEIGHT);
    NSLog(@"top bar height: %f", QH_TOPBAR_HEIGHT);
    NSLog(@"tab bar height: %f", QH_TABBAR_HEIGHT);
}

- (void)testUIView_needsCalculateSize
{
    UIView *view = [UIView new];
    XCTAssert(view.needsCalculateSize == NO);

    view.needsCalculateSize = YES;
    XCTAssert(view.needsCalculateSize == YES);

    view.needsCalculateSize = NO;
    XCTAssert(view.needsCalculateSize == NO);
}

@end
