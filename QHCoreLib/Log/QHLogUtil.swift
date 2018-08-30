//
//  QHLogUtil.swift
//  QHCoreLib
//
//  Created by changtang on 2018/8/30.
//  Copyright © 2018年 TCTONY. All rights reserved.
//

import Foundation

public class QHLog {
    public static func error(fmt: String, _ args: CVarArg...,
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if (QHLogLevel.rawValue & DDLogFlag.error.rawValue) != 0 {
            withVaList(args) {
                DDLog.log(false,
                          level: QHLogLevel,
                          flag: .error,
                          context: 0,
                          file: file,
                          function: function,
                          line: line,
                          tag: 0,
                          format: fmt,
                          args: $0)
            }
        }
    }

    public static func warn(fmt: String, _ args: CVarArg...,
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if (QHLogLevel.rawValue & DDLogFlag.warning.rawValue) != 0 {
            withVaList(args) {
                DDLog.log(false,
                          level: QHLogLevel,
                          flag: .warning,
                          context: 0,
                          file: file,
                          function: function,
                          line: line,
                          tag: 0,
                          format: fmt,
                          args: $0)
            }
        }
    }

    public static func info(fmt: String, _ args: CVarArg...,
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if (QHLogLevel.rawValue & DDLogFlag.info.rawValue) != 0 {
            withVaList(args) {
                DDLog.log(false,
                          level: QHLogLevel,
                          flag: .info,
                          context: 0,
                          file: file,
                          function: function,
                          line: line,
                          tag: 0,
                          format: fmt,
                          args: $0)
            }
        }
    }

    public static func debug(fmt: String, _ args: CVarArg...,
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if (QHLogLevel.rawValue & DDLogFlag.debug.rawValue) != 0 {
            withVaList(args) {
                DDLog.log(true,
                          level: QHLogLevel,
                          flag: .debug,
                          context: 0,
                          file: file,
                          function: function,
                          line: line,
                          tag: 0,
                          format: fmt,
                          args: $0)
            }
        }
    }

    public static func verbose(fmt: String, _ args: CVarArg...,
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if (QHLogLevel.rawValue & DDLogFlag.verbose.rawValue) != 0 {
            withVaList(args) {
                DDLog.log(true,
                          level: QHLogLevel,
                          flag: .verbose,
                          context: 0,
                          file: file,
                          function: function,
                          line: line,
                          tag: 0,
                          format: fmt,
                          args: $0)
            }
        }
    }
}
