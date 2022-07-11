//
//  YXNewStockDetailPurchaseView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import DTCoreText

class YXNewStockDetailPurchaseView: UIView {
    
    typealias ClosureStock = (_ market: Int, _ symbol: String, _ name: String) -> Void
    
    @objc var stockDetailClosure: ClosureStock?
    @objc var pdfClosure: ((_ pdfLink: String) -> Void)?
    @objc var tipClosure: (() -> Void)?
    @objc var expanseClosure: (() -> Void)?
    @objc var refreshHeightClosure: ((_ height: CGFloat) -> Void)?
    @objc var moreButtonClosure: ((_ url: String) -> Void)?
    
    var exchangeType: YXExchangeType = .hk
    
    var stockModel: YXNewStockDetailInfoModel?
    
    var ipoType: YXNewStockEcmType = .onlyPublic
    
    func refreshUI(_ model: YXNewStockDetailInfoModel) -> Void {
        
        stockModel = model
        nameLabel.text = model.stockName ?? "--"
        if let stockCode = model.stockCode {
            symbolLabel.text = String(format: "(%@)", stockCode)
        } else {
            symbolLabel.text = ""
        }
        
        
        let serverUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.serverTime)
        let financeUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.financingEndTime)
        
        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }
        
        internalPlaceLabel.isHidden = true
        if subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)) {
            
            let ecmUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.ecmEndTime)
            if ecmUnixTime > 0, ecmUnixTime > serverUnixTime, let ecmStatus = model.ecmStatus, ecmStatus == YXNewStockPurcahseStatus.purchasing.rawValue  {
                
                self.ipoType = .both
                internalPlaceLabel.isHidden = false
                var string = YXLanguageUtility.kLang(key: "newStock_internal_placement")
                if let text = model.ecmAppLinkDto?.ecmLabel, text.count > 0 {
                    string += ("-" + text)
                }
                internalPlaceLabel.text = string
            } else if ecmUnixTime > 0, ecmUnixTime <= serverUnixTime {
                self.ipoType = .bothButInternalEnd
            }
            
            //现金融资都截止或处于待开始, 只有国际认购可以认购
            if (subscribeWayArray.count == 1 || internalPlaceLabel.isHidden == false) && model.status != YXNewStockPurcahseStatus.purchasing.rawValue {
                self.ipoType = .onlyInternal  //ipo现金认购 处于待开始
            }
        }
        
        var financeExternHeight: CGFloat = 0
        bankFinanceLabel.isHidden = true
     
        if self.exchangeType == .hk, subscribeWayArray.contains(String(YXNewStockSubsType.financingSubs.rawValue)),
            let financingMultiple = model.financingMultiple, financingMultiple > 0,
            financeUnixTime > 0, financeUnixTime > serverUnixTime,
            model.status == YXNewStockPurcahseStatus.purchasing.rawValue {
            bankFinanceLabel.isHidden = false
            bankFinanceLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_bank_finance_tag"), financingMultiple)
            
            if internalPlaceLabel.isHidden == true {
                bankFinanceLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(stockPdfButton.snp.right).offset(7)
                    make.centerY.equalTo(stockPdfButton.snp.centerY)
                    make.right.lessThanOrEqualToSuperview().offset(-14)
                }
            } else {
                
                let ecmWidth = (internalPlaceLabel.text! as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).size.width
                
                let financeWidth = (bankFinanceLabel.text! as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).size.width
                
                if financeWidth < YXConstant.screenWidth - 36 - 14 * 2 - 7 * 2 - 16 * 2 - ecmWidth - stockPdfButton.frame.width {
                    bankFinanceLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(internalPlaceLabel.snp.right).offset(7)
                        make.centerY.equalTo(stockPdfButton.snp.centerY)
                        make.right.lessThanOrEqualToSuperview().offset(-14)
                    }
                } else {
                    financeExternHeight = 30
                    bankFinanceLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(stockPdfButton.snp.left)
                        make.top.equalTo(stockPdfButton.snp.bottom).offset(8)
                        make.right.lessThanOrEqualToSuperview().offset(-14)
                    }
                }
                
            }
        }
        
        
        //股票状态
        var beginTime = "--"
        var endTime = "--"
        var publishTime = "--"
        var listingTime = "--"
        
        if let time = model.beginTime, time.count >= 10 {
            beginTime = (time as NSString).substring(with: NSMakeRange(5, 5))
        }
        if let lastestEndTime = model.latestEndtime, lastestEndTime.count >= 10 {
            endTime = (lastestEndTime as NSString).substring(with: NSMakeRange(5, 5))
        }
        if let time = model.publishTime, time.count >= 10 {
            publishTime = (time as NSString).substring(with: NSMakeRange(5, 5))
        }
        if let time = model.listingTime, time.count >= 10 {
            listingTime = (time as NSString).substring(with: NSMakeRange(5, 5))
        }
        var status = YXNewStockDetailStatusView.YXNewStockType.end
        
        var purchaseStatus: YXNewStockPurcahseStatus = YXNewStockPurcahseStatus.currentStatus(model.status)
        
        if self.ipoType == .onlyInternal {
            purchaseStatus = YXNewStockPurcahseStatus.currentStatus(model.ecmStatus)
        }
        if purchaseStatus == .purchasing {
            //认购中
            status = .start
        } else if (purchaseStatus == .announceedWaitMarket) {
            //公布中签
            status = .publish
        } else if (purchaseStatus == .marketed) {
            //已上市
            status = .listing
        } else if let remainingTime = model.remainingTime, remainingTime <= 0 {
            //截止认购
            status = .end
        }
        
        if model.greyFlag == 1 {
            var darkTradeTime = "--"
            var greyTime = model.greyTradeDate
            let greyUnixTime = YXNewStockDateFormatter.shortUnixTime(greyTime)
            let shortServerTime = YXNewStockDateFormatter.shortUnixTime(model.serverTime)
            if let time = model.greyTradeDate, time.count >= 10 {
                darkTradeTime = (time as NSString).substring(with: NSMakeRange(5, 5))
                greyTime = (time as NSString).substring(to: 10)
            }
            
            statusView.setTradeStatusArray([.start, .end, .publish, .greyTrade, .listing], columns: 3)
            statusView.setDateArr([beginTime, endTime, publishTime, darkTradeTime, listingTime])
            
            if greyUnixTime > 0, shortServerTime >= greyUnixTime, status != .listing {
                status = .greyTrade
            } 
            if greyUnixTime > 0, shortServerTime > greyUnixTime, status == .greyTrade {
                statusView.setStockType(status, progress: 0.5)
            } else {
                statusView.setStockType(status)
            }
        } else {
            statusView.setDateArr([beginTime, endTime, publishTime, listingTime])
            statusView.setStockType(status)
        }
        
        if subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)), subscribeWayArray.count == 1 {
            statusView.setOnlyInternalSubs(true) //self.ipoType == .onlyInternal
        }
        if self.exchangeType == .us {
            statusView.setUSPulishText()
        }
        
        var greyHeight: CGFloat = 0
        if model.greyFlag == 1 {
            greyHeight = 56
            if YXUserManager.isENMode() {
                greyHeight = 76
            }
        }
        statusView.snp.updateConstraints { (make) in
            make.height.equalTo(64 + greyHeight)
        }
        
        var externHeight = greyHeight
        if let ecmText = model.ecmAppLinkDto?.ecmText, internalPlaceLabel.isHidden == false, let data = ecmText.data(using: .utf8) {
            explainLabel.isHidden = false
            let attributedString = NSAttributedString.init(htmlData: data, options: [DTDefaultTextColor : QMUITheme().foregroundColor().withAlphaComponent(0.8)], documentAttributes: nil)
            let layouter = DTCoreTextLayouter.init(attributedString: attributedString)
            let maxRect = CGRect.init(x: 0.0, y: 0.0, width: (YXConstant.screenWidth - 24 - 30), height: CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
            let entireString = NSMakeRange(0, attributedString?.length ?? 0)
            let layoutFrame = layouter?.layoutFrame(with: maxRect, range: entireString)
            let height: CGFloat = layoutFrame?.frame.size.height ?? 0.0
            let topMargin: CGFloat = height > 0 ? 13 : 0
            explainLabel.attributedString = attributedString
            explainLabel.snp.updateConstraints { (make) in
                make.height.equalTo(height)
                make.top.equalTo(stockPdfButton.snp.bottom).offset(topMargin + financeExternHeight)
            }
            
            externHeight += (height + topMargin)
        } else {
            explainLabel.isHidden = true
            explainLabel.snp.updateConstraints { (make) in
                make.height.equalTo(0)
                make.top.equalTo(stockPdfButton.snp.bottom).offset(financeExternHeight)
            }
        }
        
        //处理结束时间
        externHeight += handleEndTime(model)
        externHeight += financeExternHeight
        refreshHeightClosure?(externHeight)
    }
    
    
    func handleEndTime(_ model: YXNewStockDetailInfoModel) -> CGFloat {
        
        let lastestEndTime: String = model.latestEndtime ?? "--"
        typeLabel1.text = ""
        typeLabel2.text = ""
        typeLabel3.text = ""
        
        typeDateLabel1.text = ""
        typeDateLabel2.text = ""
        typeDateLabel3.text = ""
        dateLabel.text = ""
        
        var endTimeArray: [String] = []
        var endTimeTitleArray: [String] = []
        
        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }
        
        if let ecmEndTime = model.ecmEndTime, ecmEndTime.count > 0, subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)) {
            
            endTimeArray.append(ecmEndTime)
            if subscribeWayArray.count == 1 {
                endTimeTitleArray.append(YXLanguageUtility.kLang(key: "ecm_subs_endtime"))
            } else {
                endTimeTitleArray.append(YXLanguageUtility.kLang(key: "newStock_internal_placement"))
            }
        }
        
        if let endTime = model.endTime, endTime.count > 0, subscribeWayArray.contains(String(YXNewStockSubsType.cashSubs.rawValue)) {
            
            endTimeArray.append(endTime)
            if subscribeWayArray.count == 1 {
                endTimeTitleArray.append(YXLanguageUtility.kLang(key: "cash_subs_endtime"))
            } else {
                endTimeTitleArray.append(YXLanguageUtility.kLang(key: "public_subs_cash"))
            }
        }
        
        if let financeTime = model.financingEndTime, financeTime.count > 0, subscribeWayArray.contains(String(YXNewStockSubsType.financingSubs.rawValue)) {
            
            endTimeArray.append(financeTime)
            endTimeTitleArray.append(YXLanguageUtility.kLang(key: "public_subs_finance"))
        }
        
        if endTimeArray.count > 1 {
            typeLabel1.text = endTimeTitleArray[0]
            typeLabel2.text = endTimeTitleArray[1]
            
            if endTimeArray.count > 2 {
                typeLabel3.text = endTimeTitleArray[2]
            }
            
            //first end time item
            var endTimeString = endTimeArray[0]
            if endTimeString.count >= 16 {
                endTimeString = (endTimeString as NSString).substring(to: 16)
            }
            typeDateLabel1.text = endTimeString
            //second end time item
            endTimeString = endTimeArray[1]
            if endTimeString.count >= 16 {
                endTimeString = (endTimeString as NSString).substring(to: 16)
            }
            typeDateLabel2.text = endTimeString
            //third end time item
            if endTimeArray.count > 2 {
                endTimeString = endTimeArray[2]
                if endTimeString.count >= 16 {
                    endTimeString = (endTimeString as NSString).substring(to: 16)
                }
                typeDateLabel3.text = endTimeString
            }
            return 24.0 + (YXUserManager.isENMode() ? 15 : 0)
            
        } else {
            if endTimeArray.count == 1, self.exchangeType == .hk {
                endDateLabel.text = endTimeTitleArray[0]
                var endTimeString = endTimeArray[0]
                if endTimeString.count >= 16 {
                    endTimeString = (endTimeString as NSString).substring(to: 16)
                }
                dateLabel.text = endTimeString
            } else {
                endDateLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_endTime")
                if lastestEndTime.count >= 16 {
                    dateLabel.text = (lastestEndTime as NSString).substring(to: 16)
                } else {
                    dateLabel.text = lastestEndTime
                }
            }
            return 0.0
        }
        
    }
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.minimumScaleFactor = 12.0 / 20.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var stockPdfButton: QMUIButton = {
        
        let button = QMUIButton()
        button.setImage(UIImage(named: "stock_pdf"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_stockpdf"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(stockPdfButtonEvent), for: .touchUpInside)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 6.0
        button.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 1.0
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()
    
    //*倍银行融资 标签
    lazy fileprivate var bankFinanceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().themeTextColor()
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        label.layer.cornerRadius = 4
        label.backgroundColor = UIColor.qmui_color(withHexString: "#E5EDFF")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.layer.masksToBounds = true
        return label
    }()
    
    //国际配售 标签
    lazy fileprivate var internalPlaceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().themeTextColor()
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        label.layer.cornerRadius = 4
        label.backgroundColor = UIColor.qmui_color(withHexString: "#E5EDFF")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.layer.masksToBounds = true
        return label
    }()
    
    @objc lazy var rightArrowButton: YXExpandAreaButton = {
        
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "common_arrow"), for: .normal)
        
        return button
    }()
    
    lazy var stockDetailButton: QMUIButton = {
        let button = QMUIButton()
        button.addTarget(self, action: #selector(rightArrowButtonEvent), for: .touchUpInside)
        return button
    }()
    
    //股票状态
    @objc lazy var statusView: YXNewStockDetailStatusView = {
        let view = YXNewStockDetailStatusView()
        view.setTradeStatusArray([.start, .end, .publish, .listing])
        return view
    }()
    
    @objc lazy var expanseButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "stock_feed_about"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_feed_about"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.6), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(expanseButtonEvent), for: .touchUpInside)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4.0
        button.isHidden = true
        return button
        
    }()
    
    @objc lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_endTime")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var typeLabel1: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var typeLabel2: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "public_subs_cash")
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var typeLabel3: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var typeDateLabel1: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var typeDateLabel2: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var typeDateLabel3: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var explainLabel: DTAttributedLabel = {
        let label = DTAttributedLabel()
        label.delegate = self
        label.backgroundColor = UIColor.clear
        return label;
    }()
    //招股书点击事件
    @objc func stockPdfButtonEvent() -> Void {
        if let closure = pdfClosure {
            if let model = stockModel, let prospectusLink = model.prospectusLink {
                closure(prospectusLink)
            }
        }
    }
    
    //费用说明
    @objc func expanseButtonEvent() -> Void {
        
        if let closure = expanseClosure {
            closure()
        }
    }
    
    @objc func rightArrowButtonEvent() {
        if let closure = self.stockDetailClosure, let model = self.stockModel, let stockCode = model.stockCode{
            closure(model.exchangeType ?? 0, stockCode, model.stockName ?? "")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        asyncRender()
    }
    
    func asyncRender() {
        self.backgroundColor = UIColor.qmui_color(withHexString: "#52A1E3")
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = UIColor.qmui_color(withHexString: "#52A1E3")?.cgColor
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        
        addSubview(nameLabel)
        addSubview(symbolLabel)
        addSubview(stockPdfButton)
        addSubview(rightArrowButton)
        addSubview(stockDetailButton)
        addSubview(bankFinanceLabel)
        addSubview(internalPlaceLabel)
        addSubview(explainLabel)
        
        rightArrowButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.right.equalTo(snp.right).offset(-13)
            make.width.equalTo(6)
            make.height.equalTo(11)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(18)
            make.right.lessThanOrEqualTo(rightArrowButton.snp.left).offset(-60)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.left.equalTo(nameLabel.snp.right).offset(3)
            make.right.lessThanOrEqualTo(rightArrowButton.snp.left).offset(-3)
        }
        
        stockDetailButton.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        stockPdfButton.snp.makeConstraints { (make) in
            
            make.height.equalTo(22)
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        internalPlaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(stockPdfButton.snp.right).offset(7)
            make.centerY.equalTo(stockPdfButton.snp.centerY)
            make.right.lessThanOrEqualToSuperview().offset(-14)
        }
        
        bankFinanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(stockPdfButton.snp.centerY)
            make.left.equalTo(internalPlaceLabel.snp.right).offset(7)
            make.right.lessThanOrEqualToSuperview().offset(-14)
        }
        
        explainLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(snp.right).offset(-14)
            make.top.equalTo(stockPdfButton.snp.bottom).offset(0)
            make.height.equalTo(0)
        }
        
        addSubview(statusView)
        addSubview(expanseButton)
        addSubview(endDateLabel)
        addSubview(dateLabel)
        addSubview(typeLabel1)
        addSubview(typeLabel2)
        addSubview(typeLabel3)
        
        addSubview(typeDateLabel1)
        addSubview(typeDateLabel2)
        addSubview(typeDateLabel3)
        
        statusView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(64)
            make.top.equalTo(explainLabel.snp.bottom).offset(20)
        }
        
        expanseButton.snp.makeConstraints { (make) in
            make.top.equalTo(statusView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        endDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            //make.right.lessThanOrEqualTo(expanseButton.snp.left)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(endDateLabel.snp.bottom).offset(5)
            make.left.equalTo(endDateLabel.snp.left)
        }
        
        
        let typeLabelArray = [typeLabel1, typeLabel2, typeLabel3]
        typeLabelArray.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: uniHorLength(12), leadSpacing: 18, tailSpacing: 18)
        typeLabelArray.snp.makeConstraints { (make) in
            make.top.equalTo(endDateLabel.snp.bottom).offset(10)
        }
        
        let typeDateLabelArray = [typeDateLabel1, typeDateLabel2, typeDateLabel3]
        typeDateLabelArray.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: uniHorLength(12), leadSpacing: 18, tailSpacing: 18)
        typeDateLabelArray.snp.makeConstraints { (make) in
            make.top.equalTo(typeLabel2.snp.bottom).offset(6)
        }
    }
}


extension YXNewStockDetailPurchaseView: DTAttributedTextContentViewDelegate {
    func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
        
        let button = DTLinkButton.init(frame: frame)
        button.url = url
        button.guid = identifier
        button.addTarget(self, action: #selector(clickMoreButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc func clickMoreButton(sender: DTLinkButton) {
        if let action = self.moreButtonClosure {
            action(sender.url.absoluteString)
        }
    }
}
