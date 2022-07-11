//
//  YXStockDetailTool.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailTool: NSObject {

    static let shared = YXStockDetailTool()

    var stockSelectIndex = 0
    
    @objc class func pageBottomInsets() -> CGFloat {
        if YXConstant.deviceScaleEqualToXStyle() {
            return YXConstant.tabBarPadding() + 10
        } else {
            return 20
        }
    }

    @objc class func isShowTick(_ quote: YXV2Quote?) -> Bool {
        if let greyFlag = quote?.greyFlag?.value, greyFlag > 0, YXUserManager.isLogin() {
            return true
        }

        //期权
        if let market = quote?.market,
           market == kYXMarketUsOption,
           YXUserManager.isOption(kYXMarketUS),
           YXUserManager.shared().getOptionLevel() == .level1 {
            return true
        }

        //数字货币
        if let market = quote?.market,
           market == kYXMarketCryptos {
            return true
        }
        
        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stIndex.rawValue {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stSector.rawValue {
            return false
        }

        if let value = quote?.trdStatus?.value, value == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stStock.rawValue, let type2 = quote?.type2?.value, type2 == OBJECT_SECUSecuType2.stLowAdr.rawValue {
            return false
        }

        let level = YXUserManager.shared().getLevel(with: quote?.market ?? YXMarketType.HK.rawValue)
        if let market = quote?.market, market != YXMarketType.SG.rawValue, level == .delay || level == .bmp {
            return false
        }
        return true
    }

    @objc class func isGemStock(_ quote: YXV2Quote?) -> Bool {

        if let sector = quote?.listSector?.value, (sector == OBJECT_MARKETListedSector.lsGemb.rawValue || sector == OBJECT_MARKETListedSector.lsStar.rawValue), let market = quote?.market, (market == YXMarketType.ChinaSH.rawValue || market == YXMarketType.ChinaSZ.rawValue || market == YXMarketType.ChinaHS.rawValue) {
            return true
        }
        return false
    }

    //是否是港股三大指数
    @objc class func isHKThreeIndex(_ quote: YXV2Quote?) -> Bool {
        
        if let symbol = quote?.symbol, (symbol == kYXIndexHSI || symbol == kYXIndexHSCEI || symbol == kYXIndexHSTECH) {
            return true
        }
        
        return false
    }
    
    //是否展示买卖档
    @objc class func isShowAskBid(_ quote: YXV2Quote?) -> Bool {
        if let greyFlag = quote?.greyFlag?.value, greyFlag > 0, YXUserManager.isLogin() {
            return true
        }

        //期权
        if let market = quote?.market,
           market == kYXMarketUsOption,
           market.hasPrefix(kYXMarketUS),
           YXUserManager.isOption(kYXMarketUS),
           YXUserManager.shared().getOptionLevel() == .level1 {
            return true
        }

        if let market = quote?.market,
           market == kYXMarketCryptos {
            return true
        }

        let level = YXUserManager.shared().getLevel(with: quote?.market ?? YXMarketType.HK.rawValue)
        if level == .delay || level == .bmp {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stIndex.rawValue {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stSector.rawValue {
            return false
        }
        
        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stStock.rawValue, let type2 = quote?.type2?.value, type2 == OBJECT_SECUSecuType2.stLowAdr.rawValue {
            return false
        }

        return true
    }

    //是否展示经纪商列表
    @objc class func isShowBrokerList(_ quote: YXV2Quote?) -> Bool {

        if let greyFlag = quote?.greyFlag?.value, greyFlag > 0  {
            return false
        }
        if let market = quote?.market, market == YXMarketType.HK.rawValue,
            self.isShowAskBid(quote) {
            return true
        }

        return false
    }

    @objc class func lineTypeString(_ type: YXRtLineType) -> String {
        var typeString = "1"
        switch type {
            case .dayTimeLine:
                typeString = "1"

            case .fiveDaysTimeLine:
                typeString = "5"
            
            case .dayKline:
                typeString = "7"

            case .weekKline:
                typeString = "8"

            case .monthKline:
                typeString = "9"

            case .seasonKline:
                typeString = "10"

            case .yearKline:
                typeString = "12"

            case .oneMinKline:
                typeString = "1"

            case .fiveMinKline:
                typeString = "2"

            case .fifteenMinKline:
                typeString = "4"

            case .thirtyMinKline:
                typeString = "5"

            case .sixtyMinKline:
                typeString = "6"

            default:
                break
        }

        return typeString
    }
    
    @objc class func isShowPreAfterQuote(_ quote: YXV2Quote?) -> Bool {

        //期权不展示盘前盘后
        if let market = quote?.market, market == kYXMarketUsOption {
            return false
        }
       
        //美股三大指数不展示盘前盘后
        if let market = quote?.market, market == kYXMarketUS, quote?.type1?.value == OBJECT_SECUSecuType1.stIndex.rawValue  {
            return false
        }
        if let quote = quote, let market = quote.market, market == YXMarketType.US.rawValue, let marketStatus = quote.msInfo?.status?.value {
            
            // 低级adr
            if let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)), type2 == .stLowAdr {
                return false
            }
            
            if let type1 = OBJECT_SECUSecuType1(rawValue: Int32(quote.type1?.value ?? 0)), type1 == .stSector {
                return false
            }
            
            let level = YXUserManager.shared().getLevel(with: market)
                        
            if level != .delay && (marketStatus == OBJECT_MARKETMarketStatus.msPreHours.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msAfterHours.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msStart.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msClose.rawValue) {
                return true
            }
        }
        
        
        return false
    }
    
    @objc class func isUSPreAfter(_ quote: YXV2Quote?) -> Bool {
        if let quote = quote, let market = quote.market, market == YXMarketType.US.rawValue, let marketStatus = quote.msInfo?.status?.value {
            
            // 低级adr
            if let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)), type2 == .stLowAdr {
                return false
            }
            
            if let type1 = OBJECT_SECUSecuType1(rawValue: Int32(quote.type1?.value ?? 0)), type1 == .stSector {
                return false
            }

            if (marketStatus == OBJECT_MARKETMarketStatus.msPreHours.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msAfterHours.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msStart.rawValue ||
            marketStatus == OBJECT_MARKETMarketStatus.msClose.rawValue) {
                return true
            }
        }
        
        
        return false
    }


    @objc class func canShowEventReminder(_ quote: YXV2Quote?) -> Bool {
        let type1 = OBJECT_SECUSecuType1(rawValue: Int32(quote?.type1?.value ?? 0))
        let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote?.type2?.value ?? 0))
        //let type3 = OBJECT_SECUSecuType3(rawValue: Int32(quote?.type3?.value ?? 0))
        if type1 == .stStock || type1 == .stFund || type1 == .stBond { //stock

            if type2 == .stLowAdr {
                return false
            }
            return true
        }
        return false
    }

    @objc class func isShowCYQ(_ quote: YXV2Quote?) -> Bool {
        //暗盘还没有筹码分布数据
        if let greyFlag = quote?.greyFlag?.value, greyFlag > 0 {
            return false
        }
        //新股，未上市
        if let status = quote?.trdStatus?.value, status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stStock.rawValue {
            let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote?.type2?.value ?? 0))
            if type2 == .stLowAdr {
                return false
            }
            return true
        }

        return false
    }


    @objc class func canShowShortcut(_ quote: YXV2Quote) -> Bool {
        if !YXUserManager.isLogin() {
            return false
        }

        //期权不展示快捷交易
        if let market = quote.market, market == kYXMarketUsOption {
            return false
        }

        if quote.type1?.value == OBJECT_SECUSecuType1.stIndex.rawValue || quote.type1?.value == OBJECT_SECUSecuType1.stSector.rawValue {
            return false
        }

        if quote.type2?.value == OBJECT_SECUSecuType2.stLowAdr.rawValue {
            if let otcTradingType = quote.otcTradingType?.value, otcTradingType != 0 {

            } else {
                return false
            }
        }

        if quote.market == kYXMarketChinaSZ || quote.market == kYXMarketChinaSH {
            if !self.isAllowedTradeAStock(quote) {
                return false
            }
            if YXUserManager.isOpenHSTrade(with: .hs) {
                return true
            }
        } else {
            if YXUserManager.canTrade() {
                return true
            }
        }

        return false
    }

    @objc class func canOptionTrade(_ quote: YXV2Quote) -> Bool {

        if !YXUserManager.isLogin() {
            return false
        }

        if let market = quote.market,
           market == kYXMarketUsOption,
           market.hasPrefix(kYXMarketUS),
           YXUserManager.isOption(kYXMarketUS) {

            return true
        }

        return false
    }

    //是否允许A股交易 沪股通或深股通 才可以交易
    @objc class func isAllowedTradeAStock(_ quotee: YXV2Quote?) -> Bool {
        var isAllow = false
        if let quote = quotee {
            if self.canTradeSH(quote) || self.canTradeSZ(quote) {
                isAllow = true
            }
        }
        return isAllow
    }

    /**
     * 沪股通  沪股是否支持香港购买
     */
    @objc class func canTradeSH(_ quote: YXV2Quote) -> Bool {
        let SH_FLAG: Int64 = 0x1 //沪股通
        if quote.market == YXMarketType.ChinaSH.rawValue, let scmType = quote.scmType?.value, scmType & SH_FLAG > 0 {
            return true
        }
        return false
    }

    /**
     * 深股通 深股是否支持香港购买
     */
    @objc class func canTradeSZ(_ quote: YXV2Quote) -> Bool {
        let SZ_FLAG: Int64 = 0x2 //深股通
        if quote.market == YXMarketType.ChinaSZ.rawValue, let scmType = quote.scmType?.value, scmType & SZ_FLAG > 0 {
            return true
        }
        return false
    }

    /**
     *  是否是可孖展股票
     */
    @objc class func isFinancingStock(_ quote: YXV2Quote?) -> Bool {

        if let margin = quote?.margin?.value, margin == 1, let marginRatio = quote?.marginRatio?.value, marginRatio > 0 {
            return true
        }
        return false
    }

    /**
     *  是否是日内融股票
     */
    @objc class func isDayMarginStock(_ quote: YXV2Quote?) -> Bool {
        
        if let isDayMargin = quote?.dailyMargin?.value, isDayMargin == true {
            return true
        }
        return false
    }


    @objc class func mergeOrderDataToKLine(orderModel: YXKLineOrderModel?, klineData: YXKLineData?) -> [String : YXKLineEventInfo]  {
        var dic: [String : YXKLineEventInfo] = [:]
        if let klineList = klineData?.list, let orderList = orderModel?.list, orderList.count > 0 {

            for info in orderList {
                let key = String(info.latestTime)
                dic[key] = info
            }

            for lineData in klineList {
                let key = String(lineData.latestTime?.value ?? 0)
                if let info = dic[key] {
                    self.mergeSingleOrderDataToKLine(orderModel: info, klineData: lineData, base: klineData?.priceBase?.value ?? 0)
                }

            }

        }
        return dic
    }


    @objc class func mergeSingleOrderDataToKLine(orderModel: YXKLineEventInfo?, klineData: YXKLine?, base: UInt32) {

        if let lineData = klineData, let list = orderModel?.list, list.count > 0 {
            let priceBase = pow(10.0, Double(base))
            var eventsArray: [YXKLineInsideEvent] = []
            for orderInfo in list {
                let event = YXKLineInsideEvent()
                event.type = NumberInt32(orderInfo.type)
                event.context = orderInfo.context

                var boughtArray: [YXKLineInsideOrderDetail] = []
                var soldArray:[YXKLineInsideOrderDetail] = []
                if let bought = orderInfo.bought {
                    for detail in bought {
                        let insideDetail = YXKLineInsideOrderDetail()
                        let price = Double(detail.price) ?? 0
                        let value = Int64(price * priceBase)
                        insideDetail.price = NumberInt64.init(value)
                        insideDetail.volume = NumberInt64.init(detail.volume)
                        insideDetail.orderType = NumberInt32(detail.orderType)
                        boughtArray.append(insideDetail)
                    }
                }

                if let sold = orderInfo.sold {
                    for detail in sold {
                        let insideDetail = YXKLineInsideOrderDetail()
                        let price = Double(detail.price) ?? 0
                        let value = Int64(price * priceBase)
                        insideDetail.price = NumberInt64.init(value)
                        insideDetail.volume = NumberInt64.init(detail.volume)
                        insideDetail.orderType = NumberInt32(detail.orderType)
                        soldArray.append(insideDetail)
                    }
                }

                event.bought = boughtArray
                event.sold = soldArray

                eventsArray.append(event)
            }

            lineData.klineEvents = eventsArray
        }

    }


    @objc class func removeAllKLineOrderCache(_ klineData: YXKLineData?) {
        guard let list = klineData?.list, list.count > 0 else {
            return
        }

        for lineData in list {

            lineData.klineEvents = nil
        }
    }

    @objc class func removeFirstKLineOrderCache(_ klineData: YXKLineData?) {
        klineData?.list?.last?.klineEvents = nil
    }


    @objc class func mergeOrderDataToTimeline(orderModel: YXKLineOrderModel?, timelineData: YXTimeLineData?) -> [String : YXKLineEventInfo]  {

        var dic: [String : YXKLineEventInfo] = [:]
        if let timelineList = timelineData?.list, let orderList = orderModel?.list, orderList.count > 0 {

            for info in orderList {
                let key = String(info.latestTime)
                dic[key] = info
            }

            for lineData in timelineList {
                let key = String(lineData.latestTime?.value ?? 0)
                if let info = dic[key] {
                    self.mergeSingleOrderDataToTimeline(orderModel: info, timelineData: lineData, base: timelineData?.priceBase?.value ?? 0)
                }

            }

        }
        return dic
    }


    @objc class func mergeSingleOrderDataToTimeline(orderModel: YXKLineEventInfo?, timelineData: YXTimeLine?, base: UInt32) {

        if let lineData = timelineData, let list = orderModel?.list, list.count > 0 {
            let priceBase = pow(10.0, Double(base))

            var eventsArray: [YXKLineInsideEvent] = []
            for orderInfo in list {
                let event = YXKLineInsideEvent()
                event.type = NumberInt32(orderInfo.type)
                event.context = orderInfo.context

                var boughtArray: [YXKLineInsideOrderDetail] = []
                var soldArray:[YXKLineInsideOrderDetail] = []
                if let bought = orderInfo.bought {
                    for detail in bought {
                        let insideDetail = YXKLineInsideOrderDetail()
                        let price = Double(detail.price) ?? 0
                        let value = Int64(price * priceBase)
                        insideDetail.price = NumberInt64.init(value)
                        insideDetail.volume = NumberInt64.init(detail.volume)
                        insideDetail.orderType = NumberInt32(detail.orderType)
                        boughtArray.append(insideDetail)
                    }
                }

                if let sold = orderInfo.sold {
                    for detail in sold {
                        let insideDetail = YXKLineInsideOrderDetail()
                        let price = Double(detail.price) ?? 0
                        let value = Int64(price * priceBase)
                        insideDetail.price = NumberInt64.init(value)
                        insideDetail.volume = NumberInt64.init(detail.volume)
                        insideDetail.orderType = NumberInt32(detail.orderType)
                        soldArray.append(insideDetail)
                    }
                }

                event.bought = boughtArray
                event.sold = soldArray

                eventsArray.append(event)
            }

            lineData.klineEvents = eventsArray
        }
    }
    
//    @objc class func commonQuoteLevel(market :String) -> QuoteLevel {
//        let status = YXUserManager.userLevel(market)
//        switch status {
//        case .hkDelay, .sgDelay,.cnDelay:
//            return .delay
//        case .usDelay:
//            return .delay
//        case .hkBMP:
//            return .bmp
//        case .usLevel1,.usaThreeLevel1, .cnLevel1, .usoLevel1, .sgLevel1CN,.sgLevel1Overseas,.hkLevel1:
//            return .level1
//        case .hkLevel2, .sgLevel2CN,.sgLevel2Overseas,.usaArcaLevel2:
//            return .level2
//        case .hkWorldLevel2:
//            return .level2
//        case .none:
//            return .none
//        }
//    }

    @objc class func stockLabelString(_ quote: YXV2Quote?) -> String {

        let type1 = quote?.type1?.value ?? OBJECT_SECUSecuType1.st1None.rawValue
        let type3 = quote?.type3?.value ?? OBJECT_SECUSecuType3.st3None.rawValue

        var labelString = YXLanguageUtility.kLang(key: "hold_stock_name")
        if type1 == OBJECT_SECUSecuType1.stStock.rawValue {
            labelString = YXLanguageUtility.kLang(key: "hold_stock_name")
        } else if type1 == OBJECT_SECUSecuType1.stIndex.rawValue {
            labelString = YXLanguageUtility.kLang(key: "index")
        } else if type1 == OBJECT_SECUSecuType1.stFund.rawValue {
            if type3 == OBJECT_SECUSecuType3.stEtf.rawValue {
                labelString = "ETF"
            } else if type3 == OBJECT_SECUSecuType3.stTrustFundReit.rawValue {
                labelString = YXLanguageUtility.kLang(key: "markets_news_reits")
            } else {
                labelString = YXLanguageUtility.kLang(key: "hold_fund_name")
            }
        } else if type1 == OBJECT_SECUSecuType1.stBond.rawValue {
            if type3 == OBJECT_SECUSecuType3.stHkEfn.rawValue {
                labelString = "EFN"
            } else {
                labelString = YXLanguageUtility.kLang(key: "bond")
            }
        } else if type1 == OBJECT_SECUSecuType1.stSector.rawValue {
            labelString = YXLanguageUtility.kLang(key: "sector")
        } else if type1 == OBJECT_SECUSecuType1.stOption.rawValue {
            if type3 == OBJECT_SECUSecuType3.stWarrant.rawValue {
                labelString = YXLanguageUtility.kLang(key: "bullbear_warrants")
            } else if type3 == OBJECT_SECUSecuType3.stCbbc.rawValue {
                labelString = YXLanguageUtility.kLang(key: "bullbear_CBBC")
            } else if type3 == OBJECT_SECUSecuType3.stInlineWarrant.rawValue {
                labelString = YXLanguageUtility.kLang(key: "warrants_inline_warrants2")
            } else if type3 == OBJECT_SECUSecuType3.stUsRights.rawValue {
                labelString = YXLanguageUtility.kLang(key: "bullbear_us_warrant")
            } else if type3 == OBJECT_SECUSecuType3.stUsWarrant.rawValue {
                labelString = YXLanguageUtility.kLang(key: "market_warrants_warrants")
            } else if let market = quote?.market, market == kYXMarketUsOption {
                labelString = YXLanguageUtility.kLang(key: "options")
            } else if type3 == OBJECT_SECUSecuType3.stSgDlc.rawValue {
                labelString = YXLanguageUtility.kLang(key: "market_sg_dlcs")
            } else if type3 == OBJECT_SECUSecuType3.stSgWarrant.rawValue {
                labelString = YXLanguageUtility.kLang(key: "market_sg_warrants")
            }
        }

        if type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue {
            labelString = "ETN"
        }

        return labelString
    }

    //是否是开市竞价时段
    class func isOpenBiddingPeriod(_ quote: YXV2Quote?) -> Bool {
        let kCasFlag: Int32 = 0x2
        let kPosFlag: Int32 = 0x4

        if let quote = quote, let status = quote.msInfo?.status?.value,
           status == OBJECT_MARKETMarketStatus.msOpenCall.rawValue,
           let hkSecuFlag = quote.hkSecuFlag?.value {
            if (hkSecuFlag & kCasFlag) > 0 || (hkSecuFlag & kPosFlag) > 0 {
                return true
            }
        }

        return false
    }

    //是否是收市竞价时段
    class func isCloseBiddingPeriod(_ quote: YXV2Quote?) -> Bool {
        let kCasFlag: Int32 = 0x2

        if let quote = quote, let status = quote.msInfo?.status?.value,
           status == OBJECT_MARKETMarketStatus.msCloseCall.rawValue,
           let hkSecuFlag = quote.hkSecuFlag?.value {
            if (hkSecuFlag & kCasFlag) > 0 {
                return true
            }
        }

        return false
    }

    @objc class func changeDirectionImage(_ change: Double) -> UIImage? {
        var image: UIImage? = nil
        if change == 0 {

        } else if change > 0 {
            if YXUserManager.curColor(judgeIsLogin: true) == .gRaiseRFall {
                image = UIImage(named: "green_up")
            } else {
                image = UIImage(named: "green_up")?.qmui_image(withTintColor: QMUITheme().stockRedColor())
            }
        } else {
            if YXUserManager.curColor(judgeIsLogin: true) == .gRaiseRFall {
                image = UIImage(named: "red_down")
            } else {
                image = UIImage(named: "red_down")?.qmui_image(withTintColor: QMUITheme().stockGreenColor())
            }
        }

        return image
    }
    
    @objc class func showDepthOrder(_ quote: YXV2Quote?) -> Bool {
        
        if !YXUserManager.isLogin() || quote == nil {
            return false
        }
        
        if quote?.market != kYXMarketUS && quote?.market != kYXMarketSG {
            return false
        }
        
        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stIndex.rawValue {
            return false
        }

        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stSector.rawValue {
            return false
        }
        
        if let value = quote?.type1?.value, value == OBJECT_SECUSecuType1.stStock.rawValue, let type2 = quote?.type2?.value, type2 == OBJECT_SECUSecuType2.stLowAdr.rawValue {
            return false
        }
        
        if quote?.market == kYXMarketUS && YXUserManager.shared().getDepthOrderLevel() == .level2 {
            
            return true
        }
        if quote?.market == kYXMarketSG && YXUserManager.shared().getLevel(with: kYXMarketSG) == .level2 {
            
            return true
        }
        
        return false
    }
    
    class func isShowAnalyze(_ quote: YXV2Quote) -> Bool {
        
        let stockType = quote.stockType
        if stockType == .hkStock || stockType == .usStock || stockType == .sgStock || stockType == .bond || stockType == .fund || stockType == .stCbbc || stockType == .stWarrant {
            return true
        }
        
//        if stockType == .stUsStockOpt {
//            if let expDate = quote.expDate?.value,
//               let serverDate = quote.msInfo?.mktTime?.value,
//               let expTime = Double(String(String(expDate).prefix(8))),
//               let serverTime = Double(String(String(serverDate).prefix(8))),
//               expTime >= serverTime {
//                return true
//            }
//        }

        
        return false
    }
}

