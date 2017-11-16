//
//  QHLogUtil.m
//  QHCommon
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHLogUtil.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"


NS_ASSUME_NONNULL_BEGIN

DDLogLevel QHLogLevel = DDLogLevelAll;

void QHSetLogLevel(DDLogLevel logLevel)
{
    QHLogLevel = logLevel;
}

CF_INLINE NSString *QHLogFlagString(DDLogFlag flag) {
    NSString *flagString = @"";
    
    switch (flag) {
        case DDLogFlagVerbose:
            flagString = @"V";
            break;
        case DDLogFlagDebug:
            flagString = @"D";
            break;
        case DDLogFlagInfo:
            flagString = @"I";
            break;
        case DDLogFlagWarning:
            flagString = @"W";
            break;
        case DDLogFlagError:
            flagString = @"E";
            break;
        default:
            NSLog(@"unknown log flag");
            break;
    }
    
    return flagString;
}

@interface QHLogFormatter : NSObject <DDLogFormatter>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation QHLogFormatter
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    }
    return self;
}
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    return [NSString stringWithFormat:@"%@ [%@] (%@)*%@:%lu %@\n%@\n",
                                        [_dateFormatter stringFromDate:logMessage.timestamp],
                                        QHLogFlagString(logMessage.flag),
                                        logMessage.queueLabel,
                                        logMessage.fileName,
                                        (unsigned long)logMessage.line,
                                        logMessage.function,
                                        logMessage.message];
}
@end

static DDFileLogger *fileLogger = nil;

@implementation QHLogUtil

+ (void)load
{
    [self doSetup];
}

+ (void)doSetup
{
    // console log
#if QH_DEBUG && 0
    // not used any more since Xcode does not support
    setenv("XcodeColors", "YES", 1);
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithWhite:0.667 alpha:1]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagVerbose];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithWhite:0.333 alpha:1]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagWarning];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagError];
#endif
    [[DDTTYLogger sharedInstance] setLogFormatter:[[QHLogFormatter alloc] init]];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelAll];
    
    // file log
    fileLogger = [[DDFileLogger alloc] init];
    fileLogger.logFormatter = [[QHLogFormatter alloc] init];
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = 1024 * 1024;
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];

#if QH_DEBUG
    QHLogLevel = DDLogLevelVerbose;
#else
    QHLogLevel = DDLogLevelInfo;
#endif
}

+ (NSData *)getLogFileData
{
    return [NSData dataWithContentsOfFile:[[fileLogger currentLogFileInfo] filePath]];
}

+ (NSString *)getLogFilePath
{
    return [[fileLogger currentLogFileInfo] filePath];
}

@end

NS_ASSUME_NONNULL_END
