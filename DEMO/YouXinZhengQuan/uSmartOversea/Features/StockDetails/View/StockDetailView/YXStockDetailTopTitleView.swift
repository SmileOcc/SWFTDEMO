//
//  YXStockDetailTopTitleView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailTopTitleView: UIView {
    
    //model
    var quoteModel: YXV2Quote? {
        didSet {
            refreshUI()
        }
    }

//    override func didMoveToSuperview() {
//        if superview != nil {
//            autoresizingMask = [ .flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleHeight]
//        }
//    }

    var changeStockClosure: ((_ isPre: Bool) -> Void)?

    override func invalidateIntrinsicContentSize() {

    }
    
    var market = YXMarketType.HK.rawValue
    
    var nameTapBlock: ((_ name: String) -> Void)?
    
    var isDelay = false
    var isTop = false
    
    var lastMarketDes = ""
    var lastMarketStatus: Int32 = 0

    var canTriggered = true //是否可以触发回调
    var panGesture: UIPanGestureRecognizer?

    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.textAlignment = .center
        return label
    }()

    lazy var bottomView: UIView = {
        let view = UIView()

        return view
    }()

    lazy var statusContainerView: UIView = {
        let view = UIView()

        return view
    }()
    
    lazy var statusLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    lazy var nowLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        
        nameLabel.rx.tapGesture().subscribe(onNext: {
            [weak self] (ges) in
            guard let `self` = self else { return }

            self.logoClickAction()

        }).disposed(by: rx.disposeBag)
        
        statusLabel.rx.tapGesture().subscribe(onNext: {
            [weak self] (ges) in
            guard let `self` = self, let text = self.statusLabel.text else { return }
            let width = (text as NSString).boundingRect(with: CGSize(width: 1000, height: 25), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : self.statusLabel.font!], context: nil).size.width
            if width > self.statusLabel.frame.width {
                self.nameTapBlock?(self.statusLabel.text ?? "")
            }
        }).disposed(by: rx.disposeBag)
        
    }

    func addChangeStockPanGesture() {
        if self.panGesture != nil {
            return
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(processPan(gesture:)))
        panGesture.delegate = self
        self.panGesture = panGesture
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {

        self.clipsToBounds = true

        addSubview(bottomView)
        bottomView.layer.masksToBounds = true

        bottomView.addSubview(statusContainerView)
        bottomView.addSubview(nowLabel)

        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }

        statusContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(14)
        }

        nowLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(14)
            make.top.equalTo(statusContainerView.snp.bottom)
        }


        statusContainerView.addSubview(statusLabel)

        statusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(14)
        }


        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(5)
            make.leading.equalToSuperview()
        }
    }

    func scrollToTop(_ toTop: Bool) {
        if isTop == toTop {
            return
        }
        isTop = toTop
        if toTop {
            statusContainerView.snp.updateConstraints { (make) in

                make.top.equalToSuperview().offset(-14)
            }
        } else {
            statusContainerView.snp.updateConstraints { (make) in

                make.top.equalToSuperview().offset(0)
            }
        }

        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }


    //實時數據
    func refreshUI() {
        
        //name
        var stockName = "--"
        var stockSymbol = "--"
        if let market = quoteModel?.market, market == kYXMarketCryptos {
            if let name = quoteModel?.btInfo?.name {
                stockName = name
            }
            
            if let symbol = quoteModel?.btInfo?.displayedSymbol {
                stockSymbol = symbol
            }
            
            
        } else {

            if let name = quoteModel?.name {
                stockName = name
            }
            
            if let symbol = quoteModel?.symbol {
                stockSymbol = symbol
            }
            
            if let market = quoteModel?.market {
                if market == kYXMarketUsOption {
                    stockSymbol += ("." + kYXMarketUS.uppercased())
                } else {
                    stockSymbol += ("." + market.uppercased())
                }
                
            }
            
        }
        nameLabel.text = stockName
        statusLabel.text = stockSymbol
        refreshStatusLabel()

    }
    
    //marketstatus
    func refreshStatusLabel() {
//        var statusString = ""
//        if let desc = quoteModel?.msInfo?.desc, desc.count > 0 {
//            statusString = desc
//            lastMarketDes = desc
//        }
//
//        if let status = quoteModel?.msInfo?.status?.value {
//
//            if lastMarketStatus == status, statusString.isEmpty {
//                statusString = lastMarketDes
//            }
//            //记录上次的市场状态, 防止推送没有值把字段覆盖
//            lastMarketStatus = status
//        }
//
//        var isListing = true  //是否是上市状态（非 停牌，退市，暂停上市，未上市状态）
//        var isPreAfterCanTrade = false //是否是美股盘前盘后
//
//        //美股盘前盘后优先级最高，其次是待上市，已退市等状态
//        if YXStockDetailTool.isShowPreAfterQuote(quoteModel), let price = quoteModel?.sQuote?.latestPrice?.value, price > 0 {
//            isPreAfterCanTrade = true
//        }
//
//        if quoteModel?.greyFlag?.value ?? 0 == 0, !isPreAfterCanTrade {
//            let status = Int(quoteModel?.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue)
//            var str: String?
//            if status == OBJECT_QUOTETradingStatus.tsSuspended.rawValue ||
//                status == OBJECT_QUOTETradingStatus.tsVolatility.rawValue {
//                str = YXLanguageUtility.kLang(key: "stock_detail_suspenden")
//            } else if status == OBJECT_QUOTETradingStatus.tsDelisting.rawValue  {
//                str = YXLanguageUtility.kLang(key: "stock_detail_delisted")
//            }  else if status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
//                str = YXLanguageUtility.kLang(key: "stock_detail_beforList")
//            } else if status == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
//                str = YXLanguageUtility.kLang(key: "zanting")
//            }
//            if let text = str {
//                isListing = false
//                statusString = text
//            }
//        }
//
//        var timeString = ""
//
//        if (quoteModel?.greyFlag?.value ?? 0 != 0 &&  quoteModel?.msInfo?.status?.value == OBJECT_MARKETMarketStatus.msGreyPreOpen.rawValue) || !isListing {
//
//        } else {
//            //time
//            if let time = quoteModel?.latestTime?.value, time > 0 {
//                let timeModel: YXDateModel = YXDateToolUtility.dateTime(withTime: String(time))
//                var timeStr = String(format: "%@-%@ %@:%@:%@", timeModel.month, timeModel.day, timeModel.hour, timeModel.minute, timeModel.second)
//                if self.market == YXMarketType.US.rawValue {
//                    timeStr = timeStr + "  " + YXLanguageUtility.kLang(key: "stock_detail_us_time")
//                }
//
//                if statusString.isEmpty {
//                    timeString = timeStr
//                } else {
//                    timeString = " " + timeStr
//                }
//
//            }
//        }
//
//        var delayString = ""
//
//        var level = QuoteLevel.delay
//        if let userLevel = QuoteLevel(rawValue: Int(quoteModel?.level?.value ?? 0)) {
//            level = userLevel
//        }
//
//        if quoteModel?.market == kYXMarketCryptos {
//            level = .level1
//        }
//
//        if level == .delay,
//           quoteModel?.greyFlag?.value ?? 0 == 0,
//           isListing {
//            delayString = " " + YXLanguageUtility.kLang(key: "stock_detail_delayTime")
//        }
//
//        let statusText = statusString + timeString + delayString
//        if statusText.isEmpty {
//            statusLabel.text = "--"
//        } else {
//            statusLabel.text = statusText
//        }
        
        var priceBasic = 1
        if let priceBase = quoteModel?.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }
        
        //now
        if let market = quoteModel?.market, market == kYXMarketCryptos {
            if let nowStr = quoteModel?.btRealTime?.now, let _ = Double(nowStr) {
         
                var nowString = YXToolUtility.btNumberString(nowStr)
                
                var changeStr = "0.000"
                if let netchng = quoteModel?.btRealTime?.netchng {
                    changeStr = YXToolUtility.btNumberString(netchng, showPlus: true)
                }
                
                nowString = nowString + " " + changeStr
                
                var rocString = "0.00%"
                if let rocStr = quoteModel?.btRealTime?.pctchng, let roc = Double(rocStr) {
                    rocString = (roc > 0 ? "+" : "") + rocStr + "%"
                    nowLabel.textColor = YXToolUtility.changeColor(Double(roc))
                }
                nowString = nowString + " " + rocString
                nowLabel.text = nowString
            } else {
                nowLabel.text = "--"
            }
        } else {
            if let now = quoteModel?.latestPrice?.value, now > 0 {
                var nowString = YXToolUtility.stockPriceData(Double(now), deciPoint: priceBasic, priceBase: priceBasic) ?? "--"
                
                var changeString = "0.000"
                if let change = quoteModel?.netchng?.value {
                    changeString = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic) ?? changeString
                    if change > 0 {
                        changeString = "+" + changeString
                    }
                    nowLabel.textColor = YXToolUtility.changeColor(Double(change))
                }
                nowString = nowString + " " + changeString
                
                var rocString = "0.00%"
                if let roc = quoteModel?.pctchng?.value {
                    rocString = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2) ?? rocString
                   // nowLabel.textColor = YXToolUtility.changeColor(Double(roc))
                }
                nowString = nowString + " " + rocString
                nowLabel.text = nowString
            } else {
                nowLabel.text = "--"
            }
        }
        
    }

    func setDefaultStockInfo(_ name: String?, market: String, symbol: String) {
        //name
        if market == kYXMarketUsOption {
            nameLabel.text = name ?? symbol
            statusLabel.text = symbol + "." + kYXMarketUS.uppercased()
        } else if market == kYXMarketCryptos {
            nameLabel.text = name
        } else {
            nameLabel.text = name
            statusLabel.text = symbol + "." + market.uppercased()
        }
        
        

    }


    @objc func logoClickAction() {

        var name = self.quoteModel?.symbol ?? ""
        if let market = quoteModel?.market {
            if market == kYXMarketCryptos, let symbol = quoteModel?.btInfo?.displayedSymbol {
                name = symbol
            } else if market == kYXMarketUsOption, let stockname = quoteModel?.name {
                name = stockname
            }
        }

        let width = (name as NSString).boundingRect(with: CGSize(width: 1000, height: 25), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : self.nameLabel.font!], context: nil).size.width

        if width > self.nameLabel.frame.width {
            self.nameTapBlock?(name)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.bounds.size
    }

}


extension YXStockDetailTopTitleView: UIGestureRecognizerDelegate {

    @objc fileprivate func processPan(gesture: UIPanGestureRecognizer) {


        switch gesture.state {
            case .began:
                canTriggered = true
            case .changed:
                if canTriggered {
                    let translation = gesture.translation(in: self)
                    if translation.x > 50 {
                        changeCurrentStock(isPre: true)
                    } else if translation.x < -50 {
                        changeCurrentStock(isPre: false)
                    }
                }

            case .cancelled, .ended, .failed:

                if canTriggered {
                    let velocity = gesture.velocity(in: gesture.view)
                    if velocity.x < -1000 {
                        changeCurrentStock(isPre: false)
                    } else if velocity.x > 1000 {
                        changeCurrentStock(isPre: true)
                    }
                }

            default:
                break
        }
    }

    fileprivate func changeCurrentStock(isPre: Bool) {

        if canTriggered {
            canTriggered = false
            self.changeStockClosure?(isPre)
        }
    }
}
