//
//  YXStockDetailLineView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailLineView: YXStockDetailBaseView {
    
    var selectUsmartAccessCallBack: (()->())?
    
    var isHkIndex = false {
        didSet {
            self.timeLineView.isIndexStock = self.isHkIndex
            self.kLineView.isIndexStock = self.isHkIndex
        }
    }

    var isCryptos = false

    var quoteModel: YXV2Quote?
    
    var lineType: YXRtLineType = YXKLineConfigManager.shareInstance().lineType
    
    var chartSettingCallBack: (() -> Void)?
    
    var selectTpyeCallBack: ((_ selectType: YXRtLineType) -> ())?

    var updateExternHeightBlock: ((_ externHeight: CGFloat) -> ())?

    var pushToLandscapeBlock: (() -> Void)?

    var klineLoadMoreBlock: (() -> Void)?

    var doubleTapClosure: (() -> Void)?

    var requestCYQDataBlock: (() -> Void)?
    
    var market: String = kYXMarketHK

    var isOptionStock = false {
        didSet {
            setOptionStockUI()
        }
    }
    
    lazy var klineTabView: YXKlineTabView = {
        var rect: CGRect!
        if isLand {
            rect = CGRect.init(x: 0, y: 0, width: YXConstant.screenHeight - rightLandMargin - YXConstant.navBarPadding(), height: portraitTabHeight - 1)
        } else {
            rect = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth - portraitRightMargin, height: portraitTabHeight - 1)
        }
        let view = YXKlineTabView.init(frame: rect)
        view.hasMinKExpand = true
        return view
    }()

    var isLand = true

    var rPadding: CGFloat = 0 {
        didSet {
            if oldValue == self.rPadding {
                return
            }

            if isCryptos {
                self.btTimeLineView.frame = self.getTimeLineFrame()
                self.btTimeLineView.reload()
                self.loadingView.frame = self.btTimeLineView.frame
                self.noDataView.frame = self.btTimeLineView.frame
            } else {
                self.timeLineView.frame = self.getTimeLineFrame()
                self.timeLineView.reload()
                self.loadingView.frame = self.timeLineView.frame
                self.noDataView.frame = self.timeLineView.frame
            }
        }
    }

    var klinePadding: CGFloat = 0 {
        didSet {
            if oldValue == self.klinePadding {
                return
            }

            self.kLineView.frame = self.getKLineFrame()
            self.kLineView.reload()

            self.loadingView.frame = self.kLineView.frame
            self.noDataView.frame = self.kLineView.frame            
        }
    }

    var holdPrice: Double = 0 {
        didSet {
            self.kLineView.holdPrice = holdPrice
            self.timeLineView.holdPrice = holdPrice
            self.btTimeLineView.holdPrice = holdPrice
            if self.lineType == .dayTimeLine || self.lineType == .fiveDaysTimeLine {
                if isCryptos {
                    self.btTimeLineView.reload()
                } else {
                    self.timeLineView.reload()
                }
            } else {
                self.kLineView.reload()
            }
        }
    }

    let portraitRightMargin: CGFloat = 35
    let portraitTabHeight: CGFloat = 40
    let landTabHeight: CGFloat = 40
    let portraitTotalHeight: CGFloat = 320
    let portraitDealWidth: CGFloat = 140
    let kAccessoryViewHeight: CGFloat = 20
    let rightLandMargin: CGFloat = 140.0
    
    //MARK: Initialize
    init(frame: CGRect, market: String, isLand: Bool) {

        super.init(frame: frame)
        self.market = market
        if market == kYXMarketCryptos {
            self.isCryptos = true
        }
        self.isLand = isLand
        initUI()
        handleBlock()
        setDefaultSelectIndex()
        self.loadingView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let tabLineView = UIView.line()
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(self.klineTabView)
        addSubview(tabLineView)
        
        klineTabView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.height.equalTo(portraitTabHeight - 1)
            make.top.equalToSuperview()
            if self.isLand {
                make.trailing.equalToSuperview().offset(-rightLandMargin)
            } else {
                make.trailing.equalToSuperview().offset(-portraitRightMargin)
            }
        }
        
        tabLineView.snp.makeConstraints { make in
            make.bottom.equalTo(klineTabView)
            make.height.equalTo(0.5)
            if self.isLand {
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            } else {
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }            
        }
                
        if (self.isLand) {

            addSubview(scrollView)
            scrollView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.top.equalToSuperview()
            }
            self.sendSubviewToBack(self.scrollView)
            addSubview(self.timeLineView)
            addSubview(self.btTimeLineView)
            scrollView.addSubview(self.kLineView)

            self.timeLineView.reload()
        } else {

            addSubview(self.timeLineView)
            addSubview(self.btTimeLineView)
            addSubview(self.kLineView)

            self.timeLineView.reload()

            addSubview(chartSettingButton)
            chartSettingButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(klineTabView.snp.centerY)
                make.trailing.equalToSuperview().offset(-13)
                make.width.equalTo(20)
                make.height.equalTo(21)
            }

            addSubview(tickStatisticalView)
            tickStatisticalView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.timeLineView)
                make.top.equalTo(klineTabView.snp.bottom).offset(0.5)
                make.right.equalTo(self).offset(-16)
                make.width.equalTo(portraitDealWidth)
            }


            addSubview(accessoryView)
            accessoryView.snp.makeConstraints { (make) in
                make.top.equalTo(self.kLineView.snp.bottom)
                make.left.equalTo(self).offset(16)
                make.right.equalTo(self).offset(-16)
                make.height.equalTo(kAccessoryViewHeight)
            }
        }

        addSubview(noDataView)
        noDataView.frame = self.timeLineView.frame
        noDataView.isHidden = true

        addSubview(loadingView)
        loadingView.frame = self.timeLineView.frame
        loadingView.isHidden = true

        klineTabView.updateTypeCallBack = { [weak self] tabview in
            guard let `self` = self else { return }
            if self.isOptionStock {

                if self.lineType == tabview.rtLineType {
                    return
                }

                self.lineType = tabview.rtLineType
                YXKLineConfigManager.shareInstance().lineType = self.lineType
                self.refreshUIWithIndex(self.lineType)
                self.selectTpyeCallBack?(self.lineType)

            } else {
                var lineType = tabview.rtLineType
                if tabview.hasMinKExpand && lineType == .oneMinKline && tabview.subKlineType != .none {
                    lineType = YXStockDetailUtility.getRtKline(with: tabview.subKlineType)
                }
                self.lineType = lineType
                YXKLineConfigManager.shareInstance().lineType = self.lineType
                self.refreshUIWithIndex(self.lineType)
                self.selectTpyeCallBack?(self.lineType)
            }
        }
    }
    
    @objc func chartSettingClick(_ sender: UIButton) {
        
        chartSettingCallBack?()
    }

    //横屏切换 分时，K线类型时，同步
    func reloadSelectTable() {

        self.kLineView.resetSetting()
        let rtLineType = YXKLineConfigManager.shareInstance().lineType
        if rtLineType == self.lineType {
            return
        }
        self.lineType = rtLineType
        changeSelectTab(rtLineType: rtLineType)
    }

    func changeSelectTab(rtLineType: YXRtLineType) {
        if (self.isOptionStock) {
            self.klineTabView.isOption = true
            self.klineTabView.rtLineType = rtLineType
            
        } else {
            if rtLineType.rawValue < YXRtLineType.oneMinKline.rawValue {
                self.klineTabView.rtLineType = rtLineType
            } else {
                self.klineTabView.rtLineType = .oneMinKline
                self.klineTabView.subKlineType = YXStockDetailUtility.getRtSubKline(with: rtLineType)
            }
        }
        self.refreshUIWithIndex(rtLineType)
    }

    //设置初始选中的tab 为上次用户最后选择的类型
    func setDefaultSelectIndex() {

        let rtLineType = YXKLineConfigManager.shareInstance().lineType
        self.lineType = rtLineType
        changeSelectTab(rtLineType: rtLineType)
    }

    //更新图标高度(分时 和 K线图表高度不一致）
    func setCurrentLineTypeHeight() {
        var externHeight: CGFloat = 0
        if (self.lineType  == .dayTimeLine || self.lineType  == .fiveDaysTimeLine) {
            externHeight = 0
        } else {
            var count = YXKLineConfigManager.shareInstance().subAccessoryArray.count
            if (count <= 0) {
                count = 0
            }
            externHeight = CGFloat(count - 1) * self.kLineView.secondaryViewHeight
            let rect = self.getKLineFrame()
            if self.isLand {
                if (externHeight < 0) {
                    externHeight = 0
                }

                self.kLineView.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: self.kLineView.defaultHeight + externHeight)
                self.kLineView.reload()
                self.scrollView.contentSize = CGSize(width: rect.width, height: self.kLineView.frame.height + portraitTabHeight)
            } else {

                if YXKLineConfigManager.shareInstance().subAccessoryArray.count == 0 {
                    externHeight += 20
                }
                self.kLineView.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: self.kLineView.defaultHeight + externHeight)
                self.kLineView.reload()
            }
        }
        self.updateExternHeightBlock?(externHeight - 10)
    }

    //布局期权UI
    func setOptionStockUI() {

        self.kLineView.resetSetting()
        
        let rtLineType = YXKLineConfigManager.shareInstance().lineType
        changeSelectTab(rtLineType: rtLineType)
                
        self.lineType = rtLineType
        YXKLineConfigManager.shareInstance().lineType = rtLineType
    }


//    func reLayoutLandTabViewItemWidth() {
//        var rightPadding: CGFloat = rightLandMargin
//        if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine || YXKLineConfigManager.shareInstance().lineType == .fiveDaysTimeLine {
//
//            if self.rPadding > 0 {
//                rightPadding = rPadding
//            }
//
//        } else {
//            if self.klinePadding > 0 {
//                rightPadding = self.klinePadding + 60
//            }
//         }
//
//        tabLayout.lrMargin = 0
//        tabLayout.tabMargin = 0
//
//        let width: CGFloat = (max(YXConstant.screenWidth, YXConstant.screenHeight) - tabLayout.lrMargin * 2 - YXConstant.navBarPadding() - rightPadding) / CGFloat(landTabTitles.count)
//        tabLayout.tabWidth = width
//
//        tabView.snp.updateConstraints { (make) in
//
//            make.trailing.equalToSuperview().offset(-rightPadding)
//        }
//
//        self.popoverButton.snp.updateConstraints { (make) in
//            make.width.equalTo(self.tabLayout.tabWidth)
//            make.trailing.equalTo(tabView.snp.trailing).offset(-self.tabLayout.lrMargin)
//        }
//
//        tabView.reloadData()
//    }


    //MARK: Lazy Loading view

    lazy var timeLineView: YXTimeLineView = {
        let timeLineView = YXTimeLineView.init(frame: self.getTimeLineFrame())
        timeLineView.canTapPush = !self.isLand
        timeLineView.isLandscape = self.isLand
        timeLineView.isHidden = true
        return timeLineView
    }()

    lazy var kLineView: YXKLineView = {
        let view = YXKLineView(frame: self.getKLineFrame(), andIsLandscape: self.isLand)
        view?.canTapPush = !self.isLand
        view?.isHidden = true
        view?.hideHistoryTimeLine = true
        if let klineView = view {
            return klineView
        }
        return YXKLineView()
    }()

    lazy var btTimeLineView: YXBTTimeLineView = {
        let view = YXBTTimeLineView(frame: self.getTimeLineFrame(), andIsLandscape: self.isLand)
        view?.canTapPush = !self.isLand
        view?.isHidden = true
        if let timeLineView = view {
            return timeLineView
        }
        return YXBTTimeLineView()
    }()

    //setting
    lazy var chartSettingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chart_setting"), for: .normal)
        button.addTarget(self, action: #selector(self.chartSettingClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy var noDataView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()

        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "common_no_data")
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        label.sizeToFit()
        if self.isLand {
            let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
            doubleTapGes.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTapGes)
        }

        return view
    }()

    @objc func doubleTapAction() {
        self.doubleTapClosure?()
    }

    
//    lazy var tabLayout: YXTabLayout = {
//        let layout = YXTabLayout.default()
//        layout.titleColor = QMUITheme().textColorLevel2()
//        layout.titleSelectedColor = QMUITheme().mainThemeColor()
//        layout.lineHidden = true
//        layout.lineColor = QMUITheme().mainThemeColor()
//        layout.lrMargin = 0
//        layout.tabMargin = 0
//        if self.isLand {
//            width = (max(YXConstant.screenWidth, YXConstant.screenHeight) - layout.lrMargin * 2 - YXConstant.navBarPadding() - rightLandMargin) / CGFloat(landTabTitles.count)
//            layout.tabWidth = width
//        } else {
//            layout.lrMargin = 3
//            layout.tabPadding = 10
//        }
//
//        layout.titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
//        layout.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: .medium)
//
//        return layout
//    }()

    //逐笔 和 成交统计视图
    lazy var tickStatisticalView: YXStockDetailTickAndStatisticalView = {
        let view = YXStockDetailTickAndStatisticalView(frame: .zero, market: self.market)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    //筹码分布视图
    lazy var cyqView: YXCYQView = {
        let view = YXCYQView(frame: CGRect.init(x: 0, y: 0, width: portraitDealWidth, height: self.getKLineFrame().height - 20 + 5))
        view.isLand = self.isLand
        view.isHidden = true
        return view
    }()

    var loadingView = YXStockDetailLoadingView.init()
    //主副指标设置视图
    lazy var accessoryView: YXKlineAccessoryView = {
        let view = YXKlineAccessoryView(frame: .zero, isLand: false)
        view.chipsCYQCallBack = {
            [weak self] _ in
            guard let `self` = self else { return }
            YXCYQUtility.saveCYQState(true)
            self.pushToLandscapeBlock?()
        }
        return view
    }()

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()

        return view
    }()
}
//MARK: 筹码分布相关
extension YXStockDetailLineView {

    func handleShowCYQView() {
        if YXStockDetailTool.isShowCYQ(self.quoteModel), self.lineType == .dayKline {
            self.accessoryView.showCYQ = true
        } else {
            self.accessoryView.showCYQ = false
        }
    }

}

//分时, K线回调
extension YXStockDetailLineView {

    func handleBlock() {

        //K线副视图切换回调
        self.kLineView.clickSubAccessoryView = {
            [weak self] in
            guard let `self` = self, let list = self.kLineView.klineModel.list else { return }
            if list.count == 0 {
                return
            }

            if YXKLineConfigManager.shareInstance().subAccessoryArray.count == 1,
                let obj = YXKLineConfigManager.shareInstance().subAccessoryArray.firstObject as? NSNumber {
                YXKLineConfigManager.shareInstance().subAccessoryArray.removeAllObjects()
                let status = obj.intValue

                let count = YXKLineConfigManager.shareInstance().subArr.count
                for i in 0..<count {
                    let number = YXKLineConfigManager.shareInstance().subArr[i]
                    if let num = number as? NSNumber, num.intValue == status {
                        if i == count - 1 {
                            if let tempNum = YXKLineConfigManager.shareInstance().subArr.firstObject as? NSNumber, let _ = YXStockSubAccessoryStatus(rawValue: tempNum.intValue) {

                                YXKLineConfigManager.shareInstance().subAccessoryArray.append(tempNum)
                            }
                        } else {
                            if let tempNum = YXKLineConfigManager.shareInstance().subArr[i + 1] as? NSNumber, let _ = YXStockSubAccessoryStatus(rawValue: tempNum.intValue) {

                                YXKLineConfigManager.shareInstance().subAccessoryArray.append(tempNum)
                            }
                        }
                        break
                    }
                }

                self.accessoryView.resetSubStatus()
                YXKlineCalculateTool.shareInstance().calAccessoryValue(self.kLineView.klineModel)
                self.kLineView.drawAllSecondaryView();
            }

        }
        //(MA, EMA, BOLL, SAR)指标切换
        self.accessoryView.mainParameterCallBack = { [weak self] type in

            guard let `self` = self else { return }
            self.kLineView.resetMainAccessory(type)
            self.selectUsmartAccessCallBack?()
        }
        //(ARBR, DMA, MACD, KDJ, MAVOL, RSI, EMV, WR, CR)指标切换
        self.accessoryView.subParameterCallBack = { [weak self] type in

            guard let `self` = self else { return }
            self.kLineView.resetSubAccessory(type)

            self.setCurrentLineTypeHeight()
        }
        //跳转横屏回调
        self.timeLineView.pushToLandscapeRightCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.pushToLandscapeBlock?()
        }

        self.btTimeLineView.pushToLandscapeRightCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.pushToLandscapeBlock?()
        }

        //跳转横屏回调
        self.kLineView.pushToLandscapeRightCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.pushToLandscapeBlock?()
        }
        //K线加载更多回调
        self.kLineView.loadMoreCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.klineLoadMoreBlock?()
        }
        //筹码分布视图点击回调
        self.cyqView.singleTapClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.pushToLandscapeBlock?()
        }
    }
}


//MARK: 分时，k线相关
extension YXStockDetailLineView {

    //根据选择的图标类型，控制视图Frame 和 显示隐藏
    func refreshUIWithIndex(_ lineType: YXRtLineType) {
        var isTimeLineHide = false
        var isKlineHide = false
        var isDealHide = false
        if lineType == .dayTimeLine || lineType == .fiveDaysTimeLine {
            isTimeLineHide = false
            isKlineHide = true

            if lineType == .dayTimeLine, YXStockDetailTool.isShowTick(self.quoteModel) {
                isDealHide = false
            } else { //5日分时不展示逐笔
                isDealHide = true
            }

            self.timeLineView.frame = getTimeLineFrame()
            self.btTimeLineView.frame = getTimeLineFrame()
            self.loadingView.frame = self.timeLineView.frame
            self.noDataView.frame = self.timeLineView.frame

        } else {
            isTimeLineHide = true
            isKlineHide = false
            isDealHide = true
            self.loadingView.frame = self.kLineView.frame
            self.noDataView.frame = self.kLineView.frame
        }

        self.noDataView.isHidden = true
        if isCryptos {
            self.btTimeLineView.isHidden = isTimeLineHide
            self.timeLineView.isHidden = true
        } else {
            self.timeLineView.isHidden = isTimeLineHide
            self.btTimeLineView.isHidden = true
        }
        self.kLineView.isHidden = isKlineHide
        self.loadingView.isHidden = false
        if !self.isLand && isCryptos {
            self.tickStatisticalView.isHidden = true
        } else {
            self.tickStatisticalView.isHidden = isDealHide
        }
        self.accessoryView.isHidden = isKlineHide

        self.handleShowCYQView()
        self.setCurrentLineTypeHeight()
    }

    //获取分时视图Frame
    func getTimeLineFrame() -> CGRect {
        if self.isLand {
            return CGRect.init(x: 0, y: landTabHeight + 8, width: YXConstant.screenHeight - YXConstant.navBarPadding() - self.rPadding, height: YXConstant.screenWidth - 97 - 8 - (YXConstant.deviceScaleEqualToXStyle() ? 10.0 : 0.0))
        } else {

            var padding: CGFloat = 0

            if !isCryptos, YXStockDetailTool.isShowTick(self.quoteModel), self.lineType == .dayTimeLine {
                padding = portraitDealWidth
            }

            return CGRect(x: 16, y: portraitTabHeight + 8, width: YXConstant.screenWidth - padding - 32, height: portraitTotalHeight - portraitTabHeight - 10 - 8)
        }
    }

    //获取K线视图Frame
    func getKLineFrame() -> CGRect {
        if self.isLand {
            return CGRect.init(x: 0, y: landTabHeight + 4, width: YXConstant.screenHeight - YXConstant.navBarPadding() - 64 - self.klinePadding, height: YXConstant.screenWidth - 97 - 4 - (YXConstant.deviceScaleEqualToXStyle() ? 10.0 : 0.0))
        } else {

            return CGRect.init(x: 16, y: portraitTabHeight, width: YXConstant.screenWidth - 32 - self.klinePadding, height: portraitTotalHeight - portraitTabHeight - 10 - kAccessoryViewHeight)
        }
    }

    //分时视图 填充数据
    func refreshTimeLineView(_ model: YXTimeLineData?) {
        if model == nil || (model?.list?.isEmpty ?? true) {
            self.noDataView.isHidden = false
            self.timeLineView.isHidden = true
            self.btTimeLineView.isHidden = true
        } else {
            self.noDataView.isHidden = true
            self.timeLineView.isHidden = false
            self.btTimeLineView.isHidden = true
        }
        self.kLineView.isHidden = true
        timeLineView.timeLineModel = model
        timeLineView.reload()
    }

    //K线视图 填充数据
    func refreshKLineView(_ model: YXKLineData?) {
        guard self.klineTabView.rtLineType != .dayTimeLine && self.klineTabView.rtLineType != .fiveDaysTimeLine else { return }
        if model == nil || (model?.list?.isEmpty ?? true) {
            self.noDataView.isHidden = false
            self.kLineView.isHidden = true
        } else {
            self.noDataView.isHidden = true
            self.kLineView.isHidden = false
        }
        self.timeLineView.isHidden = true
        self.btTimeLineView.isHidden = true
        self.handleShowCYQView()
        kLineView.klineModel = model
        //横屏指标切换，竖屏时要同步
        kLineView.mainAccessoryStatus = YXKLineConfigManager.shareInstance().mainAccessory
        kLineView.reload()
    }

    //数字货币分时视图 填充数据
    func refreshBTTimeLineView(_ model: YXKLineData?) {
        if model == nil || (model?.list?.isEmpty ?? true) {
            self.noDataView.isHidden = false
            self.timeLineView.isHidden = true
            self.btTimeLineView.isHidden = true
        } else {
            self.noDataView.isHidden = true
            self.timeLineView.isHidden = true
            self.btTimeLineView.isHidden = false
        }
        self.kLineView.isHidden = true
        btTimeLineView.frame = self.getTimeLineFrame()
        btTimeLineView.lineType = YXKLineConfigManager.shareInstance().lineType

        self.handleShowCYQView()
        btTimeLineView.klineModel = model
        btTimeLineView.reload()
    }

    //更新逐笔视图布局（未登录 -> 到登录 lv1, lv2 的分时和tick的布局会变化）
    func updateTickView(_ quoteModel: YXV2Quote?) {

        self.quoteModel = quoteModel

        if !isCryptos, YXStockDetailTool.isShowTick(quoteModel) && self.klineTabView.rtLineType == .dayTimeLine {
            self.tickStatisticalView.isHidden = false
        } else {
            self.tickStatisticalView.isHidden = true
        }
        if isCryptos {
            self.btTimeLineView.frame = self.getTimeLineFrame()
        } else {
            self.timeLineView.frame = self.getTimeLineFrame()
        }
        self.loadingView.frame = self.getTimeLineFrame()
        self.noDataView.frame = self.getTimeLineFrame()
    }

}

