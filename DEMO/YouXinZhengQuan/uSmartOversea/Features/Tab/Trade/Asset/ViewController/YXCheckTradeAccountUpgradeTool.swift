//
//  YXCheckTradeAccountUpgradeTool.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2022/4/20.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

class YXCheckTradeAccountUpgradeTool {
    
    var checkingUpgrade = false
    
    //检查升级账户结果
    func checkIsNeedPrompt() {
        
        if checkingUpgrade {
            return
        }
        
        checkingUpgrade = true
        
        let requestModel = YXCheckIsNeedPromptRequestModel()
        
        let request = YXRequest(request: requestModel)
        
        let title = YXLanguageUtility.kLang(key: "hold_margin_upgrade_title")
        let text = YXLanguageUtility.kLang(key: "hold_margin_upgrade_success_new")
        
        request.startWithBlock(success: { [weak self] (responseModel) in
            if let res = responseModel as? YXCheckIsNeedPromptResponseModel, res.code == .success, res.shouldPrompt == 0 {
                
                self?.checkingUpgrade = false
                
                YXNewStockPurchaseUtility.noticeOneButtonAlert(title: title, msg: text) {
                    let requestModel = YXUpdatePromptRequestModel()
                    let request = YXRequest(request: requestModel)
                    request.startWithBlock(success: { (responseModel) in
                        YXUserManager.getUserInfo(complete: nil)
                    }, failure: { (request) in
                        YXUserManager.getUserInfo(complete: nil)
                    })
                }
            }
            
        }, failure: { [weak self] (request) in
            self?.checkingUpgrade = false
        })
    }
}
