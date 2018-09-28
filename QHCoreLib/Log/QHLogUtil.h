//
//  QHLogUtil.h
//  QHCommon
//
//  Created by changtang on 2017/5/17.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QHCoreLib/QHBase.h>

#import <QHCoreLib/QHDDLog.h>


NS_ASSUME_NONNULL_BEGIN

QH_EXTERN QHDDLogLevel QHLogLevel;
QH_EXTERN void QHSetLogLevel(QHDDLogLevel logLevel);

#define _LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...)    \
[QHDDLog log : isAsynchronous                                                 \
     level : lvl                                                            \
      flag : flg                                                            \
   context : ctx                                                            \
      file : __FILE__                                                       \
  function : fnct                                                           \
      line : __LINE__                                                       \
       tag : atag                                                           \
    format : (frmt), ## __VA_ARGS__]

#define _LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { \
    if(lvl & flg) \
        _LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); \
} while(0)

#if QH_DEBUG
#   define QHLogFatal(...) QHAssert(NO, @"Fatal error! " __VA_ARGS__)
#else
#   define QHLogFatal(...) QHLogError(__VA_ARGS__)
#endif

#define QHLogError(frmt, ...) \
_LOG_MAYBE(NO,  QHLogLevel, QHDDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define QHLogWarn(frmt, ...)  \
_LOG_MAYBE(YES, QHLogLevel, QHDDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define QHLogInfo(frmt, ...) \
_LOG_MAYBE(YES, QHLogLevel, QHDDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define QHLogDebug(frmt, ...) \
_LOG_MAYBE(YES, QHLogLevel, QHDDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define QHLogVerbose(frmt, ...) \
_LOG_MAYBE(YES, QHLogLevel, QHDDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)


@interface QHLogUtil : NSObject

+ (NSData *)getLogFileData;

+ (NSString *)getLogFilePath;

@end

NS_ASSUME_NONNULL_END
