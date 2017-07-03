//
//  QHCoreLibMustOverrideTests.m
//  QHCoreLib
//
//  Created by Tony Tang on 2017/7/3.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHMustOverride.h"


@interface QHMustOverrideTester : NSObject
- (void)method;
@end
@implementation QHMustOverrideTester
- (void)method
{
    @QH_SUBCLASS_MUST_OVERRIDE;
}
@end

@interface QHMustOverrideTesterSub : QHMustOverrideTester
@end
@implementation QHMustOverrideTesterSub
- (void)method
{

}
@end

@interface QHMustOverrideTesterSubSub : QHMustOverrideTesterSub
@end

@implementation QHMustOverrideTesterSubSub
@end


@interface QHCoreLibMustOverrideTests : XCTestCase

@end

@implementation QHCoreLibMustOverrideTests

- (void)testMustOverride
{
    // should compile ok
}

@end
