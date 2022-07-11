//
//  YXQuoteWebVC.swift
//  uSmartOversea
//
//  Created by youxin on 2021/7/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
import UIKit
import WebKit
import YXKit
import MJRefresh
import QMUIKit
import RxSwift

class YXQuoteWebVC: YXWebViewController {
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
    var quoteViewModel: YXQuoteWebViewModel?
    var quoteRequest: YXQuoteRequest?
    var topHeight: CGFloat = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quoteViewModel = self.viewModel as? YXQuoteWebViewModel
        
        view.addSubview(self.stockView)
        self.stockView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(topHeight)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(self.view).offset(YXConstant.navBarHeight())
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWebviewFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let market = self.quoteViewModel?.market, let symbol = self.quoteViewModel?.symbol {
            
            let secu = Secu.init(market: market, symbol: symbol)
            let level = YXUserManager.shared().getLevel(with: market)
            self.quoteRequest?.cancel()
            self.quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [secu], level: level, handler: { [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                let quote = quotes.first
                
                self.stockView.model = quote
            })
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.quoteRequest?.cancel()
    }
    
    override func topGap() -> CGFloat {
        0
    }
    
    override func bottomGap() -> CGFloat {
        return 0
    }
    
    override func webViewFrame() -> CGRect {
        return CGRect.init(x: 0, y: topHeight + YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - topHeight - self.bottomGap())
    }
    
    override func progressViewFrame() -> CGRect {
        return CGRect(x: 0, y: topHeight + YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: 2)
    }
    
    override func addRealWebView() {
        super.addRealWebView()
        
        updateWebviewFrame() //重新指定webView?.frame
        self.progressView?.frame = self.progressViewFrame()
        
        self.view.bringSubviewToFront(stockView)
        
    }
    
    
    func updateWebviewFrame() {
        self.webView?.frame = webViewFrame()
    }
    
    lazy var stockView: YXStockTopView = {
        let view = YXStockTopView()
        view.seperatorView.isHidden = false
        return view
    }()
    
}
