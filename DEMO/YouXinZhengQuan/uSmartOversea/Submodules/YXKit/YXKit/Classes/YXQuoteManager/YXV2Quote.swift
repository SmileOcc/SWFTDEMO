//
//  YXQuoteDetail.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/8/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//


import Foundation

@objc public enum QuoteLevel: Int, Codable {
    case none = -1      //无权限, 不轮训, 不订阅
    case delay = 0      //港美A股延时
    case bmp = 1        //港股bmp
    case level1 = 2     //美股level1, A股level1
    case level2 = 3     //港股level2
    case user = 4       //取用户权限(后台判断, 慎用)
    case usNational = 5     //全美行情
}

extension QuoteLevel {
    var paramValue: Int {
        switch self {
        case .none,
             .delay:
            return 0
        default:
            return rawValue
        }
    }
}

// MARK: - YXQuoteDetail
@objcMembers public class YXV2QuoteList: NSObject, Codable {
    public let list: [YXV2Quote]?
    
    init(list: [YXV2Quote]? = nil) {
        self.list = list
    }
}

// MARK: - YXV2Quote
@objcMembers public class YXV2Quote: NSObject, Codable {
//    public var delay: NumberBool?  // 延时行情
    public var otcTradingType: NumberInt32? // 低级ADR是否支持交易，0：不支持，1：支持。
    public var margin: NumberInt32? // 融资标签
    public var marginRatio: NumberDouble? // 抵押比率
    public var dailyMargin: NumberBool? //是否支持日内融
    public var dailyMarginGearing: NumberInt32? // 日内融杠杠比例
    public var level: NumberInt32? // 行情权限 等同QuoteLevel的值
    public var accer: NumberInt32?        // 5分钟涨速
    public var amount: NumberInt64?       // 总成交金额
    public var amp: NumberInt32?          // 振幅, 使用时除以 100
    public var askPrice: NumberInt64?     // 卖一价
    public var askSize: NumberUInt64?     // 卖一量
    public var avg: NumberInt64?          // 均价
    public var bidPrice: NumberInt64?     // 买一价
    public var bidSize: NumberUInt64?     // 买一量
//    public var brokerData: Broker?  // 经纪商信息
    public var bvps: NumberInt64?         // 每股净资产
    public var currency: NumberInt64?     // 货币类型
    public var dividend: NumberInt64?     // 股息
    public var eps: NumberInt64?          // 每股收益
    public var epsTTM: NumberInt64?       // 每股收益预测, 用于计算市盈率
    public var exchange: NumberInt64?     // 交易所ID
    public var firstDayClosePrice: NumberInt64?   //上市首日收盘价
    public var cittDiff: NumberInt64?     // 委差
    public var close: NumberInt64?        // 收盘价
    public var divYield: NumberInt32?     // 股息率
    public var floatCap: NumberInt64?     // 流通市值
    public var floatShare: NumberUInt64?   // 流通股数
    public var greyFlag: NumberInt32?      // 是否是暗盘行情
    public var historyHigh: NumberInt64?  // 历史最高
    public var historyLow: NumberInt64?   // 历史最低
    public var high: NumberInt64?         // 最高价
    public var `in`: NumberUInt64?        // 内盘
    public var issuePrice: NumberInt64?   // 发行价
    public var issuedShare: NumberUInt64?  // 总股本
    public var latestPrice: NumberInt64?  // 最新价
    public var latestTime: NumberUInt64?  // 市场行情时间 YYYYMMDDHHMMSSsss
    public var limitDown: NumberInt64?    // 跌幅下限
    public var limitUp: NumberInt64?      // 涨幅上限
    public var listDate: NumberInt64?     // 上市日期
    public var listStatus: NumberInt64?   // 证券状态
    public var low: NumberInt64?          // 最低价
    public var lowerLimit: NumberInt64?   // 跌停价
    public var market: String?            // 市场
    public var mktCap: NumberInt64?       // 总市值
    public var msInfo: MSInfo?      // 市场状态
    public var name: String?        // 名称
    public var netAsset: NumberInt64?     // 最新年度净资产
    public var netIncomeLastYear: NumberInt64?    // 最新年度净利润
    public var netIncomeLtm: NumberInt64?         // 滚动年度净利润
    public var netchng: NumberInt64?      // 涨跌值
    public var open: NumberInt64?         // 开盘价
    public var out: NumberUInt64?         // 外盘
    public var pb: NumberInt32?           // 市净率
    public var pctchng: NumberInt32?      // 涨跌幅, 使用时除以 100
    public var pe: NumberInt32?           // 静态市盈率
    public var peTTM: NumberInt32?        // 动态市盈率
//    public var pos: Pos?            // 盘口
    public var preClose: NumberInt64?     // 昨收价
    public var priceBase: NumberUInt32?   // 价格小数计算基数，10的幂次表示
    public var qtType: NumberInt32?       // 行情类别，决定读取后面哪个数据字段
    public var qtyUnit: NumberInt32?      // 实时价差
    public var recvTime: NumberUInt64?    // 解码行情接收时间，客户端不用
    public var sQuote: SQuote?      // 盘前、盘后行情，如果没有则是null
    public var scmType: NumberInt64?      // 按位使用，0x1-港股通（沪）,0x2-港股通（深）,0x4-沪股通, 0x8-深股通
    public var sector: NumberInt64?       // 板块信息
    public var seq: NumberUInt32?         // 行情编号
    public var stc: NumberInt64?          // 价位表类型
    public var symbol: String?            // 代码
    public var totalDividend: NumberInt64?// 近12个月分红综合
    public var trdStatus: NumberInt32?    // 个股交易状态,参见：TradingStatus
    public var turnoverRate: NumberInt32? // 换手率
    public var type1: NumberInt32?        // 证券一级类型
    public var type2: NumberInt32?        // 证券二级类型
    public var type3: NumberInt32?        // 证券三级类型
    public var upperLimit: NumberInt64?   // 涨停价
    public var usTime: NumberInt32?       // 美股用，冬、夏令时
    public var vcmFlag: NumberBool?       // 冷静期标识
    public var casFlag: NumberBool?       // 竞价标识
    public var volume: NumberUInt64?      // 成交量
    public var volumeRatio: NumberInt32?  // 量比, 使用时除以 100
    public var week52High: NumberInt64?   // 52周最高
    public var week52Low: NumberInt64?    // 52周最低
    public var vcm: Vcm?            // 市调机制
    public var cas: Cas?            // 收盘集合竞价
    public var unchange: NumberUInt32?    // 平家数，包括停牌
    public var up: NumberUInt32?          // 涨家数
    public var down: NumberUInt32?        // 跌家数
    public var navPS: NumberInt64?        // 基金净值
    public var callPutFlag: NumberInt64?  // 权证类型
    public var conversionRatio: NumberUInt64?  // 换股比率 使用时除以 100
    public var strikeLower: NumberInt64?  // 界内证下限价
    public var strikePrice: NumberInt64?  // 行使价
    public var strikeUpper: NumberInt64?  // 界内证上限价
    public var maturityDate: NumberInt64? // 到期时间 YYYYMMDDHHMMSSsss
    public var lastTrdDate: NumberInt64?  // 最后交易日
    public var outstandingPct: NumberInt64?   // 街货比
    public var outstandingQty: NumberInt64?   // 街货量
    public var callPrice: NumberInt64?    // 牛熊证收回价
    public var issueShares: NumberInt64?  // 界内证发行量
    public var premium: NumberInt32?      // 溢价,使用时除以 100
    public var impliedVolatility: NumberInt32?    // 引申波幅 （期权： 隐含波动率）
    public var delta: NumberInt32?        // 对冲值
    public var ah: Ah?              // ah股行情，如果没有则是null
    public var underlingSEC: UnderlingSEC?  // 关联正股信息
    public var wrnType: NumberInt32?      // 涡轮牛熊类型
    public var moneyness: NumberInt32?    // 价值状况
    public var gearing: NumberInt32?      // 杠杆比率
    public var effgearing: NumberInt32?   // 有效杠杆
    public var diffRatio: NumberInt32?    // 正股价距离收回价比率
    public var convertPrice: NumberInt64? // 换股价：最新价 * 换股比率
    public var breakevenPoint: NumberInt32?   // 打和点
    public var fromUpper: NumberInt32?    // 距上限价 除以100
    public var fromLower: NumberInt32?    // 距下限价 除以100
    public var wap: NumberInt64?          // 质押式回购专用
    public var wapcbp: NumberInt64?       // 加权平均价涨跌幅
    public var pwap: NumberInt64?         // 昨收加权平均价
    public var pcbp: NumberInt64?         // 最近价涨跌幅
    public var adr: Adr?                  // adr关联信息
    public var trdUnit: NumberUInt32?     // 每手股数
    public var postVolume: NumberUInt64?  // 盘后量 科创板使用
    public var postAmount: NumberInt64?   // 盘后额 科创板使用
    public var aStockFlag: NumberInt32?   //科创版/创业板标识，按位与方式使用(1: 是否注册制，2: 是否未盈利, 4: 是否存在投票权差异, 8是否具有协议控制架构)
    public var listSector: NumberInt64?   // 板块信息
    public var related: Related?          //特殊正股关联

    //期权相关
    public var contractSize: NumberUInt32?     // 每份合约
    public var expDate: NumberInt64? // 到期时间 YYYYMMDDHHMMSSsss
    public var openInt: NumberUInt64? // //未平仓数
    public var gamma: NumberInt32? // Gamma(Delta变化/标的资产价格变化；期权价格对标的资产价格的二阶导数)，真实值除以10000
    public var theta: NumberInt32? // Theta(期权价格变化/期权有效期变化；期权价格对时间的一阶导数)，真实值除以10000
    public var vega: NumberInt32? // Vega(期权价格变化/标的资产价格波动率的变化；期权价格对波动率的一阶导数)，真实值除以10000
    public var rho: NumberInt32? // Rho（期权价格变化/利率变化；期权价格对无风险利率的一阶导数），真实值除以10000
    public var theoryPrice: NumberInt64? // 期权理论价格
    /* 期权相关 end */

    public var hkSecuFlag: NumberInt32? // 港股证券相关标识: VCM,CAS,POS,CCASS,Dummy security, 参考HKSecuFlagType
    public var shortSellFlag: NumberBool? // 未知(沽空? = nil)

    public var totalAsset: NumberInt64? // 总资产
    public var assetType: NumberInt32? // 资产类型
    public var lever: NumberInt32? // 基金杠杆比例

    public var exerciseStyle: NumberInt32? //期权类型

    public var ID: QuoteID?   //市场，代码

    public var btInfo: BTInfo?  //数字货币基础信息

    public var btRealTime: BTRealTime? //数字货币实时行情数据
    public var btOrderBook: BTOrderBook? //数字货币档位信息
    
    public var multiplier: NumberInt32? //合约乘数
    public var inValue: NumberInt64?    //内在价值
    public var timeValue: NumberInt64?  //时间价值
    public var greyMarket: NumberInt32? //1：辉立，2：富途
    public var supportGreyMarkets: NumberInt32? //按位使用， 1：辉立，2：富途, 3： 富途+辉立
    public var greyTradingMarkets: NumberInt32? //支持交易的暗盘市场，1：辉立、2：富途、3：辉立+富途
    public var greyStyle: NumberInt32? //支持暗盘样式标志，1： 单暗盘，2：双暗盘
    public var pctChng5Day: NumberInt32? //近一年涨跌幅，真实值除以10000
    public var pctChngThisYear: NumberInt32? //近一年涨跌幅，真实值除以10000
    public var netChng5Day: NumberInt64? //近5日涨跌额，真实值除以10^priceBase
    public var netChngThisYear: NumberInt64? //年初至今涨跌额，真实值除以10^priceBase
    public var spreadTab: String?       //SG股票价差
    
    public var fractionnalTrade: NumberBool?    //是否支持美股碎股交易
    public var cmpActiveFlag:NumberInt32? // 1-派息


    public enum CodingKeys: String, CodingKey {
        case otcTradingType, margin, marginRatio, dailyMargin, dailyMarginGearing, level, accer, amount, amp, askPrice, askSize, avg, bidPrice, bidSize, bvps, currency, dividend, eps, epsTTM, exchange, firstDayClosePrice, cittDiff, close, divYield, floatCap, floatShare, greyFlag, historyHigh, historyLow, high
        case `in` = "in"
        case issuePrice, issuedShare, latestPrice, latestTime, limitDown, limitUp, listDate, listStatus, low, lowerLimit, market, mktCap, msInfo, name, netAsset, netIncomeLastYear, netIncomeLtm, netchng
        case open, out, pb, pctchng, pe, peTTM, preClose, priceBase, qtType, qtyUnit, recvTime, sQuote, scmType, sector, seq, stc, symbol, totalDividend, trdStatus, turnoverRate, type1, type2, type3, upperLimit, usTime, vcmFlag, casFlag, volume, volumeRatio, week52High, week52Low, vcm, cas, unchange, up, down
        case navPS = "navPs"
        case callPutFlag, conversionRatio, strikeLower, strikePrice, strikeUpper, maturityDate, lastTrdDate, outstandingPct, outstandingQty, callPrice, issueShares, premium, impliedVolatility, delta
        case underlingSEC = "underlingSec"
        case ah, wrnType, moneyness, gearing, effgearing, diffRatio, convertPrice, breakevenPoint, fromUpper, fromLower, wap, wapcbp, pwap, pcbp
        case adr, trdUnit
        case postVolume, postAmount, aStockFlag, listSector
        case related
        case contractSize, expDate, openInt, gamma, theta, vega, rho, theoryPrice
        case hkSecuFlag, shortSellFlag
        case totalAsset, assetType, lever, exerciseStyle
        case btInfo = "info"
        case btRealTime = "realtime"
        case btOrderBook = "orderBook"
        case ID = "id"
        case multiplier, inValue, timeValue
        case greyMarket, supportGreyMarkets, greyTradingMarkets, greyStyle
        case pctChng5Day, pctChngThisYear
        case netChng5Day, netChngThisYear
        case spreadTab
        case fractionnalTrade
        case cmpActiveFlag
        public static func simpleRawValues() -> [String] {
            return simpleValues().map({ (codingKey) -> String in
                return codingKey.rawValue
            })
        }
        
        static func simpleValues() -> [CodingKeys] {
            return [.recvTime, .name, .market, .symbol, .greyFlag, .latestPrice, .pctchng, .netchng, .priceBase, .turnoverRate, .volume, .amount, .amp, .volumeRatio, .mktCap, .pb, .peTTM, .pe, .listStatus, .trdStatus, .msInfo, .level, .type1, .type2, .type3, .sQuote, .greyMarket, .supportGreyMarkets, .greyTradingMarkets, .greyStyle, .pctChng5Day, .pctChngThisYear,netChng5Day, netChngThisYear, .latestTime, .fractionnalTrade, .cmpActiveFlag]
        }

    }
    
    @objc public override init() {
        super.init()
    }
    
    public init(otcTradingType: NumberInt32? = nil, margin: NumberInt32? = nil, marginRatio: NumberDouble? = nil, dailyMargin: NumberBool? = nil, dailyMarginGearing: NumberInt32? = nil, level: NumberInt32? = nil, accer: NumberInt32? = nil, amount: NumberInt64? = nil, amp: NumberInt32? = nil, askPrice: NumberInt64? = nil, askSize: NumberUInt64? = nil, avg: NumberInt64? = nil, bidPrice: NumberInt64? = nil, bidSize: NumberUInt64? = nil, bvps: NumberInt64? = nil, currency: NumberInt64? = nil, dividend: NumberInt64? = nil, eps: NumberInt64? = nil, epsTTM: NumberInt64? = nil, exchange: NumberInt64? = nil, firstDayClosePrice: NumberInt64? = nil, cittDiff: NumberInt64? = nil, close: NumberInt64? = nil, divYield: NumberInt32? = nil, floatCap: NumberInt64? = nil, floatShare: NumberUInt64? = nil, greyFlag: NumberInt32? = nil, historyHigh: NumberInt64? = nil, historyLow: NumberInt64? = nil, high: NumberInt64? = nil, `in`: NumberUInt64? = nil, issuePrice: NumberInt64? = nil, issuedShare: NumberUInt64? = nil, latestPrice: NumberInt64? = nil, latestTime: NumberUInt64? = nil, limitDown: NumberInt64? = nil, limitUp: NumberInt64? = nil, listDate: NumberInt64? = nil, listStatus: NumberInt64? = nil, low: NumberInt64? = nil, lowerLimit: NumberInt64? = nil, market: String? = nil, mktCap: NumberInt64? = nil, msInfo: MSInfo? = nil, name: String? = nil, netAsset: NumberInt64? = nil, netIncomeLastYear: NumberInt64? = nil, netIncomeLtm: NumberInt64? = nil, netchng: NumberInt64? = nil, open: NumberInt64? = nil, out: NumberUInt64? = nil, pb: NumberInt32? = nil, pctchng: NumberInt32? = nil, pe: NumberInt32? = nil, peTTM: NumberInt32? = nil, preClose: NumberInt64? = nil, priceBase: NumberUInt32? = nil, qtType: NumberInt32? = nil, qtyUnit: NumberInt32? = nil, recvTime: NumberUInt64? = nil, sQuote: SQuote? = nil, scmType: NumberInt64? = nil, sector: NumberInt64? = nil, seq: NumberUInt32? = nil, stc: NumberInt64? = nil, symbol: String? = nil, totalDividend: NumberInt64? = nil, trdStatus: NumberInt32? = nil, turnoverRate: NumberInt32? = nil, type1: NumberInt32? = nil, type2: NumberInt32? = nil, type3: NumberInt32? = nil, upperLimit: NumberInt64? = nil, usTime: NumberInt32? = nil, vcmFlag: NumberBool? = nil, casFlag: NumberBool? = nil, volume: NumberUInt64? = nil, volumeRatio: NumberInt32? = nil, week52High: NumberInt64? = nil, week52Low: NumberInt64? = nil, vcm: Vcm? = nil, cas: Cas? = nil, unchange: NumberUInt32? = nil, up: NumberUInt32? = nil, down: NumberUInt32? = nil, navPS: NumberInt64? = nil, callPutFlag: NumberInt64? = nil, conversionRatio: NumberUInt64? = nil, strikeLower: NumberInt64? = nil, strikePrice: NumberInt64? = nil, strikeUpper: NumberInt64? = nil, maturityDate: NumberInt64? = nil, lastTrdDate: NumberInt64? = nil, outstandingPct: NumberInt64? = nil, outstandingQty: NumberInt64? = nil, callPrice: NumberInt64? = nil, issueShares: NumberInt64? = nil, premium: NumberInt32? = nil, impliedVolatility: NumberInt32? = nil, delta: NumberInt32? = nil, ah: Ah? = nil, underlingSEC: UnderlingSEC? = nil, wrnType: NumberInt32? = nil, moneyness: NumberInt32? = nil, gearing: NumberInt32? = nil, effgearing: NumberInt32? = nil, diffRatio: NumberInt32? = nil, convertPrice: NumberInt64? = nil, breakevenPoint: NumberInt32? = nil, fromUpper: NumberInt32? = nil, fromLower: NumberInt32? = nil, wap: NumberInt64? = nil, wapcbp: NumberInt64? = nil, pwap: NumberInt64? = nil, pcbp: NumberInt64? = nil, trdUnit: NumberUInt32? = nil, postVolume: NumberUInt64? = nil, postAmount: NumberInt64? = nil, aStockFlag: NumberInt32? = nil, listSector: NumberInt64? = nil, related: Related? = nil, contractSize: NumberUInt32? = nil, expDate: NumberInt64? = nil, openInt: NumberUInt64? = nil, gamma: NumberInt32? = nil, theta: NumberInt32? = nil, vega: NumberInt32? = nil, rho: NumberInt32? = nil, theoryPrice: NumberInt64? = nil, hkSecuFlag: NumberInt32? = nil, shortSellFlag: NumberBool? = nil, totalAsset: NumberInt64? = nil, assetType: NumberInt32? = nil, lever: NumberInt32? = nil, exerciseStyle: NumberInt32? = nil, btInfo: BTInfo? = nil, btRealTime: BTRealTime? = nil, btOrderBook: BTOrderBook? = nil, ID: QuoteID? = nil, multiplier: NumberInt32? = nil, inValue: NumberInt64? = nil, timeValue: NumberInt64? = nil, greyMarket: NumberInt32? = nil, supportGreyMarkets: NumberInt32? = nil, greyTradingMarkets: NumberInt32? = nil, greyStyle: NumberInt32? = nil, pctChng5Day: NumberInt32? = nil, pctChngThisYear:NumberInt32? = nil, netChng5Day:NumberInt64? = nil,netChngThisYear:NumberInt64? = nil, spreadTab: String? = nil, fractionnalTrade: NumberBool? = nil, cmpActiveFlag:NumberInt32? = nil) {

        self.otcTradingType = otcTradingType
        self.margin = margin
        self.marginRatio = marginRatio
        self.dailyMargin = dailyMargin
        self.dailyMarginGearing = dailyMarginGearing
        self.level = level
        self.accer = accer
        self.amount = amount
        self.amp = amp
        self.askPrice = askPrice
        self.askSize = askSize
        self.avg = avg
        self.bidPrice = bidPrice
        self.bidSize = bidSize
//        self.brokerData = brokerData
        self.bvps = bvps
        self.currency = currency
        self.dividend = dividend
        self.eps = eps
        self.epsTTM = epsTTM
        self.exchange = exchange
        self.firstDayClosePrice = firstDayClosePrice
        self.cittDiff = cittDiff
        self.close = close
        self.divYield = divYield
        self.floatCap = floatCap
        self.floatShare = floatShare
        self.greyFlag = greyFlag
        self.historyHigh = historyHigh
        self.historyLow = historyLow
        self.high = high
        self.in = `in`
        self.issuePrice = issuePrice
        self.issuedShare = issuedShare
        self.latestPrice = latestPrice
        self.latestTime = latestTime
        self.limitDown = limitDown
        self.limitUp = limitUp
        self.listDate = listDate
        self.listStatus = listStatus
        self.low = low
        self.lowerLimit = lowerLimit
        self.market = market
        self.mktCap = mktCap
        self.msInfo = msInfo
        self.name = name
        self.netAsset = netAsset
        self.netIncomeLastYear = netIncomeLastYear
        self.netIncomeLtm = netIncomeLtm
        self.netchng = netchng
        self.open = open
        self.out = out
        self.pb = pb
        self.pctchng = pctchng
        self.pe = pe
        self.peTTM = peTTM
//        self.pos = pos
        self.preClose = preClose
        self.priceBase = priceBase
        self.qtType = qtType
        self.qtyUnit = qtyUnit
        self.recvTime = recvTime
        self.sQuote = sQuote
        self.scmType = scmType
        self.sector = sector
        self.seq = seq
        self.stc = stc
        self.symbol = symbol
        self.totalDividend = totalDividend
        self.trdStatus = trdStatus
        self.turnoverRate = turnoverRate
        self.type1 = type1
        self.type2 = type2
        self.type3 = type3
        self.upperLimit = upperLimit
        self.usTime = usTime
        self.vcmFlag = vcmFlag
        self.casFlag = casFlag
        self.volume = volume
        self.volumeRatio = volumeRatio
        self.week52High = week52High
        self.week52Low = week52Low
        self.vcm = vcm
        self.cas = cas
        self.unchange = unchange
        self.up = up
        self.down = down
        self.navPS = navPS
        self.callPutFlag = callPutFlag
        self.conversionRatio = conversionRatio
        self.strikeLower = strikeLower
        self.strikePrice = strikePrice
        self.strikeUpper = strikeUpper
        self.maturityDate = maturityDate
        self.lastTrdDate = lastTrdDate
        self.outstandingPct = outstandingPct
        self.outstandingQty = outstandingQty
        self.callPrice = callPrice
        self.issueShares = issueShares
        self.premium = premium
        self.impliedVolatility = impliedVolatility
        self.delta = delta
        self.ah = ah
        self.underlingSEC = underlingSEC
        self.wrnType = wrnType
        self.moneyness = moneyness
        self.gearing = gearing
        self.effgearing = effgearing
        self.diffRatio = diffRatio
        self.convertPrice = convertPrice
        self.breakevenPoint = breakevenPoint
        self.fromUpper = fromUpper
        self.fromLower = fromLower
        self.trdUnit = trdUnit
        self.postVolume = postVolume
        self.postAmount = postAmount
        self.aStockFlag = aStockFlag
        self.listSector = listSector
        self.related = related
        self.contractSize = contractSize
        self.expDate = expDate
        self.openInt = openInt
        self.gamma = gamma
        self.theta = theta
        self.vega = vega
        self.rho = rho
        self.theoryPrice = theoryPrice
        self.hkSecuFlag = hkSecuFlag
        self.shortSellFlag = shortSellFlag
        self.totalAsset = totalAsset
        self.assetType = assetType
        self.lever = lever
        self.exerciseStyle = exerciseStyle
        self.btInfo = btInfo
        self.btRealTime = btRealTime
        self.btOrderBook = btOrderBook
        self.ID = ID
        self.multiplier = multiplier
        self.inValue = inValue
        self.timeValue = timeValue
        self.greyMarket = greyMarket
        self.supportGreyMarkets = supportGreyMarkets
        self.greyTradingMarkets = greyTradingMarkets
        self.greyStyle = greyStyle
        self.pctChng5Day = pctChng5Day
        self.pctChngThisYear = pctChngThisYear
        self.netChng5Day = netChng5Day
        self.netChngThisYear = netChngThisYear
        self.spreadTab = spreadTab
        self.fractionnalTrade = fractionnalTrade
        self.cmpActiveFlag = cmpActiveFlag
    }
    
    @objc public class func quote(market: String, symbol: String) -> YXV2Quote {
        return YXV2Quote(market: market, symbol: symbol)
    }
    
    @objc public func deepMerged(with value: YXV2Quote?) -> YXV2Quote {
        guard let value = value else { return self }
        
        let oldDict = [String: Any].encoder(toDictionary: self)
        let recvDict = [String: Any].encoder(toDictionary: value)
        
        if let recvDict = recvDict {
            let result = oldDict?.merging(recvDict, uniquingKeysWith: { left, right in
                right ?? left
            })
            return result?.decode(YXV2Quote.self) ?? self
        }
        
        return self
    }

    //补全数据
    @objc public func supplementaryQuote() {

        if let ID = self.ID {
            market = ID.market
            symbol = ID.symbol
        }

        if let info = self.btInfo {
            name = info.name
            type1 = info.type1
            type2 = info.type3
            type3 = info.type3
        }

        if let realTime = self.btRealTime {
            if let value = realTime.latestTime?.value {
                latestTime = NumberUInt64(value)
            }
        }
    }
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
    
    @objc public func extraType() -> YXSocketExtraQuote {
        if let level = self.level?.value, level == QuoteLevel.usNational.rawValue {
            return .usNation
        }
        if self.greyMarketType() == .futu {
            return .futu
        }
        return .none
    }
    
    public func isLowAdr() -> Bool {
        if let type1 = type1?.value, let type2 = type2?.value, let a = OBJECT_SECUSecuType1.init(rawValue: type1), let b = OBJECT_SECUSecuType2.init(rawValue: type2) {
            if a == .stStock, b == .stLowAdr {
                return true
            }
        }
        return false
    }

}

// MARK: - Pos
@objcMembers public class PosBroker: NSObject, Codable {
    public var name: String?            // 名字
    public var symbol: String?            // 代码
    public var market: String?            // 市场
    public var pos: Pos?            // 盘口
    public var brokerData: Broker?  // 经纪商信息
    public var greyMarket: NumberInt32? //1：辉立，2：富途
    public var priceBase: NumberUInt32?   // 价格小数计算基数，10的幂次表示
    public var latestPrice: NumberInt64?        // 最新价
    public var msInfo: MSInfo?      // 市场状态
    public var preClose: NumberInt64?     // 昨收价
    public var greyFlag: NumberInt32?      // 是否是暗盘行情
    public let type1: NumberInt32?        // 证券一级类型
    public let type2: NumberInt32?        // 证券二级类型
    public let type3: NumberInt32?        // 证券三级类型
    public var level: NumberInt32? // 行情权限 等同QuoteLevel的值
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
    
    @objc public func getRealPreClose() -> NumberInt64? {
        
        if market == "us" {
            if let status = msInfo?.status?.value , let type = OBJECT_MARKETMarketStatus.init(rawValue: status) {
                if type == .msPreHours {
                    // 盘前
                    return latestPrice
                } else if type == .msAfterHours || type == .msClose || type == .msStart {
                    // 盘后
                    return latestPrice
                }
            }
        }
        return preClose
    }
}

// MARK: - PosBrokerList
@objcMembers public class PosBrokerList: NSObject, Codable {
    public let list: [PosBroker]?
    
    init(list: [PosBroker]? = nil) {
        self.list = list
    }
}

// MARK: - Pos
@objcMembers public class Pos: NSObject, Codable {
    public let cittDiff: NumberInt64?     // 委差
    public let cittThan: NumberInt32?     // 委比, 使用时除以 100
    public let latestTime: NumberUInt64?  // 市场行情时间 YYYYMMDDHHMMSSss
    public let posData: [PosData]?  // 盘口
    public let totalAskSize: NumberInt64?    // 卖总
    public let totalBidSize: NumberInt64?    // 买总
    enum CodingKeys: String, CodingKey {
        case cittDiff, cittThan, latestTime
        case posData = "posData"
        case totalAskSize, totalBidSize
    }
    
    public init(cittDiff: NumberInt64? = nil, cittThan: NumberInt32? = nil, latestTime: NumberUInt64? = nil, posData: [PosData]? = nil, totalAskSize: NumberInt64? = nil, totalBidSize: NumberInt64? = nil) {
        self.cittDiff = cittDiff
        self.cittThan = cittThan
        self.latestTime = latestTime
        self.posData = posData
        self.totalAskSize = totalAskSize
        self.totalBidSize = totalBidSize
    }
}

//  MARK: - Broker
@objcMembers public class Broker: NSObject, Codable {
    public let bidBroker: [BrokerDetail]?   // 买盘经纪
    public let askBroker: [BrokerDetail]?   // 卖盘经纪
    
    enum CodingKeys: String, CodingKey {
        case bidBroker, askBroker
    }
    
    public init(bidBroker: [BrokerDetail]? = nil, askBroker: [BrokerDetail]?) {
        self.bidBroker = bidBroker
        self.askBroker = askBroker
    }
}

//  MARK: - BrokerDetail
@objcMembers public class BrokerDetail: NSObject, Codable {
    public let Id: String?     // 经纪ID
    public var Name: String?   // 经纪名称
    
    enum CodingKeys: String, CodingKey {
        case Id, Name
    }
    
    public init(Id: String? = nil, Name: String? = nil) {
        self.Id = Id
        self.Name = Name
    }
}

//  MARK: - PosData
@objcMembers public class PosData: NSObject, Codable {
    public let askOrderCount: NumberUInt64?  // 卖委托订单个数
    public let askPrice: NumberInt64?        // 委卖价
    public let askSize: NumberUInt64?        // 委卖量
    public let bidOrderCount: NumberUInt64?  // 买委托订单个数
    public let bidPrice: NumberInt64?        // 委买价
    public let bidSize: NumberUInt64?        // 委买量
    public var bidChange: NumberInt32?      // 委买量变化 / 1 涨 -1 跌 / 刷新盘口动画增
    public var askChange: NumberInt32?      // 委卖量变化 / 1 涨 -1 跌 / 刷新盘口动画增
    
    enum CodingKeys: String, CodingKey {
        case askOrderCount, askPrice, askSize, bidOrderCount, bidPrice, bidSize, bidChange, askChange
    }
    
    public init(askOrderCount: NumberUInt64? = nil, askPrice: NumberInt64? = nil, askSize: NumberUInt64? = nil, bidOrderCount: NumberUInt64? = nil, bidPrice: NumberInt64? = nil, bidSize: NumberUInt64? = nil) {
        self.askOrderCount = askOrderCount
        self.askPrice = askPrice
        self.askSize = askSize
        self.bidOrderCount = bidOrderCount
        self.bidPrice = bidPrice
        self.bidSize = bidSize
        self.bidChange = NumberInt32(0)
        self.askChange = NumberInt32(0)
    }
}

// MARK: - MSInfo
@objcMembers public class MSInfo: NSObject, Codable {
    public let desc: String?        // 描述
    public let market: NumberInt32?       // 市场代码
    public let mktTime: NumberUInt64?     // 市场时间
    public let status: NumberInt32?       // 市场状态
    public let statusDesc: JSONAny? // 多语言数组，目前客户端不用
    
    public init(desc: String? = nil, market: NumberInt32? = nil, mktTime: NumberUInt64? = nil, status: NumberInt32? = nil, statusDesc: JSONAny? = nil) {
        self.desc = desc
        self.market = market
        self.mktTime = mktTime
        self.status = status
        self.statusDesc = statusDesc
    }
}

@objcMembers public class SQuote: NSObject, Codable {
    public let seq: NumberUInt32?         // 行情序号
    public let latestTime: NumberUInt64?  // 市场行情时间 YYYYMMDDHHMMSSss
    public let latestPrice: NumberInt64?  // 最新价
    public let netchng: NumberInt64?      // 涨跌值
    public let pctchng: NumberInt32?      // 涨跌幅, 使用时除以 100
    public var high: NumberInt64?         // 最高价
    public var low: NumberInt64?          // 最低价
    public var amount: NumberInt64?       // 总成交金额
    public var volume: NumberUInt64?      // 成交量
    
    public init(seq: NumberUInt32? = nil, latestTime: NumberUInt64? = nil, latestPrice: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil, high: NumberInt64? = nil, low: NumberInt64? = nil, amount: NumberInt64? = nil, volume: NumberUInt64? = nil) {
        self.seq = seq
        self.latestTime = latestTime
        self.latestPrice = latestPrice
        self.netchng = netchng
        self.pctchng = pctchng
        self.high = high
        self.low = low
        self.amount = amount
        self.volume = volume
    }
}

@objcMembers public class Vcm: NSObject, Codable {
    public let startTime: NumberUInt64?   // 开始时间
    public let endTime: NumberUInt64?     // 结束时间
    public let refPrice: NumberInt64?     // 参考价格
    public let lowerPrice: NumberInt64?   // 价格下限
    public let upperPrice: NumberInt64?   // 价格上限
    
    public init(startTime: NumberUInt64? = nil, endTime: NumberUInt64? = nil, refPrice: NumberInt64? = nil, lowerPrice: NumberInt64? = nil, upperPrice: NumberInt64? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.refPrice = refPrice
        self.lowerPrice = lowerPrice
        self.upperPrice = upperPrice
    }
}

@objcMembers public class Cas: NSObject, Codable {
    public let refPrice: NumberInt64?     // 参考价格
    public let lowerPrice: NumberInt64?   // 价格下限
    public let upperPrice: NumberInt64?   // 价格上限
    public let imbDirection: NumberInt32? // 差额方向,取值见：IMBDirection
    public let ordImbQty: NumberUInt64?   // 不能配对数量
    public let iePrice: NumberInt64?   // IEP
    public let ieVol: NumberInt64?   // IEV
    
    public init(refPrice: NumberInt64? = nil, lowerPrice: NumberInt64? = nil, upperPrice: NumberInt64? = nil, imbDirection: NumberInt32? = nil, ordImbQty: NumberUInt64? = nil, iePrice: NumberInt64? = nil, ieVol: NumberInt64? = nil) {
        self.refPrice = refPrice
        self.lowerPrice = lowerPrice
        self.upperPrice = upperPrice
        self.imbDirection = imbDirection
        self.ordImbQty = ordImbQty
        self.iePrice = iePrice
        self.ieVol = ieVol
    }
}

@objcMembers public class UnderlingSEC: NSObject, Codable {
    public let bvps: NumberInt64?         // 每股净资产
    public let casFlag: NumberBool?       // 竞价标识
    public let currency: NumberInt64?     // 货币类型
    public let dividend: NumberInt64?     // 股息
    public let eps: NumberInt64?          // 每股收益
    public let epsTTM: NumberInt64?       // 每股收益预测，用于计算市盈率
    public let exchange: NumberInt64?     // 交易所ID
    public let firstDayClosePrice: NumberInt64?   // 上市首日收盘价
    public let floatShare: NumberInt64?   // 流通股数
    public let greyFlag: NumberInt32?      // 是否是暗盘行情
    public let issuePrice: NumberInt64?   // 发行价
    public let issuedShare: NumberInt64?  // 总股本
    public var latestPrice: NumberInt64?  // 最新价
    public let limitDown: NumberInt64?    // 跌幅下限
    public let limitUp: NumberInt64?      // 涨幅上限
    public let listDate: NumberUInt64?    // 上市日期
    public let listStatus: NumberInt64?   // 证券状态
    public var market: String?      // 市场
    public var name: String?        // 名称
    public let netAsset: NumberInt64?     // 最新年度净资产
    public let netIncomeLastYear: NumberInt64?    // 最新年度净利润
    public let netIncomeLtm: NumberInt64?         // 滚动年度净利润
    public var netchng: NumberInt64?      // 涨跌值
    public var pctchng: NumberInt32?      // 涨跌幅, 使用时除以 100
    public var priceBase: NumberUInt32?   // 价格小数计算基数，10的幂次表示
    public let scmType: NumberInt64?      // 按位使用，0x1-港股通（沪）,0x2-港股通（深）,0x4-沪股通, 0x8-深股通
    public let shortSellFlag: NumberBool? // 未知(沽空? = nil)
    public let stc: NumberInt64?          // 价位表类型
    public var symbol: String?      // 代码
    public let totalDividend: NumberInt64?    // 近12个月分红综合
    public let trdUnit: NumberUInt32?      // 每手股数
    public let type1: NumberInt32?        // 证券一级类型
    public let type2: NumberInt32?        // 证券二级类型
    public let type3: NumberInt32?        // 证券三级类型
    public let vcmFlag: NumberBool?       // 冷静期标识
    
    public init(bvps: NumberInt64? = nil, casFlag: NumberBool? = nil, currency: NumberInt64? = nil, dividend: NumberInt64? = nil, eps: NumberInt64? = nil, epsTTM: NumberInt64? = nil, exchange: NumberInt64? = nil, firstDayClosePrice: NumberInt64? = nil, floatShare: NumberInt64? = nil, greyFlag: NumberInt32? = nil, issuePrice: NumberInt64? = nil, issuedShare: NumberInt64? = nil, latestPrice: NumberInt64? = nil, limitDown: NumberInt64? = nil, limitUp: NumberInt64? = nil, listDate: NumberUInt64? = nil, listStatus: NumberInt64? = nil, market: String? = nil, name: String? = nil, netAsset: NumberInt64? = nil, netIncomeLastYear: NumberInt64? = nil, netIncomeLtm: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil, priceBase: NumberUInt32? = nil, scmType: NumberInt64? = nil, shortSellFlag: NumberBool? = nil, stc: NumberInt64? = nil, symbol: String? = nil, totalDividend: NumberInt64? = nil, trdUnit: NumberUInt32? = nil, type1: NumberInt32? = nil, type2: NumberInt32? = nil, type3: NumberInt32? = nil, vcmFlag: NumberBool? = nil) {
        self.bvps = bvps
        self.casFlag = casFlag
        self.currency = currency
        self.dividend = dividend
        self.eps = eps
        self.epsTTM = epsTTM
        self.exchange = exchange
        self.firstDayClosePrice = firstDayClosePrice
        self.floatShare = floatShare
        self.greyFlag = greyFlag
        self.issuePrice = issuePrice
        self.issuedShare = issuedShare
        self.latestPrice = latestPrice
        self.limitDown = limitDown
        self.limitUp = limitUp
        self.listDate = listDate
        self.listStatus = listStatus
        self.market = market
        self.name = name
        self.netAsset = netAsset
        self.netIncomeLastYear = netIncomeLastYear
        self.netIncomeLtm = netIncomeLtm
        self.netchng = netchng
        self.pctchng = pctchng
        self.priceBase = priceBase
        self.scmType = scmType
        self.shortSellFlag = shortSellFlag
        self.stc = stc
        self.symbol = symbol
        self.totalDividend = totalDividend
        self.trdUnit = trdUnit
        self.type1 = type1
        self.type2 = type2
        self.type3 = type3
        self.vcmFlag = vcmFlag
    }
}

// MARK: - Ah
@objcMembers public class Ext: NSObject, Codable {
    public let ah: Ah?      // ah股行情，如果没有则是null
    public let adr: Adr?    // adr关联信息
    
    public init(ah: Ah? = nil, adr: Adr? = nil) {
        self.ah = ah
        self.adr = adr
    }
}

// MARK: - Ah
@objcMembers public class Ah: NSObject, Codable {
    public let market: String?      // 市场
    public let symbol: String?      // 代码
    public let latestPrice: NumberInt64?  // 最新价
    public let netchng: NumberInt64?      // 涨跌值
    public let pctchng: NumberInt32?      // 涨跌幅, 使用时除以 100
    public let latestTime: NumberUInt64?
    public let priceBase: NumberUInt32?   // 价格小数计算基数，10的幂次表示
    public let premium: NumberInt32?      // 溢价,使用时除以 100
    public var delay: NumberBool?         // 延时
    
    public init(market: String? = nil, symbol: String? = nil, latestPrice: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil, latestTime: NumberUInt64? = nil, priceBase: NumberUInt32? = nil, premium: NumberInt32? = nil, delay: NumberBool? = nil) {
        self.market = market
        self.symbol = symbol
        self.latestPrice = latestPrice
        self.netchng = netchng
        self.pctchng = pctchng
        self.latestTime = latestTime
        self.priceBase = priceBase
        self.premium = premium
        self.delay = delay
    }
    
    @objc public func deepMerged(with value: Ah?) -> Ah {
        guard let value = value else { return self }
        
        let oldDict = [String: Any].encoder(toDictionary: self)
        let recvDict = [String: Any].encoder(toDictionary: value)
        
        if let recvDict = recvDict {
            let result = oldDict?.merging(recvDict, uniquingKeysWith: { left, right in
                right ?? left
            })
            return result?.decode(Ah.self) ?? self
        }
        
        return self
    }
}

// MARK: - Adr
@objcMembers public class Adr: NSObject, Codable {
    public let market: String?      // 市场
    public let symbol: String?      // 代码
    public let name: String?        // 名称
    public let convPrice: NumberInt64?    // ADR换算价（HKD） = ADR报价（USD）/换股比率*汇率,汇率：1USD = 7.838HKD
    public let convRatio: NumberUInt32?   // ADR换股比率
    public let relaNetchng: NumberInt64?  // 对应代码涨跌额（ADR相对港股）
    public let relaPctchng: NumberInt32?  // 相对代码涨跌幅, 使用时除以 100(ADR相对港股)
    public let latestPrice: NumberInt64?  // 最新价
    public let netchng: NumberInt64?      // 涨跌值
    public let pctchng: NumberInt32?      // 涨跌幅, 使用时除以 100
    public let latestTime: NumberUInt64?
    public let priceBase: NumberUInt32?   // 价格小数计算基数，10的幂次表示
    public var delay: NumberBool?         // 延时
    
    public init(market: String? = nil, symbol: String? = nil, name: String? = nil, convPrice: NumberInt64? = nil, convRatio: NumberUInt32? = nil, relaNetchng: NumberInt64? = nil, relaPctchng: NumberInt32? = nil,  latestPrice: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil, latestTime: NumberUInt64? = nil, priceBase: NumberUInt32? = nil, delay: NumberBool? = nil) {
        self.market = market
        self.symbol = symbol
        self.name = name
        self.convPrice = convPrice
        self.convRatio = convRatio
        self.relaNetchng = relaNetchng
        self.relaPctchng = relaPctchng
        self.latestPrice = latestPrice
        self.netchng = netchng
        self.pctchng = pctchng
        self.latestTime = latestTime
        self.priceBase = priceBase
        self.delay = delay
    }
    
    @objc public func deepMerged(with value: Adr?) -> Adr {
        guard let value = value else { return self }
        
        let oldDict = [String: Any].encoder(toDictionary: self)
        let recvDict = [String: Any].encoder(toDictionary: value)
        
        if let recvDict = recvDict {
            let result = oldDict?.merging(recvDict, uniquingKeysWith: { left, right in
                right ?? left
            })
            return result?.decode(Adr.self) ?? self
        }
        
        return self
    }
}

// MARK: - Related
@objcMembers public class Related: NSObject, Codable {
    public let aStockFlag: NumberInt32?   //科创版/创业板标识，按位与方式使用(1: 是否注册制，2: 是否未盈利, 4: 是否存在投票权差异, 8是否具有协议控制架构)
    public let casFlag: NumberBool?       // 竞价标识
    public let dailyMargin: NumberBool?   //是否支持日内融
    public let dailyMarginGearing: NumberInt32? // 日内融杠杠比例
    public var exchange: NumberInt64?     // 交易所ID
    public var greyFlag: NumberInt32?      // 是否是暗盘行情
    public var listSector: NumberInt64?       // 板块信息
    public var listStatus: NumberInt64?   // 证券状态
    public var margin: NumberInt32? // 融资标签
    public var marginRatio: NumberDouble? // 抵押比率
    public var name: String?        // 名称
    public var market: String?      // 市场
    public var scmType: NumberInt64?      // 按位使用，0x1-港股通（沪）,0x2-港股通（深）,0x4-沪股通, 0x8-深股通
    public let shortSellFlag: NumberBool? // 未知(沽空? = nil)
    public var stc: NumberInt64?          // 价位表类型
    public var symbol: String?      // 代码
    public var type1: NumberInt32?        // 证券一级类型
    public var type2: NumberInt32?        // 证券二级类型
    public var type3: NumberInt32?        // 证券三级类型
    public var vcmFlag: NumberBool?       // 冷静期标识

    public init(aStockFlag: NumberInt32? = nil, casFlag: NumberBool? = nil, dailyMargin: NumberBool? = nil, dailyMarginGearing: NumberInt32? = nil, exchange: NumberInt64? = nil, greyFlag: NumberInt32? = nil, listSector: NumberInt64? = nil, listStatus: NumberInt64? = nil, margin: NumberInt32? = nil, marginRatio: NumberDouble? = nil, name: String? = nil, market: String? = nil, scmType: NumberInt64? = nil, shortSellFlag: NumberBool? = nil, stc: NumberInt64? = nil, symbol: String? = nil, type1: NumberInt32? = nil, type2: NumberInt32? = nil, type3: NumberInt32? = nil, vcmFlag: NumberBool? = nil) {
        self.aStockFlag = aStockFlag
        self.casFlag = casFlag
        self.dailyMargin = dailyMargin
        self.dailyMarginGearing = dailyMarginGearing
        self.exchange = exchange
        self.greyFlag = greyFlag
        self.listSector = listSector
        self.listStatus = listStatus
        self.margin = margin
        self.marginRatio = marginRatio
        self.name = name
        self.market = market
        self.scmType = scmType
        self.shortSellFlag = shortSellFlag
        self.stc = stc
        self.symbol = symbol
        self.type1 = type1
        self.type2 = type2
        self.type3 = type3
        self.vcmFlag = vcmFlag
    }
}


// MARK: - BTInfo
@objcMembers public class BTInfo: NSObject, Codable {
    public let baseAsset: String?        // 主代码
    public let quoteAsset: String?       // 用于交易的货币代码
    public let basePrecision: NumberInt32?     // 主代码的最大小数点位数
    public let quotePrecision: NumberInt32?       // 用于交易的货币代码的最大小数点位数
    public let name: String? // 名称
    public let type1: NumberInt32?        // 证券一级类型
    public let type2: NumberInt32?        // 证券二级类型
    public let type3: NumberInt32?        // 证券三级类型
    public let iconUrl: String?  // icon地址
    public let displayedSymbol: String?  // 用户展示的货币代码

    public init(baseAsset: String? = nil, quoteAsset: String? = nil, basePrecision: NumberInt32? = nil, quotePrecision: NumberInt32? = nil, name: String? = nil, type1: NumberInt32? = nil, type2: NumberInt32? = nil, type3: NumberInt32? = nil, iconUrl: String? = nil, displayedSymbol: String? = nil) {
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        self.basePrecision = basePrecision
        self.quotePrecision = quotePrecision
        self.name = name
        self.type1 = type1
        self.type2 = type2
        self.type3 = type3
        self.iconUrl = iconUrl
        self.displayedSymbol = displayedSymbol
    }
}


// MARK: - BTRealTime
@objcMembers public class BTRealTime: NSObject, Codable {
    public let latestTime: NumberUInt64?        // 最新时间
    public let high: String?                     // 24h最高成交价格
    public let low: String?                      // 24h最低成交价格
    public let now: String?                      // 24h最新一笔价格
    public let preClose: String?                 // 24h向前最后一笔价格
    public let open: String?                     // 24h向后数第一笔价格
    public let avg: String?                      // 平均价格
    public let netchng: String?                   // 24h 价格变化值
    public let pctchng: String?                   // 24 价格变化百分比
    public let amount: String?                   // 24h成交额
    public let volume: String?                   // 24成交量
    public let high52W: String?                  // 52周高成交价格
    public let low52W: String?                   // 52周最低成交价格
    public let trdStatus: NumberInt32?           // 个股交易状态

    public init(latestTime: NumberUInt64? = nil, high: String? = nil, low: String? = nil, now: String? = nil, preClose: String? = nil, open: String? = nil, avg: String?  = nil, netchng: String? = nil, pctchng: String? = nil, amount: String? = nil, volume: String? = nil, high52W: String? = nil, low52W: String? = nil, trdStatus: NumberInt32? = nil) {
        self.latestTime = latestTime
        self.high = high
        self.low = low
        self.now = now
        self.preClose = preClose
        self.open = open
        self.avg = avg
        self.netchng = netchng
        self.pctchng = pctchng
        self.amount = amount
        self.volume = volume
        self.high52W = high52W
        self.low52W = low52W
        self.trdStatus = trdStatus
    }
}

// MARK: - BTOrderBook
@objcMembers public class BTOrderBook: NSObject, Codable {
    public let latestTime: NumberUInt64?        // 最新时间
    public let items: [BTOrderBookItem]?         // 报单簿条目

    public init(latestTime: NumberUInt64? = nil, items: [BTOrderBookItem]? = nil) {
        self.latestTime = latestTime
        self.items = items
    }
}

// MARK: - BTOrderBookItem
@objcMembers public class BTOrderBookItem: NSObject, Codable {
    public let bidPrice: String?        // 买一
    public let bidVolume: String?       // 买一量
    public let askPrice: String?        // 卖一
    public let askVolume: String?       // 卖一量

    public init(bidPrice: String? = nil, bidVolume: String? = nil, askPrice: String? = nil, askVolume: String? = nil) {
        self.bidPrice = bidPrice
        self.bidVolume = bidVolume
        self.askPrice = askPrice
        self.askVolume = askVolume
    }
}


// MARK: - BTOrderBookItem
@objcMembers public class QuoteID: NSObject, Codable {
    public let market: String?        // 市场
    public let symbol: String?       // 代码

    public init(market: String? = nil, symbol: String? = nil) {
        self.market = market
        self.symbol = symbol
    }
}
@objcMembers public class NumberInt32: NSObject, Codable {
    
    public let value: Int32
    public let stringValue: String
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(Int32.self) {
                self.value = value
                self.stringValue = "\(value)"
            } else if let value = try? container.decode(String.self) {
                self.stringValue = value
                self.value = Int32(value) ?? 0
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberInt32.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
    
    public init(_ value: Int32) {
        self.value = value
        self.stringValue = "\(value)"
    }
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.value = Int32(stringValue) ?? 0
    }
}

@objcMembers public class NumberUInt32: NSObject, Codable {
    
    public let value: UInt32
    public let stringValue: String
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(UInt32.self) {
                self.value = value
                self.stringValue = "\(value)"
            } else if let value = try? container.decode(String.self) {
                self.stringValue = value
                self.value = UInt32(value) ?? 0
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberUInt32.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
    
    public init(_ value: UInt32) {
        self.value = value
        self.stringValue = "\(value)"
    }
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.value = UInt32(stringValue) ?? 0
    }
}


@objcMembers public class NumberInt64: NSObject, Codable {
    public let value: Int64
    public let stringValue: String
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(Int64.self) {
                self.value = value
                self.stringValue = "\(value)"
            } else if let value = try? container.decode(String.self) {
                self.stringValue = value
                self.value = Int64(value) ?? 0
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberInt64.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
    
    public init(_ value: Int64) {
        self.value = value
        self.stringValue = "\(value)"
    }
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.value = Int64(stringValue) ?? 0
    }
}

@objcMembers public class NumberUInt64: NSObject, Codable {
    
    public let value: UInt64
    public let stringValue: String
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(UInt64.self) {
                self.value = value
                self.stringValue = "\(value)"
            } else if let value = try? container.decode(String.self) {
                self.stringValue = value
                self.value = UInt64(value) ?? 0
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberUInt64.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
    
    public init(_ value: UInt64) {
        self.value = value
        self.stringValue = "\(value)"
    }
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.value = UInt64(stringValue) ?? 0
    }
}

@objcMembers public class NumberBool: NSObject, Codable {
    
    public let value: Bool
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(Bool.self) {
                self.value = value
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberBool.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
    public init(_ value: Bool) {
        self.value = value
    }
}

@objcMembers public class NumberDouble: NSObject, Codable {
    
    public let value: Double
    public let stringValue: String
    
    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(Double.self) {
                self.value = value
                self.stringValue = "\(value)"
            } else if let value = try? container.decode(String.self) {
                self.stringValue = value
                self.value = Double(value) ?? 0
            }  else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }else {
            throw DecodingError.typeMismatch(NumberDouble.self,  DecodingError.Context.init(codingPath: [], debugDescription: "typeMismatch"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try stringValue.encode(to: encoder)
    }
    
    public init(_ value: Double) {
        self.value = value
        self.stringValue = "\(value)"
    }
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.value = Double(stringValue) ?? 0
    }
}


