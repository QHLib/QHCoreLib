//
//  QHNetworkMultipart.m
//  QHCoreLib
//
//  Created by changtang on 2017/6/19.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHNetworkMultipart.h"

#import <Security/Security.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "QHNetworkUtil.h"

#import "QHLog.h"


NS_ASSUME_NONNULL_BEGIN

static NSString * const QHHttpHeaderContentType = @"Content-Type";
static NSString * const QHHttpHeaderContentLength = @"Content-Length";
static NSString * const QHHttpHeaderContentDisposition = @"Content-Disposition";


@interface QHMultipartFormData : NSObject <QHNetworkMultipartBuilder>

- (instancetype)initWithUrlRequest:(NSMutableURLRequest *)request
                    stringEncoding:(NSStringEncoding)encoding;

- (NSMutableURLRequest *)finalRequest;

@end


@implementation QHNetworkMultipart

+ (NSMutableURLRequest *)requestFromUrl:(NSString *)urlString
                              queryDict:(NSDictionary * _Nullable)queryDict
                               bodyDict:(NSDictionary * _Nullable)bodyDict
                       multipartBuilder:(QHNetworkMultipartBuilderBlock)builderBlock
{
    NSMutableURLRequest *request = [QHNetworkUtil requestFromMethod:QHNetWorkHttpMethodPost
                                                                url:urlString
                                                          queryDict:queryDict
                                                           bodyDict:nil];

    QHMultipartFormData *formData = [[QHMultipartFormData alloc] initWithUrlRequest:request
                                                                     stringEncoding:NSUTF8StringEncoding];

    if (bodyDict && bodyDict.count) {
        [bodyDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            QHAssertReturnVoidOnFailure(QH_IS_STRING(key) && QH_IS_STRING(obj),
                                        @"key and value both should be string: %@ %@",
                                        key, obj);

            [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding]
                                        name:key];
        }];
    }

    if (builderBlock) {
        QH_BLOCK_INVOKE(^{
            builderBlock(formData);
        });
    }

    return [formData finalRequest];
}

@end

#pragma mark -

static NSString *QHMultipartCreateBoundary()
{
    NSData *data = QHRandomBytes(8);
    QHAssert(data != nil, @"create random bytes should not fail");

    if (data != nil) {
        int32_t *buffer = (int32_t *)data.bytes;
        return $(@"--------------Boundary%08X%08X", buffer[0], buffer[1]); // length is 38
    } else {
        return @"--------------BoundaryABCDEFGHABCDEFGH";
    }
}

static NSString * const QHMultipartCRLF = @"\r\n";

static inline NSString * QHMultipartBoundaryFirst(NSString *boundary) {
    return $(@"--%@%@", boundary, QHMultipartCRLF);
}

static inline NSString * QHMultipartBoundaryMiddle(NSString *boundary) {
    return $(@"%@--%@%@", QHMultipartCRLF, boundary, QHMultipartCRLF);
}

static inline NSString * QHMultipartBoundaryLast(NSString *boundary) {
    return $(@"%@--%@--%@", QHMultipartCRLF, boundary, QHMultipartCRLF);
}

@interface QHMultipartBodyPart : NSObject

@property (nonatomic, assign) NSStringEncoding stringEncoding;

@property (nonatomic,   copy) NSString *boundary;

@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic,   copy) NSString *name;

@property (nonatomic, strong) id bodyObject; // NSData, NSURL(fileUrl), NSInputStream
@property (nonatomic, assign) uint64_t bodyLength; // in byte

@end

@interface QHMultipartBodyStream : NSInputStream <NSStreamDelegate>

- (instancetype)initWithStringEncoding:(NSStringEncoding)encoding;

- (BOOL)isEmpty;

- (uint64_t)contentLength;

- (void)appendBodyPart:(QHMultipartBodyPart *)bodyPart;

@end

@interface QHMultipartFormData ()

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) NSStringEncoding stirngEncoding;
@property (nonatomic,   copy) NSString *boundary;
@property (nonatomic, strong) QHMultipartBodyStream *bodyStream;

@end

@implementation QHMultipartFormData

- (instancetype)initWithUrlRequest:(NSMutableURLRequest *)request
                    stringEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        self.request = request;
        self.stirngEncoding = encoding;
        self.boundary = QHMultipartCreateBoundary();
        self.bodyStream = [[QHMultipartBodyStream alloc] initWithStringEncoding:encoding];
    }
    return self;
}

- (NSMutableURLRequest *)finalRequest
{
    if ([self.bodyStream isEmpty]) {
        return self.request;
    }

    [self.request setHTTPBodyStream:self.bodyStream];

    [self.request setValue:$(@"multipart/form-data; boundary=%@", self.boundary)
        forHTTPHeaderField:QHHttpHeaderContentType];

    [self.request setValue:$(@"%llu", [self.bodyStream contentLength])
        forHTTPHeaderField:QHHttpHeaderContentLength];

    return self.request;
}

#pragma mark -

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name
{
    QHAssertParam(data);
    QHAssertParam(name);

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers qh_setObject:$(@"form-data; name=\"%@\"", name)
                   forKey:QHHttpHeaderContentDisposition];

    [self appendPartWithHeaders:headers name:name body:data];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         name:(NSString *)name
                         body:(NSData *)body
{
    QHAssertParam(headers);
    QHAssertParam(name);
    QHAssertParam(body);

    QHMultipartBodyPart *bodyPart = [[QHMultipartBodyPart alloc] init];
    bodyPart.stringEncoding = self.stirngEncoding;
    bodyPart.boundary = self.boundary;
    bodyPart.headers = headers;
    bodyPart.name = name;
    bodyPart.bodyObject = body;
    bodyPart.bodyLength = [body length];

    [self.bodyStream appendBodyPart:bodyPart];
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                     mimieType:(NSString *)mimeType
{
    QHAssertParam(data);
    QHAssertParam(name);
    QHAssertParam(fileName);
    QHAssertParam(mimeType);

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers qh_setObject:$(@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName)
                   forKey:QHHttpHeaderContentDisposition];
    [headers qh_setObject:mimeType
                   forKey:QHHttpHeaderContentType];

    [self appendPartWithHeaders:headers name:name body:data];
}

- (BOOL)appendPartWithFileUrl:(NSURL *)fileUrl
                         name:(NSString *)name
                        error:(NSError * __autoreleasing *)error
{
    QHAssertParam(fileUrl);
    QHAssertParam(name);

    NSString *fileName = [fileUrl lastPathComponent];
    NSString *mimeType = QHContentTypeOfExtension([fileUrl pathExtension]);

    return [self appendPartWithFileUrl:fileUrl
                                  name:name
                              fileName:fileName
                              mimeType:mimeType
                                 error:error];
}

- (BOOL)appendPartWithFileUrl:(NSURL *)fileUrl
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __autoreleasing *)error
{
    QHAssertParam(fileUrl);
    QHAssertReturnValueOnFailure(NO, [fileUrl isFileURL], @"need file url");
    QHAssertParam(name);
    QHAssertParam(fileName);
    QHAssertParam(mimeType);

    if ([fileUrl checkResourceIsReachableAndReturnError:error] == NO) {
        if (error) {
            *error = QH_ERROR(NSStringFromClass([self class]),
                              -1,
                              $(@"file url %@ is not reachable", fileUrl),
                              nil);
        }
        return NO;
    }

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:error];
    if (!fileAttributes) {
        return NO;
    }

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers qh_setObject:$(@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName)
                   forKey:QHHttpHeaderContentDisposition];
    [headers qh_setObject:mimeType
                   forKey:QHHttpHeaderContentType];

    QHMultipartBodyPart *bodyPart = [[QHMultipartBodyPart alloc] init];
    bodyPart.stringEncoding = self.stirngEncoding;
    bodyPart.boundary = self.boundary;
    bodyPart.headers = headers;
    bodyPart.name = name;
    bodyPart.bodyObject = fileUrl;
    bodyPart.bodyLength = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];

    [self.bodyStream appendBodyPart:bodyPart];

    return YES;
}

- (void)appendPartWithInputStream:(NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(uint64_t)length
                         mimeType:(NSString *)mimeType
{
    QHAssertParam(inputStream);
    QHAssertParam(name);
    QHAssertParam(fileName);
    QHAssertParam(mimeType);

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers qh_setObject:$(@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName)
                   forKey:QHHttpHeaderContentDisposition];
    [headers qh_setObject:mimeType
                   forKey:QHHttpHeaderContentType];

    QHMultipartBodyPart *bodyPart = [[QHMultipartBodyPart alloc] init];
    bodyPart.stringEncoding = self.stirngEncoding;
    bodyPart.boundary = self.boundary;
    bodyPart.headers = headers;
    bodyPart.name = name;
    bodyPart.bodyObject = inputStream;
    bodyPart.bodyLength = length;

    [self.bodyStream appendBodyPart:bodyPart];
}

@end

#pragma mark -

typedef NS_ENUM(NSUInteger, QHMultipartBodyPartSection) {
    QHMultipartBodyPartSectionBegin = 0,
    QHMultipartBodyPartSectionHeaders,
    QHMultipartBodyPartSectionBody,
    QHMultipartBodyPartSectionEnd,

    QHMultipartBodyPartSectionReadOver, // no content for this section
};

@interface QHMultipartBodyPart () <NSCopying>

@property (nonatomic, assign) BOOL isFirstPart;
@property (nonatomic, assign) BOOL isLastPart;

- (uint64_t)contentLength;  // include boundary

@property (nonatomic, strong) NSInputStream * _Nullable stream;

- (BOOL)hasBytesAvailable;

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;

@property (nonatomic, assign) QHMultipartBodyPartSection currentSection;
@property (nonatomic, assign) uint64_t sectionOffset;

@end

@implementation QHMultipartBodyPart

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isFirstPart = NO;
        self.isLastPart = NO;
        self.currentSection = QHMultipartBodyPartSectionBegin;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone * _Nullable)zone
{
    QHMultipartBodyPart *bodyPart = [[[self class] allocWithZone:zone] init];

    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.boundary = self.boundary;
    bodyPart.headers = self.headers;
    bodyPart.bodyObject = bodyPart.bodyObject;
    bodyPart.bodyLength = bodyPart.bodyLength;

    return bodyPart;
}

- (NSString *)description
{
    return $(@"<%@: %p, %@=%@>", NSStringFromClass([self class]), self, self.name, self.bodyObject);
}

- (NSData *)beginData
{
    if (self.isFirstPart) {
        return [QHMultipartBoundaryFirst(self.boundary) dataUsingEncoding:self.stringEncoding];
    }
    else {
        return [QHMultipartBoundaryMiddle(self.boundary) dataUsingEncoding:self.stringEncoding];
    }
}

- (NSData *)headersData
{
    NSMutableString *headerString = [NSMutableString string];

    for (NSString *key in [self.headers allKeys]) {
        [headerString appendFormat:@"%@: %@%@", key, self.headers[key], QHMultipartCRLF];
    }
    [headerString appendString:QHMultipartCRLF];

    return [[NSString stringWithString:headerString] dataUsingEncoding:self.stringEncoding];
}

- (NSData *)endData
{
    if (self.isLastPart) {
        return [QHMultipartBoundaryLast(self.boundary) dataUsingEncoding:self.stringEncoding];
    }
    return [NSData data];
}

- (uint64_t)contentLength
{
    uint64_t length = 0;

    length += [self beginData].length;
    length += [self headersData].length;
    length += self.bodyLength;
    length += [self endData].length;

    return length;
}

#pragma mark -

- (NSInputStream * _Nullable)stream
{
    if (_stream == nil) {
        if (QH_IS(self.bodyObject, NSData)) {
            _stream = [NSInputStream inputStreamWithData:self.bodyObject];
        }
        else if (QH_IS(self.bodyObject, NSURL)) {
            _stream = [NSInputStream inputStreamWithURL:self.bodyObject];
        }
        else if (QH_IS(self.bodyObject, NSInputStream)) {
            _stream = self.bodyObject;
        }
        else {
            QHAssert(NO, @"invalid bodyObject: %@", self.bodyObject);
            _stream = [NSInputStream inputStreamWithData:[NSData data]];
        }
    }
    return _stream;
}

- (void)dealloc
{
    if (_stream) {
        [_stream close];
        _stream = nil;
    }
}

- (BOOL)hasBytesAvailable
{
    return self.currentSection < QHMultipartBodyPartSectionReadOver;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    NSInteger readCount = 0;

    while ((NSUInteger)readCount < length) {
        NSUInteger maxReadCountThisLoop = length - (NSUInteger)readCount;
        NSUInteger readCountThisLoop = 0;

        if (self.currentSection == QHMultipartBodyPartSectionBegin) {
            readCountThisLoop = [self readData:[self beginData]
                                    intoBuffer:&buffer[readCount]
                                     maxLength:maxReadCountThisLoop];
        }
        else if (self.currentSection == QHMultipartBodyPartSectionHeaders) {
            readCountThisLoop = [self readData:[self headersData]
                                    intoBuffer:&buffer[readCount]
                                     maxLength:maxReadCountThisLoop];

        }
        else if (self.currentSection == QHMultipartBodyPartSectionBody) {
            readCountThisLoop = [self.stream read:&buffer[readCount]
                                        maxLength:maxReadCountThisLoop];
            if (readCountThisLoop == -1) {
                return -1;
            }
            else {
                if ([self.stream streamStatus] >= NSStreamStatusAtEnd) {
                    [self moveToNextSection];
                }
            }
        }
        else if (self.currentSection == QHMultipartBodyPartSectionEnd) {
            readCountThisLoop = [self readData:[self endData]
                                    intoBuffer:&buffer[readCount]
                                     maxLength:maxReadCountThisLoop];
        }
        else if (self.currentSection == QHMultipartBodyPartSectionReadOver) {
            break;
        }

        if (readCountThisLoop > 0) {
            readCount += readCountThisLoop;
        }
    }

    return readCount;
}

- (NSInteger)readData:(NSData *)data
           intoBuffer:(uint8_t *)buffer
            maxLength:(NSUInteger)length
{
    NSUInteger maxToBeRead = [data length] - (NSUInteger)self.sectionOffset;
    NSRange range = NSMakeRange((NSUInteger)self.sectionOffset, MIN(length, maxToBeRead));

    [data getBytes:buffer range:range];
    self.sectionOffset += range.length;

    if ((NSUInteger)self.sectionOffset >= [data length]) {
        [self moveToNextSection];
    }

    return (NSInteger)range.length;
}

- (void)moveToNextSection
{
    self.currentSection++;
    self.sectionOffset = 0;

    if (self.currentSection == QHMultipartBodyPartSectionBody) {
        QHAssertParam([NSRunLoop currentRunLoop]);
        [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
        [self.stream open];
    }
    else if (self.currentSection == QHMultipartBodyPartSectionEnd) {
        [self.stream close];
    }
}

@end

#pragma mark -

@interface QHMultipartBodyStream () <NSCopying>

@property (nonatomic, assign) NSStringEncoding stringEncoding;

@property (nonatomic, strong) NSMutableArray *bodyParts;
@property (nonatomic, strong) NSEnumerator *bodyPartEnumerator;
@property (nonatomic, strong) QHMultipartBodyPart *currentBodyPart;

@property (nonatomic, assign, readwrite) NSStreamStatus streamStatus;
@property (nonatomic,   copy, readwrite) NSError *streamError;
@property (nonatomic,   weak, readwrite) id<NSStreamDelegate> delegate;

@end

@implementation QHMultipartBodyStream

@synthesize delegate;

- (instancetype)initWithStringEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        self.stringEncoding = encoding;
        self.bodyParts = [NSMutableArray array];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone * _Nullable)zone
{
    QHMultipartBodyStream *bodyStream = [[[self class] allocWithZone:zone] initWithStringEncoding:self.stringEncoding];

    for (QHMultipartBodyPart *bodyPart in self.bodyParts) {
        [bodyStream appendBodyPart:[bodyPart copy]];
    }

    return bodyStream;
}

- (NSString *)description
{
    NSString *bodyPartsDesc = [[self.bodyParts qh_mappedArrayWithBlock:^id(NSUInteger idx, id obj) {
        return [obj description];
    }] componentsJoinedByString:@", "];

    return $(@"<%@: %p, %@>", NSStringFromClass([self class]), self, bodyPartsDesc);
}

- (void)appendBodyPart:(QHMultipartBodyPart *)bodyPart
{
    [self.bodyParts qh_addObject:bodyPart];

    [self updateBoundaryFalgs];
}

- (void)updateBoundaryFalgs
{
    if (self.bodyParts.count == 0) return;

    [self.bodyParts enumerateObjectsUsingBlock:^(QHMultipartBodyPart * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isFirstPart = (idx == 0);
        obj.isLastPart = (idx == self.bodyParts.count - 1);
    }];
}

- (BOOL)isEmpty
{
    return [self.bodyParts count] == 0;
}

- (uint64_t)contentLength
{
    uint64_t length = 0;
    for (QHMultipartBodyPart *bodyPart in self.bodyParts) {
        length += [bodyPart contentLength];
    }
    return length;
}

#pragma mark - NSStream

@synthesize streamStatus;
@synthesize streamError;

- (void)open
{
    if (self.streamStatus == NSStreamStatusOpen) {
        return;
    }

    self.streamStatus = NSStreamStatusOpen;

    self.bodyPartEnumerator = [self.bodyParts objectEnumerator];
}

- (void)close
{
    self.streamStatus = NSStreamStatusClosed;
}

- (nullable id)propertyForKey:(NSStreamPropertyKey)key
{
    return nil;
}

- (BOOL)setProperty:(id _Nullable)property forKey:(NSStreamPropertyKey)key
{
    return NO;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSRunLoopMode)mode
{
    // do nothing
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSRunLoopMode)mode
{
    // do nothing
}

#pragma mark - NSInputStream

- (BOOL)hasBytesAvailable
{
    return self.streamStatus == NSStreamStatusOpen;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    if (self.streamStatus == NSStreamStatusClosed) {
        return 0;
    }

    NSInteger readCount = 0;

    while ((NSUInteger)readCount < length) {
        if (self.currentBodyPart == nil || [self.currentBodyPart hasBytesAvailable] == NO) {
            if ((self.currentBodyPart = [self.bodyPartEnumerator nextObject]) == nil) {
                break;
            }
        }
        else {
            NSUInteger maxReadCountThisLoop = length - (NSUInteger)readCount;
            NSUInteger readCountThisLoop = [self.currentBodyPart read:&buffer[readCount]
                                                            maxLength:maxReadCountThisLoop];
            if (maxReadCountThisLoop == -1) {
                self.streamError = self.currentBodyPart.stream.streamError;
                break;
            }
            else {
                readCount += readCountThisLoop;
            }
        }
    }

    return readCount;
}

- (BOOL)getBuffer:(uint8_t * _Nullable *)buffer length:(NSUInteger *)len
{
    return NO;
}

@end

NS_ASSUME_NONNULL_END
