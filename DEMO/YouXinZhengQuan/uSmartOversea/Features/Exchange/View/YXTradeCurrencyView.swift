//
//  YXTradeCurrencyView.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/1/30.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit


class YXTradeCurrencyView: UIView {

    typealias ClosureAction = () -> Void
    @objc var exchangeMarketClosure: ClosureAction?
    
    var selectCurrencyClosure: ((_ index: Int, _ currencyType: YXCurrencyType) -> Void)?

    @objc var currencyMarket = "";

    var leftCurrencyType: YXCurrencyType = .sg
    var rightCurrencyType: YXCurrencyType = .us

    private lazy var leftView: YXTradeCurrenySelectionView = {
        let view = YXTradeCurrenySelectionView()
        view.currencyButton.addTarget(self, action: #selector(selectCurrencyEvent(_:)), for: .touchUpInside)
        view.currencyButton.tag = 1
        return view
    }()
    
    @objc lazy var exchangeButton : UIButton = {
       let button = UIButton(type: .custom)
       button.setImage(UIImage(named: "currency_exchange"), for: .normal)
       button.addTarget(self, action: #selector(exchangeButtonEvent), for: .touchUpInside)
       return button
    }()

    private lazy var rightView: YXTradeCurrenySelectionView = {
        let view = YXTradeCurrenySelectionView()
        view.currencyButton.addTarget(self, action: #selector(selectCurrencyEvent(_:)), for: .touchUpInside)
        view.currencyButton.tag = 2
        return view
    }()

    @objc func exchangeButtonEvent() {
        if let closure = exchangeMarketClosure {
            closure()
        }
    }

    @objc func selectCurrencyEvent(_ sender: QMUIButton) {
        if let closure = selectCurrencyClosure {
            if sender.tag == 1 {
                closure(sender.tag, leftCurrencyType)
            } else {
                closure(sender.tag, rightCurrencyType)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required init(frame: CGRect, market: String) {
        super.init(frame: frame)
        initUI()
        currencyMarket = market
        initLogoTitle(market: currencyMarket)
    }
    
    //initUI
    @objc func initUI() {
        
        self.backgroundColor = QMUITheme().foregroundColor()
        //中间的交换按钮
        addSubview(exchangeButton)
        self.exchangeButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(25)
            make.height.equalTo(24)
        }

        addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.exchangeButton.snp.left)
        }

        addSubview(rightView)
        rightView.snp.makeConstraints { make in
            make.left.equalTo(self.exchangeButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    @objc func initLogoTitle(market: String) {
        if market.lowercased().elementsEqual(YXMarketType.HK.rawValue) {
            leftCurrencyType = .hk
            rightCurrencyType = .us
        } else if market.lowercased().elementsEqual(YXMarketType.US.rawValue) {
            leftCurrencyType = .us
            rightCurrencyType = .hk
        } else {
            leftCurrencyType = .sg
            rightCurrencyType = .hk
        }

        leftView.currencyType = leftCurrencyType
        rightView.currencyType = rightCurrencyType
    }
    
    func didSelect(with source:YXCurrencyType, target:YXCurrencyType) {
        leftCurrencyType = source
        leftView.currencyType = leftCurrencyType
        
        rightCurrencyType = target
        rightView.currencyType = rightCurrencyType
    }
    
}

fileprivate class YXTradeCurrenySelectionView: UIView {

    var currencyType: YXCurrencyType = .sg {
        didSet {
            iconImageView.image = UIImage(named: currencyType.iconName())
            currencyButton.setTitle(currencyType.name(), for: .normal)
        }
    }

    @objc lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    @objc lazy var currencyButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setImage(UIImage(named: "icon_drop_slim_down"), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 4.0
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    @objc func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()

        let stackView = UIStackView.init(arrangedSubviews: [iconImageView, currencyButton])
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.alignment = .center
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }
    }

}
