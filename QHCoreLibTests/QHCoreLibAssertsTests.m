//
//  QHCoreLibAssertsTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHAsserts.h"

#import "QHLogUtil.h"


@interface QHCoreLibAssertsTests : XCTestCase

@end

@implementation QHCoreLibAssertsTests

- (void)testAssert
{
    {
        dispatch_block_t block = ^{
            QHAssert(0 == 0, @"assert 0 == 0 will not throw");
        };

        XCTAssertNoThrow(block());
    }

    {
        dispatch_block_t block = ^{
            QHAssert(0 == 1, @"assert 0 == 1 will throw");
        };

        //block();
        XCTAssertThrows(block());
    }
}

- (void)testSetAssertFunction
{
    QHSetAssertFunction(^(NSString *condition,
                          NSString *fileName,
                          NSNumber *lineNumber,
                          NSString *function,
                          NSString *message) {
        QHLogError(@"%@:%@\n%@ assert \"%@\" failed: %@",
                   fileName,
                   lineNumber,
                   function,
                   condition,
                   message);
    });

    QHAssert(0 == 0, @"zero equals to zero");
    QHAssert(0 == 1, @"zero not equals to one is right");
}

- (void)testAssertXXX
{
    QHAssertMainQueue();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        QHAssertNotMainQueue();
    });

    id obj = nil;
    dispatch_block_t block = ^{
        QHAssertParam(obj);
    };
    XCTAssertThrows(block());
}

QH_NOT_IMPLEMENTED(- (void)not_implemented)

- (void)testNotImplemented
{
    XCTAssertThrows([self performSelector:@selector(not_implemented)]);
}

@end
