//
//  YXTradeAccountItemsView.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/12/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeAccountItemsView: UIView {
    
    typealias ClosureClick = () -> Void
    
    
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
   
    // 专业投资者
    @objc var onClickProfessionalFlow: ClosureClick?
    
    // pro引导
    @objc var onClickGoProFlow: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "accounts")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    lazy var professionalButton: YXTradeItemSubView = { //专业投资者
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_professional", text: YXLanguageUtility.kLang(key: "common_pi"))
        return view
    }()
    
    lazy var goProButton: YXTradeItemSubView = { //高级账户
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_gopro", text: YXLanguageUtility.kLang(key: "account_pro"))
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
        
        self.addSubview(self.professionalButton)
        self.addSubview(self.goProButton)
        self.addSubview(self.placeholderButton)
        self.addSubview(self.placeholderButton2)
        
        let firstBtns = [professionalButton, goProButton, placeholderButton, placeholderButton2]
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(itemHeight)//50
        }
        
        addTapGestureWith(view: self.professionalButton, sel: #selector(professionalAction))
        addTapGestureWith(view: self.goProButton, sel: #selector(proAction))
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func professionalAction() {
        if let closure = onClickProfessionalFlow {
            closure()
        }
    }
    
    @objc func proAction() {
        if let closure = onClickGoProFlow {
            closure()
        }
    }
}


