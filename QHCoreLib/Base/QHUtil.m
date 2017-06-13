//
//  QHUtil.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUtil.h"

#import "QHMacros.h"


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
        QHBlockInvoke(block, NULL, 0);
    }
    else if (QHIsMainThread()) {
        // prefer to ensure 'sync' than 'main queue' when currently
        // running on 'background queue on main thread'
        QHCoreLibWarn(@"can't assure main queue for dispatch sync main, because we are"
                      @"currently on background queue that running on main thread!\n%@",
                      QHCallStackShort());
        QHBlockInvoke(block, NULL, 0);
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            QHBlockInvoke(block, NULL, 0);
        });
    }
}

void QHDispatchAsyncMain(dispatch_block_t block)
{
    if (block == nil) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        QHBlockInvoke(block, NULL, 0);
    });
}

void QHDispatchAsyncDefault(dispatch_block_t block)
{
    if (block == nil) return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QHBlockInvoke(block, NULL, 0);
    });
}

BOOL QHBlockInvoke(dispatch_block_t block, const char *filePath, int line)
{
    if (block == nil) {
        return NO;
    }

    @try {
        block();

        return YES;
    }
    @catch(NSException *exception) {
        if (filePath != NULL) {
            QHCoreLibFatal(@"(%@:%d) %@ throws exception: %@\n%@",
                           [[NSString stringWithFormat:@"%s", filePath] lastPathComponent],
                           line,
                           block,
                           [exception qh_description],
                           [exception callStackSymbols]);
        }
        else {
            QHCoreLibFatal(@"%@ throws exception: %@\n%@",
                           block,
                           [exception qh_description],
                           [exception callStackSymbols]);
        }
        return NO;
    }
}
