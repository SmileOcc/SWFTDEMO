//
//  YXSmartConfigView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXSmartConfigView: UIView, YXTradeHeaderSubViewProtocol, YXTradeHeaderViewProtocol {
    
    var heightDidChange: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: YXLanguageUtility.kLang(key: "trade_valid_date"),
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                                                               .foregroundColor: QMUITheme().textColorLevel1()])
        return label
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
        
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var preAfterView: YXSmartTradePreAfterView = {
        var type: YXTradePreAfterView.AllowType = .notAllow
        if tradeModel.tradePeriod == .preAfter {
            type = .allow
        }
        let view = YXSmartTradePreAfterView(type) { [weak self] type in
            self?.tradeModel.tradePeriod = type.tradePeriod
            self?.dateView.tradePeriod = type.tradePeriod
        }
        
        if tradeModel.market == kYXMarketUS,
           tradeModel.condition.entrustGear != .market,
           tradeModel.condition.smartOrderType != .tralingStop {
            view.isHidden = false
        } else {
            view.isHidden = true
        }
        
        return view
    }()
    
    lazy var dateView: YXSmartDateView = {
        let view = YXSmartDateView(selectedType: tradeModel.condition.strategyEnddateDesc, selectedBlock:  { [weak self] item in
            guard let strongSelf = self else { return }
            
            strongSelf.tradeModel.condition.strategyEnddateDesc = item.type ?? ""
            strongSelf.tradeModel.condition.strategyEnddateTitle = item.msg ?? ""
            strongSelf.tradeModel.condition.strategyEnddateYearMsg = item.transformValidTime(strongSelf.tradeModel.tradePeriod) ?? ""
        })
        return view
    }()
    
    var tradeModel: TradeModel! {
        didSet {
            if preMarket != tradeModel.market {
                dateView.getConditionValidtime(tradeModel.market)
                preMarket = tradeModel.market
            }
            setupUI()
        }
    }
    
    var preMarket: String?
    func setupUI() {

        if tradeModel.market == kYXMarketUS,
           tradeModel.condition.entrustGear != .market,
           tradeModel.condition.smartOrderType != .tralingStop {
            preAfterView.isHidden = false
        } else {
            preAfterView.isHidden = true
            preAfterView.updateType(selected: .notAllow)
        }
    }
    
    var quote: YXV2Quote?
    
    convenience init(tradeModel: TradeModel) {
        self.init()
        
        self.tradeModel = tradeModel
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }
        
        setupStackView()
        configStackView()
        updateHeight()
        
        setupUI()
    }
    
    
    func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(topMargin)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        
        stackView.addArrangedSubview(dateView)
        stackView.addArrangedSubview(preAfterView)
        
        insertSubview(shadowView, at: 0)
        shadowView.snp.makeConstraints { make in
            make.top.equalTo(stackView).offset(-margin)
            make.left.right.equalTo(stackView)
            make.bottom.equalTo(stackView).offset(bottomMargin)
        }
    }
    
    private let margin: CGFloat = 4
    
    var topMargin: CGFloat {
        return 48 + margin
    }
    
    var bottomMargin: CGFloat {
        return 16
    }
}
