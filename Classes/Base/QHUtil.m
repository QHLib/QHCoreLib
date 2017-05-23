//
//  QHUtil.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUtil.h"


BOOL QHIsMainQueue()
{
    static void *mainQueueKey = &mainQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(),
                                    mainQueueKey,
                                    mainQueueKey,
                                    NULL);
    });
    return dispatch_get_specific(mainQueueKey) == mainQueueKey;
}

BOOL QHIsMainThread()
{
    return [NSThread currentThread].isMainThread;
}

void QHDispatchSyncMainSafe(dispatch_block_t block)
{
    if (block == nil) return;

    if (QHIsMainQueue()) {
        block();
    }
    else if (QHIsMainThread()) {
        // prefer to ensure 'sync' than 'main queue' when currently
        // running on 'background queue on main thread'
        QHCoreLibWarn(@"can't assure main queue for dispatch sync main, because we are"
                      @"currently on background queue that running on main thread!\n%@",
                      QHCallStackShort());
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

void QHDispatchAsyncMain(dispatch_block_t block)
{
    if (block == nil) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

void QHDispatchAsyncDefault(dispatch_block_t block)
{
    if (block == nil) return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

