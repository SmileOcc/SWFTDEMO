//
//  YXTradeTotalAmountView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/3/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//


class YXTradeTotalAmountView: UIView, YXTradeHeaderSubViewProtocol {
    
    private lazy var bgView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) lazy var amountTitleLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font =  .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "amount_of_moneny")
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .left
        return label
    }()
    
    private lazy var amountLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font =  .systemFont(ofSize: 16, weight: .medium)
        label.text = "--"
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        return label
    }()
    
    private lazy var marginTipLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        label.text = "(" + YXLanguageUtility.kLang(key: "trading_margin_buy_tip") + ")"
        return label
    }()
    
    var useMargin: Bool = false {
        didSet {
            if useMargin {
                marginTipLab.isHidden = false
            } else {
                marginTipLab.isHidden = true
            }
        }
    }
    
    var showEstimated: Bool = false {
        didSet {
            if showEstimated {
                amountTitleLab.text = YXLanguageUtility.kLang(key: "trade_amount_estimated")
            } else {
                amountTitleLab.text = YXLanguageUtility.kLang(key: "amount_of_moneny")
            }
        }
    }
    
    var totalAmount: String? {
        didSet {
            updateAmount()
        }
    }
    
    var currency: String? {
        didSet {
            updateAmount()
        }
    }
    
    func updateAmount() {
        var amountTextColor: UIColor = QMUITheme().textColorLevel3()
        
        if let amount = totalAmount {
            amountTextColor = QMUITheme().textColorLevel1()
            
            amountLab.text = amount
            if let currency = currency, currency.count > 0 {
                amountLab.text = amount + " " + currency
            }
        } else {
            amountLab.text = "--"
        }
        amountLab.textColor = amountTextColor
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSmart: Bool = false {
        didSet {
            if isSmart {
                bgView.snp.updateConstraints { make in
                    make.height.equalTo(52)
                }
            } else {
                bgView.snp.updateConstraints { make in
                    make.height.equalTo(44)
                }
            }
        }
    }
    
    func initialUI() {
        
        addSubview(bgView)
        bgView.addSubview(amountTitleLab)
        bgView.addSubview(marginTipLab)
        bgView.addSubview(amountLab)

        bgView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
                     
        amountTitleLab.snp.makeConstraints { (make) in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        marginTipLab.snp.makeConstraints { (make) in
            make.bottom.top.height.equalTo(amountTitleLab)
            make.left.equalTo(amountTitleLab.snp.right).offset(8)
            make.width.equalTo(marginTipLab.sizeThatFits(CGSize(width: 100, height: 44)))
        }
        
        amountLab.snp.makeConstraints { (make) in
            make.bottom.top.equalTo(amountTitleLab)
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(marginTipLab.snp.right).offset(5)
        }
        amountLab.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentHeight = 52
    }
}

extension TradeModel {
    var totalAmount: String? {
        
        if tradeOrderType == .smart, condition.conditionOrderType == .market {
            return nil
        }
        
        var priceValue = Double(entrustPrice) ?? 0
        if tradeOrderType == .bidding
            || tradeOrderType == .market {
            priceValue = Double(latestPrice ?? "") ?? 0
        }
        

        var entrustQuantityValue = entrustQuantity.doubleValue
        if tradeType == .fractional {
            entrustQuantityValue = fractionalQuantity.doubleValue
        }
        if priceValue > 0, entrustQuantityValue > 0 {
            let moneyFormatter = NumberFormatter()
            moneyFormatter.positiveFormat = "###,##0.00"
            moneyFormatter.locale = Locale(identifier: "zh")
            
            //加0.00001防止精度丢失
            let amountValue = entrustQuantityValue * priceValue * Double(multiplier ?? 1) + 0.00001
            return moneyFormatter.string(from: NSNumber(string: String(format: "%.2f", amountValue)) ?? 0)
        }
        return nil
    }
}

