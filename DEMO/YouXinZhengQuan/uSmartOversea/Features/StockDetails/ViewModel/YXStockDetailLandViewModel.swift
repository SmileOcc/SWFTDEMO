//
//  YXStockDetailLandViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YYModel
import URLNavigator
import YXKit

class YXStockDetailLandViewModel: HUDServicesViewModel {
    
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    //market/symbol/name
    var market = "" {
        didSet {
            self.exchangeType = YXToolUtility.getExchangeType(with: YXMarketType.init(rawValue: self.market) ?? YXMarketType.HK)
        }
    }
    
    var exchangeType: YXExchangeType = .hk
    var symbol = ""
    var name: String?
    var type1: Int32?
    var type2: Int32?
    var type3: Int32?
    
    var timeLineValue = "1"
    var isFromLandVC = false
    // 判断是否是从竖屏进来的,只用一次这个属性,然后置为true
    var isFromStockDetailVC = false
    var kLineData: YXKLineData?

    var selectIndexBlock: ((Int)->())?
    
    var direction: OBJECT_QUOTEKLineDirection {
        let type = YXKLineConfigManager.shareInstance().adjustType
        if type == .notAdjust {
            return .kdNone
        } else if type == .preAdjust {
            return .kdForward
        } else {
            return .kdBackward
        }
    }
    
    var greyFlag = false
    
    /// 从个股详情竖屏传进来的
    var selectTsType: YXTimeShareLineType?
    
    //params
    var level: QuoteLevel {
        
        if self.greyFlag {
            if YXUserManager.isLogin() {
                return .level2
            } else {
                return .delay
            }
        }

        if market == kYXMarketCryptos {
            return .level1
        }

        if let quote = self.quoteModel,
           let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)), type2 == .stLowAdr {
            return .delay
        }

        return YXUserManager.shared().getLevel(with: self.market)
    }
    
    var timeLineType: String = "1"
    
    // 股票类型
    var stockType: YXStockDetailStockType {
        
        let type1 = OBJECT_SECUSecuType1(rawValue: Int32(self.type1 ?? 0))
        let type3 = OBJECT_SECUSecuType3(rawValue: Int32(self.type3 ?? 0))
        if type1 == .st1None || type1 == .stStock { //stock
            if market.elementsEqual(YXMarketType.HK.rawValue) {
                return .hkStock
            } else if market.elementsEqual(YXMarketType.US.rawValue) {
                return .usStock
            } else {
                return .shStock
            }
        } else if type1 == .stIndex { //index
            return .stIndex
        } else if type1 == .stSector { //sector
            return .stSector
        } else if type1 == .stFund { //fund
            return .fund
        } else if type3 == .stWarrant { //warrant
            return .stWarrant
        } else if type3 == .stCbbc { //cbbc
            return .stCbbc
        }  else if type3 == .stUsWarrant {
            return .stUsWarrant
        } else if self.market == kYXMarketUsOption {
            return .stUsStockOpt
        }
        return .hkStock
        
    }
    //quote数据
    var quoteModel: YXV2Quote?
   
    //step/service
    typealias Services = YXQuotesDataService
    var services: YXQuotesDataService! = YXQuotesDataService()
    
    var navigator: NavigatorServicesType!
    
    let newStockService = YXNewStockService()

    var holdAssetSubject = PublishSubject<Double>()
    var klineOrderSubject = PublishSubject<YXKLineOrderModel>()
    var timeLineOrderSubject = PublishSubject<YXKLineOrderModel>()
    
    //init
    var dataSource: [YXStockInputModel] = []

    var selectIndex: Int = 0 //当前数据源在 dataSource 中的位置
    
    // 趋势长盈数据
    var isRequestSignal = false
    var signalList: [YXUsmartSignalModel]?
    var lastKlineData: YXKLine?
    var lastTimelineData: YXTimeLine?
    
    init() {
        
    }

    init(dataSource: [YXStockInputModel], selectIndex: Int) {
        self.dataSource = dataSource
        self.selectIndex = selectIndex

        if self.selectIndex >= self.dataSource.count {
            self.selectIndex = self.dataSource.count - 1
        }
        let input = self.dataSource[self.selectIndex]

        setCurrentDataSource(input)
    }

    func setCurrentDataSource(_ input: YXStockInputModel) {

        self.market = input.market
        self.symbol = input.symbol
        self.name = input.name

        self.type1 = input.type1

        self.type2 = input.type2

        self.type3 = input.type3

        if market == YXMarketType.HK.rawValue {
            self.exchangeType = .hk
        } else if market == YXMarketType.US.rawValue {
            self.exchangeType = .us
        } else if market == YXMarketType.ChinaHS.rawValue {
            self.exchangeType = .hs
        } else if market == YXMarketType.ChinaSZ.rawValue {
            self.exchangeType = .sz
        } else if market == YXMarketType.ChinaSH.rawValue {
            self.exchangeType = .sh
        } else if market == YXMarketType.USOption.rawValue {
            self.exchangeType = .usop
        }

        timeLineType = "1"
        greyFlag = false

        timeLineType = "0"
        kLineData = nil

        self.quoteModel = nil

        timeLineValue = "1"

        kLineData = nil

        lastKlineData = nil
        lastTimelineData = nil
    }
}


extension YXStockDetailLandViewModel {

    func loadHoldAssetData() {
        let requestModel = YXStockSingleAssetRequestModel()
        requestModel.stockCode = self.symbol

        if self.market == YXMarketType.HK.rawValue {
            requestModel.exchangeType = 0
        } else if self.market == YXMarketType.US.rawValue {
            requestModel.exchangeType = 5
        } else {
            requestModel.exchangeType = 67
        }

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let `self` = self else { return }
            if responseModel.code == YXResponseStatusCode.success, let data = responseModel.data {
                let model = YXJYHoldStockModel.yy_model(withJSON: data)
                if let holdModel = model, let costPrice = Double(holdModel.costPrice ?? "0") {
                    self.holdAssetSubject.onNext(costPrice)
                }
            }
            }, failure: { (request) in

        })

    }


    func loadKLineOrderData(_ klineData: YXKLineData) {
        return
        /* 加载K线订单条件
         * 1.用户在设置中打开显示买卖点
         * 2.在当前为日K模式下
         * 3.该只股票可以交易 且 用户可以交易该只股票
         * 4.K线会缓存之前请求的数据，只需要在viewWillAppear, 下拉刷新，加载更多时 请求接口
         */

        guard let quoteModel = self.quoteModel, YXKLineConfigManager.shareInstance().lineType == .dayKline, (YXKLineConfigManager.shareInstance().showBuySellPoint || YXKLineConfigManager.shareInstance().showCompanyActionPoint), (YXStockDetailTool.canShowShortcut(quoteModel) || YXStockDetailTool.canOptionTrade(quoteModel)) else {
            return
        }

        guard let list = klineData.list, list.count > 0 else {
            return
        }
        
        self.requestLineOrder(beginDate: Int64(klineData.list?.first?.latestTime?.value ?? 0), endDate: Int64(klineData.list?.last?.latestTime?.value ?? 0), type: "kline1Day") { [weak self] (model) in
            guard let `self` = self else { return }

            YXStockDetailTool.mergeOrderDataToKLine(orderModel: model, klineData: self.kLineData)
            self.lastKlineData = self.kLineData?.list?.last
            self.klineOrderSubject.onNext(model)
        }
    }

    func loadTimeLineOrderData(_ timelineData: YXTimeLineData) {
        return
        /* 加载K线订单条件
         * 1.用户在设置中打开显示买卖点
         * 2.在当前为1日分时模式下
         * 3.该只股票可以交易 且 用户可以交易该只股票
         *  分时每次http请求都会覆盖之前的数据，买卖点都需要重新请求
         */
        guard let quoteModel = self.quoteModel, YXKLineConfigManager.shareInstance().lineType == .dayTimeLine, YXKLineConfigManager.shareInstance().showBuySellPoint, (YXStockDetailTool.canShowShortcut(quoteModel) || YXStockDetailTool.canOptionTrade(quoteModel)) else {
            return
        }

        guard let list = timelineData.list, list.count > 0 else {
            return
        }

        self.requestLineOrder(beginDate: Int64(timelineData.list?.first?.latestTime?.value ?? 0), endDate: Int64(timelineData.list?.last?.latestTime?.value ?? 0), type: "timeline1Day") { [weak self] (model) in
            guard let `self` = self else { return }

            self.timeLineOrderSubject.onNext(model)
        }
    }

    func requestLineOrder(beginDate: Int64, endDate: Int64, type: String, completion: @escaping ((_ model: YXKLineOrderModel) -> Void)) {
        // 2022.3.4 此接口赞不用请求
        return
        let requestModel = YXKLineOrderRequestModel()
        requestModel.market = self.market
        requestModel.symbol = self.symbol
        requestModel.type = type
        requestModel.beginDate = beginDate
        requestModel.endDate = endDate

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if responseModel.code == YXResponseStatusCode.success, let data = responseModel.data {
                let model = YXKLineOrderModel.yy_model(withJSON: data)
                if let holdModel = model, let list = holdModel.list, list.count > 0 {
                    completion(holdModel)
                }
            }
        }, failure: { (request) in

        })
    }

}
