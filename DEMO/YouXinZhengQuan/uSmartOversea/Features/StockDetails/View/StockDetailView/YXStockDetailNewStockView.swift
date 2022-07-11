//
//  YXStockDetailNewStockView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailNewStockView: YXStockDetailBaseView {

    enum NewStockStatus {
        case normal
        case greyTrade     //暗盘交易当天非暗盘交易中
        case greyTrading   //暗盘交易中
    }

    var clickBlock: (() -> Void)?
    var greyTradingType: YXNewStockDetailStatusView.GreyTradingType = .none
    var refreshHeightClosure: ((_ height: CGFloat) -> Void)?
    var status: NewStockStatus = .normal {
        didSet {

        }
    }

    var greyFlag: Bool = false {
        didSet {
            if greyFlag {
                bottomView.isHidden = true
            }
        }
    }

    var firstFillData = true


    func refreshUI(_ model: YXNewStockDetailInfoModel) -> Void {


        firstFillData = false
        var isOnlyEcm = false

        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }

        if subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)) {

            /*
             var isSupportEcm = false
             let serverUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.serverTime)
             let ecmUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.ecmEndTime)
             if ecmUnixTime > 0, ecmUnixTime > serverUnixTime, let ecmStatus = model.ecmStatus, ecmStatus == YXNewStockPurcahseStatus.purchasing.rawValue  {
             isSupportEcm = true
             }
             */
            //现金融资都截止或处于待开始, 只有国际认购可以认购
            if subscribeWayArray.count == 1 { //|| (isSupportEcm && model.status != YXNewStockPurcahseStatus.purchasing.rawValue)
                isOnlyEcm = true
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

        if isOnlyEcm {
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


        if self.greyFlag {

            var greyTime = ""
            //暗盘交易当天
            statusView.setTradeStatusArray([.publish, .greyTrade, .listing], columns: 3)
            if self.greyTradingType == .noOpen {
                status = .publish
            } else {
                status = .greyTrade
            }
            statusView.setStockType(status)
            statusView.setGreyTradingType(self.greyTradingType)
            if let time = model.publishTime, time.count >= 10 {
                publishTime = (time as NSString).substring(with: NSMakeRange(0, 10))
            }
            if let time = model.listingTime, time.count >= 10 {
                listingTime = (time as NSString).substring(with: NSMakeRange(0, 10))
            }
            if let time = model.greyTradeDate, time.count >= 10 {
                greyTime = (time as NSString).substring(with: NSMakeRange(0, 10))
            }

            if let startTime = model.greyTimeBegin, startTime.count >= 5,
                let endTime = model.greyTimeEnd, endTime.count >= 5 {
                let start = startTime.subString(toCharacterIndex: 5)
                let end = endTime.subString(toCharacterIndex: 5)
                greyTime += ("\n" + start + "~" + end)
            }
            statusView.setDateArr([publishTime, greyTime, listingTime])

        } else {
            if model.greyFlag == 1 {
                var darkTradeTime = "--"
                let greyUnixTime = YXNewStockDateFormatter.shortUnixTime(model.greyTradeDate)
                let shortServerTime = YXNewStockDateFormatter.shortUnixTime(model.serverTime)
                if let time = model.greyTradeDate, time.count >= 10 {
                    darkTradeTime = (time as NSString).substring(with: NSMakeRange(5, 5))
                }
                statusView.setTradeStatusArray([.start, .end, .publish, .greyTrade, .listing], columns: 3)
                statusView.setDateArr([beginTime, endTime, publishTime, darkTradeTime, listingTime])

                if greyUnixTime > 0, shortServerTime > greyUnixTime, status != .listing {

                    status = .greyTrade
                    //暗盘已结束
                    statusView.setStockType(status, progress: 0.5)
                } else {
                    //暗盘未开盘
                    statusView.setStockType(status)
                }
            } else {
                statusView.setDateArr([beginTime, endTime, publishTime, listingTime])
                statusView.setStockType(status)
            }
        }
        statusView.setOnlyInternalSubs(isOnlyEcm)

        var greyHeight: CGFloat = 0
        if model.greyFlag == 1 {
            greyHeight = 60
            if YXUserManager.isENMode() {
                greyHeight = 72
            }
        }
        statusView.snp.updateConstraints { (make) in

            if YXUserManager.isENMode() {
                make.height.equalTo(72 + greyHeight)
            } else {
                make.height.equalTo(60 + greyHeight)
            }
        }

        if self.greyFlag {

            let ipoExternHeight: CGFloat = 24

            if self.ipoInfoTitleView.superview == nil {

                statusView.snp.updateConstraints { (make) in
                    make.top.equalTo(self.snp.top).offset(44)
                }

                self.addSubview(self.ipoInfoTitleView)
                self.ipoInfoTitleView.snp.makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.height.equalTo(44)
                }
            }
            self.ipoInfoTitleView.isHidden = false
            refreshHeightClosure?(100 + ipoExternHeight + (YXUserManager.isENMode() ? 20 : 0))
        } else {
            var externHeight = greyHeight

            //处理结束时间
            externHeight += handleEndTime(model)

            refreshHeightClosure?(externHeight + 170)
        }

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
            return 14.0 + (YXUserManager.isENMode() ? 15 : 0)

        } else {
            if endTimeArray.count == 1 {
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
                if ges.state == .ended {
                    self.clickBlock?()
                }

            }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initUI() -> Void {

        addSubview(statusView)
        addSubview(bottomView)
        bottomView.addSubview(endDateLabel)
        bottomView.addSubview(dateLabel)
        bottomView.addSubview(typeLabel1)
        bottomView.addSubview(typeLabel2)
        bottomView.addSubview(typeLabel3)

        bottomView.addSubview(typeDateLabel1)
        bottomView.addSubview(typeDateLabel2)
        bottomView.addSubview(typeDateLabel3)

        statusView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if YXUserManager.isENMode() {
                make.height.equalTo(76)
            } else {
                make.height.equalTo(60)
            }
            make.top.equalTo(self.snp.top).offset(20)
        }

        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(statusView.snp.bottom).offset(18)
        }

        endDateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
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

    //股票状态
    @objc lazy var statusView: YXNewStockDetailStatusView = {
        let view = YXNewStockDetailStatusView()
        view.circleSelectedColor = QMUITheme().mainThemeColor()
        view.circleNormalColor = UIColor.qmui_color(withHexString: "#ACACAC")!
        view.lineSelectedColor = QMUITheme().mainThemeColor()
        view.lineNormalColor = UIColor.qmui_color(withHexString: "#ACACAC")!
        view.titleLabelSelectedColor = QMUITheme().mainThemeColor()
        view.titleLabelNormalColor = QMUITheme().textColorLevel2()
        view.dateLabelSelectedColor = QMUITheme().textColorLevel2()
        view.dateLabelNormalColor = QMUITheme().textColorLevel2()
        view.circleType = .ring
        view.setTradeStatusArray([.start, .end, .publish, .listing])
        return view
    }()

    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()


    @objc lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_endTime")
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()

    lazy var typeLabel1: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel2().withAlphaComponent(0.6)
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
        label.textColor = QMUITheme().textColorLevel2().withAlphaComponent(0.6)
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
        label.textColor = QMUITheme().textColorLevel2().withAlphaComponent(0.6)
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
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()


    lazy var typeDateLabel2: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()

    lazy var typeDateLabel3: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0 / 12.0
        label.textAlignment = .left
        return label
    }()


    lazy var ipoInfoTitleView: UIView = {
        let view = UIView()
  
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "stock_ipo_info")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        let arrowButton = QMUIButton()
        arrowButton.setTitle(YXLanguageUtility.kLang(key: "webview_detailTitle"), for: .normal)
        arrowButton.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        arrowButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        arrowButton.imagePosition = .right
        arrowButton.spacingBetweenImageAndTitle = 6
        arrowButton.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        arrowButton.isUserInteractionEnabled = false
        view.addSubview(arrowButton)
        arrowButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-11)
            make.centerY.equalToSuperview()
        }
        return view
    }()

}
