//
//  YXTradeRequestTool.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/4/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YYCategories

class YXTradeRequestTool: NSObject {

    // 暗盘, 市价单，条件单提示
    class func queryTradeTips(_ sceneType: Int, completion: @escaping ((_ attributeString: NSAttributedString) -> Void)) {
        let requestModel = YXKindlyReminderSelectRequestModel()
        requestModel.sceneType = sceneType

        let request = YXRequest.init(request: requestModel)

        request.startWithBlock(success: { (responseModel) in

            if responseModel.code == .success, let data = responseModel.data as? [String : Any] {
                let key = "sceneType" + "\(sceneType)"
                if let text = data[key] as? String, !text.isEmpty {

                    let attStr = YXNewStockPurchaseUtility.htmlString(text: text)
                    let muAttStr = NSMutableAttributedString.init(attributedString: attStr)
                    muAttStr.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel4()], range: NSRange(location: 0, length: attStr.length))

                    completion(muAttStr)
                }
            }

        }, failure: { (request) in

        })
    }

    //获取提示接口
//    class func queryOrderTimeTips(_ type: TradeOrderType, textType: String, completion: @escaping ((_ content: String, _ orderSwitch: Bool) -> Void)) {
//        let requestModel = YXOrderTimeRequestModel()
//
//        var typeStr = "0"
//        if type == .bidding {
//            typeStr = "d"
//        } else if type == .limitBidding {
//            typeStr = "g"
//        }
//        requestModel.type = typeStr
//        requestModel.textType = textType
//
//        let request = YXRequest.init(request: requestModel)
//        request.startWithBlock(success: { (responseModel) in
//
//            if responseModel.code == .success, let data = responseModel.data as? [String : Any], let content = data["content"] as? String {
//
//                var orderSwitch: Bool = false
//                if let availble = data["orderSwitch"] as? NSNumber  {
//                    orderSwitch = availble.boolValue
//                }
//                completion(content, orderSwitch)
//            }
//
//        }, failure: { (request) in
//
//        })
//    }


    class func queryOrderTradeStatus(_ symbol: String, completion: @escaping ((_ info: YXTradeOrderPreAfterStatusInfo) -> Void)) {

        if symbol.isEmpty {
            return
        }
        let requestModel = YXOrderTradeStatusRequestModel()

        requestModel.stockCode = symbol

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { (responseModel) in

            if responseModel.code == .success, let data = responseModel.data as? [String : Any] {

                let info = YXTradeOrderPreAfterStatusInfo()

                if let value = data["cantTradeReason"] as? String {
                    info.cantTradeReasonTips  = value
                }

                if let sessionType = data["sessionType"] as? NSNumber, (sessionType.intValue == 1 || sessionType.intValue == 2) {

                    if let tips = data["tips"] as? String {
                        info.tradeStatusTips = tips
                    }
                    info.isShowTradeStatus = true

                    if let canTrade = data["canTrade"] as? NSNumber, canTrade.boolValue  {

                    } else { //不允许交易时的错误码
                        if let value = data["cantTradeReasonNo"] as? NSNumber {
                            info.cantTradeReasonNo = value.intValue;
                        }
                    }
                }

                completion(info)
            }

        }, failure: { (request) in

        })
    }


    class func queryTradeConditionTime(_ market: String, completion: @escaping ((_ date: String, _ unixTime: TimeInterval) -> Void)) {

        if market.isEmpty {
            return
        }
        let requestModel = YXConditionTimeRequestModel()

        let marketType = YXMarketType.init(rawValue: market.lowercased())
        requestModel.exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK).rawValue

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { (responseModel) in

            if responseModel.code == .success, let data = responseModel.data as? [String : Any] {

                var timeString = ""
                if let timeStr = data["time"] as? String {
                    timeString = timeStr
                } else if let timeNum = data["time"] as? NSNumber {
                    timeString = "\(timeNum)"
                }

                let interval = YXDateHelper.unixTime(from: timeString, formatter: "yyyyMMddHHmmss")

                completion(timeString, interval)
            }

        }, failure: { (request) in

        })
    }
}


@objcMembers class YXTradeOrderPreAfterStatusInfo: NSObject {

    var isShowTradeStatus = false
    var tradeStatusTips = ""
    var cantTradeReasonTips = ""
    var cantTradeReasonNo = 0

}


@objcMembers class YXTradeOrderConditionDateStatus: NSObject {

    var title = ""
    var msg = "--"
    var yearMsg = ""
    var date: String = ""
    var index = 0
}
