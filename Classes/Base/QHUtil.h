//
//  QHUtil.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QHDefines.h"

// check if currently on the main queue
QH_EXTERN BOOL QHIsMainQueue(void);

// check if currently on the main thread
// `QHIsMainQueue` is preferred, see
// http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
QH_EXTERN BOOL QHIsMainThread(void);
