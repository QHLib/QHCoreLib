//
//  QHUtil.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QHDefines.h"
#import "Foundation+QHCoreLib.h"

// check if currently on the main queue
QH_EXTERN BOOL QHIsMainQueue(void);

// check if currently on the main thread
// `QHIsMainQueue` is preferred, see
// http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
QH_EXTERN BOOL QHIsMainThread(void);


QH_EXTERN void QHDispatchSyncMainSafe(dispatch_block_t block);
QH_EXTERN void QHDispatchAsyncMain(dispatch_block_t block);
QH_EXTERN void QHDispatchAsyncDefault(dispatch_block_t block);


#define QHCallStackShort() QHCallStackSlice(0, 6)
#define QHCallStackSlice(_start, _length) \
    [[NSThread callStackSymbols] qh_sliceFromStart:_start length:_length]
