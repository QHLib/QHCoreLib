//
//  QHScopedLock.m
//  QHCoreLib
//
//  Created by Tony Tang on 2019/4/12.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHScopedLock.h"
#import "QHBase+internal.h"

QHScopedLock::QHScopedLock(QHMutex *mutex)
: m_mutex(mutex)
{
    [m_mutex lock];
}

QHScopedLock::~QHScopedLock()
{
    [m_mutex unlock];
}
