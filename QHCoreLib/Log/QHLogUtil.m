//
//  QHLogUtil.m
//  QHCommon
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHLogUtil.h"
#import "QHDDTTYLogger.h"
#import "QHDDFileLogger.h"

NS_ASSUME_NONNULL_BEGIN

QHDDLogLevel QHLogLevel = QHDDLogLevelAll;

void QHSetLogLevel(QHDDLogLevel logLevel)
{
    QHLogLevel = logLevel;
}

CF_INLINE NSString *QHLogFlagString(QHDDLogFlag flag) {
    NSString *flagString = @"";
    
    switch (flag) {
        case QHDDLogFlagVerbose:
            flagString = @"V";
            break;
        case QHDDLogFlagDebug:
            flagString = @"D";
            break;
        case QHDDLogFlagInfo:
            flagString = @"I";
            break;
        case QHDDLogFlagWarning:
            flagString = @"W";
            break;
        case QHDDLogFlagError:
            flagString = @"E";
            break;
        default:
            NSLog(@"unknown log flag");
            break;
    }
    
    return flagString;
}

@interface QHLogFormatter : NSObject <QHDDLogFormatter>
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
- (NSString *)formatLogMessage:(QHDDLogMessage *)logMessage
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

static QHDDFileLogger *fileLogger = nil;

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
    [[QHDDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[QHDDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithWhite:0.667 alpha:1]
                                     backgroundColor:nil
                                             forFlag:QHDDLogFlagVerbose];
    [[QHDDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithWhite:0.333 alpha:1]
                                     backgroundColor:nil
                                             forFlag:QHDDLogFlagDebug];
    [[QHDDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor]
                                     backgroundColor:nil
                                             forFlag:QHDDLogFlagInfo];
    [[QHDDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor]
                                     backgroundColor:nil
                                             forFlag:QHDDLogFlagWarning];
    [[QHDDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor]
                                     backgroundColor:nil
                                             forFlag:QHDDLogFlagError];
#endif
    [[QHDDTTYLogger sharedInstance] setLogFormatter:[[QHLogFormatter alloc] init]];
    [QHDDLog addLogger:[QHDDTTYLogger sharedInstance] withLevel:QHDDLogLevelAll];
    
    // file log
    fileLogger = [[QHDDFileLogger alloc] init];
    fileLogger.logFormatter = [[QHLogFormatter alloc] init];
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = 1024 * 1024;
    [QHDDLog addLogger:fileLogger withLevel:QHDDLogLevelInfo];

#if QH_DEBUG
    QHLogLevel = QHDDLogLevelVerbose;
#else
    QHLogLevel = QHDDLogLevelInfo;
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
