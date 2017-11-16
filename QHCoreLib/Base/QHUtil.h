//
//  QHUtil.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <QHCoreLib/QHDefines.h>
#import <QHCoreLib/Foundation+QHCoreLib.h>


NS_ASSUME_NONNULL_BEGIN

QH_EXTERN NSString *QHCoreLibBundleId(void);

// check if currently on the main queue
QH_EXTERN BOOL QHIsMainQueue(void);

// check if currently on the main thread
// `QHIsMainQueue` is preferred, see
// http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
QH_EXTERN BOOL QHIsMainThread(void);


QH_EXTERN void QHDispatchSyncMainSafe(dispatch_block_t block);
QH_EXTERN void QHDispatchAsyncMain(dispatch_block_t block);
QH_EXTERN void QHDispatchAsyncDefault(dispatch_block_t block);

QH_EXTERN void QHDispatchDelayMain(NSTimeInterval delay, dispatch_block_t block);
QH_EXTERN void QHDispatchDelayDefault(NSTimeInterval delay, dispatch_block_t block);


#define QHCallStackShort() QHCallStackSlice(0, 10)
#define QHCallStackSlice(_start, _length) \
    [[NSThread callStackSymbols] qh_sliceFromStart:_start length:_length]


// safe invoke block
// return YES if no error occurs while executing the block
QH_EXTERN BOOL QHBlockInvoke(dispatch_block_t block, const char * _Nullable filePath, int line);
#define QH_BLOCK_INVOKE(block) QHBlockInvoke(block, __FILE__, __LINE__)


static inline void QHDispatchSemaphoreLock(dispatch_semaphore_t lock, dispatch_block_t block) {
    if (block == nil) return;

    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    QH_BLOCK_INVOKE(block);
    dispatch_semaphore_signal(lock);
}

static inline void QHNSLock(id<NSLocking> lock, dispatch_block_t block) {
    if (block == nil) return;

    [lock lock];
    QH_BLOCK_INVOKE(block);
    [lock unlock];
}


QH_EXTERN NSData *QHRandomBytes(uint32_t length);

QH_EXTERN uint32_t QHRandomNumber(void);


// MIME type of 'ext'
QH_EXTERN NSString *QHContentTypeOfExtension(NSString *ext);


QH_EXTERN CGSize QHSizeAspectFitInSize(CGSize size, CGSize fitInSize, BOOL shouldEnlarge);
QH_EXTERN CGSize QHSizeAspectFillInSize(CGSize size, CGSize fillInSize, BOOL shouldEnlarge);


QH_EXTERN double QHTimestampInDouble(void);  // seconds
QH_EXTERN uint64_t QHTimestampInSeconds(void);
QH_EXTERN uint64_t QHTimestampInMilliseconds(void);

QH_EXTERN uint64_t QHTimestampDayFloor(uint64_t timestamp); // in seconds
QH_EXTERN uint64_t QHTimestampWeekFloor(uint64_t timestamp); // in seconds

QH_EXTERN CGFloat QHClamp(CGFloat value, CGFloat bounds1, CGFloat bounds2);

// 字符判断
QH_EXTERN BOOL QHCharacterIsChinese(unichar character);
QH_EXTERN BOOL QHCharacterIsAlphabet(unichar character);
QH_EXTERN BOOL QHCharacterIsNumber(unichar character);
QH_EXTERN BOOL QHCharacterIsAlpNum(unichar character);


NS_ASSUME_NONNULL_END
