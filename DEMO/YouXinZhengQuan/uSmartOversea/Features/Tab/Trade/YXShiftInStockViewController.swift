//
//  YXShiftInStockViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXShiftInStockViewController: YXWebViewController {

    var shiftInViewModel: YXShiftInStockViewModel {
        get {
            self.viewModel as! YXShiftInStockViewModel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        
        self.title = YXLanguageUtility.kLang(key: "hold_shiftin_history")
        
        
        let serviceItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "hold_shiftin_view_history"), target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [serviceItem]
        
        serviceItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            self.shiftInViewModel.entryHitory()
            }.disposed(by: disposeBag)
    }
    
    override func setupWebView() {
        super.setupWebView()
        
        self.webView?.scrollView.mj_header = nil
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        let market = self.shiftInViewModel.exchangeType.market
        if let url = URL.init(string: YXH5Urls.YX_SHIFTIN_STOCK_URL(market: market)) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }
}
