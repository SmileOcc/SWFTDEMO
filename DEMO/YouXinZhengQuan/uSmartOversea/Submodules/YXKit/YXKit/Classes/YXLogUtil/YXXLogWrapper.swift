//
//  YXXLogWrapper.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public let jmb = JinkeyMarsBridge()

public func log(_ level: XloggerType, tag: UnsafePointer<Int8>?, content: String?, file: String = #file, function: String = #function, line: Int = #line) {
    jmb.log(level, tag: tag, content: content, fileName: file, function: function, line: line)
}

public func initXlogger(_ debugLevel: XloggerType, releaseLevel: XloggerType, path: String! = YXConstant.logPath, prefix: UnsafePointer<Int8>!) {
    jmb.initXlogger(debugLevel, releaseLevel: releaseLevel, path: path, prefix: prefix)
}

public func deinitXlogger() {
    jmb.deinitXlogger()
}

public func flush() {
    jmb.flush()
}

public func flushSync() {
    jmb.flushSync()
}
