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
