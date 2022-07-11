//
//  YXNewStockCenterPreMarketModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/20.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockCenterPreMarketStockModel2: YXModel {
    
    @objc enum YXStocklabelStatus: Int {
        case purchase, wined, notWined
    }
    
    ///ipoId
    @objc var ipoId: String = ""
    
    //是否区分普通高级账户 0-不区分，1-区分
    @objc var financingAccountDiff : Int = 0
    
    ///市场类型(0-港股, 5-us)
    @objc var exchangeType: Int = 0
    
    ///新股代码
    @objc var stockCode: String = ""
    
    ///新股名称
    @objc var stockName: String = ""
    
    ///标签状态(0-已认购,1-已中签,2-未中签 3-申请额度中)
    @objc var labelStatus: String = ""
    
    @objc var labelStatusName: String = ""
    
    ///起购金额
    @objc var leastAmount: NSNumber?
    
    //ecm最低认购金额
    @objc var ecmLeastAmount: NSNumber?
    
    ///最高招股价
    @objc var priceMax: NSNumber?
    
    ///最低招股价
    @objc var priceMin: NSNumber?
    
    ///认购截止日期
    @objc var endTime: String = ""
    
    ///认购剩余时间（秒）
    @objc var remainingTime: Int = 0
    
    ///公布中签日期
    @objc var publishTime: String = ""
    
    ///中签率
    @objc var successRate: NSNumber?
    
    ///认购倍数
    @objc var bookingRatio: NSNumber?
    
    //上市日期
    @objc var listingTime: String?
    
    ///服务器时间
    @objc var serverTime: String = ""
    
    ///国际认购、融资认购和现金认购截止时间最晚的时间
    @objc var latestEndtime: String = ""
    
    ///认购方式 1-公开现金认购，2-公开融资认购，3-国际配售
    @objc var subscribeWay: String = "0"
    
    //融资认购截止时间
    @objc var financingEndTime: String = ""
    
    //ECM认购截止时间
    @objc var ecmEndTime: String = ""
    
    //ECM状态
    @objc var ecmStatus: Int = 0
    
    //专业投资者标签
    @objc var ecmLabel = ""
    
    //自定义标签
    @objc var ecmLabelV2 = ""
    
    // pi认证
    @objc var piFlag = 0
    
    // 是否支持暗盘（0-不支持，1-支持）
    @objc var greyFlag = 0
    
    // 是否显示标签 0 不显示 1 显示
    @objc var piTag = 0
    
    @objc var piTagName = ""
    
    //公开认购状态
    @objc var status: Int = 0
    
    ///融资倍数
    @objc var financingMultiple: Int = 0
    
    @objc var listExchanges = ""
    
    @objc var tagList: [YXNewStockCenterTagModel] = []
    
    //每手股数
    @objc var handAmount = ""
    
    //普通用户融资倍数，可能返回 null
    @objc var ordinaryFinancingMultiple: Int = 0
    
    // 是否可以打开详情页
    @objc var openApplyInfo = 1
    
    func ipoTagText() -> String {
        return ""
    }
    
    @objc func isCanPublic() -> Bool {
        return isCanCash() || isCanIPO()
    }
    
    @objc func isCanCash() -> Bool {
        let subscribeWays = self.subscribeWay.components(separatedBy: ",")
        return subscribeWays.contains("1") && status == 1 && isCashTimeValid()
    }
    
    @objc func isCanIPO() -> Bool {
        let subscribeWays = self.subscribeWay.components(separatedBy: ",")
        return subscribeWays.contains("2") && status == 1 && isIpoTimeValid()
    }
    
    @objc func isCanECM() -> Bool {
        let subscribeWays = self.subscribeWay.components(separatedBy: ",")
        return subscribeWays.contains("3") &&  ecmStatus == 1 && isECMTimeValid()
    }
    
    @objc func isSupportECM() -> Bool {
        let subscribeWays = self.subscribeWay.components(separatedBy: ",")
        return subscribeWays.contains("3")
    }
    
    @objc func isCashTimeValid() -> Bool {
        return compareDate(firstDate: serverTime, lessThanSecond: endTime)
    }
    
    @objc func isIpoTimeValid() -> Bool {
        return compareDate(firstDate: serverTime, lessThanSecond: financingEndTime)
    }
    
    @objc func isECMTimeValid() -> Bool {
        return compareDate(firstDate: serverTime, lessThanSecond: ecmEndTime)
    }
    
    func compareDate(firstDate: String, lessThanSecond secondDate: String) -> Bool {
        let firstDate = NSDate.init(string: firstDate, format: "yyyy-MM-dd HH:mm:ss")
        let secondDate = NSDate.init(string: secondDate, format: "yyyy-MM-dd HH:mm:ss")
        
        if (firstDate != nil && secondDate != nil) {
            return firstDate!.compare(secondDate! as Date) == .orderedAscending
        }
        
        return true
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["tagList": YXNewStockCenterTagModel.self]
    }
    
}

class YXNewStockCenterTagModel: YXModel {
    
    @objc var seniorFlag: Int = 0 //0-普通账户，1-高级账户
    @objc var tagType: Int = 0 //tag类型(0-其他，1-融资倍数，2-融资利率，3-国际配售，4-PI)
    @objc var tagText: String = "" //标签文案
    
}

class YXNewStockCenterPreMarketModel2: YXModel {

    @objc var pageNum: Int = 0
    @objc var pageSize: Int = 0
    @objc var total: Int = 0
    @objc var list: [YXNewStockCenterPreMarketStockModel2] = []
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXNewStockCenterPreMarketStockModel2.self]
    }
    
}
