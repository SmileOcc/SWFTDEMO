//
//  Foundation+Extension.swift
//  SwiftStructure
//
//  Created by MountainZhu on 2019/8/21.
//  Copyright © 2019 Mountain. All rights reserved.
//

import Foundation
import UIKit

extension TimeInterval {
    // 把秒数转换成时间的字符串
    func convertString() -> String {
        // 把获取到的秒数转换成具体的时间
        let createDate = Date(timeIntervalSince1970: self)
        // 获取当前日历
        let calender = Calendar.current
        // 获取日期的年份
        let comps = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: createDate, to: Date())
        // 日期格式
        let formatter = DateFormatter()
        // 判断当前日期是否为今年
        guard createDate.isThisYear() else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: createDate)
        }
        // 是否是前天
        if createDate.isBeforeYesterday() {
            formatter.dateFormat = "前天 HH:mm"
            return formatter.string(from: createDate)
        } else if createDate.isToday() || createDate.isYesterday() {
            // 判断是否是今天或者昨天
            if comps.hour! >= 1 {
                return String(format: "%d小时前", comps.hour!)
            } else if comps.minute! >= 1 {
                return String(format: "%d分钟前", comps.minute!)
            } else {
                return "刚刚"
            }
        } else {
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: createDate)
        }
    }
}

extension Int {
    
    func convertString() -> String {
        guard self >= 10000 else {
            return String(describing: self)
        }
        return String(format: "%.1f万", Float(self) / 10000.0)
    }
    
    /// 将秒数转成字符串
    func convertVideoDuration() -> String {
        // 格式化时间
        if self == 0 { return "00:00" }
        let hour = self / 3600
        let minute = (self / 60) % 60
        let second = self % 60
        if hour > 0 { return String(format: "%02d:%02d:%02d", hour, minute, second) }
        return String(format: "%02d:%02d", minute, second)
    }
    
}

public extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

public extension CGFloat {
    static func scaleW(_ value: CGFloat) -> CGFloat {
        let newValue = HDConst.ScreenWith(width: CGFloat(value))
        return newValue
    }
    
    static func scaleH(_ value: CGFloat) -> CGFloat {
        let newValue = HDConst.ScreenHeight(height: CGFloat(value))
        return newValue
    }
}

