//
//  QHCoreLibBaseModelTests.m
//  QHCoreLibTests
//
//  Created by Tony Tang on 2021/6/17.
//  Copyright © 2021 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <QHCoreLib/QHbaseModel.h>


struct TestStruct {
    int a;
    int b;
};

union TestUnion {
    int a;
    struct {
        short h;
        short l;
    } b;
};

@interface QHTestModel: QHBaseModel {
@public
    struct TestStruct m_struct;
    union TestUnion m_union;
}

@property (nonatomic, copy) NSString *stringValue;
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, assign) int intValue;

@end

@implementation QHTestModel

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;

    QHTestModel *other = (QHTestModel *)object;

    return ([self.stringValue isEqualToString:other.stringValue]
            && self.boolValue == other.boolValue
            && self.intValue == other.intValue
            && self->m_struct.a == other->m_struct.a
            && self->m_struct.b == other->m_struct.b
            && self->m_union.a == other->m_union.a);
}

@end

@interface QHCoreLibBaseModelTests : XCTestCase

@end

@implementation QHCoreLibBaseModelTests

- (void)testEncodeDecode {
    QHTestModel *model = [QHTestModel new];
    model.stringValue = @"str";
    model.boolValue = YES;
    model.intValue = 123;
    model->m_struct.a = 1;
    model->m_struct.b = 2;
    model->m_union.a = 0x12345678;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    XCTAssert(data != nil);

    QHTestModel *model2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssert([model2 isEqual:model]);
}

@end
