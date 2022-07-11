//
//  YXTradeItemsView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeTradeItemsView: UIView {
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    private var showGrey = false
    
    typealias ClosureClick = () -> Void
    
    // 交易
    @objc var onClickTrade: ClosureClick?
    
    // 月供股票
    @objc var onClickMonthly: ClosureClick?
    
    // 新股认购
    //@objc var onClickNewStock: ClosureClick?
    
    // 转入股票
    //@objc var onClickShiftIn: ClosureClick?
    
    // 基金交易
    @objc var onClickTradeFund: ClosureClick?
    
    // 专业投资者
    //@objc var onClickProfessionalFlow: ClosureClick?
    
    // 债券
    @objc var onClickBond: ClosureClick?
    
    @objc var onClickGrey: ClosureClick?
      
    @objc var onClickOrder: ClosureClick?
      
    @objc var onClickSmartTrade: ClosureClick?
    
    @objc var onClickConditionOrder: ClosureClick?
    
    @objc var onClickSmartOrder: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "hold_trade_title")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    // 买入
    lazy var tradeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_trade", text: YXLanguageUtility.kLang(key: "hold_trade_title"))
        addTapGestureWith(view: view, sel: #selector(tradeAction))
        return view
    }()
    
    // 智選基金
    lazy var tradeFundBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_fund", text: YXLanguageUtility.kLang(key: "hold_trade_fund"))
        addTapGestureWith(view: view, sel: #selector(tradeFundAction))
        return view
    }()
    
    // 月供股票
    lazy var monthlyBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_monthly", text: YXLanguageUtility.kLang(key: "hold_monthly"))
        addTapGestureWith(view: view, sel: #selector(monthlyAction))
        return view
    }()
    
    
    //    // 新股认购
    //    lazy var newStockBtn: YXTradeItemSubView = {
    //        let view = YXTradeItemSubView(frame: CGRect.zero)
    //        view.updateWith("hold_ipo", text: YXLanguageUtility.kLang(key: "hold_new_stock"))
    //
    //        return view
    //    }()
    
    
    //    // 转入股票
    //    lazy var shiftinBtn: YXTradeItemSubView = {
    //        let view = YXTradeItemSubView(frame: CGRect.zero)
    //        view.updateWith("hold_shiftin", text: YXLanguageUtility.kLang(key: "hold_shiftin"))
    //
    //        return view
    //    }()
    
    // 债券
    lazy var bondBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_bond", text: YXLanguageUtility.kLang(key: "hold_bond_buy"))
        addTapGestureWith(view: view, sel: #selector(bondAction))
        return view
    }()
    
    //    //新股认购的标签
    //    lazy var newStockTagView: QMUIPopupContainerView = {
    //        let view = QMUIPopupContainerView()
    //        view.backgroundColor = UIColor.qmui_color(withHexString: "#F86D6D")
    //        view.shadowColor = UIColor.white
    //        view.borderColor = UIColor.qmui_color(withHexString: "#F86D6D")
    //        view.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    //        view.cornerRadius = 4
    //        view.textLabel.font = UIFont.systemFont(ofSize: 12)
    //        view.textLabel.textColor = UIColor.white
    //        view.arrowSize = CGSize(width: 9, height: 7)
    //        view.sourceView = self.newStockTagSourceView
    //        view.isUserInteractionEnabled = false
    //        view.isHidden = true
    //        self.addSubview(view)
    //        return view
    //    }()
    //
    //    //新股认购的标签
    //    lazy var newStockTagSourceView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = UIColor.clear
    //        return view
    //    }()
    
    lazy var orderBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_order", text: YXLanguageUtility.kLang(key: "hold_orders"))
        addTapGestureWith(view: view, sel: #selector(orderAction))
        return view
    }()
    
    lazy var smartOrderBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_smart_order", text: YXLanguageUtility.kLang(key: "hold_smart_order"))
        addTapGestureWith(view: view, sel: #selector(smartOrderAction))
        return view
    }()
    
    lazy var conditionOrderBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_condition", text: YXLanguageUtility.kLang(key: "condition_order"))
        addTapGestureWith(view: view, sel: #selector(conditionOrderAction))
        return view
    }()
    
    //智能下单
    lazy var smartTradeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_smart", text: YXLanguageUtility.kLang(key: "hold_smart"))
        addTapGestureWith(view: view, sel: #selector(smartTradeAction))
        return view
    }()
    
    //暗盘
    lazy var greyBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_grey", text: YXLanguageUtility.kLang(key: "grey_mkt"))
        addTapGestureWith(view: view, sel: #selector(greyAction))
        return view
    }()
    
    lazy var placeholderButton: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        view.isHidden = true
        return view
    }()
    
    lazy var placeholderButton2: YXTradeItemSubView = {//占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        view.isHidden = true
        return view
    }()
    
    lazy var placeholderButton3: YXTradeItemSubView = {//占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        view.isHidden = true
        return view
    }()
    
    lazy var defaultHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return 50
    }()
    
    lazy var itemHeight: CGFloat = {
        50
    }()
    
    required init(frame: CGRect, exchangeType: YXExchangeType, showGrey: Bool) {
        super.init(frame: frame)
        // 当前市场类型
        self.exchangeType = exchangeType
        self.showGrey = showGrey
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        isUserInteractionEnabled = true
        
        addSubview(markView)
        addSubview(titleLabel)
        
        addSubview(tradeBtn)
        addSubview(smartTradeBtn)
        addSubview(monthlyBtn)
        
        addSubview(orderBtn)
        addSubview(smartOrderBtn)
        addSubview(conditionOrderBtn)
        addSubview(placeholderButton)
        addSubview(placeholderButton2)
        addSubview(placeholderButton3)
        addSubview(tradeFundBtn)
        
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
        
        var firstBtns = [YXTradeItemSubView]()
        var secondBtns = [YXTradeItemSubView]()
        if exchangeType == .hk, showGrey == true {
            addSubview(greyBtn)
            firstBtns = [tradeBtn, smartTradeBtn, monthlyBtn, greyBtn]
            secondBtns = [orderBtn, smartOrderBtn, conditionOrderBtn, tradeFundBtn]
        } else if exchangeType == .us, YXUserManager.isGray(with: .bond) {
            addSubview(bondBtn)
            firstBtns = [tradeBtn, smartTradeBtn, monthlyBtn, bondBtn]
            secondBtns = [orderBtn, smartOrderBtn, conditionOrderBtn, tradeFundBtn]
        } else if exchangeType == .hk || exchangeType == .us {
            firstBtns = [tradeBtn, smartTradeBtn, monthlyBtn, orderBtn]
            secondBtns = [smartOrderBtn, conditionOrderBtn, tradeFundBtn, placeholderButton]
        }  else {
            monthlyBtn.isHidden = true
            tradeFundBtn.isHidden = true
            firstBtns = [tradeBtn, smartTradeBtn, orderBtn, smartOrderBtn]
            secondBtns = [conditionOrderBtn, placeholderButton, placeholderButton2, placeholderButton3]
        }
        
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(defaultHeight)//50
        }
        
        secondBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        secondBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.tradeBtn.snp.bottom).offset(12)
            make.height.equalTo(itemHeight)//50
        }
        
        // 港股
        //        if marketType == .HK || marketType == .US {
        //            let firstBtns = [tradeBtn, monthlyBtn, newStockBtn, shiftinBtn]
        //            firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        //            firstBtns.snp.makeConstraints { (make) in
        //                make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
        //                make.height.equalTo(itemHeight)//50
        //            }
        //
        //            var showBond = false
        //            var showFund = false
        //            if YXUserManager.isGray(with: .fund) {
        //                showFund = true
        //                addSubview(tradeFundBtn)
        //                addTapGestureWith(view: self.tradeFundBtn, sel: #selector(tradeFundAction))
        //            }
        //            if YXUserManager.isGray(with: .bond) && marketType == .US {
        //                showBond = true
        //                addSubview(bondBtn)
        //                addTapGestureWith(view: bondBtn, sel: #selector(bondAction))
        //            }
        //
        //            if showFund, showBond {
        //                self.tradeFundBtn.snp.makeConstraints { (make) in
        //                    make.top.equalTo(self.tradeBtn.snp.bottom).offset(18)
        //                    make.size.left.equalTo(self.tradeBtn)
        //                }
        //
        //                self.bondBtn.snp.makeConstraints { (make) in
        //                    make.top.equalTo(self.tradeFundBtn)
        //                    make.size.left.equalTo(self.monthlyBtn)
        //                }
        //
        //            } else if showFund {
        //                self.tradeFundBtn.snp.makeConstraints { (make) in
        //                    make.top.equalTo(self.tradeBtn.snp.bottom).offset(18)
        //                    make.size.equalTo(self.tradeBtn.snp.size)
        //                    make.left.equalTo(self.tradeBtn.snp.left)
        //                }
        //
        //            } else if showBond {
        //                self.bondBtn.snp.makeConstraints { (make) in
        //                    make.top.equalTo(self.tradeBtn.snp.bottom).offset(18)
        //                    make.size.equalTo(self.tradeBtn.snp.size)
        //                    make.left.equalTo(self.tradeBtn.snp.left)
        //                }
        //
        //            } else {
        //
        //            }
        //        } else {
        //            // A股
        //            self.addSubview(self.placeholderButton)
        //            self.addSubview(self.placeholderButton2)
        //            let firstBtns = [self.tradeBtn, self.shiftinBtn, self.placeholderButton, self.placeholderButton2]
        //            firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        //            firstBtns.snp.makeConstraints { (make) in
        //                make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
        //                make.height.equalTo(itemHeight)//50
        //            }
        //            self.newStockBtn.isHidden = true
        //            self.monthlyBtn.isHidden = true
        //        }
        //
        //        addTapGestureWith(view: self.tradeBtn, sel: #selector(tradeAction))
        //        addTapGestureWith(view: self.monthlyBtn, sel: #selector(monthlyAction))
        //        addTapGestureWith(view: self.newStockBtn, sel: #selector(newStockAction))
        //        addTapGestureWith(view: self.shiftinBtn, sel: #selector(shiftinAction))
        //
        //        addSubview(newStockTagSourceView)
        //        newStockTagSourceView.snp.makeConstraints { (make) in
        //            make.width.height.equalTo(10)
        //            make.centerX.equalTo(self.newStockBtn)
        //            make.top.equalTo(self.newStockBtn.snp.top).offset(12)
        //        }
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func tradeAction() {
        if let closure = onClickTrade {
            closure()
        }
    }
    
    @objc func monthlyAction() {
        if let closure = onClickMonthly {
            closure()
        }
    }
    
    //    @objc func newStockAction() {
    //        if let closure = onClickNewStock {
    //            closure()
    //        }
    //    }
    
    //    @objc func shiftinAction() {
    //        if let closure = onClickShiftIn {
    //            closure()
    //        }
    //    }
    @objc func greyAction() {
        if let closure = onClickGrey {
            closure()
        }
    }
    
    @objc func orderAction() {
        if let closure = onClickOrder {
            closure()
        }
    }
    
    @objc func smartOrderAction() {
        if let closure = onClickSmartOrder {
            closure()
        }
    }
    
    @objc func smartTradeAction() {
        if let closure = onClickSmartTrade {
            closure()
        }
    }
    
    @objc func conditionOrderAction() {
        if let closure = onClickConditionOrder {
            closure()
        }
    }
    
    @objc func tradeFundAction() {
        if let closure = onClickTradeFund {
            closure()
        }
    }
    
    @objc func bondAction() {
        if let closure = onClickBond {
            closure()
        }
    }
}

