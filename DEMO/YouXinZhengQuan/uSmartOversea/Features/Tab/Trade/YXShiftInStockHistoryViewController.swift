//
//  YXShiftInStockHistoryViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXShiftInStockHistoryViewController: YXWebViewController {

    var shiftInStockHistoryViewModel: YXShiftInStockHistoryViewModel {
        get {
            self.viewModel as! YXShiftInStockHistoryViewModel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        
        self.title = YXLanguageUtility.kLang(key: "hold_shiftin_history")
        
        let serviceItem = UIBarButtonItem.qmui_item(with: UIImage(named: "service") ?? UIImage(), target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [serviceItem]
        
        serviceItem.rx.tap.bind {[weak self] in
            self?.serviceAction()
            }.disposed(by: disposeBag)
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        
        let market = (self.shiftInStockHistoryViewModel.exchangeType == .hk ? kYXMarketHK : kYXMarketUS)
        if let url = URL.init(string: YXH5Urls.YX_SHIFTIN_STOCK_HISTORY_URL(market: market)) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }
}
