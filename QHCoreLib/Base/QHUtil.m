//
//  QHUtil.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "QHUtil.h"

#import <Security/Security.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "QHInternal.h"
#import "QHAsserts.h"


NS_ASSUME_NONNULL_BEGIN

QH_DUMMY_CLASS(InQHCoreLibBundle);

NSString *QHCoreLibBundleId()
{
    NSBundle *bundle = [NSBundle bundleForClass:[QHDummyClassInQHCoreLibBundle class]];
    return [bundle bundleIdentifier];
}

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

    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       QHBlockInvoke(block, NULL, 0);
                   });
}

void QHDispatchAsyncDefault(dispatch_block_t block)
{
    if (block == nil) return;

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0),
                   ^{
                       QHBlockInvoke(block, NULL, 0);
                   });
}

void QHDispatchDelayMain(NSTimeInterval delay, dispatch_block_t block)
{
    if (block == nil) return;
    
    delay = MAX(0.0, delay);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       QHBlockInvoke(block, NULL, 0);
                   });
}

void QHDispatchDelayDefault(NSTimeInterval delay, dispatch_block_t block)
{
    if (block == nil) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0),
                   ^{
                       QHBlockInvoke(block, NULL, 0);
                   });
}

BOOL QHBlockInvoke(dispatch_block_t block, const char * _Nullable filePath, int line)
{
    if (block == nil) {
        return NO;
    }

#if DEBUG
    block();

    return YES;
#else
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
#endif
}

NSData *QHRandomBytes(uint32_t length)
{
    uint8_t *bytes = malloc(length);
    if (bytes == NULL) {
        QHCoreLibFatal(@"malloc(%d) failed", length);
        return nil;
    }

    int code = SecRandomCopyBytes(nil, length, bytes);
    if (code != 0) {
        QHCoreLibWarn(@"SecRandomCopyBytes create random %d bytes failed with code %d",
                      length, code);
    }

    return [NSData dataWithBytesNoCopy:bytes length:length];
}

uint32_t QHRandomNumber()
{
    NSData *fourBytes = QHRandomBytes(4);
    return *((uint32_t *)fourBytes.bytes);
}


NSString *QHContentTypeOfExtension(NSString *ext)
{
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"application/octet-stream";
#endif
}

CGSize QHSizeAspectFitInSize(CGSize size, CGSize fitInSize, BOOL shouldEnlarge)
{
    if (size.width == 0 || size.height == 0 || fitInSize.width == 0 || fitInSize.height == 0) {
        return CGSizeZero;
    }

    if (shouldEnlarge == NO && fitInSize.width > size.width && fitInSize.height > size.height) {
        return size;
    }

    CGFloat widthRatio = fitInSize.width / size.width;
    CGFloat heightRatio = fitInSize.height / size.height;

    CGFloat ratio = MIN(widthRatio, heightRatio);

    return CGSizeMake(size.width * ratio, size.height * ratio);
}

CGSize QHSizeAspectFillInSize(CGSize size, CGSize fillInSize, BOOL shouldEnlarge)
{
    if (size.width == 0 || size.height == 0 || fillInSize.width == 0 || fillInSize.height == 0) {
        return CGSizeZero;
    }

    if (shouldEnlarge == NO && fillInSize.width > size.width && fillInSize.height > size.height) {
        return size;
    }

    CGFloat widthRatio = fillInSize.width / size.width;
    CGFloat heightRatio = fillInSize.height / size.height;

    CGFloat ratio = MAX(widthRatio, heightRatio);

    return CGSizeMake(size.width * ratio, size.height * ratio);
}


double QHTimestampInDouble()
{
    return [[NSDate date] timeIntervalSince1970];
}

uint64_t QHTimestampInSeconds()
{
    return (uint64_t)QHTimestampInDouble();
}

uint64_t QHTimestampInMilliseconds()
{
    return (uint64_t)(QHTimestampInDouble() * 1000);
}

NS_ASSUME_NONNULL_END
