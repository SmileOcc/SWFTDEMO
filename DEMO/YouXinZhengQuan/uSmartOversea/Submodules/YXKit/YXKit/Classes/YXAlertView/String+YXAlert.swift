//
//  String+YXAlert.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public extension String {
    func characterLength() -> Int {
        var range: NSRange
        var length: Int = 0
        var i = 0
        while i < count {
            range = (self as NSString).rangeOfComposedCharacterSequence(at: i)
            let str = (self as NSString).substring(with: range)
            if str.validateChineseCharacter() {
                length += 2
            } else {
                length += str.count
            }
            i += range.length
        }
        return length
    }

    func validateChineseCharacter() -> Bool {
        let nameRegEx = "[\\u4e00-\\u9fa5]"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        if predicate.evaluate(with: self) {
            return true
        }
        return false
    }

    func subString(toCharacterIndex index: UInt) -> String {
        var length: Int = 0
        var range: NSRange

        var stringIndex: Int = 0
        var i = 0
        while i < count {
            var stringLength: Int = 0

            range = (self as NSString).rangeOfComposedCharacterSequence(at: i)
            let str = (self as NSString).substring(with: range)
            if str.validateChineseCharacter() {
                stringLength = 2
            } else {
                stringLength = str.count
            }
            length += stringLength

            if length > index {
                break
            } else {
                stringIndex += range.length
                if length == index {
                    break
                }
            }
            i += range.length
        }
        return (self as NSString).substring(to: stringIndex)
    }
}
