//
//  QHUtil.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHUtil.h"

#import <CommonCrypto/CommonDigest.h>
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

NSString *QHHexStringFromBytes(const uint8_t *p, int length)
{
    static char *table = "0123456789abcdef";
    
    if (!p || !length) return @"";
    
    uint8_t *h =  malloc(length * 2);
    for (int i = 0; i < length; ++i) {
        h[2 * i] = table[p[i] >> 4];
        h[2 * i + 1] = table[p[i] & 0xf];
    }
    return [[NSString alloc] initWithBytesNoCopy:h
                                          length:length * 2
                                        encoding:NSASCIIStringEncoding
                                    freeWhenDone:YES];
}

uint8_t QHHexCharToHexValue(char c) {
    if (c >= '0' &&  c <= '9') {
        return c - '0';
    } else if (c >= 'a' &&  c <= 'f') {
        return c - 'a' + 10;
    } else if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    } else {
        return 0;
    }
}

NSData *QHHexStringToData(NSString *hexStr) {
    NSMutableData *data = [NSMutableData data];
    if (hexStr) {
        NSData *hexData = [hexStr dataUsingEncoding:NSUTF8StringEncoding];
        char *bytes = (char *)[hexData bytes];
        for (int i = 0; i+1 < hexData.length; i += 2) {
            uint8_t value = (QHHexCharToHexValue(bytes[i]) << 4) + QHHexCharToHexValue(bytes[i+1]);
            [data appendBytes:&value length:1];
        }
    }
    return  data;
}

NSString *QHMD5String(NSString *input) {
    if (input == nil) {
        return nil;
    }
    char buf[CC_MD5_DIGEST_LENGTH];
    CC_MD5([input UTF8String],
           (unsigned)[input lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
           (unsigned char *)buf);
    return QHHexStringFromBytes((unsigned char *)buf, CC_MD5_DIGEST_LENGTH);
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

// timestamp 0 是北京时间1970年1月1日 08:00 星期四
uint64_t QHTimestampDayFloor(uint64_t timestamp)
{
    uint64_t delta = ((timestamp % 86400) + 8 * 3600) % 86400;
    return timestamp - delta;
}

// timestamp 0 是北京时间1970年1月1日 08:00 星期四
uint64_t QHTimestampWeekFloor(uint64_t timestamp)
{
    static uint64_t weekInSeconds = 7 * 86400;
    uint64_t delta = ((timestamp % weekInSeconds) + 3 * 86400 + 8 * 3600) % weekInSeconds;
    return timestamp - delta;
}

CGFloat QHClamp(CGFloat value, CGFloat bounds1, CGFloat bounds2)
{
    if (bounds1 < bounds2) {
        return MIN(MAX(value, bounds1), bounds2);
    } else {
        return MAX(MIN(value, bounds1), bounds2);
    }
}

// https://stackoverflow.com/a/9169489/822417
BOOL QHCharacterIsChinese(unichar character)
{
    if ((character >= 0x4E00 && character <= 0x9FFF)
        || (character >= 0x3400 && character <= 0x4DBF)) {
        return YES;
    }
    return NO;
}

BOOL QHCharacterIsAlphabet(unichar character)
{
    return ((character >= 'a' && character <= 'z')
            || (character >= 'A' && character <= 'Z'));
}

BOOL QHCharacterIsNumber(unichar character)
{
    return (character >= '0' && character <= '9');
}

BOOL QHCharacterIsAlpNum(unichar character)
{
    return (QHCharacterIsAlphabet(character)
            || QHCharacterIsNumber(character));
}

static NSPredicate *isCM = nil;
static NSPredicate *isCU = nil;
static NSPredicate *isCT = nil;
static inline void QHMobilePhoneNumberInit()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 134、135、136、137、138、139、
        // 147、
        // 150、151、152、157、158、159、
        // 178
        // 182、183、184、187、188、
        isCM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                @"^1(3[4-9]|47|5[0-27-9]|78|8[23478])\\d{8}$"];

        // 130、131、132、
        // 155、156、
        // 176
        // 185、186、
        isCU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                @"^1(3[0-2]|5[56]|76|8[56])\\d{8}$"];

        // 133、
        // 153、
        // 177
        // 180、181、189、
        isCT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                @"^1(33|53|77|8[019])\\d{8}$"];
    });
}

BOOL QHMobilePhoneNumberCheck(NSString *number)
{
    QHMobilePhoneNumberInit();

    return ([isCM evaluateWithObject:number]
            || [isCU evaluateWithObject:number]
            || [isCT evaluateWithObject:number]);
}

NS_ASSUME_NONNULL_END
