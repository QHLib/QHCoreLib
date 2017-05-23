//
//  QHCoreLibDefaultValueTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QHDefaultValue.h"


@interface QHCoreLibDefaultValueTests : XCTestCase

@end

@implementation QHCoreLibDefaultValueTests

- (void)testQHBool
{
    XCTAssertTrue(QHBool(nil, NO) == NO);
    XCTAssertTrue(QHBool([NSNull null], NO) == NO);
    XCTAssertTrue(QHBool(@(YES), NO) == YES);
    XCTAssertTrue(QHBool(@(1), NO) == YES);
    XCTAssertTrue(QHBool(@(2), NO) == YES);
    XCTAssertTrue(QHBool(@"1", NO) == YES);
    XCTAssertTrue(QHBool([NSObject new], NO) == NO);
}

- (void)testQHInteger
{
    XCTAssertEqual(1, QHInteger(nil, 1));
    XCTAssertEqual(1, QHInteger([NSNull null], 1));
    XCTAssertEqual(1, QHInteger(@(1), 0));
    XCTAssertEqual(1, QHInteger(@(1.5), 0));
    XCTAssertEqual(1, QHInteger(@"1", 0));
    XCTAssertEqual(1, QHInteger(@"1.5", 0));
    XCTAssertEqual(1, QHInteger([NSObject new], 1));
}

- (void)testQHDouble
{
    XCTAssertEqual(1.0, QHDouble(nil, 1.0));
    XCTAssertEqual(1.0, QHDouble([NSNull null], 1.0));
    XCTAssertEqual(1.0, QHDouble(@(1.0), 0.0));
    XCTAssertEqual(1.0, QHDouble(@"1.0", 0.0));
    XCTAssertEqual(1.0, QHDouble([NSObject new], 1.0));
}

- (void)testQHString
{
    XCTAssertEqualObjects(@"", QHString(nil, @""));
    XCTAssertEqualObjects(@"", QHString([NSNull null], @""));
    XCTAssertEqualObjects(@"1", QHString(@(1.0), @""));
    XCTAssertEqualObjects(@"1.0", QHString(@"1.0", @""));
    XCTAssertEqualObjects(@"", QHString([NSObject new], @""));
}

- (void)testQHArray
{
    XCTAssertEqualObjects(@[], QHArray(nil, @[]));
    XCTAssertEqualObjects(@[], QHArray([NSNull null], @[]));
    XCTAssertEqualObjects(@[], QHArray(@[], nil));
    XCTAssertEqualObjects(@[], QHArray([NSObject new], @[]));
}

- (void)testQHDictionary
{
    XCTAssertEqualObjects(@{}, QHDictionary(nil, @{}));
    XCTAssertEqualObjects(@{}, QHDictionary([NSNull null], @{}));
    XCTAssertEqualObjects(@{}, QHDictionary(@{}, nil));
    XCTAssertEqualObjects(@{}, QHDictionary([NSObject new], @{}));
}

@end
