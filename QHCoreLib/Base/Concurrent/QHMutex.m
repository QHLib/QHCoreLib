//
//  QHMutex.m
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/11.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHMutex.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
#import <os/lock.h>

@implementation QHMutex {
    os_unfair_lock m_lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (void)lock
{
    os_unfair_lock_lock(&m_lock);
}

- (BOOL)tryLock
{
    return os_unfair_lock_trylock(&m_lock);
}

- (void)unlock
{
    os_unfair_lock_unlock(&m_lock);
}

@end

#else

// using dispatch_seamaphore (which is better than pthread_mutext) under 10.0
@implementation QHMutex {
    dispatch_semaphore_t m_lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)lock
{
    dispatch_semaphore_wait(m_lock, DISPATCH_TIME_FOREVER);
}

- (BOOL)tryLock
{
    return 0 == dispatch_semaphore_wait(m_lock, DISPATCH_TIME_NOW);
}

- (void)unlock
{
    dispatch_semaphore_signal(m_lock);
}

@end

#endif

