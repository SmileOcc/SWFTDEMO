//
//  YXWarrantBullBearView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/6/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation
import NSObject_Rx

class YXWarrantBullBearView: UIView {
    
    @objc var tapItemAction: ((_ market: String, _ symbol: String) -> Void)?
    @objc var tapBullBearMoreAction: ((_ type: YXBullAndBellType) -> Void)?
    
    @objc var bullBearModel: YXWarrantBullBearModel? {
        didSet {
            if let model = bullBearModel {
                isHidden = false
                bull.item = model.bull
                bear.item = model.bear
                call.item = model.call
                put.item = model.put
                rise.item = model.rise
                fall.item = model.fall
            } else {
                isHidden = true
            }
        }
    }
    
    lazy var rise: YXWarrantsBullBearItemView = {
        let view = YXWarrantsBullBearItemView()
        view.statusColor = QMUITheme().stockRedColor()
        view.statusLabel.text = YXLanguageUtility.kLang(key: "forecase_up")
        
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var fall: YXWarrantsBullBearItemView = {
        let view = YXWarrantsBullBearItemView()
        view.statusColor = QMUITheme().stockGreenColor()
        view.statusLabel.text = YXLanguageUtility.kLang(key: "forecase_down")
        
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var bear: YXWarrantBullBearObjectView = {
        let view = YXWarrantBullBearObjectView()
        view.type = .bullBear
        view.titleLabel.text = YXDerivativeType.bullBear.fallText
        view.titleLabel.textColor = QMUITheme().stockGreenColor()
        view.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.05)
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapItemAction, let model = self?.bullBearModel {
                if let market = model.bear?.market, let symbol = model.bear?.symbol {
                    action(market, symbol)
                }
            }
        }
        view.addGestureRecognizer(tap)
        
        view.moreButton.rx.tap.subscribe(onNext: { [weak self] () in
            if let action = self?.tapBullBearMoreAction {
                action(.bear)
            }
        }).disposed(by: rx.disposeBag)
        return view
    }()
    
    lazy var bull: YXWarrantBullBearObjectView = {
        let view = YXWarrantBullBearObjectView()
        view.type = .bullBear
        view.titleLabel.text = YXDerivativeType.bullBear.riseText
        view.titleLabel.textColor = QMUITheme().stockRedColor()
        view.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.05)
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapItemAction, let model = self?.bullBearModel {
                if let market = model.bull?.market, let symbol = model.bull?.symbol {
                    action(market, symbol)
                }
            }
        }
        view.addGestureRecognizer(tap)
        
        view.moreButton.rx.tap.subscribe(onNext: { [weak self] () in
            if let action = self?.tapBullBearMoreAction {
                action(.bull)
            }
        }).disposed(by: rx.disposeBag)
        
        return view
    }()
    
    lazy var call: YXWarrantBullBearObjectView = {
        let view = YXWarrantBullBearObjectView()
        view.type = .warrant
        view.titleLabel.text = YXDerivativeType.warrant.riseText
        view.titleLabel.textColor = QMUITheme().stockRedColor()
        view.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.05)
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapItemAction, let model = self?.bullBearModel {
                if let market = model.call?.market, let symbol = model.call?.symbol {
                    action(market, symbol)
                }
            }
        }
        view.addGestureRecognizer(tap)
        
        view.moreButton.rx.tap.subscribe(onNext: { [weak self] () in
            if let action = self?.tapBullBearMoreAction {
                action(.buy)
            }
        }).disposed(by: rx.disposeBag)
        
        return view
    }()
    
    lazy var put: YXWarrantBullBearObjectView = {
        let view = YXWarrantBullBearObjectView()
        view.type = .warrant
        view.titleLabel.text = YXDerivativeType.warrant.fallText
        view.titleLabel.textColor = QMUITheme().stockGreenColor()
        view.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.05)
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapItemAction, let model = self?.bullBearModel {
                if let market = model.put?.market, let symbol = model.put?.symbol {
                    action(market, symbol)
                }
            }
        }
        view.addGestureRecognizer(tap)
        
        view.moreButton.rx.tap.subscribe(onNext: { [weak self] () in
            if let action = self?.tapBullBearMoreAction {
                action(.sell)
            }
        }).disposed(by: rx.disposeBag)
        
        return view
    }()
    
    lazy var riseView: UIView = {
        let view = UIView()
        let subView  = UIView()
        subView.layer.cornerRadius = 4
        subView.layer.masksToBounds = true
        
        view.addSubview(rise)
        view.addSubview(subView)
        subView.addSubview(bull)
        subView.addSubview(call)
        
        rise.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80.0 * YXConstant.screenWidth/375.0)
        }
        
        subView.snp.makeConstraints { (make) in
            make.left.equalTo(rise.snp.right).offset(8)
            make.top.bottom.right.equalToSuperview()
        }
        
        bull.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(subView.snp.centerX)
        }
        
        call.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(bull.snp.right)
        }
        
        return view
    }()
    
    lazy var fallView: UIView = {
        let view = UIView()
        let subView  = UIView()
        subView.layer.cornerRadius = 4
        subView.layer.masksToBounds = true
        
        view.addSubview(fall)
        view.addSubview(subView)
        subView.addSubview(bear)
        subView.addSubview(put)
        
        fall.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(80.0 * YXConstant.screenWidth/375.0)
            make.height.equalTo(178)
        }
        
        subView.snp.makeConstraints { (make) in
            make.left.equalTo(fall.snp.right).offset(8)
            make.top.bottom.right.equalToSuperview()
        }
        
        bear.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(subView.snp.centerX)
        }
        
        put.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(bear.snp.right)
        }
        
        return view
    }()
    
    lazy var signalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "bullbear_usmart_highlight")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isHidden = true
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(titleLabel)
        addSubview(riseView)
        addSubview(fallView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        riseView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(178)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
        }
        
        fallView.snp.makeConstraints { (make) in
            make.top.equalTo(riseView.snp.bottom).offset(8)
            make.height.equalTo(178)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objcMembers class YXWarrantsBullBearItemView: UIView {
    var statusColor: UIColor? {
        didSet {
            backgroundColor = statusColor?.withAlphaComponent(0.05)
            statusLabel.textColor = statusColor
            percentLabel.textColor = statusColor
            amountLabel.textColor = statusColor
            amountValueLabel.textColor = statusColor
        }
    }
    
    var item: [String: AnyObject]? {
        didSet {
            if let amount = item?["amount"] as? NSNumber {
                print(amount)
                amountValueLabel.text = YXToolUtility.stockData(amount.doubleValue, deciPoint: 2, stockUnit: "", priceBase: 4)
            } else {
                amountValueLabel.text = "--"
            }
            
            if let ratio = item?["ratio"] as? NSNumber {
                percentLabel.text = String(format:"%.2f%%",ratio.doubleValue/100)
            } else {
                percentLabel.text = "--"
            }
        }
    }
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        return label
    }()
    
    lazy var percentLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "market_amount")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var amountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view = UIView()
        
        addSubview(view)
        
        view.addSubview(statusLabel)
        view.addSubview(percentLabel)
        view.addSubview(amountLabel)
        view.addSubview(amountValueLabel)
        
        statusLabel.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        percentLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
            make.left.equalTo(statusLabel)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(percentLabel.snp.bottom).offset(22)
            make.left.equalTo(statusLabel)
        }
        
        amountValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(statusLabel)
        }
        
        view.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers class YXWarrantBullBearObjectView: UIView {
    var item: YXBullBearItem? {
        didSet {
            if let item = item {
                let base = pow(10.0, Double(item.priceBase))
                nameLabel.text = item.name
                codeLabel.text = item.symbol
                let formatExercisePrice = YXNewStockPurchaseUtility.moneyFormat(value: (Double(item.exercisePrice) / base), decPoint: 3)
                exercisePriceLabel.text = YXLanguageUtility.kLang(key: "stock_detail_strike") + ": " + (formatExercisePrice ?? "--")
                if type == .warrant {
                    recyclePriceLabel.text = YXLanguageUtility.kLang(key: "stock_detail_impliedVolatility") + ": " + String(format: "%.3lf", Double(item.impliedVolatility) / base)
                    leverLabel.text = YXLanguageUtility.kLang(key: "stock_detail_effect_gear") + "：" + String(format: "%.2lf", Double(item.effectiveGearing) / base)
                }else {
                    let formatRecoveryPrice = YXNewStockPurchaseUtility.moneyFormat(value: (Double(item.recoveryPrice) / base), decPoint: 3)
                    recyclePriceLabel.text = YXLanguageUtility.kLang(key: "stock_detail_call") + "：" + (formatRecoveryPrice ?? "--")
                    leverLabel.text = YXLanguageUtility.kLang(key: "warrants_gearing") + ": " + String(format: "%.2lf", Double(item.gearing) / base)
                }
            } else {
                nameLabel.text = "--"
                codeLabel.text = "--"
                exercisePriceLabel.text = YXLanguageUtility.kLang(key: "warrants_strike") + ": " + "--"
                leverLabel.text = YXLanguageUtility.kLang(key: "stock_detail_effect_gear") + "：" + "--"
                if type == .warrant {
                    recyclePriceLabel.text = YXLanguageUtility.kLang(key: "stock_detail_impliedVolatility") + ": " + "--"
                }else {
                    recyclePriceLabel.text = YXLanguageUtility.kLang(key: "stock_detail_call") + ": " + "--"
                }
            }
        }
    }
    
    var type: YXDerivativeType?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        
        return label
    }()
    
    lazy var exercisePriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "stock_detail_strike") + "："
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var recyclePriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "stock_detail_call") + "："
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var leverLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "stock_detail_effect_gear") + "："
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitle(YXLanguageUtility.kLang(key: "share_info_more"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(nameLabel)
        addSubview(codeLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview()
        }
        
        codeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
        }
        
        let stackView = UIStackView.init(arrangedSubviews: [exercisePriceLabel, recyclePriceLabel, leverLabel])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 5
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(codeLabel.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-6)
        }
        
        addSubview(moreButton)
        
        moreButton.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(stackView.snp.bottom).offset(11)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
