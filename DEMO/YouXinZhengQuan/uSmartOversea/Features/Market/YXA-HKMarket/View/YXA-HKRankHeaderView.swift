//
//  YXA-HKRankHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

enum YXA_HKRankType: Int {
    // 资金净流向
    case fundDirection = 1
    // 涨跌幅
    case roc = 2
    // 成交量
    case volume = 3
    // 上限预警
    case limitWarning = 4
    
    var text: String {
        switch self {
        case .fundDirection:
            return YXLanguageUtility.kLang(key: "bubear_net_capital_flow")
        case .roc:
            return YXLanguageUtility.kLang(key: "bubear_roc_top")
        case .volume:
            return YXLanguageUtility.kLang(key: "bubear_turnover_top")
        case .limitWarning:
            return YXLanguageUtility.kLang(key: "bubear_upper_limitalert")
        }
    }
}

enum YXA_HKRankSortType {
    case stockNum(sortType: YXSortState)
    case fundAmount(sortType: YXSortState)
    case ratio(sortType: YXSortState)
    case roc(sortType: YXSortState)
    case price(sortType: YXSortState)
    
    var sortKey: String {
        switch self {
        case .stockNum(_):
            return "volume"
        case .fundAmount(_):
            return "amount"
        case .ratio(_):
            return "ratio"
        case .roc(_):
            return "1"
        case .price(_):
            return "2"
        }
    }
    
    var sortType: String {
        switch self {
        case .stockNum(let sortType), .fundAmount(let sortType), .ratio(let sortType):
            if sortType == .descending {
                return "desc"
            }else {
                return "asc"
            }
        case .roc(let sortType), .price(let sortType):
            if sortType == .descending {
                return "1"
            }else {
                return "0"
            }
        }
    }
}

class YXA_HKRankHeaderView: UIView {
    
    let rankType: YXA_HKRankType
    
    var tapSortButtonAction: ((_ type: YXA_HKRankSortType) -> Void)?

    // 更新时间
    lazy var updateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.text = "\(YXLanguageUtility.kLang(key: "bubear_update_time"))："
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    // 选择时间按钮
    lazy var selectTimeButton: UIButton = {
        let button = UIButton()
        button.setTitle("--", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10)
        button.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.4), for: .normal)
        button.setImage(UIImage.init(named: "market_arrow_WhiteSkin"), for: .normal)
        button.setButtonImagePostion(.right, interval: 2)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    // 第一列
    lazy var firstColLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.text = YXLanguageUtility.kLang(key: "market_codeName_wrap")
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    // 净买卖股数
    lazy var dealAmountSortButton: YXSortButton = {
        
        let sortButton = YXSortButton.init(sortType: .dealAmount, sortState: .normal)
        sortButton.titleLabel?.numberOfLines = 2
        sortButton.titleLabel?.textAlignment = .left
        sortButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sortButton.titleLabel?.minimumScaleFactor = 0.3
        sortButton.addTarget(self, action: #selector(tapSortButton(button:)), for: .touchUpInside)
        sortButton.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.6), for: .normal)
        return sortButton
    }()
    
    // 资金净流向
    lazy var fundFlowSortButton: YXSortButton = {
        let sortButton = YXSortButton.init(sortType: .fundFlow, sortState: .descending)
        sortButton.titleLabel?.numberOfLines = 2
        sortButton.titleLabel?.textAlignment = .left
        sortButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sortButton.titleLabel?.minimumScaleFactor = 0.3
        sortButton.addTarget(self, action: #selector(tapSortButton(button:)), for: .touchUpInside)
        sortButton.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.6), for: .normal)
        return sortButton
    }()
    
    // 买卖股数占流通股比例
    lazy var dealRatioSortButton: YXSortButton = {
        let sortButton = YXSortButton.init(sortType: .dealRatio, sortState: .normal)
        sortButton.titleLabel?.numberOfLines = 2
        sortButton.titleLabel?.textAlignment = .left
        sortButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sortButton.titleLabel?.minimumScaleFactor = 0.3
        sortButton.addTarget(self, action: #selector(tapSortButton(button:)), for: .touchUpInside)
        sortButton.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.6), for: .normal)
        return sortButton
    }()
    
    // 买入额
    lazy var buyAmount: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor =  QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        if self.rankType == .limitWarning {
            label.text = YXLanguageUtility.kLang(key: "market_codeName_wrap")
        }else {
            label.text = YXLanguageUtility.kLang(key: "bubear_buy_trades")
        }
        
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        let view = UIView()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }
        
        return view
        
    }()
    
    // 卖出额
    lazy var sellAmount: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor =  QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        
        if self.rankType == .limitWarning {
            label.text = YXLanguageUtility.kLang(key: "bubear_share_holding")
        }else {
            label.text = YXLanguageUtility.kLang(key: "bubear_sell_trades")
        }
        
        label.numberOfLines = 2
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        let view = UIView()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }
        
        return view
        
    }()
    
    // 买卖总额
    lazy var totalDeal: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor =  QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        
        if self.rankType == .limitWarning {
            label.text = YXLanguageUtility.kLang(key: "bubear_total_equity")
        }else {
            label.font = .systemFont(ofSize: 12)
            label.text = "\(YXLanguageUtility.kLang(key: "bubear_turnover"))/\n\(YXLanguageUtility.kLang(key: "bubear_net_captialflow"))"
        }
        
        label.numberOfLines = 3
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        let view = UIView()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }
        
        return view
        
    }()
    
    lazy var stackView: UIStackView = {

        let stackView = UIStackView.init()
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal

        return stackView
    }()
    
    @objc func tapSortButton(button: YXSortButton) {
        var sortState: YXSortState
        if button.sortState == .descending {
            button.sortState = .ascending
            sortState = .ascending
        }else {
            button.sortState = .descending
            sortState = .descending
        }
        
        var rankSortType: YXA_HKRankSortType?
        switch button.mobileBrief1Type {
        case .dealAmount:
            rankSortType = .stockNum(sortType: sortState)
            fundFlowSortButton.sortState = .normal
            dealRatioSortButton.sortState = .normal
        case .fundFlow:
            rankSortType = .fundAmount(sortType: sortState)
            dealAmountSortButton.sortState = .normal
            dealRatioSortButton.sortState = .normal
        case .dealRatio:
            rankSortType = .ratio(sortType: sortState)
            dealAmountSortButton.sortState = .normal
            fundFlowSortButton.sortState = .normal
        default:
            break
        }
        
        if let sortType = rankSortType, let action = tapSortButtonAction {
            action(sortType)
        }
    }
    
    init(frame: CGRect, rankType: YXA_HKRankType) {
        self.rankType = rankType
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(stackView)
        
        switch rankType {
        case .fundDirection:
            addSubview(updateTimeLabel)
            addSubview(selectTimeButton)
            
            updateTimeLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.top.equalToSuperview().offset(15)
                make.right.lessThanOrEqualTo(selectTimeButton.snp.left).offset(-5)
            }
            
            selectTimeButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-18)
                make.top.equalTo(updateTimeLabel).offset(-2)
            }
            
            let bgView1 = UIView()
            bgView1.addSubview(dealAmountSortButton)
            dealAmountSortButton.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
            }
            let bgView2 = UIView()
            bgView2.addSubview(fundFlowSortButton)
            fundFlowSortButton.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
            }
            let bgView3 = UIView()
            bgView3.addSubview(dealRatioSortButton)
            dealRatioSortButton.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
            }
            stackView.addArrangedSubview(firstColLabel)
            stackView.addArrangedSubview(bgView1)
            stackView.addArrangedSubview(bgView2)
            stackView.addArrangedSubview(bgView3)
            
            stackView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.bottom.equalToSuperview().offset(-5)
            }
            
            if #available(iOS 11.0, *) {
                stackView.setCustomSpacing(10, after: bgView1)
            } else {
                // Fallback on earlier versions
            }
            
        case .volume:
            addSubview(selectTimeButton)
            selectTimeButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-6)
                make.top.equalToSuperview().offset(15)
            }
            stackView.addArrangedSubview(firstColLabel)
            stackView.addArrangedSubview(buyAmount)
            stackView.addArrangedSubview(sellAmount)
            stackView.addArrangedSubview(totalDeal)
            
            stackView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.bottom.equalToSuperview().offset(-5)
            }
            
            if #available(iOS 11.0, *) {
                stackView.setCustomSpacing(10, after: buyAmount)
            } else {
                // Fallback on earlier versions
            }
            
        case .limitWarning:
            firstColLabel.text = YXLanguageUtility.kLang(key: "bubear_trading_date")
            stackView.addArrangedSubview(firstColLabel)
            stackView.addArrangedSubview(buyAmount)
            stackView.addArrangedSubview(sellAmount)
            stackView.addArrangedSubview(totalDeal)
            
            stackView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.bottom.equalToSuperview().offset(-5)
            }
            
            if #available(iOS 11.0, *) {
                stackView.setCustomSpacing(10, after: buyAmount)
            } else {
                // Fallback on earlier versions
            }
            
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
