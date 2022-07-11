//
//  YXNewStockListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

///title：认购记录
class YXNewStockListViewController: YXSwipeViewController, UIGestureRecognizerDelegate {

    var exchangeType: YXExchangeType = .hk
    var navigator: NavigatorServicesType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "newStock_purchase_list")        
        let hkVC = YXNewStockPurchaseListViewController()
        hkVC.viewModel.exchangeType = .hk
        hkVC.viewModel.navigator = self.navigator

//        let dic: [String: Any] = [
//            YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEW_STOCK_SUBSCRIBE_RECORD_URL()
//        ]
//        let webViewModel = YXWebViewModel(dictionary: dic)
//        let hkVC = YXNewStockHKRecordWebVC.instantiate(withViewModel: webViewModel, andServices: WebServices(webService: YXWebService(), newsService: YXNewsService()), andNavigator: self.navigator)

        let usVC = YXNewStockPurchaseListViewController()
        usVC.viewModel.exchangeType = .us
        usVC.viewModel.navigator = self.navigator
        
        self.viewControllersArray = [hkVC, usVC]
        self.titlesArray = [YXLanguageUtility.kLang(key: "hold_hk_account"), YXLanguageUtility.kLang(key: "hold_us_account")]
        
        let config = YXSwipeBarConfig(segmentViewHeight: 48, lineHeight: 2, lineWidth: 46, lineBottomMargin: 8, lineColor: QMUITheme().themeTextColor(), normalTitleColor: QMUITheme().textColorLevel2(), selectTitleColor: QMUITheme().themeTextColor(), normalTitleFont: UIFont.systemFont(ofSize: 16), selectTitleFont: UIFont.systemFont(ofSize: 16))
        self.config = config
        
        if exchangeType == .us {
            currentPageIndex = 1
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "nav_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLeftAction))
        self.navigationItem.rightBarButtonItems = [messageItem]

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func handleLeftAction() {
        
        var isFind: Bool = false
        
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers.reversed() {
                if vc.isKind(of: YXNewStockDetailViewController.self) {
                    isFind = true
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                } else if vc.isKind(of: YXNewStockCenterViewController.self) {
                    isFind = true
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
        
        if !isFind {
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}


struct WebServices: HasYXWebService, HasYXNewsService {
    let webService: YXWebService
    let newsService: YXNewsService
}
