//
//  YXMarginManager.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMarginManager: NSObject {
    @objc public static let shared = YXMarginManager()
    func requestUserAccType(boker:String,finishBlock: @escaping ((YXTradeAccountResponse) -> Void)) {
        if boker == YXBrokersBitType.dolph.brokerNo()  {
            return
        }
        let  requestModel = YXTradeAccountRequest()
        requestModel.BrokerNo = boker
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock { respons in
            if respons.code == .success{
                if let res = respons as? YXTradeAccountResponse {
                    if res.accountType == "CASH" {
                        YXUserManager.shared().brokerAccountType = .cash
                    }else if res.accountType == "MARGIN"{
                        YXUserManager.shared().brokerAccountType = .financing

                        // 现金升级到保证金账户后通知交易页更新数据
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "YXBrokerAccountTypeDidChangeNotification"),
                            object: nil
                        )
                    }
                    
                    finishBlock(res)
                }
            }
        } failure: { requet in
            
        }
    }
    func requsetStockCanMargin(stockCode:String,market:String, finishBlock: @escaping ((YXCconfigMortgageRateQueryResModel?) -> Void))  {
        
        let requestModel = YXCconfigMortgageRateQueryReqModel()
        requestModel.stockCode = stockCode
        requestModel.exchangeType = market.uppercased()
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (responseModel)  in
            if (responseModel.code == .success) {
                if let res = YXCconfigMortgageRateQueryResModel.yy_model(withJSON: responseModel.data){
                    finishBlock(res)
                }
            } else {
                finishBlock(nil)
            }
        }) { (request) in
            finishBlock(nil)
        }
    }
}
