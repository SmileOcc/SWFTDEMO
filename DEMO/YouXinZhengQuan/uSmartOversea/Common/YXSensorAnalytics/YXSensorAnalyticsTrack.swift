//
//  YXSensorAnalyticsTrack.swift
//  uSmartEducation
//
//  Created by 胡华翔 on 2018/12/4.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import SensorsAnalyticsSDK

open class YXSensorAnalyticsTrack: NSObject {
    // event 的名称
    var event: YXSensorAnalyticsEvent?
    
    // event的属性
    var props: Dictionary<String, Any> = [:]
    
    // MARK: - 类方法
    /// 神策事件追踪
    /// 调用 track 接口，追踪一个无私有属性的 event
    /// - Parameter event: event 的名称
    @objc open class func track(withEvent event: YXSensorAnalyticsEvent) -> Void {
        YXSensorAnalyticsTrack.track(withEvent: event, properties: [:])
    }
    
    /// 神策事件追踪
    /// 调用 track 接口，追踪一个带有属性的 event
    /// propertyDict 是一个 Map。
    /// 其中的 key 是 Property 的名称，必须是 NSString
    /// value 则是 Property 的内容，只支持 NSString、NSNumber、NSSet、NSArray、NSDate 这些类型
    /// 特别的，NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString
    /// - Parameters:
    ///   - event: event 的名称
    ///   - properties: event的属性
    @objc open class func track(withEvent event: YXSensorAnalyticsEvent, properties: Dictionary<String, Any>) -> Void {
        guard event != .Unknown else {
            return
        }
        SensorsAnalyticsSDK.sharedInstance()?.track(event.rawValue, withProperties: properties)

    }
    
    /// 初始化事件的计时器
    /// 若需要统计某个事件的持续时间，先在事件开始时调用 trackTimer:"Event" 记录事件开始时间，该方法并不会真正发
    /// 送事件；随后在事件结束时，调用 track:"Event" withProperties:properties，SDK 会追踪 "Event" 事件，并自动将事件持续时
    /// 间记录在事件属性 "event_duration" 中。
    /// 时间单位为秒，若需要以其他时间单位统计时长
    /// 多次调用 trackTimer:"Event" 时，事件 "Event" 的开始时间以最后一次调用时为准。
    ///
    /// - Parameter event: event 的名称
    @objc open class func trackTimerStart(withEvent event: YXSensorAnalyticsEvent) -> Void {
        SensorsAnalyticsSDK.sharedInstance()?.trackTimerStart(event.rawValue)
    }
    
    /// 结束事件计时器
    /// 结束后，会自动上传事件
    ///
    /// - Parameters:
    ///   - event: event 的名称
    ///   - properties: event的属性
    @objc open class func trackTimerEnd(withEvent event: YXSensorAnalyticsEvent, properties: Dictionary<String, String>) -> Void {
       
        SensorsAnalyticsSDK.sharedInstance()?.trackTimerEnd(event.rawValue, withProperties: properties)
    }
    
    
    
    
    /// 系统日志追追事件
    ///
    /// - Parameters:
    ///   - logModule: 日志模块
    ///   - logType: 日志类型
    ///   - logDesc: 日志描述
    @objc open class func trackSystemLog(withLogModule logModule: String, logType: String, logDesc: String) {
//        YXSensorAnalyticsTrack.track(withEvent: YXSensorAnalyticsEvent.SystemLog,
//                                    properties: [
//                                        YXSensorAnalyticsPropsConstant.PROP_LOG_MODULE: logModule,
//                                        YXSensorAnalyticsPropsConstant.PROP_LOG_TYPE: logType,
//                                        YXSensorAnalyticsPropsConstant.PROP_LOG_DESC: logDesc
//                                    ])
    }
    
    // MARK: - 实例方法
    /// 设置需要追踪器的事件名
    ///
    /// - Parameter event: event 的名称
    /// - Returns: 追踪器
    @objc open func event(_ event: YXSensorAnalyticsEvent) -> YXSensorAnalyticsTrack {
        self.event = event
        return self
    }
    
    /// 向追踪器添加events的属性
    ///
    /// - Parameters:
    ///   - propKey: events属性的key
    ///   - propValue: events属性的value
    /// - Returns: 追踪器
    @objc open func addProp(_ propKey: String, _ propValue: Any) -> YXSensorAnalyticsTrack {
        props[propKey] = propValue
        return self
    }
    
    /// 追踪事件
    @objc open func track() -> Void {
        guard self.event != .Unknown else {
            return
        }
        
        if let event = self.event {
            var result: Dictionary<String, Any>? = [:]
            for (key, value) in self.props {
                result?[key] = value
            }
            SensorsAnalyticsSDK.sharedInstance()?.track(event.rawValue, withProperties: result)
        }
    }
}

