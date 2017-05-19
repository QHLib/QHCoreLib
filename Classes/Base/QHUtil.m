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
