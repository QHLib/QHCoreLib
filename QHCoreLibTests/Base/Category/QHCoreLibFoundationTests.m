//
//  QHCoreLibFoundationTests.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/25.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Foundation+QHCoreLib.h"


@interface QHCoreLibFoundationTests : XCTestCase

@end

@implementation QHCoreLibFoundationTests

- (void)testNSObject
{
    id str = @"1";
    id num = @1;

    XCTAssertEqual([NSString qh_cast:str], str);
    XCTAssertNil([NSString qh_cast:num]); // warn
    XCTAssertNil([NSString qh_cast:num warnOnFailure:NO]); // no warn

    XCTAssertEqual([NSNumber qh_cast:num], num);
    XCTAssertNil([NSNumber qh_cast:str]); // warn
    XCTAssertNil([NSNumber qh_cast:str warnOnFailure:NO]); // no warn

    XCTAssertNil(self.qh_handy_carry);
    self.qh_handy_carry = @1;
    XCTAssertEqualObjects(self.qh_handy_carry, @1);
    self.qh_handy_carry = nil;
    XCTAssertNil(self.qh_handy_carry);

    XCTAssertNil(self.qh_handy_carry2);
    self.qh_handy_carry2 = @2;
    XCTAssertEqualObjects(self.qh_handy_carry2, @2);
    self.qh_handy_carry2 = nil;
    XCTAssertNil(self.qh_handy_carry2);

    XCTAssertNil(self.qh_handy_carry3);
    self.qh_handy_carry3 = @3;
    XCTAssertEqualObjects(self.qh_handy_carry3, @3);
    self.qh_handy_carry3 = nil;
    XCTAssertNil(self.qh_handy_carry3);

    XCTAssertNil(self.qh_handy_weakCarry);
    @autoreleasepool {
        id obj = [NSObject new];
        self.qh_handy_weakCarry = obj;
        XCTAssertEqual(obj, self.qh_handy_weakCarry);
    }
    XCTAssertNil(self.qh_handy_weakCarry);

    XCTAssertNil(self.qh_handy_weakCarry2);
    @autoreleasepool {
        id obj = [NSObject new];
        self.qh_handy_weakCarry2 = obj;
        XCTAssertEqual(obj, self.qh_handy_weakCarry2);
    }
    XCTAssertNil(self.qh_handy_weakCarry2);

    XCTAssertNil(self.qh_handy_weakCarry3);
    @autoreleasepool {
        id obj = [NSObject new];
        self.qh_handy_weakCarry3 = obj;
        XCTAssertEqual(obj, self.qh_handy_weakCarry3);
    }
    XCTAssertNil(self.qh_handy_weakCarry3);
}

- (void)testNSArray
{
    NSArray<NSNumber *> *array = @[ @1, @2, @3 ];

    XCTAssertEqualObjects([array qh_sliceFromStart:1 length:2],
                          [array subarrayWithRange:NSMakeRange(1, 2)]);

    XCTAssertEqualObjects([array qh_sliceFromStart:1 length:3],
                          [array subarrayWithRange:NSMakeRange(1, 2)]);

    XCTAssertEqualObjects([array qh_sliceFromStart:3 length:1],
                          @[]);

    XCTAssertEqualObjects([array qh_filteredArrayWithBlock:^BOOL(NSUInteger idx, id obj) {
        return ((idx + 1) % 2) == 0;
    }], @[ @2 ]);

    NSArray *reverseArray = @[ @3, @2, @1 ];
    XCTAssertEqualObjects([array qh_mappedArrayWithBlock:^id(NSUInteger idx, id obj) {
        return @(4 - [obj integerValue]);
    }], reverseArray);

    XCTAssertEqualObjects([array qh_objectAtIndex:0], @1);
    XCTAssertEqualObjects([array qh_objectAtIndex:3], nil);

    XCTAssertEqualObjects([array qh_objectsAtIndexes:[NSIndexSet indexSetWithIndex:0]],
                          @[ @1 ]);
    XCTAssertEqualObjects([array qh_objectsAtIndexes:[NSIndexSet indexSetWithIndex:3]],
                          @[ ]);
}

- (void)testArrayDefaultValue
{
    NSArray *array = @[ [NSObject new], @YES, @1, @1.0, @"1", @[ @1 ], @{ @1: @1 } ];

    XCTAssertEqual([array qh_boolAtIndex:0 defaultValue:NO], NO);
    XCTAssertEqual([array qh_boolAtIndex:1 defaultValue:NO], YES);

    XCTAssertEqual([array qh_integerAtIndex:0 defaultValue:0], 0);
    XCTAssertEqual([array qh_integerAtIndex:2 defaultValue:-1], 1);

    XCTAssertEqual([array qh_doubleAtIndex:0 defaultValue:0.0], 0.0);
    XCTAssertEqual([array qh_doubleAtIndex:3 defaultValue:-1.0], 1.0);

    XCTAssertEqualObjects([array qh_stringAtIndex:0 defaultValue:@""], @"");
    XCTAssertEqualObjects([array qh_stringAtIndex:4 defaultValue:@""], @"1");

    XCTAssertEqualObjects([array qh_arrayAtIndex:0 defaultValue:@[]], @[]);
    XCTAssertEqualObjects([array qh_arrayAtIndex:5 defaultValue:@[]], @[ @1 ]);

    XCTAssertEqualObjects([array qh_dictionaryAtIndex:0 defaultValue:@{}], @{});
    XCTAssertEqualObjects([array qh_dictionaryAtIndex:6 defaultValue:@{}], @{ @1: @1 });
}

- (void)testNSMutableArray
{
    NSMutableArray<NSNumber *> *array = [NSMutableArray array];

    [array qh_addObject:nilValue()];
    [array qh_addObject:@1];

    [array qh_insertObject:nilValue() atIndex:array.count];
    [array qh_insertObject:@1 atIndex:array.count];
    [array qh_insertObject:@1 atIndex:array.count + 1];

    [array qh_removeObjectAtIndex:array.count];
    [array qh_removeObjectAtIndex:0];
}

- (void)testNSDictionary
{
    NSDictionary<NSNumber *, NSNumber *> *dict = @{ @1: @1, @2: @2 };
    NSDictionary *result = @{ @1: @2, @2: @4 };

    XCTAssertEqualObjects([dict qh_mappedDictionaryWithBlock:^id _Nonnull(NSNumber * _Nonnull key, NSNumber * _Nonnull obj) {
        return @([obj integerValue] * 2);
    }], result);
}

- (void)testNSDictionaryDefaultValue
{
    NSDictionary *dict = @{ @0: [NSObject new],
                            @1: @YES,
                            @2: @1,
                            @3: @1.0,
                            @4: @"1",
                            @5: @[ @1 ],
                            @6: @{ @1: @1 } };
    XCTAssertEqual([dict qh_boolForKey:@0 defaultValue:NO], NO);
    XCTAssertEqual([dict qh_boolForKey:@1 defaultValue:NO], YES);

    XCTAssertEqual([dict qh_integerForKey:@0 defaultValue:0], 0);
    XCTAssertEqual([dict qh_integerForKey:@2 defaultValue:0], 1);

    XCTAssertEqual([dict qh_doubleForKey:@0 defaultValue:0.0], 0.0);
    XCTAssertEqual([dict qh_doubleForKey:@3 defaultValue:0.0], 1.0);

    XCTAssertEqualObjects([dict qh_stringForKey:@0 defaultValue:@""], @"");
    XCTAssertEqualObjects([dict qh_stringForKey:@4 defaultValue:@""], @"1");

    XCTAssertEqualObjects([dict qh_arrayForKey:@0 defaultValue:@[]], @[]);
    XCTAssertEqualObjects([dict qh_arrayForKey:@5 defaultValue:@[]], @[ @1 ]);

    XCTAssertEqualObjects([dict qh_dictionaryForKey:@0 defaultValue:@{}], @{});
    XCTAssertEqualObjects([dict qh_dictionaryForKey:@6 defaultValue:@{}], @{ @1: @1 });
}

- (void)testNSMutableDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @1: @1, @2: @2 }];

    [dict qh_setObject:nilValue() forKey:nilValue()];
    [dict qh_setObject:nilValue() forKey:@1];
    [dict qh_setObject:@1 forKey:nilValue()];
    [dict qh_setObject:@2 forKey:@1];
    XCTAssertEqualObjects(@2, dict[@1]);

    XCTAssertEqualObjects([dict qh_objectForKey:@2 createIfNotExists:nil], @2);
    XCTAssertEqualObjects([dict qh_objectForKey:@3 createIfNotExists:^id _Nonnull{
        return @3;
    }], @3);
    XCTAssertEqualObjects([dict qh_objectForKey:@3 createIfNotExists:nil], @3);
}

- (void)testMutableSet
{
    NSMutableSet *set = [NSMutableSet setWithObjects:@"1", @"2", @"3", nil];
    XCTAssertNoThrow([set qh_addObject:nilValue()]);
    [set qh_addObject:@"0"];
    XCTAssertEqual(set.count, 4);
}

- (void)testUserDefaults
{
    NSUserDefaults *testUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@__FILE__];
    QH_XCTAssertThrows_On_DEBUG([testUserDefaults qh_setObject:@{ @1: @1 } forKey:@"anykey"]);
}

- (void)testMainBundle
{
    NSLog(@"%@\n%@\n%@\n%@\n%@\n",
          [NSBundle qh_mainBundle_identifier],
          [NSBundle qh_mainBundle_version],
          [NSBundle qh_mainBundle_shortVersion],
          [NSBundle qh_mainBundle_name],
          [NSBundle qh_mainBundle_displayName]);
}

- (void)testDateFormatter
{
    // test shared
    XCTAssert([NSDateFormatter qh_sharedFormatter:@"aaa"] == [NSDateFormatter qh_sharedFormatter:@"aaa"]);

    NSDate *date = [NSDate date];
    NSLog(@"full: %@", [date qh_stringFromDateFormat:kQHDateFormatFull]);
    NSLog(@"date: %@", [date qh_stringFromDateFormat:kQHDateFormatDate]);
    NSLog(@"dateChinese: %@", [date qh_stringFromDateFormat:kQHDateFormatDateChinese]);
    NSLog(@"monthDay: %@", [date qh_stringFromDateFormat:kQHDateFormatMouthDay]);
    NSLog(@"monthDayChinese: %@", [date qh_stringFromDateFormat:kQHDateFormatMouthDayChinese]);
    NSLog(@"time: %@", [date qh_stringFromDateFormat:kQHDateFormatTime]);
    NSLog(@"timeCxtra: %@", [date qh_stringFromDateFormat:kQHDateFormatTimeExtra]);
    NSLog(@"weekNumber: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekNumber]);
    NSLog(@"weekStringShort: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringShort]);
    NSLog(@"weekStringLong: %@", [date qh_stringFromDateFormat:kQHDateFormatWeekStringLong]);
}

- (void)testDateUnitCheck
{
    NSCalendar *calenar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *now = [calenar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute ) fromDate:[NSDate date]];

    NSDate *date = [calenar dateWithEra:1 year:now.year month:now.month day:now.day hour:now.hour minute:now.minute second:now.second nanosecond:0];
    XCTAssertTrue([date qh_isWithinMinute]);
    XCTAssertTrue([date qh_isWithinHour]);
    XCTAssertTrue([date qh_isWithinDay]);
    XCTAssertTrue([date qh_isWithinWeek]);
    XCTAssertTrue([date qh_isWithinWestWeek]);
    XCTAssertTrue([date qh_isWithinMonth]);
    XCTAssertTrue([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 year:now.year month:now.month day:now.day hour:now.hour minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinMinute]);
    XCTAssertTrue([date qh_isWithinHour]);
    XCTAssertTrue([date qh_isWithinDay]);
    XCTAssertTrue([date qh_isWithinMonth]);
    XCTAssertTrue([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 year:now.year month:now.month day:now.day hour:now.hour-1 minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinMinute]);
    XCTAssertFalse([date qh_isWithinHour]);
    XCTAssertTrue([date qh_isWithinDay]);
    XCTAssertTrue([date qh_isWithinMonth]);
    XCTAssertTrue([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 year:now.year month:now.month day:now.day-1 hour:now.hour-1 minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinMinute]);
    XCTAssertFalse([date qh_isWithinHour]);
    XCTAssertFalse([date qh_isWithinDay]);
    XCTAssertTrue([date qh_isWithinMonth]);
    XCTAssertTrue([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 year:now.year month:now.month-1 day:now.day-1 hour:now.hour-1 minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinMinute]);
    XCTAssertFalse([date qh_isWithinHour]);
    XCTAssertFalse([date qh_isWithinDay]);
    XCTAssertFalse([date qh_isWithinMonth]);
    XCTAssertTrue([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 year:now.year-1 month:now.month-1 day:now.day-1 hour:now.hour-1 minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinMinute]);
    XCTAssertFalse([date qh_isWithinHour]);
    XCTAssertFalse([date qh_isWithinDay]);
    XCTAssertFalse([date qh_isWithinMonth]);
    XCTAssertFalse([date qh_isWithinYear]);

    date = [calenar dateWithEra:1 yearForWeekOfYear:now.year weekOfYear:now.weekOfYear weekday:now.weekday hour:0 minute:0 second:0 nanosecond:0];
    XCTAssertTrue([date qh_isWithinWestWeek]);
    XCTAssertTrue([date qh_isWithinWeek]);

    date = [calenar dateWithEra:1 yearForWeekOfYear:now.year weekOfYear:now.weekOfYear-1 weekday:now.weekday hour:0 minute:0 second:0 nanosecond:0];
    XCTAssertFalse([date qh_isWithinWestWeek]);

    // 上个礼拜天
    date = [calenar dateWithEra:1 year:now.year-1 month:now.month-1 day:now.day-now.weekday+1 hour:now.hour-1 minute:now.minute - 1 second:now.second nanosecond:0];
    XCTAssertFalse([date qh_isWithinWeek]);
    XCTAssert([date qh_weekDayIndex] == 7);
}

@end
