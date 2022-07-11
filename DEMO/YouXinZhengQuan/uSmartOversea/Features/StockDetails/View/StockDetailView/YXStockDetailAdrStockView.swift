//
//  YXStockDetailAdrStockView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit
import RxSwift
import RxGesture
import RxCocoa


class YXStockDetailAdrStockView: UIView, YXStockDetailSubHeaderViewProtocol {
    
    var isParentADR = false {
        didSet {
            initBottomView()
        }
    }
    
    var tapADRBlock: ((_ market: String, _ symbol: String) -> Void)?
    var adrInfo: Adr? {
        didSet {
            if adrInfo?.convPrice != nil {                
                refreshUI()
            }
        }
    }
    
    func refreshUI() {
        guard let adrModel = adrInfo else {
            self.isHidden = true
            return
        }
        self.isHidden = false
        
        var priceBasic = 1
        if let priceBase = adrModel.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }
        
        //now
        if let convPrice = adrModel.convPrice?.value, convPrice > 0 {
            convPriceLabel.text = YXToolUtility.stockPriceData(Double(convPrice), deciPoint: priceBasic, priceBase: priceBasic)
        } else {
            convPriceLabel.text = "--"
        }
        
        //change
        if let change = adrModel.relaNetchng?.value {
            let number = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)
            if change > 0 {
                self.convChangeLabel.text = "+" + (number ?? "0.000")
            } else {
                self.convChangeLabel.text = (number ?? "0.000")
            }
        }
        
        //roc
        if let roc = adrModel.relaPctchng?.value {
            self.convRocLabel.text = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            self.convRocLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.convChangeLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.convPriceLabel.textColor = YXToolUtility.changeColor(Double(roc))
        } else {
            self.convRocLabel.text = "0.00%"
        }
        
        guard isParentADR else {
            return
        }

        var stockText = ""
        if adrModel.market == YXMarketType.HK.rawValue {
            stockText = (adrModel.symbol ?? "") + "(" + YXLanguageUtility.kLang(key: "stockdetail_AH_H") + ")"
        } else  {
            stockText = YXLanguageUtility.kLang(key: "stockdetail_AH_A")
        }

        if let time = adrModel.latestTime?.value  {
            let dateModel = YXDateToolUtility.dateTime(withTime: String(time))
            let timeString = dateModel.hour + ":" + dateModel.minute + ":" + dateModel.second
            stockText += String(format: "(%@ %@)", timeString, "HKT")
        }

        stockLabel.text = stockText
        
        //now
        if let now = adrModel.latestPrice?.value, now > 0 {
            priceLabel.text = YXToolUtility.stockPriceData(Double(now), deciPoint: priceBasic, priceBase: priceBasic)
        } else {
            priceLabel.text = "--"
        }
        
        //roc
        if let roc = adrModel.pctchng?.value {
            self.rocLabel.text = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            self.rocLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.changeLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.priceLabel.textColor = YXToolUtility.changeColor(Double(roc))
        } else {
            self.rocLabel.text = "0.00%"
        }
        


    }
    
    @objc func tipButtonAction() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "stock_detail_adr_tips"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
            
        }))
        
        alertView.showInWindow()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            if let market = self.adrInfo?.market, let symbol = self.adrInfo?.symbol {
                self.tapADRBlock?(market, symbol)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initBottomView() {

        let bottomView = UIView()
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bottomView.addSubview(rocLabel)
        bottomView.addSubview(stockLabel)
        bottomView.addSubview(priceLabel)

        stockLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        rocLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rocLabel.snp.left).offset(-12)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(stockLabel.snp.right).offset(5)
        }
        let lineView = UIView.line()
        bottomView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalTo(bottomView)
        }

        stockLabel.text = "--"
        priceLabel.text = "--"
        rocLabel.text = "--"
    }
    
    func initUI() {

        let topView = UIView()
        let bottomView = UIView()

        addSubview(topView)
        addSubview(bottomView)

        topView.addSubview(adrLabel)
        topView.addSubview(tipButton)
        topView.addSubview(convPriceLabel)
        bottomView.addSubview(relateLabel)
        bottomView.addSubview(convChangeLabel)
        bottomView.addSubview(convRocLabel)
        
        let topLineView = UIView.line()
        addSubview(topLineView)
        topLineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalTo(topView)
        }
        
        let bottomLineView = UIView.line()
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalTo(bottomView)
        }

        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(30)
        }

        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(30)
        }
        
        adrLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        tipButton.snp.makeConstraints { (make) in
            make.left.equalTo(adrLabel.snp.right).offset(4)
            make.width.height.equalTo(14)
            make.centerY.equalTo(adrLabel)
        }
        
        convPriceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(adrLabel)
        }
        
        relateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        convRocLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(relateLabel)
        }

        convChangeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(convRocLabel.snp.left).offset(-12)
            make.centerY.equalTo(relateLabel)
        }
        
        adrLabel.text = YXLanguageUtility.kLang(key: "stock_detail_adr_conversion_price")
        convPriceLabel.text = "--"
        relateLabel.text = YXLanguageUtility.kLang(key: "stock_detail_adr_compare_h")
        convChangeLabel.text = "--"
        convRocLabel.text = "--"
    }
    
    lazy var adrLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.setImage(UIImage(named: "stock_about"), for: .highlighted)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var convPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var relateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var convChangeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var convRocLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var stockLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 9.0 / 12.0
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    func fixMarginRate() -> CGFloat {
        if YXConstant.screenWidth < 414, YXUserManager.isENMode() {
            if YXConstant.screenWidth <= 320 {
                return 0.6
            }
            return 0.8
        } else if YXConstant.screenWidth <= 320 {
            return 0.8
        }
        return 1.0
    }
    
    func fontFitSize(_ fontSize: CGFloat) -> CGFloat {
        
        if YXUserManager.isENMode() {
            if YXConstant.screenWidth <= 320 {
                return fontSize * 0.7
            } else if YXConstant.screenWidth <= 375 {
                return fontSize * 0.8
            }
            return fontSize * 0.9
        } else if YXConstant.screenWidth <= 320 {
            return fontSize * 0.8
        }
        return fontSize
    }
    
}


class YXStockParameterView: UIView {

    var type: YXStockDetailBasicType = .open
    var tipActionBlock: (() -> Void)?

    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var valueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_detail_about"), for: .normal)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    @objc func tipButtonAction() {
        tipActionBlock?()
    }
    convenience init(frame: CGRect, title: String?, isShowLine: Bool = true) {
        self.init(frame: frame)
        self.titleLabel.text = title
    }

    var showTip: Bool = false {
        didSet {
            if showTip, tipButton.superview == nil {
                addSubview(tipButton)
                var offset: CGFloat = 0
                if YXUserManager.isENMode() || YXToolUtility.is4InchScreenWidth() {
                    offset = -4
                }
                tipButton.snp.makeConstraints { (make) in
                    make.left.equalTo(titleLabel.snp.right).offset(offset)
                    make.centerY.equalToSuperview()
                    make.width.height.equalTo(30)
                }

                valueLabel.snp.remakeConstraints { (make) in
                    make.right.centerY.equalToSuperview()
                    make.left.greaterThanOrEqualTo(tipButton.snp.right).offset(offset)
                }
            }
            tipButton.isHidden = !showTip
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(self.titleLabel)
        addSubview(self.valueLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.valueLabel.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(self.titleLabel.snp.right).offset(3)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXStockDetailRelateStockView: UIView, YXStockDetailSubHeaderViewProtocol {

    var underlingSec: UnderlingSEC? {
        didSet {
            refreshUI()
        }
    }

    var quote: YXV2Quote? {
        didSet {
            refreshQuoteUI()
        }
    }

    var tapBlock: ((_ market: String, _ symbol: String) -> Void)?

    func refreshUI() {
        guard let quoteModel = underlingSec else {
            return
        }
        self.isHidden = false

        if let name = quoteModel.symbol {
            stockLabel.text = name
        } else  {
            stockLabel.text = "--"
        }

        var priceBasic = 1
        if let priceBase = quoteModel.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }

        //now
        if let latestPrice = quoteModel.latestPrice?.value, latestPrice > 0 {
            priceLabel.text = YXToolUtility.stockPriceData(Double(latestPrice), deciPoint: priceBasic, priceBase: priceBasic)
        } else {
            priceLabel.text = "--"
        }

        //change
        if let change = quoteModel.netchng?.value {
            let number = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)
            if change > 0 {
                self.changeLabel.text = "+" + (number ?? "0.000")
            } else {
                self.changeLabel.text = (number ?? "0.000")
            }
        }

        //roc
        if let roc = quoteModel.pctchng?.value {
            self.rocLabel.text = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            self.rocLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.changeLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.priceLabel.textColor = YXToolUtility.changeColor(Double(roc))
        } else {
            self.rocLabel.text = "0.00%"
        }
    }

    func refreshQuoteUI() {
        guard let quoteModel = quote else {
            return
        }
        self.isHidden = false

        if let market = quoteModel.market {
            if market == kYXMarketHK {
                stockLabel.text = YXLanguageUtility.kLang(key: "related_hk_stock")
            } else if market == kYXMarketUS {
                stockLabel.text = YXLanguageUtility.kLang(key: "related_us_stock")
            } else {
                stockLabel.text = YXLanguageUtility.kLang(key: "related_a_stock")
            }
        } else  {
            stockLabel.text = "--"
        }

        var priceBasic = 1
        if let priceBase = quoteModel.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }

        //now
        if let latestPrice = quoteModel.latestPrice?.value, latestPrice > 0 {
            priceLabel.text = YXToolUtility.stockPriceData(Double(latestPrice), deciPoint: priceBasic, priceBase: priceBasic)
        } else {
            priceLabel.text = "--"
        }

        //change
        if let change = quoteModel.netchng?.value {
            let number = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)
            if change > 0 {
                self.changeLabel.text = "+" + (number ?? "0.000")
            } else {
                self.changeLabel.text = (number ?? "0.000")
            }
        }

        //roc
        if let roc = quoteModel.pctchng?.value {
            self.rocLabel.text = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            self.rocLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.changeLabel.textColor = YXToolUtility.changeColor(Double(roc))
            self.priceLabel.textColor = YXToolUtility.changeColor(Double(roc))
        } else {
            self.rocLabel.text = "0.00%"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initEmptyData()
        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            if let market = self.underlingSec?.market, let symbol = self.underlingSec?.symbol {
                self.tapBlock?(market, symbol)
            } else if let market = self.quote?.market, let symbol = self.quote?.symbol {
                self.tapBlock?(market, symbol)
            }
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initEmptyData() {
        stockLabel.text = "--"
        priceLabel.text = "--"
        changeLabel.text = "--"
        rocLabel.text = "--"
    }

    func initUI() {
        addSubview(stockLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(rocLabel)

        stockLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-10)
        }
        stockLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        rocLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        rocLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        changeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rocLabel.snp.left).offset(-12)
            make.centerY.equalToSuperview()
        }
        changeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)


        priceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(changeLabel.snp.left).offset(-12)
            make.centerY.equalToSuperview()
        }
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

//        let lineView = UIView()
//        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#DDDDDD")
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//            make.top.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
    }

    lazy var stockLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()

}
