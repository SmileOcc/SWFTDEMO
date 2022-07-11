//
//  YXGotoTradeCommonLogic.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

class YXGotoTradeCommonLogic {
    lazy var sheet:YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightBtnOnlyImage(iamge: UIImage.init(named: "nav_info"))
        sheet.rightButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true) { (finish) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.smartHelpUrl())
                }
            }
        }
        sheet.leftButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true)
            }
        }
        sheet.titleLabel.text = YXLanguageUtility.kLang(key: "account_stock_order_title")
        return sheet
    }()
    
    func gotoSmartTrade(model: TradeModel) {
        let viewModel = YXSmartTradeGuideViewModel(services:NavigatorServices.shareInstance, params:["tradeModel": model])
        let vc = YXSmartTradeGuideViewController(viewModel: viewModel)
        sheet.showViewController(vc: vc)
    }
    
    func gotoTrade(model: TradeModel) {
        YXTradeManager.getOrderType(market: model.market) { orderType in
            
            let tradeModel = model
            tradeModel.tradeOrderType = orderType

            let viewModel = YXTradeViewModel(services: NavigatorServices.shareInstance, params: ["tradeModel": tradeModel])
            NavigatorServices.shareInstance.push(viewModel, animated: true)
        }
    }
}
