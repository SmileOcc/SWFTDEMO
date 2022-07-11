//
//  YXQueryEntruesOrderResponseModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXQueryEntruesOrderResponseModel: YXResponseModel {
    @objc var businessAmount: Int = 0
    @objc var businessAveragePrice: Int = 0
    @objc var conId: Int64 = 0
    @objc var createDate: String = ""
    @objc var createTime: String = ""
    @objc var dayEnd: Int32 = 0
    @objc var entrustAmount: Int = 0
    @objc var entrustId: String = ""
    @objc var entrustNo: String = ""
    @objc var entrustPrice: Int = 0
    @objc var entrustProp: String = ""
    @objc var entrustType: Int32 = 0
    @objc var exchangeType: Int32 = 0
    @objc var finalStateFlag: String = ""
    @objc var flag: String = ""
    @objc var moneyType: Int32 = 0
    @objc var sessionType: Int32 = 0
    @objc var status: Int32 = 0
    @objc var statusName: String = ""
    @objc var stockCode: String = ""
    @objc var stockName: String = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        [
            "businessAmount": "data.businessAmount",
            "businessAveragePrice": "data.businessAveragePrice",
            "conId": "data.conId",
            "createDate": "data.createDate",
            "createTime": "data.createTime",
            "dayEnd": "data.dayEnd",
            "entrustAmount": "data.entrustAmount",
            "entrustId": "data.entrustId",
            "entrustNo": "data.entrustNo",
            "entrustPrice": "data.entrustPrice",
            "entrustProp": "data.entrustProp",
            "entrustType": "data.entrustType",
            "exchangeType": "data.exchangeType",
            "finalStateFlag": "data.finalStateFlag",
            "flag": "data.flag",
            "moneyType": "data.moneyType",
            "sessionType": "data.sessionType",
            "status": "data.status",
            "statusName": "data.statusName",
            "stockCode": "data.stockCode",
            "stockName": "data.stockName",
        ];
    }
}
