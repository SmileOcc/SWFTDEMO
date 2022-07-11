//
//  YXStockAnalyzeTradeView.swift
//  uSmartOversea
//
//  Created by 裴艳东 on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockAnalyzeTradeView: UIView {

    @objc var tabClickBlock: ((_ type: Int) -> Void)?
    
    var baseValue: Int64 {
        
        if YXUserManager.isENMode() {
            return 1000
        } else {
            return 10000
        }
    }

    @objc var model: YXStockAnalyzeBrokerListModel? {
        didSet {

            if (model?.blist == nil || (model?.blist.isEmpty ?? false)) && (model?.slist == nil || (model?.slist.isEmpty ?? false)) {
                noDataView.isHidden = false
                containerView.snp.updateConstraints { (make) in
                    make.height.equalTo(CGFloat(itemCount) * itemHeight + CGFloat(15))
                }
                return
            } else {
                noDataView.isHidden = true
            }

            if let latestTime = model?.latestTime {
                if selectIndex == 0 {
                    let timeString = YXDateHelper.commonDateStringWithNumber(UInt64(latestTime), format: .DF_MDYHM)
                    timeLabel.text = String(format: YXLanguageUtility.kLang(key: "broker_buy_sell_update_tip"), timeString)
                } else {
                    let timeString = YXDateHelper.commonDateStringWithNumber(UInt64(latestTime))
                    timeLabel.text = String(format: YXLanguageUtility.kLang(key: "broker_buy_sell_history_update_tip"), timeString)
                }
            }
            var maxValue: Int64 = 0
            var maxCount: Int = 0
            if let holdVolume = model?.blist.first?.holdVolume {
                maxValue = holdVolume
            }
            if let holdVolume = model?.slist.first?.holdVolume, maxValue < abs(holdVolume) {
                maxValue = holdVolume
            }
            //买入
            var buyList: [YXStockAnalyzeBrokerListDetailInfo] = []
            if let tempBuylist = model?.blist, !tempBuylist.isEmpty {
                buyList = tempBuylist
            }
            maxCount = buyList.count
            //卖出
            var sellList: [YXStockAnalyzeBrokerListDetailInfo] = []
            if let tempSellList = model?.slist, !tempSellList.isEmpty {
                sellList = tempSellList
            }

            if sellList.count > maxCount {
                maxCount = sellList.count
            }

            for (index, view) in buyViewArray.enumerated() {
                if index < buyList.count {
                    let info = buyList[index]
                    var name = ""
                    if let tempName = self.brokerDic[info.brokerCode] as? String {
                        name = tempName
                    }
                    view.drawProgress(name: name, maxValue: abs(maxValue), currentValue: info.holdVolume, base: baseValue)
                } else {
                    if index >= maxCount {
                        view.drawProgress(name: "", maxValue:0, currentValue: 0, base: baseValue)
                    } else {
                        view.drawProgress(name: "--", maxValue:0, currentValue: 0, base: baseValue, emptyString: "+0.00")
                    }
                }
            }

            for (index, view) in sellViewArray.enumerated() {
                if index < sellList.count {
                    let info = sellList[index]
                    var name = ""
                    if let tempName = self.brokerDic[info.brokerCode] as? String {
                        name = tempName
                    }
                    view.drawProgress(name: name, maxValue: -abs(maxValue), currentValue: info.holdVolume, base: baseValue)
                } else {
                    if index >= maxCount {
                        view.drawProgress(name: "", maxValue:0, currentValue: 0, base: baseValue)
                    } else {
                        view.drawProgress(name: "--", maxValue:0, currentValue: 0, base: baseValue, emptyString: "-0.00")
                    }
                }
            }

            containerView.snp.updateConstraints { (make) in
                make.height.equalTo(CGFloat(maxCount > itemCount ? itemCount : maxCount) * itemHeight + CGFloat(15))
            }

        }

    }

    @objc func stockClickAction(_ sender: YXStockAnalyzeProportionView) {

        var namesArray: [YXStockAnalyzeBrokerStockInfo] = []
        var list: [YXStockAnalyzeBrokerListDetailInfo] = []
        var index: Int = 0
        if sender.alignment == .right {
            index = sender.tag - 1500
            if let tempBuylist = model?.blist, !tempBuylist.isEmpty {
                list = tempBuylist
            }
        } else {
            index = sender.tag - 2000
            if let tempSellList = model?.slist, !tempSellList.isEmpty {
                list = tempSellList
            }
        }

        for (index, info) in list.enumerated() {
            if index >= 10 {
                break
            }
            var name = ""
            if let tempName = self.brokerDic[info.brokerCode] as? String {
                name = tempName
            }
            let detailModel = YXStockAnalyzeBrokerStockInfo()
            detailModel.name = name
            detailModel.code = info.brokerCode
            namesArray.append(detailModel)
        }

        if index < namesArray.count {
            self.clickBlock?(["index" : index,
                              "brokerInfo" : namesArray])
        }

    }

    @objc var clickBlock: ((_ params: [String: Any]) -> Void)?

    @objc var brokerDic: [String : Any] = [:]
    var selectIndex: UInt = 0
    var itemCount: Int = 5
    var itemHeight: CGFloat = 46.0
    var level: QuoteLevel = .delay


    @objc init(frame: CGRect = CGRect.zero, level: QuoteLevel, itemCount: Int = 5, defaultTabSelectIndex: UInt = 0) {
        super.init(frame: frame)
        self.level = level
        self.itemCount = itemCount
        self.selectIndex = defaultTabSelectIndex
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var sellViewArray: [YXStockAnalyzeProportionView] = []
    var buyViewArray: [YXStockAnalyzeProportionView] = []

    func initUI() {

        addSubview(tabView)
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }

        addSubview(unitLabel)
        unitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(tabView.snp.bottom).offset(6)
        }
        unitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)


        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(tabView.snp.bottom).offset(6)
            make.right.lessThanOrEqualTo(unitLabel.snp.left).offset(-4)
        }

        let width = (YXConstant.screenWidth - 32 - 27) / 2.0

        addSubview(buyLabel)
        addSubview(sellLabel)
        buyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(22)
            make.height.equalTo(22)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(width)
        }

        sellLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(22)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(width)
        }

        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(buyLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(5.0 * itemHeight + 15)
            make.bottom.equalToSuperview()
        }

        for i in 0..<self.itemCount {
            let buyview = YXStockAnalyzeProportionView(frame: CGRect.zero, alignment: .right, maxWidth: width, isBuy: true)
            let sellview = YXStockAnalyzeProportionView(frame: CGRect.zero, alignment: .left, maxWidth: width, isBuy: false)
            buyview.tag = 1500 + i
            sellview.tag = 2000 + i
            addSubview(buyview)
            addSubview(sellview)
            buyview.snp.makeConstraints { (make) in
                make.width.equalTo(width)
                make.height.equalTo(itemHeight)
                make.top.equalTo(buyLabel.snp.bottom).offset(4 + CGFloat(i) * itemHeight)
                make.left.equalTo(buyLabel)
            }

            sellview.snp.makeConstraints { (make) in
                make.width.equalTo(width)
                make.height.equalTo(itemHeight)
                make.top.equalTo(sellLabel.snp.bottom).offset(4 + CGFloat(i) * itemHeight)
                make.left.equalTo(sellLabel)
            }

            buyview.addTarget(self, action: #selector(stockClickAction(_:)), for: .touchUpInside)
            sellview.addTarget(self, action: #selector(stockClickAction(_:)), for: .touchUpInside)

            sellViewArray.append(sellview)
            buyViewArray.append(buyview)
        }

        addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.bottom.equalTo(containerView)
        }
    }

    lazy var layout: YXTabLayout = {
        let layout = YXTabLayout.default()
        layout.lrMargin = 16.0
        layout.tabMargin = 0
        layout.tabWidth = (YXConstant.screenWidth - 32.0) / CGFloat(self.titles.count)
        layout.lineColor = QMUITheme().themeTextColor()
        layout.titleColor = QMUITheme().textColorLevel2()
        layout.titleSelectedColor = QMUITheme().themeTextColor()
        layout.titleFont = UIFont.systemFont(ofSize: 14)
        layout.titleSelectedFont = UIFont.systemFont(ofSize: 14)
        layout.lineWidth = 16
        layout.lineHeight = 4
        layout.lineCornerRadius = 2
        return layout
    }()

    lazy var tabView: YXTabView = {

        let view = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 26), with: self.layout)
        view.titles = self.titles
        view.delegate = self
        view.defaultSelectedIndex = self.selectIndex
        return view
    }()


    var titles: [String] {
        var titles = [YXLanguageUtility.kLang(key: "real_time"),
                      YXLanguageUtility.kLang(key: "recent_one_day"),
                      YXLanguageUtility.kLang(key: "recent_five_day"),
                      YXLanguageUtility.kLang(key: "recent_twenty_day"),
                      YXLanguageUtility.kLang(key: "recent_sixty_day")]
        if self.level != .level2 {
            titles = [YXLanguageUtility.kLang(key: "recent_one_day"),
                      YXLanguageUtility.kLang(key: "recent_five_day"),
                      YXLanguageUtility.kLang(key: "recent_twenty_day"),
                      YXLanguageUtility.kLang(key: "recent_sixty_day")]
        }
        return titles
    }

    lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "broker_buy_unit")
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()


    lazy var buyLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "broker_buy_1")
        return label
    }()

    lazy var sellLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "broker_sell_1")
        return label
    }()

    lazy var noDataView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        //view.setCenterYOffset(-20)
        return view
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

}

extension YXStockAnalyzeTradeView: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {

        let arr = [0, 1, 2, 3, 4]
        self.selectIndex = index
        if index < arr.count {
            self.tabClickBlock?(arr[Int(index)])
        }
    }
}


extension YXStockAnalyzeTradeView {

    @objc func updateLevel(_ level: QuoteLevel) {
        if level != self.level {
            self.level = level

            if self.level == .level2 {
                self.selectIndex += 1
            } 
            self.layout.tabWidth = (YXConstant.screenWidth - 32.0) / CGFloat(self.titles.count)
            self.tabView.titles = self.titles
            self.tabView.defaultSelectedIndex = self.selectIndex
            self.tabView.reloadData()
        }
    }

}
