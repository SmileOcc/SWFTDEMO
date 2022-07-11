//
//  QMUICommonViewController+.swift
//  uSmartEducation
//
//  Created by usmart on 2022/1/11.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import SensorsAnalyticsSDK
import UIKit

extension QMUICommonViewController:SAAutoTracker {
    
    //进入页面时添加 页面属性  统一处理了showed事件
    public func getTrackProperties() -> [AnyHashable : Any] {
        if pageName.isEmpty {
            return [:]
        }else {
            var properties = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:pageName,
                              YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:"showed",
                              YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app"]
            for value in pageProperties {
                properties[value.key] = value.value
            }
            return properties
        }
    }
    
    @objc public var pageName: String {
        return ""
    }
    
    @objc public var pageProperties: [String:String] {
        return [:]
    }
    
    @objc func trackViewClickEvent(name: String, other: [String:String]? = nil) {
        trackViewClickEvent(customPageName: pageName, name: name, other: other)
    }
    
    @objc func trackViewClickEvent(customPageName:String,name: String, other: [String:String]? = nil) {
        var dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:customPageName,
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app",
                    YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:"click",
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_BTN:name]
        if let other = other {
            for value in other {
                dict[value.key] = value.value
            }
        }
        YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: dict)
    }
    
    func trackViewEvent(act: String, other: [String:String]? = nil) {
        trackViewEvent(customPageName: pageName, act: act, other: other)
    }
    
    
    @objc func trackViewEvent(customPageName:String,act: String, other: [String:String]? = nil) {
        var dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:customPageName,
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app",
                    YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:act]
        if let other = other {
            for value in other {
                dict[value.key] = value.value
            }
        }
        YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: dict)
    }
    
}

//使用view 进行埋点 会自动获取view所在的当前VC
extension UIView{
    
     func getViewController() -> QMUICommonViewController? {
         var nextResponder:UIResponder? = self
         while nextResponder != nil {
            if let vc = nextResponder as? QMUICommonViewController{
                return vc
            }
             nextResponder = nextResponder?.next
        }
        return nil
    }
    
     func getTrackerPageName() ->String{
        if let curVC = getViewController(){
            return curVC.pageName
        }
        return ""
    }
    
   @objc func trackViewClickEvent(name: String, other: [String:String]? = nil) {
       trackViewClickEvent(customPageName: getTrackerPageName(), name: name, other: other)
    }
   @objc func trackViewClickEvent(customPageName:String,name: String, other: [String:String]? = nil) {
        var dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:customPageName,
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app",
                    YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:"click",
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_BTN:name]
        if let other = other {
            for value in other {
                dict[value.key] = value.value
            }
        }
        YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: dict)
    }
    
    @objc func trackViewEvent(act: String, other: [String:String]? = nil) {
        trackViewEvent(customPageName: getTrackerPageName(), act: act, other: other)
    }
    
    
    @objc func trackViewEvent(customPageName:String,act: String, other: [String:String]? = nil) {
        var dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:customPageName,
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app",
                    YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:act]
        if let other = other {
            for value in other {
                dict[value.key] = value.value
            }
        }
        YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: dict)
    }
}
