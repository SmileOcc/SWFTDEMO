//
//  YXTradeFundsItemsView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeFundsItemsView: UIView {
    
    typealias ClosureClick = () -> Void
    
    // 存入资金
    @objc var onClickDespositFunds: ClosureClick?
    
    // 货币兑换
    @objc var onClickExchangeCurrency: ClosureClick?
    
    // 提取资金
    @objc var onClickWithdrawFunds: ClosureClick?
    
    // 历史记录
    @objc var onClickHistory: ClosureClick?
    
    // 资金流水
    @objc var onClickCapitalFlow: ClosureClick?
    // 资金流水
    @objc var onClickCapital: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "hold_trade_funds")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()

    // 存入资金
    lazy var depositFundsBtn: QMUIButton = {
        let depositFundsBtn = QMUIButton()
        depositFundsBtn.imagePosition = .top
        depositFundsBtn.setTitle(YXLanguageUtility.kLang(key: "hold_deposit_funds"), for: .normal)
        depositFundsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        depositFundsBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        depositFundsBtn.setImage(UIImage(named: "hold_deposit_funds"), for: .normal)
        depositFundsBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        depositFundsBtn.titleLabel?.minimumScaleFactor = 0.3
        depositFundsBtn.spacingBetweenImageAndTitle = 6
        return depositFundsBtn
    }()
    
    // 货币兑换
    lazy var exchangeCurrencyBtn: QMUIButton = {
        let exchangeCurrencyBtn = QMUIButton()
        exchangeCurrencyBtn.imagePosition = .top
        exchangeCurrencyBtn.setTitle(YXLanguageUtility.kLang(key: "hold_exchange_currency"), for: .normal)
        exchangeCurrencyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        exchangeCurrencyBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        exchangeCurrencyBtn.setImage(UIImage(named: "hold_exchange_currency"), for: .normal)
        exchangeCurrencyBtn.spacingBetweenImageAndTitle = 6
        exchangeCurrencyBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        exchangeCurrencyBtn.titleLabel?.minimumScaleFactor = 0.3
        return exchangeCurrencyBtn
    }()
    
    // 提取资金
    lazy var withdrawFundsBtn: QMUIButton = {
        let withdrawFundsBtn = QMUIButton()
        withdrawFundsBtn.imagePosition = .top
        withdrawFundsBtn.setTitle(YXLanguageUtility.kLang(key: "hold_withdraw_funds"), for: .normal)
        withdrawFundsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        withdrawFundsBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        withdrawFundsBtn.setImage(UIImage(named: "hold_withdraw_funds"), for: .normal)
        withdrawFundsBtn.spacingBetweenImageAndTitle = 6
        withdrawFundsBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        withdrawFundsBtn.titleLabel?.minimumScaleFactor = 0.3
        return withdrawFundsBtn
    }()
    
    // 历史记录
    lazy var historyBtn: QMUIButton = {
        let historyBtn = QMUIButton()
        historyBtn.imagePosition = .top
        historyBtn.setTitle(YXLanguageUtility.kLang(key: "hold_history"), for: .normal)
        historyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        historyBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        historyBtn.setImage(UIImage(named: "hold_history"), for: .normal)
        historyBtn.spacingBetweenImageAndTitle = 6
        historyBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        historyBtn.titleLabel?.minimumScaleFactor = 0.3
        return historyBtn
    }()
    
    // 资金流水
    lazy var capitalFlowBtn: QMUIButton = {
        let capitalFlowBtn = QMUIButton()
        capitalFlowBtn.imagePosition = .top
        capitalFlowBtn.setTitle(YXLanguageUtility.kLang(key: "hold_capital_flow"), for: .normal)
        capitalFlowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        capitalFlowBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        capitalFlowBtn.setImage(UIImage(named: "hold_capital_flow"), for: .normal)
        capitalFlowBtn.spacingBetweenImageAndTitle = 6
        capitalFlowBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        capitalFlowBtn.titleLabel?.minimumScaleFactor = 0.3
        return capitalFlowBtn
    }()
    
    lazy var capitalBtn: QMUIButton = {
        let capitalFlowBtn = QMUIButton()
        capitalFlowBtn.imagePosition = .top
        capitalFlowBtn.setTitle(YXLanguageUtility.kLang(key: "fund_allocation"), for: .normal)
        capitalFlowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        capitalFlowBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        capitalFlowBtn.setImage(UIImage(named: "trade_capital"), for: .normal)
        capitalFlowBtn.spacingBetweenImageAndTitle = 6
        capitalFlowBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        capitalFlowBtn.titleLabel?.minimumScaleFactor = 0.3
        return capitalFlowBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.addSubview(self.markView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.depositFundsBtn)
        self.addSubview(self.withdrawFundsBtn)
        self.addSubview(self.exchangeCurrencyBtn)
        self.addSubview(self.historyBtn)
        self.addSubview(self.capitalFlowBtn)
        self.addSubview(self.capitalBtn)
        
        self.markView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(17)
            make.width.equalTo(4)
            make.height.equalTo(14)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.markView)
            make.left.equalTo(self.markView.snp.right).offset(7)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-8)
        }
        
        let firstBtns = [self.depositFundsBtn, self.withdrawFundsBtn, self.exchangeCurrencyBtn, self.historyBtn]
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(50)
        }
        
        
        self.capitalFlowBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.depositFundsBtn.snp.bottom).offset(18)
            make.size.equalTo(self.depositFundsBtn.snp.size)
            make.left.equalTo(self.depositFundsBtn.snp.left)
        }
        
        self.capitalBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.withdrawFundsBtn.snp.bottom).offset(18)
            make.size.equalTo(self.withdrawFundsBtn.snp.size)
            make.left.equalTo(self.withdrawFundsBtn.snp.left)
        }

        self.depositFundsBtn.addTarget(self, action: #selector(depositFundsAction(sender:)), for: .touchUpInside)
        
        self.exchangeCurrencyBtn.addTarget(self, action: #selector(exchangeCurrencyAction(sender:)), for: .touchUpInside)
        
        self.withdrawFundsBtn.addTarget(self, action: #selector(withdrawAction(sender:)), for: .touchUpInside)
        
        self.historyBtn.addTarget(self, action: #selector(historyAction(sender:)), for: .touchUpInside)
        
        self.capitalFlowBtn.addTarget(self, action: #selector(capitalFlowAction(sender:)), for: .touchUpInside)
        
        self.capitalBtn.addTarget(self, action: #selector(capitalAction(sender:)), for: .touchUpInside)
    }
    
    @objc func depositFundsAction(sender: UIButton) {
        if let closure = onClickDespositFunds {
            closure()
        }
    }
    
    @objc func exchangeCurrencyAction(sender: UIButton) {
        if let closure = onClickExchangeCurrency {
            closure()
        }
    }
    
    @objc func withdrawAction(sender: UIButton) {
        if let closure = onClickWithdrawFunds {
            closure()
        }
    }
    
    @objc func historyAction(sender: UIButton) {
        if let closure = onClickHistory {
            closure()
        }
    }
    
    @objc func capitalFlowAction(sender: UIButton) {
        if let closure = onClickCapitalFlow {
            closure()
        }
    }
    
    @objc func capitalAction(sender: UIButton) {
        if let closure = onClickCapital {
            closure()
        }
    }
}
