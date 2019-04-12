//
//  QHCoreLibConcurrentTests.m
//  QHCoreLibTests
//
//  Created by Tony Tang on 2019/4/11.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QHBase.h"
#import "QHScopedLock.h"

@interface QHCoreLibConcurrentTests : XCTestCase

@end

@implementation QHCoreLibConcurrentTests


- (void)testMutex
{
    QHMutex *lock = [QHMutex new];
    
    [NSThread detachNewThreadSelector:@selector(lockOneSecond:)
                             toTarget:self
                           withObject:lock];
    
    usleep(1000);
    NSTimeInterval start = QHTimestampInDouble();
    
    [lock lock];
    
    NSTimeInterval cost = QHTimestampInDouble() - start;
    NSLog(@"cost %f", cost);
    QHAssert(cost >= 0.999, @"get lock too early!");
    
    [lock unlock];
}

- (void)lockOneSecond:(QHMutex *)lock;
{
    [lock lock];
    
    sleep(1);
    
    [lock unlock];
}

- (void)testScopedLock
{
    QHMutex *lock = [QHMutex new];
    
    [NSThread detachNewThreadSelector:@selector(lockOneSecond:)
                             toTarget:self
                           withObject:lock];
    
    usleep(1000);
    NSTimeInterval start = QHTimestampInDouble();
    {
        QHScopedLock scopedLock(lock);
    }
    NSTimeInterval cost = QHTimestampInDouble() - start;
    NSLog(@"cost %f", cost);
    QHAssert(cost >= 0.999, @"get lock too early!");
    
    XCTAssert([lock tryLock], @"lock should not be locked");
    [lock unlock];
}


@end
