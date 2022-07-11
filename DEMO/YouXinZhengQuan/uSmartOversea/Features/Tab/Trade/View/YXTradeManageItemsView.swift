//
//  YXTradeManagerItemView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/5/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeManageItemsView: UIView {

    typealias ClosureClick = () -> Void
      
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    // 选股选息
    @objc var onClickStockSelection: ClosureClick?
    
    // 供股选择
    @objc var onClickStockOption: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "trade_equity_mgt")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    lazy var stockSelectionButton: YXTradeItemSubView = { //专业投资者
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_stockselection", text: YXLanguageUtility.kLang(key: "trade_stock_interest"))
        return view
    }()
    
    lazy var stockOptionButton: YXTradeItemSubView = { //高级账户
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_stockoption", text: YXLanguageUtility.kLang(key: "trade_rights_issues"))
        return view
    }()
    
    lazy var placeholderButton: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var placeholderButton2: YXTradeItemSubView = {//占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var itemHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return 50
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
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.markView)
        self.addSubview(self.titleLabel)
        
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
        
        self.addSubview(self.stockSelectionButton)
        self.addSubview(self.stockOptionButton)
        self.addSubview(self.placeholderButton)
        self.addSubview(self.placeholderButton2)
        
        let firstBtns = [stockSelectionButton, stockOptionButton, placeholderButton, placeholderButton2]
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(itemHeight)//50
        }
        
        addTapGestureWith(view: self.stockSelectionButton, sel: #selector(stockSelectionAction))
        addTapGestureWith(view: self.stockOptionButton, sel: #selector(stockOptionAction))
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func stockSelectionAction() {
        if let closure = onClickStockSelection {
            closure()
        }
    }
    
    @objc func stockOptionAction() {
        if let closure = onClickStockOption {
            closure()
        }
    }

}
