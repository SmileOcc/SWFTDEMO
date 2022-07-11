//
//  YXIntradayTradeItemsView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayTradeItemsView: UIView {
    
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    typealias ClosureClick = () -> Void
    
    //交易
    @objc var onClickTrade: ClosureClick?
    //资金调拨
    @objc var onClickCapital: ClosureClick?
    
    //全部订单
    @objc var onClickAllOrder: ClosureClick?
    
    //资金流水
    @objc var onClickFund: ClosureClick?
    
    //资金流水
    @objc var onClickHistory: ClosureClick?
    
    // 买入
    lazy var tradeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_trade", text: YXLanguageUtility.kLang(key: "hold_trade_title"))
        addTapGestureWith(view: view, sel: #selector(tradeAction))
        return view
    }()
    
    // 交易订单
    lazy var orderBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_order", text: YXLanguageUtility.kLang(key: "hold_orders"))
        addTapGestureWith(view: view, sel: #selector(orderAction))
        return view
    }()
    
    
    lazy var capitalBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("trade_capital", text: YXLanguageUtility.kLang(key: "fund_allocation"))
        addTapGestureWith(view: view, sel: #selector(capitalAction))
        return view
    }()
    
    //资金流水
    lazy var fundBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_capital_flow", text: YXLanguageUtility.kLang(key: "hold_capital_flow"))
        addTapGestureWith(view: view, sel: #selector(fundAction))
        return view
    }()
    
    //资金流水
    lazy var holdHistoryBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("intraday_hold_history", text: YXLanguageUtility.kLang(key: "hold_intraday_history"))
        addTapGestureWith(view: view, sel: #selector(historyAction))
        return view
    }()
    
    lazy var defaultHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return 50
    }()
    
    lazy var itemHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return defaultHeight
    }()
    
    required init(frame: CGRect, exchangeType: YXExchangeType) {
        super.init(frame: frame)
        // 当前市场类型
        self.exchangeType = exchangeType
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        isUserInteractionEnabled = true
        
        addSubview(tradeBtn)
        addSubview(orderBtn)
        addSubview(capitalBtn)
        addSubview(fundBtn)
        addSubview(holdHistoryBtn)
        
        let buttons = [tradeBtn, orderBtn, capitalBtn, fundBtn, holdHistoryBtn]
        buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 20, tailSpacing: 20)
        buttons.snp.makeConstraints { (make) in
            make.top.equalTo(20);
            make.height.equalTo(defaultHeight)
        }
        
    }
    
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    
    @objc func fundAction() {
        if let closure = onClickFund {
            closure()
        }
    }
    
    @objc func capitalAction() {
        if let closure = onClickCapital {
            closure()
        }
    }
    
    @objc func orderAction() {
        if let closure = onClickAllOrder {
            closure()
        }
    }
    
    @objc func tradeAction() {
        if let closure = onClickTrade {
            closure()
        }
    }
    
    @objc func historyAction() {
        if let closure = onClickHistory {
            closure()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
