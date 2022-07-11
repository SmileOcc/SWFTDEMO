//
//  YXStockDetailPreAfterQuotaView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailPreAfterQuotaView: UIView, YXStockDetailSubHeaderViewProtocol {

    var clickActionBlock: (() -> Void)?

    var usQuotesStatementBlock: (() -> Void)?

    var marketStatus:Int32 = OBJECT_MARKETMarketStatus.msPreHours.rawValue
    
    let contenView = YXStockDetailPreAfterContentView.init()
    
    var isSelect: Bool = false {
        didSet {
            if isSelect {
                contenView.isHidden = false
            } else {
                contenView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: 视图布局
    func initUI() {

        contenView.isHidden = true
        
        self.addSubview(self.preQuotaStatusLabel)
        self.addSubview(self.preQuotaNowLabel)
        addSubview(rightIconView)
        addSubview(tipButton)
        addSubview(contenView)

        preQuotaNowLabel.adjustsFontSizeToFitWidth = true
        preQuotaNowLabel.minimumScaleFactor = 0.3
        preQuotaStatusLabel.adjustsFontSizeToFitWidth = true
        preQuotaStatusLabel.minimumScaleFactor = 0.3
        
        self.preQuotaStatusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualTo(preQuotaNowLabel.snp.left).offset(-10)
        }

        self.preQuotaStatusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        tipButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.preQuotaStatusLabel.snp.right).offset(4)
            make.centerY.equalTo(self.preQuotaStatusLabel)
            make.width.height.equalTo(14)
        }

        self.preQuotaNowLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-36)
            make.centerY.equalTo(self.preQuotaStatusLabel)
            make.left.greaterThanOrEqualTo(tipButton.snp.right).offset(4)
        }
        self.preQuotaNowLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        rightIconView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(self.preQuotaStatusLabel)
            make.width.height.equalTo(15)
        }
        
        contenView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(26)
        }
        
        let lineView = UIView.line()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        let control = UIControl.init()
        control.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        addSubview(control)
        control.backgroundColor = UIColor.clear
        control.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.bringSubviewToFront(tipButton)
    }

    //MARK: 懒加载视图
    lazy var preQuotaStatusLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var preQuotaNowLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().itemBorderColor()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()

    lazy var timeZoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().itemBorderColor()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var rightIconView: UIImageView = {
        let view = UIImageView.init(image: rightImage)
        return view
    }()
    
    let rightImage = UIImage(named: "market_arrow_WhiteSkin")
    
    @objc func click(_ sender: UIControl) {
        self.isSelect = !self.isSelect
        if isSelect {
            rightIconView.image = rightImage?.qmui_image(with: .down)
        } else {
            rightIconView.image = rightImage
        }
        clickActionBlock?()
    }

    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.setImage(UIImage(named: "stock_about"), for: .highlighted)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func tipButtonAction() {
        self.usQuotesStatementBlock?()
    }
    
    
    func updateUI(with preQuote: SQuote, _ priceBase: Int, _ lastPrice: Int64) {
        let highColor = YXToolUtility.stockColor(withData: Double(preQuote.high?.value ?? 0), compareData: Double(lastPrice))
        let lowColor = YXToolUtility.stockColor(withData: Double(preQuote.low?.value ?? 0), compareData: Double(lastPrice))
        
        if let high = preQuote.high?.value {
            self.contenView.highView.rightLabel.text = YXToolUtility.stockPriceData(Double(high), deciPoint: priceBase, priceBase: priceBase)
        } else {
            self.contenView.highView.rightLabel.text = "--"
        }
        if let low = preQuote.low?.value {
            self.contenView.lowView.rightLabel.text = YXToolUtility.stockPriceData(Double(low), deciPoint: priceBase, priceBase: priceBase)
        } else {
            self.contenView.lowView.rightLabel.text = "--"
        }
        if let vol = preQuote.volume?.value {
            self.contenView.volView.rightLabel.text = YXToolUtility.stockData(Double(vol), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
        } else {
            self.contenView.volView.rightLabel.text = "--"
        }
        
        self.contenView.highView.rightLabel.textColor = highColor
        self.contenView.lowView.rightLabel.textColor = lowColor
    }

}


class YXStockDetailPreAfterContentView: UIView {
    
    let highView = YXStockDetailPreAfterSubContentView.init()
    let lowView = YXStockDetailPreAfterSubContentView.init()
    let volView = YXStockDetailPreAfterSubContentView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: 视图布局
    func initUI() {
        backgroundColor = QMUITheme().blockColor()
        highView.leftLabel.text = YXLanguageUtility.kLang(key: "stock_detail_high")
        lowView.leftLabel.text = YXLanguageUtility.kLang(key: "stock_detail_low")
        volView.leftLabel.text = YXLanguageUtility.kLang(key: "stock_detail_vol")
        
        let stackView = UIStackView.init()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(highView)
        stackView.addArrangedSubview(lowView)
        stackView.addArrangedSubview(volView)
    }
    
}

class YXStockDetailPreAfterSubContentView: UIView {
    
    let leftLabel = UILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.normalFont12(), text: "--")
    let rightLabel = UILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.normalFont12(), text: "--")
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: 视图布局
    func initUI() {
        
        rightLabel.adjustsFontSizeToFitWidth = true
        rightLabel.minimumScaleFactor = 0.3
        rightLabel.textAlignment = .left
        leftLabel.numberOfLines = 2
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { make in
            make.left.equalTo(leftLabel.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-2)
            make.centerY.equalToSuperview()
        }
        
        rightLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
    }
    
}
