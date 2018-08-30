//
//  empty.swift
//  QHCoreLibDemo
//
//  Created by changtang on 2017/12/6.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

import Foundation
import QHCoreLib

@objc class TestSwift: NSObject {

    @objc static func log() {
        QHLog.error(fmt: "error with code: %d", -1)
        QHLog.warn(fmt: "error with code: %d", -1)
        QHLog.info(fmt: "error with code: %d", -1)
        QHLog.debug(fmt: "error with code: %d", -1)
        QHLog.verbose(fmt: "error with code: %d", -1)
    }

}
