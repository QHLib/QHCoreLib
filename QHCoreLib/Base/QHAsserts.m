//
//  QHAsserts.m
//  QHCoreLib
//
//  Created by changtang on 2017/5/18.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHAsserts.h"


NS_ASSUME_NONNULL_BEGIN

void _QHAssertFormat(const char *condition,
                     const char *fileName,
                     int lineNumber,
                     const char *function,
                     NSString *format,
                     ...)
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    QHAssertFunction assertFunction = QHGetAssertFunction();
    if (assertFunction == nil) {
        [[NSAssertionHandler currentHandler] handleFailureInFunction:@(function)
                                                                file:@(fileName)
                                                          lineNumber:lineNumber
                                                         description:@"%@", message];
    }
    else {
        assertFunction(@(condition), @(fileName), @(lineNumber), @(function), message);
    }
}


static QHAssertFunction QHCurrentAssertFunction = nil;

void QHSetAssertFunction(QHAssertFunction _Nullable assertFunction)
{
    QHCurrentAssertFunction = assertFunction;
}

QHAssertFunction QHGetAssertFunction()
{
    return QHCurrentAssertFunction;
}

NSException *_QHNotImplementedException(SEL cmd, Class cls)
{
    NSString *msg = [NSString stringWithFormat:@"%s is not implemented "
                     "for the class %@", sel_getName(cmd), cls];
    return [NSException exceptionWithName:@"RCTNotImplementedException"
                                   reason:msg userInfo:nil];
}

NS_ASSUME_NONNULL_END
