//
//  QHCoreLibAssertsTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QHCoreLib/QHAsserts.h>
#import <QHCoreLib/QHLogUtil.h>


@interface QHCoreLibAssertsTests : XCTestCase

@end

@implementation QHCoreLibAssertsTests

- (void)p_setAssertFunction
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
}

- (void)tearDown
{
    QHSetAssertFunction(nil);

    [super tearDown];
}

- (void)testFatal
{
    dispatch_block_t block = ^{
        QHFatal(@"some error...%@", @"");
    };

    QH_XCTAssertThrows_On_DEBUG(block());
}

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

        QH_XCTAssertThrows_On_DEBUG(block());
    }
}

- (void)testSetAssertFunction
{
    [self p_setAssertFunction];

    QHAssert(0 == 0, @"zero equals to zero");
    QHAssert(0 == 1, @"zero not equals to one is right");
}

- (void)testAssertXXX
{
    QHAssertMainQueue();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        QHAssertNotMainQueue();
    });

    void (^block)(id) = ^(id obj){
        QHAssertParam(obj);
    };

    QH_XCTAssertThrows_On_DEBUG(block(nil));
}

- (void)testAssertReturnVoid
{
    [self p_setAssertFunction];

    QHAssertReturnVoidOnFailure(YES, @"ok");

    QHAssertReturnVoidOnFailure(NO, @"return on failure");

    XCTAssert(NO, @"must not be here");
}

- (void)testAssertReturnValue
{
    [self p_setAssertFunction];

    int (^block) (BOOL, int) = ^(BOOL cond, int value) {
        QHAssertReturnValueOnFailure(value, cond, @"return %d on failure", value);
        return 0;
    };

    XCTAssert(0 == block(YES, 1), @"return 0 on succeed");

    XCTAssert(1 == block(NO, 1), @"return 1 on failure");
}

QH_NOT_IMPLEMENTED(- (void)not_implemented)

- (void)testNotImplemented
{
    XCTAssertThrows([self performSelector:@selector(not_implemented)]);
}

@end
