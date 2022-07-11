//
//  YXRedDotHelper.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

@objc enum YXRedDotType: Int {
    // 每日复盘港股
    case dailyReplayHK
    // 每日复盘美股
    case dailyReplayUS
    // 智投入口
    case investSmarter
    
    var ids: [String] {
        switch self {
        case .dailyReplayHK:
            return ["001"]
        case .dailyReplayUS:
            return ["002"]
        case .investSmarter:
            // 港版取003 004 005 大陆版只取003 004
            return ["003", "004", "005"]
        default:
            return []
        }
    }
    
    var cacheTimeKey: String {
        switch self {
        case .dailyReplayHK:
            return "YXRedDotCacheTimeKeyDailyReplayHK"
        case .dailyReplayUS:
            return "YXRedDotCacheTimeKeyDailyReplayUS"
        case .investSmarter:
            return "YXRedDotCacheTimeKeyInvestSmarter"
        default:
            return "YXRedDotCacheTimeKey"
        }
    }
}

class YXRedDotHelper: NSObject {
    static let shareInstance: YXRedDotHelper = {
        let instance = YXRedDotHelper()
        return instance
    }()
    
    var latestTimeDic: [String: String] = [:]
    
    @objc func updateCacheTime(with redDotType: YXRedDotType) {
        if let latestTime = latestTimeDic[redDotType.cacheTimeKey] {
            // 覆盖本地的缓存
            MMKV.default().set(latestTime, forKey: redDotType.cacheTimeKey)
        }
    }
    
    @objc func getRedDotData(with type: YXRedDotType, showRedDotBlock showRedDot: @escaping(() -> Void)) {
        let requestModel = YXRedDotRequestModel()
        
        requestModel.ids = type.ids
        
        let request = YXRequest.init(request: requestModel)
        
        request.startWithBlock(success: { (response) in
            
            if response.code == YXResponseStatusCode.success {
                
                let redDotModel = YXRedDotResponseModel.yy_model(withJSON: response.data ?? [:])
                let cacheTime = MMKV.default().string(forKey: type.cacheTimeKey, defaultValue: "2020-01-01 00:00:00")
                var isNew = false
                var latestUpdateTime: String?
                
                if let records = redDotModel?.records {
                    for item in records {
                        if let updateTime = item.updateTime, let diskTime = cacheTime {
                            // 后端返回的时间比本地保存的时间新，就展示小红点，同时把返回的最新的时间找出来，点击红点时覆盖本地的缓存
                            if self.compareDate(date: updateTime, greaterThan: diskTime) {
                                isNew = true
                                latestUpdateTime = updateTime
                            }
                        }
                    }
                }
                
                if isNew, let time = latestUpdateTime {
                    self.latestTimeDic[type.cacheTimeKey] = time
                    showRedDot()
                }
            }

        }, failure: { (request) in
            
        })
    }
    
    
    
    @objc func compareDate(date: String, greaterThan anotherDate: String) -> Bool {
        let firstDate = NSDate.init(string: date, format: "yyyy-MM-dd HH:mm:ss")
        let secondDate = NSDate.init(string: anotherDate, format: "yyyy-MM-dd HH:mm:ss")
        
        if (firstDate != nil && secondDate != nil) {
            return firstDate!.compare(secondDate! as Date) == .orderedDescending
        }
        
        return false
    }
}

class YXRedDotRequestModel: YXHZBaseRequestModel {
    @objc var ids: [String] = []
    
    override func yx_requestUrl() -> String {
        return "/mod-stat/api/v1/query"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXRedDotResponseModel: YXModel {
    
    @objc var num = 0
    @objc var records: [YXRedDotItem] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["records": YXRedDotItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXRedDotItem: YXModel {
    
    @objc var moduleId: String?
    @objc var updateTime: String?
    @objc var appType = 1
    @objc var msgNum = 0
    @objc var title: String?
    @objc var icon: String?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}
