//
//  QHCoreLibStandardUserDefaultsPropertyTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <QHCoreLib/QHDefines.h>
#import <QHCoreLib/NSObject+QHUserDefaultsProperty.h>


@interface QHCoreLibStandardUserDefaultsPropertyTests : XCTestCase

@property (nonatomic) BOOL testBool;
@property (nonatomic) NSInteger testInteger;
@property (nonatomic) double testDouble;
@property (nonatomic) NSString *testString;
@property (nonatomic) NSArray *testArray;
@property (nonatomic) NSDictionary *testDict;

@end

@implementation QHCoreLibStandardUserDefaultsPropertyTests

@dynamic testBool;
@dynamic testInteger;
@dynamic testDouble;
@dynamic testString;
@dynamic testArray;
@dynamic testDict;

- (void)testSynthesize
{
    NSString *suiteName = [NSString stringWithFormat:@"testUserDefaultsProperty_%f", [[NSDate date] timeIntervalSince1970]];
    NSUserDefaults *testUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

    [[self class] qh_synthesizeBOOLProperty:@"testBool"
                                     forKey:@"testBool"
                               defaultValue:YES
                               userDefaults:testUserDefaults];

    [[self class] qh_synthesizeIntegerProperty:@"testInteger"
                                        forKey:@"testInteger"
                                  defaultValue:-1
                                  userDefaults:testUserDefaults];

    [[self class] qh_synthesizeDoubleProperty:@"testDouble"
                                       forKey:@"testDouble"
                                 defaultValue:-1.0
                                 userDefaults:testUserDefaults];

    [[self class] qh_synthesizeStringProperty:@"testString"
                                       forKey:@"testString"
                                 defaultValue:@""
                                 userDefaults:testUserDefaults];

    [[self class] qh_synthesizeArrayProperty:@"testArray"
                                      forKey:@"testArray"
                                defaultValue:@[]
                                userDefaults:testUserDefaults];

    [[self class] qh_synthesizeDictionaryProperty:@"testDict"
                                           forKey:@"testDict"
                                     defaultValue:@{}
                                     userDefaults:testUserDefaults];

    XCTAssertNil([testUserDefaults objectForKey:@"testBool"]);
    XCTAssertEqual(self.testBool, YES);
    self.testBool = NO;
    XCTAssertFalse(self.testBool);
    XCTAssertFalse([testUserDefaults boolForKey:@"testBool"]);

    XCTAssertNil([testUserDefaults objectForKey:@"testInteger"]);
    XCTAssertEqual(self.testInteger, -1);
    self.testInteger = 1;
    XCTAssertEqual(self.testInteger, 1);
    XCTAssertEqual([testUserDefaults integerForKey:@"testInteger"], 1);

    XCTAssertNil([testUserDefaults objectForKey:@"testDouble"]);
    XCTAssertEqual(self.testDouble, -1.0);
    self.testDouble = 1.0;
    XCTAssertEqual(self.testDouble, 1.0);
    XCTAssertEqual([testUserDefaults doubleForKey:@"testDouble"], 1.0);

    XCTAssertNil([testUserDefaults objectForKey:@"testString"]);
    XCTAssertEqualObjects(self.testString, @"");
    self.testString = @"str";
    XCTAssertEqualObjects(self.testString, @"str");
    XCTAssertEqualObjects([testUserDefaults objectForKey:@"testString"], @"str");

    XCTAssertNil([testUserDefaults objectForKey:@"testArray"]);
    XCTAssertEqualObjects(self.testArray, @[]);
    self.testArray = @[ @1 ];
    XCTAssertEqualObjects(self.testArray, @[ @1 ]);
    XCTAssertEqualObjects([testUserDefaults arrayForKey:@"testArray"], @[ @1 ]);

    XCTAssertNil([testUserDefaults objectForKey:@"testDict"]);
    XCTAssertEqualObjects(self.testDict, @{});
    self.testDict = @{ @"1": @1 };
    XCTAssertEqualObjects(self.testDict, @{ @"1": @1 });
    XCTAssertEqualObjects([testUserDefaults dictionaryForKey:@"testDict"], @{ @"1": @1 });

    QH_XCTAssertThrows_DEBUG(self.testDict = @{ @1: @2 });

    QH_XCTAssertThrows_DEBUG([[self class] qh_synthesizeBOOLProperty:@"testBool"
                                                              forKey:@"testBool"
                                                        defaultValue:YES
                                                        userDefaults:testUserDefaults]);
}

- (void)testKey
{
    NSString *key = [NSString stringWithFormat:@"QHUserDefaultPropertyKey-%@-%@",
                     NSStringFromClass([self class]),
                     QH_PROPETY_NAME(testBool)];
    XCTAssertEqualObjects([[self class] qh_userDefaultsKeyForProperty:QH_PROPETY_NAME(testBool)],
                          key);
}

@end
