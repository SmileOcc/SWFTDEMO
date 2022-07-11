//
//  YXSmartViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXSmartViewController: YXSwipeViewController  {

    var smartType: YXSmartType!
    var navigator: NavigatorServicesType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "smart_watch")
        self.hidesBottomBarWhenPushed = true
        let selfStockVC = YXSmartMyStockViewController()
        selfStockVC.viewModel = YXSmartViewModel()
        selfStockVC.viewModel.services = SmartService(smartService: YXSmartService(), quotesDataService: YXQuotesDataService())
        selfStockVC.viewModel.smartType = YXSmartType.selfStock
        selfStockVC.viewModel.navigator = self.navigator
        
        let stockPositionVC = YXSmartMyStockViewController()
        stockPositionVC.viewModel = YXSmartViewModel()
        stockPositionVC.viewModel.services = SmartService(smartService: YXSmartService(), quotesDataService: YXQuotesDataService())
        stockPositionVC.viewModel.smartType = YXSmartType.stockPosition
        stockPositionVC.viewModel.navigator = self.navigator
        
        self.viewControllersArray = [selfStockVC, stockPositionVC]
        self.titlesArray = [YXLanguageUtility.kLang(key: "smart_selfStock"), YXLanguageUtility.kLang(key: "smart_myPosition")]
        
        if smartType == YXSmartType.stockPosition {
            currentPageIndex = 1
        }
    }
    
    override var currentPageIndex: Int {
        willSet {
            if newValue == 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem()
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "smart_setting"), style: .plain, target: self, action: #selector(handleRightAction))
            }
        }
    }
    
    @objc func handleRightAction() {
        var smartType = YXSmartType.selfStock
        if currentPageIndex == 1 {
            smartType = YXSmartType.stockPosition
        }

        self.navigator.push(YXModulePaths.smartSettings.url, context: smartType)
    }
    
}
