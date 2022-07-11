//
//  YXHoldFundListCell.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import NSObject_Rx

class YXHoldFundListCell: QMUITableViewCell,HasDisposeBag {

    lazy var stock = BehaviorRelay<YXHoldFundModel?>(value: nil)
    
    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    var config: YXNewStockMarketConfig
    var isDelay: Bool = false

    func refreshUI(model: YXHoldFundModel?, exchangeType: YXExchangeType) {
        
        nameLabel.text = model?.fundName ?? "--"
        switch model?.status {
        case 1:
            statusLabel.text =  YXLanguageUtility.kLang(key: "hold_fund_some_trading")
            statusLabel.textColor = UIColor.qmui_color(withHexString: "#F1B92D")
        case 2:
            statusLabel.text =  YXLanguageUtility.kLang(key: "hold_fund_trading")
            statusLabel.textColor = QMUITheme().themeTextColor()
        default:
            statusLabel.text = ""
        }
        
        var quoteLevel: QuoteLevel = .delay
        switch exchangeType {
        case .hk:
            quoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
        case .us:
            quoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.US.rawValue)
        default:
            log(.info, tag: kOther, content: "其他交易所不支持基金")
        }
        if quoteLevel == .delay {
            isDelay = true
        } else {
            isDelay = false
        }
        
        for label in labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model)
            }
        }
        
        // 延时
        delayLabel.isHidden = !isDelay
        
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXHoldFundModel?) {
        switch type {
        case .amountMoney: ////成交金额
            if let dailyBalance = model?.marketValue, let value = Double(dailyBalance) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0.00"
                    label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                }
            }
        case .yesterdayGains://昨日收益
            if let holdingBalance = model?.preEarningBalance, let value = Double(holdingBalance) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0.00"
                    label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
        case .holdGains://持有收益
            if let holdingBalance = model?.holdingBalance, let value = Double(holdingBalance) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0.00"
                    label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
            
        default:
            break
        }
    }
    
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        
        self.sortTypes = sortTypes
        self.config = config
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        initializeViews()
    }
    
    func initializeViews() {
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(delayLabel)
        contentView.addSubview(scrollView)
        contentView.addSubview(bottomLine)
        
        
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
            make.height.equalTo(20)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.bottom.equalToSuperview().offset(-14)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin - self.config.itemMargin)
            make.height.equalTo(15)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(statusLabel.snp.centerY)
            make.left.equalTo(statusLabel.snp.right).offset(6)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(18)
            make.height.equalTo(1)
        }
        
        
        let width = self.config.itemWidth
        
        for (index, type) in sortTypes.enumerated() {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .right
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.3
            label.tag = type.rawValue
            
            labels.append(label)
            scrollView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()//equalTo(nameLabel)
                make.width.equalTo(width - 10)
                make.left.equalToSuperview().offset(width * CGFloat(index) + 10)
            }
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(labels.count) + self.config.itemMargin, height: self.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)//UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0/16.0
        return label
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.font = .systemFont(ofSize: 8)
        label.textColor = QMUITheme().textColorLevel3()
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.layer.cornerRadius = 1.0
        label.layer.masksToBounds = true
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.0765)
        return view
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
