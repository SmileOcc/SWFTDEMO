//
//  YXStockLandDealAndAskBidView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockLandDealAndAskBidView: UIView {
    
    var posBroker: PosBroker? {
        didSet {
            refreshUI()
        }
    }
    
    var isOnlyTick: Bool = false {
        didSet {
            if isOnlyTick {
                self.tabView.titles = [YXLanguageUtility.kLang(key: "stock_detail_quote_tricker")]
                self.bidView.isHidden = true
                self.tickView.isHidden = false
                self.tabView.defaultSelectedIndex = 0
                self.tabView.reloadData()
            } else {
                if market == kYXMarketHK || market == kYXMarketSG {
                    self.tabView.titles = [YXLanguageUtility.kLang(key: "stock_detail_buying"), YXLanguageUtility.kLang(key: "stock_detail_quote_tricker")]
                } else {
                    self.tabView.titles = [YXLanguageUtility.kLang(key: "stock_detail_buying"), YXLanguageUtility.kLang(key: "stock_detail_tricker")]
                }
                self.tabView.reloadData()
            }
        }
    }
    
    func refreshUI() -> Void {
        guard let posBroker = posBroker else {
            return
        }

        if let market = posBroker.market, market == kYXMarketCryptos {

//            let position: [BTOrderBookItem]? = quoteModel.btOrderBook?.items
//            guard let finalPostion = position, finalPostion.count > 0 else {
//                return
//            }

//            self.bidView.decimalCount = YXToolUtility.btDecimalPoint(quoteModel.btRealTime?.now)
//            self.bidView.pClose = Double(posBroker.btRealTime?.preClose ?? "0") ?? 0
//            self.bidView.items = finalPostion

        } else {
            let position: [PosData]? = posBroker.pos?.posData

            guard let finalPostion = position, finalPostion.count > 0 else {
                return
            }

            self.bidView.pClose = Double(self.posBroker?.preClose?.value ?? 0)
            self.bidView.priceBase = Int(self.posBroker?.priceBase?.value ?? 0)
            self.bidView.list = finalPostion
        }

    }
    
    lazy var bidView: YXStockLandBidView = {
        let view = YXStockLandBidView.init(frame: .zero, self.market)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var tickView: YXStockDetailDealView = {
        let view =  YXStockDetailDealView.init(frame: .zero, market: self.market, isLandScape: true)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    var market: String = "hk"

    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = true
        tabLayout.titleFont = .systemFont(ofSize: 12)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 12, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        if YXUserManager.curLanguage() == .ML || YXUserManager.curLanguage() == .TH {
            tabLayout.titleFont = .systemFont(ofSize: 10)
            tabLayout.titleSelectedFont = .systemFont(ofSize: 10, weight: .medium)
        }
        
        tabLayout.tabWidth = 70
        tabLayout.lrMargin = 0
        tabLayout.tabMargin = 0
        if self.market == kYXMarketCryptos {
            tabLayout.tabWidth = 100
        }

        let tabView = YXTabView(frame: .zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.delegate = self

        var titles: [String] = []
        if market == kYXMarketHK || market == kYXMarketSG {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_buying"), YXLanguageUtility.kLang(key: "stock_detail_quote_tricker")]
        } else {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_buying"), YXLanguageUtility.kLang(key: "stock_detail_tricker")]
        }

        tabView.titles = titles
        return tabView
    }()
    
    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        self.market = market
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isGreyFlag: Bool = false {
        didSet {
            if isGreyFlag {
                tabView.titles = [YXLanguageUtility.kLang(key: "stock_detail_buying"), YXLanguageUtility.kLang(key: "stock_detail_quote_tricker")]
                tabView.reloadData()
            }
        }
    }
    
    func initUI() {
        tickView.isHidden = true
        addSubview(tickView)
        addSubview(bidView)

        let bottomMargin: CGFloat = (YXConstant.deviceScaleEqualToXStyle() ? 10 : 0)

        addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview()
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.height.equalTo(0.5)
        }

        let leftLineView = UIView()
        leftLineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(leftLineView)
        leftLineView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(0.5)
        }

        bidView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }

        tickView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }

    }

}

extension YXStockLandDealAndAskBidView: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        guard !self.isOnlyTick else {
            return
        }
        self.bidView.isHidden = index != 0
        self.tickView.isHidden = index == 0
    }
}
