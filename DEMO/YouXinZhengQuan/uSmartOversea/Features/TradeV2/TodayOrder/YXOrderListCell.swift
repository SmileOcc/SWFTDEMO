//
//  YXHKOrderListCell.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderListCell: YXTableViewCell {
    
    typealias ClosureOrder = (_ secu: Any?) -> Void
    @objc var onClickOrder: ClosureOrder?
    
    @objc var isAll = false

    fileprivate lazy var countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSize = 3;
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 4
        return formatter;
    }()
    
    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()

    lazy var stockInfoView: YXStockBaseinfoView = {
        let view = YXStockBaseinfoView()
        let tapGes = UITapGestureRecognizer(actionBlock: { [weak self] (tap)  in
            guard let strongSelf = self else { return }
            
            if strongSelf.isAll {
                if let closure = strongSelf.onClickOrder, let model = strongSelf.model {
                    closure(model)
                }
            }
        })
        view.addGestureRecognizer(tapGes)
        return view
    }()

    lazy var conditionFlagLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "condition_order")
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.layer.cornerRadius = 1
        label.layer.masksToBounds = true
        label.layer.borderColor = QMUITheme().itemBorderColor().cgColor
        label.layer.borderWidth = 0.5
        label.isHidden = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        return label
    }()

    lazy var statusNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2;
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        return label
    }()

    @objc lazy var fractionFlagLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8)
        label.backgroundColor = UIColor.themeColor(withNormalHex: "#B0B6CB", andDarkColor: "#858999")
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.isHidden = true
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "fractions_flag")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var entrustDirectionLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var entrustLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        return label
    }()
    
    lazy var entrustDoneLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var entrustPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        return label
    }()
    
    lazy var entrustAvgLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()

    lazy var aboutButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandY = 5
        button.expandX = 5
        button.setImage(UIImage(named: "stock_detail_about"), for: .normal)
        button.addTarget(self, action: #selector(aboutButtonAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    @objc func aboutButtonAction() {
        if let model = model as? YXOrderModel {
            let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "fail_reason"), message: model.failReason)
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {  [weak alertView] (action) in
                alertView?.hide()
            }))
            alertView.showInWindow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    lazy var margin: Int  = {
        var margin = 9;
        return margin;
    }()

    override func initialUI() {
        super.initialUI()
        self.clipsToBounds = true
        backgroundColor = QMUITheme().foregroundColor()
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()

        contentView.addSubview(stockInfoView)
        contentView.addSubview(statusNameLabel)
        contentView.addSubview(conditionFlagLabel)
        contentView.addSubview(fractionFlagLabel)
        contentView.addSubview(entrustDirectionLabel)
        contentView.addSubview(entrustLabel)
        contentView.addSubview(entrustDoneLabel)
        contentView.addSubview(entrustPriceLabel)
        contentView.addSubview(entrustAvgLabel)
        contentView.addSubview(aboutButton)

        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16);
            make.top.bottom.equalToSuperview()
            make.right.equalTo(entrustPriceLabel.snp.left).offset(-2)
        }

        statusNameLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(margin + 41+20)
            make.centerY.equalTo(stockInfoView.nameLabel)
            make.height.lessThanOrEqualTo(24)
        }

        fractionFlagLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(entrustDoneLabel.snp.right).offset(5)
            make.right.equalTo(entrustDirectionLabel.snp.left).offset(-2)
            make.centerY.equalTo(entrustDirectionLabel)
        }
        
        entrustDirectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusNameLabel.snp.bottom).offset(3)
            make.right.equalToSuperview().offset(-16)
        }
        
        entrustLabel.snp.makeConstraints { (make) in
            make.right.equalTo(statusNameLabel.snp.left).offset(-margin);
            make.width.equalTo(80)
            make.centerY.equalTo(statusNameLabel)
        }

        entrustDoneLabel.snp.makeConstraints { (make) in
            make.right.equalTo(entrustLabel)
            make.width.equalTo(entrustLabel)
            make.centerY.equalTo(entrustDirectionLabel)
            make.height.equalTo(15)
        }

        entrustPriceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(entrustLabel.snp.left).offset(-margin)
            make.width.equalTo(80)
            make.centerY.equalTo(entrustLabel)
        }
        
        entrustAvgLabel.snp.makeConstraints { (make) in
            make.right.equalTo(entrustPriceLabel)
            make.width.equalTo(entrustPriceLabel)
            make.centerY.equalTo(entrustDoneLabel)
            make.height.equalTo(15);
        }
    }
    
    override func refreshUI() {
        super.refreshUI()
        
        if self.isAll == true {
            stockInfoView.isUserInteractionEnabled = true
        } else {
            stockInfoView.isUserInteractionEnabled = false
        }
        
        if let model = model as? YXOrderModel {
            configStock(model: model)
        }else if let model = model as? YXBondOrderModel2 {
            configBond(model: model)
        }
    }

    //sg的股票展示，返回的字段变了
    func configStock(model: YXOrderModel) {
        stockInfoView.nameLabel.text = model.symbolName
        stockInfoView.symbolLabel.text = model.symbol
        stockInfoView.market = model.market

        statusNameLabel.text = model.statusName

        fractionFlagLabel.isHidden =  model.symbolType != 2

        if model.entrustSide == "B" {
            entrustDirectionLabel.text = YXLanguageUtility.kLang(key: "buy")
        } else {
            entrustDirectionLabel.text = YXLanguageUtility.kLang(key: "sale")
        }

        if (model.realMarket() == kYXMarketUS && (model.tradePeriod == "A" || model.tradePeriod == "B")) { //盘前
            let panName : String = (model.tradePeriod == "A" ) ? "common_pre_opening" : "common_after_opening"
            conditionFlagLabel.text = YXLanguageUtility.kLang(key: panName)
            conditionFlagLabel.isHidden = false
            conditionFlagLabel.backgroundColor = UIColor.qmui_color(withHexString: "#D1D1D1")
            conditionFlagLabel.textColor = UIColor.qmui_color(withHexString: "#ffffff")
            conditionFlagLabel.layer.borderColor = UIColor.clear.cgColor
        } else {
            conditionFlagLabel.backgroundColor = UIColor.clear
            if model.tradePeriod == "G" {
                conditionFlagLabel.text = YXLanguageUtility.kLang(key: "grey_mkt")
                conditionFlagLabel.isHidden = false
            } else if model.flag == "1" {
                conditionFlagLabel.text = YXLanguageUtility.kLang(key: "condition_order")
                conditionFlagLabel.isHidden = false
            } else if model.flag == "2" {
                conditionFlagLabel.text = YXLanguageUtility.kLang(key: "broken_order")
                conditionFlagLabel.isHidden = false
            } else if model.flag == "3" {
                conditionFlagLabel.text = YXLanguageUtility.kLang(key: "hold_monthly_order")
                conditionFlagLabel.isHidden = false
            } else if model.flag == "7" {
               conditionFlagLabel.text = YXLanguageUtility.kLang(key: "trading_smart_order_record")
               conditionFlagLabel.isHidden = false
            }  else {
                conditionFlagLabel.isHidden = true
            }
            
            if model.tradePeriod == "G" {
                conditionFlagLabel.textColor = UIColor.qmui_color(withHexString: "#7A4CFF")
                conditionFlagLabel.layer.borderColor = UIColor.qmui_color(withHexString: "#7A4CFF")?.cgColor
            } else {
                conditionFlagLabel.textColor = QMUITheme().textColorLevel3()
                conditionFlagLabel.layer.borderColor = QMUITheme().itemBorderColor().cgColor
            }
        }

        if let entrustAmount = model.entrustQty, let formatString = countFormatter.string(from: entrustAmount) {
            entrustLabel.text = formatString
        } else {
            entrustLabel.text = "--"
        }
        
        if let businessAmount = model.businessQty, let formatString = countFormatter.string(from: businessAmount) {
            entrustDoneLabel.text = formatString
        } else {
            entrustDoneLabel.text = "--"
        }
        
        if let entrustPrice = model.entrustPrice {
            entrustPriceLabel.text = priceFormatter.string(from: entrustPrice)
        } else {
            entrustPriceLabel.text = "--"
        }

        if model.entrustProp == "AM" {
            entrustPriceLabel.text = "--"
        }
        
        if model.entrustProp == "MKT" {
            entrustPriceLabel.text = YXLanguageUtility.kLang(key: "trade_market_price")
        }

        if let businessAveragePrice = model.businessAvgPrice {
            entrustAvgLabel.text = priceFormatter.string(from: businessAveragePrice)
        } else {
            entrustAvgLabel.text = "--"
        }
        setColor(isfinal: model.finalStateFlag == "1", direction: model.entrustSide)

        if model.status == 31 { // 下单失败
            statusNameLabel.textColor = UIColor.themeColor(withNormalHex: "#FF6933", andDarkColor: "#E05C2D")
        } else if model.finalStateFlag == "1" { // 终态
            statusNameLabel.textColor = UIColor.themeColor(withNormalHex: "#C4C5CE", andDarkColor: "#5D5E66")
        } else {
            statusNameLabel.textColor = QMUITheme().textColorLevel1()
        }
    }

    
    // 债券展示
    func configBond(model: YXBondOrderModel2) {
        statusNameLabel.text = model.externalStatusName
        entrustDirectionLabel.text = model.direction.name

        if let entrustQuantity = model.entrustQuantity, let formatString = countFormatter.string(from: entrustQuantity) {
            entrustLabel.text = formatString
        } else {
            entrustLabel.text = "--"
        }
        
        if let clinchQuantity = model.clinchQuantity, let formatString = countFormatter.string(from: clinchQuantity) {
            entrustDoneLabel.text = formatString
        } else {
            entrustDoneLabel.text = "--"
        }
        
        if model.entrustPrice.count > 0 {
            entrustPriceLabel.text = priceFormatter.string(from: NSNumber(value: model.entrustPrice.doubleValue))
        } else {
            entrustPriceLabel.text = "--"
        }
        
        if model.clinchPrice.count > 0 {
            entrustPriceLabel.text = priceFormatter.string(from: NSNumber(value: model.clinchPrice.doubleValue))
        }else {
            entrustAvgLabel.text = "--"
        }
    }
    
    func setColor(isfinal: Bool, direction: String)  {
        if direction == "B"{
            entrustDirectionLabel.textColor = QMUITheme().buy()
        } else {
            entrustDirectionLabel.textColor = QMUITheme().sell()
        }
    }

}
