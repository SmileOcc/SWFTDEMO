//
//  YXStockDetailNameView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailNameView: YXStockDetailBaseView {
        

    
    lazy var subQuoteView: StockDetailNameViewSubQuoteView = {
        let view = StockDetailNameViewSubQuoteView()
        return view
    }()
    


    var quoteModel: YXV2Quote? {
        didSet {
            refreshUI()
            self.subQuoteView.quoteModel = quoteModel
        }
    }
    
    

    func refreshUI() {
                            
        var priceBasic = 1
        if let priceBase = quoteModel?.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }

        var change = Double(quoteModel?.netchng?.value ?? 0)
        var changeString = ""
        var rocString = ""
        if let market = quoteModel?.market, market == kYXMarketCryptos {
          
            self.nowLabel.text = YXToolUtility.btNumberString(quoteModel?.btRealTime?.now)

            if let valueStr = quoteModel?.btRealTime?.netchng, let value = Double(valueStr)  {
                changeString = YXToolUtility.btNumberString(valueStr, showPlus: true)
                change = value
            } else {
                changeString = "0.000"
            }

            if let valueStr = quoteModel?.btRealTime?.pctchng, let value = Double(valueStr)  {
                rocString = String(format: "(%@%%)", (value > 0 ? "+" : "") + valueStr)
            } else {
                rocString = "(0.00%)"
            }

        } else {
            //now
            if let now = quoteModel?.latestPrice?.value, now > 0 {
                let nowString = YXToolUtility.stockPriceData(Double(now), deciPoint: priceBasic, priceBase: priceBasic)
                self.nowLabel.text = nowString
            } else {
                self.nowLabel.text = "--"
            }

            //change
            if let change = quoteModel?.netchng?.value {
                let number = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)
                if change > 0 {
                    changeString = "+" + (number ?? "0.000")
                } else {
                    changeString = (number ?? "0.000")
                }

            } else {               
                changeString = "--"
            }

            //roc
            if let roc = quoteModel?.pctchng?.value {
                let number = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
                rocString = "(" + (number ?? "0.00%") + ")"

            } else {
               // rocString = "(0.00%)"
                changeString = "--"
            }
        }
        
        self.changeLabel.text = changeString + " " + rocString

        self.changeLabel.textColor = YXToolUtility.changeColor(Double(change))
        self.nowLabel.textColor = YXToolUtility.changeColor(Double(change))
    
        imageView.image = YXStockDetailTool.changeDirectionImage(change)

//        if self.lablesView.quote == nil {
//            self.lablesView.quote = quoteModel
//        }

    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(imageView)
        addSubview(self.nowLabel)
        addSubview(self.changeLabel)

        addSubview(subQuoteView)
        
                
        subQuoteView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(11)
            make.height.equalTo(47)
//            make.width.equalTo(102)
        }

        self.nowLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(7)
            make.height.equalTo(30)
        }

        self.imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(16)
            make.top.equalTo(self.nowLabel.snp.bottom).offset(5)
        }

        self.changeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.imageView.snp.right).offset(1)
            make.centerY.equalTo(self.imageView)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-16)
        }
            
        self.changeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill

        return imageView
    }()

    lazy var nowLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var changeLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "0.000"
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

}


class StockDetailNameViewSubQuoteView: UIView {
    
    var isShowParameter = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.arrowImageView.transform = self.isShowParameter ? CGAffineTransform.init(rotationAngle: .pi) : CGAffineTransform.identity
            }
        }
    }
    
    var tapCallBack: (()->())?
    
    let arrowImageView = UIImageView(image: UIImage(named: "kline_pull_down"))

    lazy var highLabel: UILabel = {
        let view = UILabel(with: QMUITheme().textColorLevel1(), font: UIFont.normalFont10(), text: "--")
        return view
    }()
    lazy var lowLabel: UILabel = {
        let view = UILabel(with: QMUITheme().textColorLevel1(), font: UIFont.normalFont10(), text: "--")
        return view
    }()
    lazy var volLabel: UILabel = {
        let view = UILabel(with: QMUITheme().textColorLevel1(), font: UIFont.normalFont10(), text: "--")
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.3
        return view
    }()
    
    let volTitle = UILabel(with: QMUITheme().textColorLevel3(), font: UIFont.normalFont10(), text: YXLanguageUtility.kLang(key: "stock_detail_vol"))
    
    var quoteModel: YXV2Quote? {
        didSet {
            guard let quoteModel = quoteModel else { return }
            guard let market = quoteModel.market else { return }
            let priceBasic = Int(quoteModel.priceBase?.value ?? 0)
            
            let stockType = quoteModel.stockType
            
            if priceBasic > 0  {
                // 最高
                if let high = quoteModel.high?.value {
                    if high > 0 {
                        let highString = YXToolUtility.stockPriceData(Double(high), deciPoint: priceBasic, priceBase: priceBasic)
                        highLabel.text = highString
                        if let pclose = quoteModel.preClose?.value {
                            highLabel.textColor = YXToolUtility.changeColor(Double(high - pclose))
                        }
                    } else {
                        highLabel.text = "--"
                    }
                }
                // 最低
                if let low = quoteModel.low?.value {
                    if low > 0 {
                        let lowString = YXToolUtility.stockPriceData(Double(low), deciPoint: priceBasic, priceBase: priceBasic)
                        lowLabel.text = lowString
                        if let pclose = quoteModel.preClose?.value {
                            lowLabel.textColor = YXToolUtility.changeColor(Double(low - pclose))
                        }
                    } else {
                        lowLabel.text = "--"
                    }
                }
                
                if stockType == .stIndex && market == kYXMarketHK {
                    ///港股指数显示成交额
                    volTitle.text = YXLanguageUtility.kLang(key: "stock_detail_turnover")
                    
                    if let amount = quoteModel.amount?.value, amount > 0 {
                        let amountString = YXToolUtility.stockData(Double(amount), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                        volLabel.text = amountString
                    } else {
                        volLabel.text = "0.00"
                    }
                    
                } else {
                    volTitle.text = YXLanguageUtility.kLang(key: "stock_detail_vol")
                    var unitString = YXLanguageUtility.kLang(key: "stock_unit_en")
                    if let market = quoteModel.market, market == kYXMarketUsOption {
                        unitString = YXLanguageUtility.kLang(key: "options_page")
                    }
                    if let volume = quoteModel.volume?.value, volume > 0 {
                        let volumeString = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unitString, priceBase: 0)
                        volLabel.text = volumeString
                    } else {
                        volLabel.text = "0.00" + unitString
                       
                        if YXStockDetailOCTool.isUSIndex(quoteModel){
                            volLabel.text = "--"
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let highTitle = UILabel(with: QMUITheme().textColorLevel3(), font: UIFont.normalFont10(), text: YXLanguageUtility.kLang(key: "stock_detail_high"))
        let lowTitle = UILabel(with: QMUITheme().textColorLevel3(), font: UIFont.normalFont10(), text: YXLanguageUtility.kLang(key: "stock_detail_low"))
        
        
        let rightSquareView = UIView()
        rightSquareView.layer.cornerRadius = 2
        rightSquareView.clipsToBounds = true
        rightSquareView.backgroundColor = QMUITheme().backgroundColor()
        
        
        addSubview(rightSquareView)
        rightSquareView.addSubview(arrowImageView)
        
        addSubview(highLabel)
        addSubview(lowLabel)
        addSubview(volLabel)
        addSubview(highTitle)
        addSubview(lowTitle)
        addSubview(volTitle)
        
        rightSquareView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(12)
            make.top.bottom.equalToSuperview()
        }
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(10)
        }
        highLabel.snp.makeConstraints { make in
            make.right.equalTo(rightSquareView.snp.left).offset(-8)
            make.top.equalToSuperview()
        }
        lowLabel.snp.makeConstraints { make in
            make.right.equalTo(highLabel)
            make.centerY.equalToSuperview()
        }
        volLabel.snp.makeConstraints { make in
            make.right.equalTo(highLabel)
            make.bottom.equalToSuperview()
        }
        
        highTitle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(highLabel)
            make.right.lessThanOrEqualTo(highLabel.snp.left).offset(-12)
        }
        lowTitle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(lowLabel)
            make.right.lessThanOrEqualTo(lowLabel.snp.left).offset(-12)
        }
        volTitle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(volLabel)
            make.right.lessThanOrEqualTo(volLabel.snp.left).offset(-12)
        }
        
        volLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let tapControl = UIControl.init()
        addSubview(tapControl)
        tapControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tapControl.qmui_tapBlock = { [weak self] sender in
            self?.tapCallBack?()
            
        }
    }
    
}


class StockDetailHeaderTimeView: UIView {
    
    var lastMarketDes = ""
    var lastMarketStatus: Int32 = 0
    
    lazy var statusLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var lablesView: YXStockDetailLabelsView = {
        let view = YXStockDetailLabelsView()

        return view
    }()
    
    var quoteModel: YXV2Quote? {
        didSet {
            
            var statusString = ""
            if let desc = quoteModel?.msInfo?.desc, desc.count > 0 {
                statusString = desc
                lastMarketDes = desc
            }
            
            if let status = quoteModel?.msInfo?.status?.value {
                
                if lastMarketStatus == status, statusString.isEmpty {
                    statusString = lastMarketDes
                }
                //记录上次的市场状态, 防止推送没有值把字段覆盖
                lastMarketStatus = status
            }
            
            var isListing = true  //是否是上市状态（非 停牌，退市，暂停上市，未上市状态）
            var isPreAfterCanTrade = false //是否是美股盘前盘后
            
            //美股盘前盘后优先级最高，其次是待上市，已退市等状态
            if YXStockDetailTool.isShowPreAfterQuote(quoteModel), let price = quoteModel?.sQuote?.latestPrice?.value, price > 0 {
                isPreAfterCanTrade = true
            }
            
            if quoteModel?.greyFlag?.value ?? 0 == 0, !isPreAfterCanTrade {
                let status = Int(quoteModel?.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue)
                var str: String?
                if status == OBJECT_QUOTETradingStatus.tsSuspended.rawValue ||
                    status == OBJECT_QUOTETradingStatus.tsVolatility.rawValue {
                    str = YXLanguageUtility.kLang(key: "stock_detail_suspenden")
                } else if status == OBJECT_QUOTETradingStatus.tsDelisting.rawValue  {
                    str = YXLanguageUtility.kLang(key: "stock_detail_delisted")
                }  else if status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
                    str = YXLanguageUtility.kLang(key: "stock_detail_beforList")
                } else if status == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                    str = YXLanguageUtility.kLang(key: "zanting")
                }
                if let text = str {
                    isListing = false
                    statusString = text
                }
            }
            
            var timeString = ""
            
            if (quoteModel?.greyFlag?.value ?? 0 != 0 &&  quoteModel?.msInfo?.status?.value == OBJECT_MARKETMarketStatus.msGreyPreOpen.rawValue) || !isListing {
                
            } else {
                //time
                if let time = quoteModel?.latestTime?.value, time > 0 {
                    
                    var timeStr = YXDateHelper.commonDateStringWithNumber(time, format: .DF_MDHMS)
                    if quoteModel?.market == YXMarketType.US.rawValue {
                        timeStr = timeStr + " " + YXLanguageUtility.kLang(key: "stock_detail_us_time")
                    }
                    
                    if statusString.isEmpty {
                        timeString = timeStr
                    } else {
                        timeString = " " + timeStr
                    }
                    
                }
            }
            
            var delayString = ""
            
            var level = QuoteLevel.delay
            if let userLevel = QuoteLevel(rawValue: Int(quoteModel?.level?.value ?? 0)) {
                level = userLevel
            }
            
            if quoteModel?.market == kYXMarketCryptos {
                level = .level1
            }
            
            if level == .delay,
               quoteModel?.greyFlag?.value ?? 0 == 0,
               isListing {
                if quoteModel?.market == kYXMarketSG {
                    delayString = " " + YXLanguageUtility.kLang(key: "stock_detail_sg_delayTime")
                } else {
                    delayString = " " + YXLanguageUtility.kLang(key: "stock_detail_delayTime")
                }
                
            }
            
            let statusText = statusString + timeString + delayString
            if statusText.isEmpty {
                statusLabel.text = "--"
            } else {
                statusLabel.text = statusText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        addSubview(self.statusLabel)
        addSubview(lablesView)
        
        lablesView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.statusLabel)
            make.height.equalTo(26)
            make.right.equalToSuperview()
        }
        
        self.statusLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(self.lablesView.snp.right).offset(-10)
        }
        
        self.statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        statusLabel.rx.tapGesture().subscribe(onNext: {
            [weak self] (ges) in
            if ges.state == .ended {
                guard let `self` = self, let text = self.statusLabel.text else { return }
                let width = (text as NSString).boundingRect(with: CGSize(width: 1000, height: 25), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : self.statusLabel.font!], context: nil).size.width
                if width > self.statusLabel.frame.width {
                    YXProgressHUD.showMessage(self.statusLabel.text ?? "", in: UIApplication.shared.keyWindow, hideAfterDelay: 2.0)
                }
            }
           
        }).disposed(by: rx.disposeBag)
    }
}
