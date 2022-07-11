//
//  YXIPOTodayCountResModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

class YXIPOTodayCountResModel: YXModel {
    @objc var applying : Int = 0
    @objc var ecmApplying : Int = 0
    @objc var ipoAppliyList : [YXIPOTodayCountItem] = []
    @objc var ipoGreyList : [YXIPOTodayCountItem] = []
    @objc var ipoSubscribeList : [YXIPOTodayCountItem] = []
    @objc var ipoAllList : [YXIPOTodayCountItem] = []    
    @objc var list : Int = 0
    @objc var publish : Int = 0
    @objc var todayDark : Int = 0
    @objc var waitListing : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["ipoAppliyList": YXIPOTodayCountItem.self, "ipoGreyList": YXIPOTodayCountItem.self, "ipoSubscribeList": YXIPOTodayCountItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXIPOTodayCountItem: YXModel {
    @objc var exchangeType : Int = 0
    @objc var ipoId : String?
    @objc var stockCode : String?
    @objc var stockName : String?
    @objc var subscribeId : String?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
    
    func symbolText() -> String {
        var market = ""
        if exchangeType == 0 {
            market = "HK"
        }else if exchangeType == 5 {
            market = "US"
        }
        
        return "\(stockCode ?? "--").\(market)"
    }
}


extension YXIPOTodayCountResModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
