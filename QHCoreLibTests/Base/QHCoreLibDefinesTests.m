//
//  QHCoreLibDefinesTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/message.h>

#import "QHDefines.h"


@interface __singleton : NSObject
QH_SINGLETON_DEF
@end

@implementation __singleton
QH_SINGLETON_IMP
@end


@interface QHCoreLibDefinesTests : XCTestCase

@end

@implementation QHCoreLibDefinesTests

- (void)testUnusedVar
{
    int unused_var, unused_var_should_not_warn;
    QH_UNUSED_VAR(unused_var_should_not_warn);
}

- (void)testIS
{
    XCTAssertTrue(QH_IS(@"", NSString), @"@\"\" is NSString");

    NSString *nilStr = nil;
    XCTAssertFalse(QH_IS(nilStr, NSString), @"nil is not NSString");

    NSNumber *number = @0;
    XCTAssertFalse(QH_IS(number, NSString), @"number is not NSString");
}

- (void)testISXXX
{
    XCTAssertTrue(QH_IS_STRING(@""));
    XCTAssertTrue(QH_IS_NUMBER(@0));
    XCTAssertTrue(QH_IS_ARRAY(@[]));
    XCTAssertTrue(QH_IS_DICTIONARY(@{}));
    XCTAssertTrue(QH_IS_SET([NSSet set]));
    XCTAssertTrue(QH_IS_DATA([NSData data]));
}

- (void)testAS
{
    QH_AS(@"", NSString, str);
    XCTAssertNotNil(str, @"@\"\" can be casted to NSString");

    QH_AS(@0, NSString, str2);
    XCTAssertNil(str2, @"number can not be casted to NSString");
}

- (void)testSingleton
{
    __singleton *one = [__singleton sharedInstance];
    __singleton *two = [__singleton sharedInstance];
    XCTAssertEqual(one , two);
}

- (void)testWeakifyStrongifyRetainify
{
    XCTestExpectation *expect = [self expectationWithDescription:@""];
    __block NSObject *obj = [[NSObject alloc] init];
    @weakify(obj);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(obj);
        XCTAssertNotNil(obj);
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        obj = nil;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(obj);
        XCTAssertNil(obj);
        [expect fulfill];
    });

    XCTestExpectation *expect2 = [[XCTestExpectation alloc] initWithDescription:@""];
    @autoreleasepool {
        NSObject *obj2 = [[NSObject alloc] init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @retainify(obj2);
            XCTAssertNotNil(obj2);
            [expect2 fulfill];
        });
    }

    [self waitForExpectationsWithTimeout:0.2 handler:nil];
}

- (void)testConcat
{
#define A aaa
#define B bbb

    int aaabbb = 0;
    // expanded
    XCTAssert(QH_CONCAT(A, B) == 0);

    int AB = 1;
    // not expand
    XCTAssert(_QH_CONCAT(A, B) == 1);
}

- (void)testPerformSelectorLeakWarning
{
    SEL selector = NSSelectorFromString(@"description");
    // yields a warning
    [self performSelector:selector withObject:nil];

    // no warning
    QH_SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING_BEGIN {
        [self performSelector:selector withObject:nil];
    } QH_SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING_END;
}


- (void)testMsgSend
{
    QH_msgSendFunc_void_void(f0);
    f0(self, @checkselector0(self, void_void));

    QH_msgSendFunc_void_value(f1, NSString *);
    NSString *str = f1(self, @checkselector0(self, void_value));
    XCTAssertTrue(QH_IS_STRING(str));

    QH_msgSendFunc_void_value(desc, NSString *);
    XCTAssertEqualObjects(desc(self, @selector(description)), [self description]);

    QH_msgSendFunc_params_void(f4, NSString *, int);
    f4(self, @checkselector(self, params_void:, int:) , @"", 0);

    QH_msgSendFunc_params_value(f5, NSString *, NSString *, id, int);
    str = f5(self, @checkselector(self, params_value:, obj:, int:), @"", nil, 0);
    XCTAssertEqualObjects(@"", str);

    QH_msgSendFunc_void_value(f6, int);
    int i = f6(self, @checkselector0(self, void_int));
    XCTAssertEqual(i, 1);
}

- (void)void_void
{
    XCTAssertTrue(YES);
}

- (NSString *)void_value
{
    XCTAssertTrue(YES);
    return [NSString new];
}

- (void)params_void:(NSString *)str int:(int)i
{
    XCTAssertTrue(YES);
}

- (NSString *)params_value:(NSString *)str obj:(id)obj int:(int)i
{
    XCTAssertTrue(YES);
    return @"";
}

- (int)void_int
{
    return 1;
}


@end
