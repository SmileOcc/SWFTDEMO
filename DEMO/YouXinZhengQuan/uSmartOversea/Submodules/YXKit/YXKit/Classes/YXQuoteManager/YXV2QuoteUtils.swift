//
//  YXV2QuoteUtils.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/9/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

extension Dictionary {
    public func deepMerged(with other: [Key: Value]?) -> [Key: Value]
    {
        guard let other = other else { return self }
        
        var result: [Key: Value] = self
        for (key, value) in other {
            if let value = value as? [Key: Value],
                let existing = result[key] as? [Key: Value],
                let merged = existing.deepMerged(with: value) as? Value
            {
                result[key] = merged
            } else {
                if value != nil {
                    result[key] = value
                }
            }
        }
        return result
    }
    
    public static func encoder<T>(toDictionary model: T) -> [String: Any]? where T: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(model) else { return nil }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
            return nil
        }
        return dict
    }
    
    public func decode<T>(_ type: T.Type) -> T? where T: Decodable {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        
        guard let model = try? JSONDecoder().decode(type, from: jsonData) else {
            return nil
        }
        return model
    }
}

class YXV2QuoteUtils {
    static func klQuote(from pbQuote: OBJECT_QUOTEKLineData) -> YXKLine {
        let time = NumberUInt64(pbQuote.latestTime)
        let preClose = NumberInt64(pbQuote.preClose)
        let open = NumberInt64(pbQuote.open)
        let close = NumberInt64(pbQuote.close)
        let high = NumberInt64(pbQuote.high)
        let low = NumberInt64(pbQuote.low)
        let avg = NumberInt64(pbQuote.avg)
        let volume = NumberUInt64(pbQuote.volume)
        let amount = NumberInt64(pbQuote.amount)
        let netchng = NumberInt64(pbQuote.netchng)
        let pctchng = NumberInt32(pbQuote.pctchng)
        let turnoverRate = NumberInt32(pbQuote.turnoverRate)
        let postVolume = NumberUInt64(pbQuote.postVolume)
        let postAmount = NumberInt64(pbQuote.postAmount)
        return YXKLine(latestTime: time, preClose: preClose, open: open, close: close, high: high, low: low, avg: avg, volume: volume, amount: amount, netchng: netchng, pctchng: pctchng, turnoverRate: turnoverRate, postVolume: postVolume, postAmount: postAmount)
    }
    
    static func tkQuote(from pbQuote: OBJECT_QUOTETickData) -> YXTick {
        let id_p = NumberUInt64(pbQuote.id_p)
        let time = NumberUInt64(pbQuote.time)
        let price = NumberInt64(pbQuote.price)
        let volume = NumberUInt64(pbQuote.volume)
        let direction = NumberInt32(pbQuote.direction.rawValue)
        let tickNum = NumberUInt32(pbQuote.tick)
        let bidOrderNo = NumberInt64(pbQuote.bidOrderNo)
        let bidOrderSize = NumberUInt64(pbQuote.bidOrderSize)
        let askOrderNo = NumberInt64(pbQuote.askOrderNo)
        let askOrderSize = NumberUInt64(pbQuote.askOrderSize)
        let trdType = NumberUInt32(pbQuote.trdType)
        let exchange = NumberInt32(pbQuote.exchange.rawValue)
        return YXTick(id: id_p, time: time, price: price, volume: volume, direction: direction, tick: tickNum, bidOrderNo: bidOrderNo, bidOrderSize: bidOrderSize, askOrderNo: askOrderNo, askOrderSize: askOrderSize, trdType: trdType, exchange: exchange)
    }
    
    static func tsQuote(from pbQuote: OBJECT_QUOTETSData) -> YXTimeLine {
        let time = NumberUInt64(pbQuote.latestTime)
        let preClose = NumberInt64(pbQuote.preClose)
        let price = NumberInt64(pbQuote.price)
        let avg = NumberInt64(pbQuote.avg)
        let volume = NumberUInt64(pbQuote.volume)
        let amount = NumberInt64(pbQuote.amount)
        let netchng = NumberInt64(pbQuote.netchng)
        let pctchng = NumberInt32(pbQuote.pctchng)
        return YXTimeLine(latestTime: time, preClose: preClose, price: price, avg: avg, volume: volume, amount: amount, netchng: netchng, pctchng: pctchng)
    }
    
    //港美股行情
    static func rtQuote(from pbQuote: OBJECT_QUOTEQuote) -> YXV2Quote {
        let quote = YXV2Quote()
        quote.priceBase = NumberUInt32(pbQuote.priceBase)
        quote.recvTime = NumberUInt64(pbQuote.recvTime)
        if pbQuote.hasQuoteData, let _quoteData = pbQuote.quoteData {
            quote.seq = NumberUInt32(_quoteData.seq)
            quote.latestTime = NumberUInt64(_quoteData.latestTime)
            quote.qtType = NumberInt32(_quoteData.qtType.rawValue)
            quote.preClose = NumberInt64(_quoteData.preClose)
            quote.open = NumberInt64(_quoteData.open)
            quote.latestPrice = NumberInt64(_quoteData.latestPrice)
            quote.high = NumberInt64(_quoteData.high)
            quote.low = NumberInt64(_quoteData.low)
            quote.close = NumberInt64(_quoteData.close)
            quote.volume = NumberUInt64(_quoteData.volume)
            quote.amount = NumberInt64(_quoteData.amount)
            quote.netchng = NumberInt64(_quoteData.netchng)
            quote.pctchng = NumberInt32(_quoteData.pctchng)
            quote.amp = NumberInt32(_quoteData.amp)
            quote.avg = NumberInt64(_quoteData.avg)
            quote.week52High = NumberInt64(_quoteData.week52High)
            quote.week52Low = NumberInt64(_quoteData.week52Low)
            quote.historyHigh = NumberInt64(_quoteData.historyHigh)
            quote.historyLow = NumberInt64(_quoteData.historyLow)
            quote.volumeRatio = NumberInt32(_quoteData.volumeRatio)
            quote.turnoverRate = NumberInt32(_quoteData.turnoverRate)
            quote.qtyUnit = NumberInt32(_quoteData.qtyUnit)
            quote.askPrice = NumberInt64(_quoteData.askPrice)
            quote.askSize = NumberUInt64(_quoteData.askSize)
            quote.bidPrice = NumberInt64(_quoteData.bidPrice)
            quote.bidSize = NumberUInt64(_quoteData.bidSize)
            quote.trdStatus = NumberInt32(_quoteData.trdStatus.rawValue)
            quote.accer = NumberInt32(_quoteData.accer)
            quote.usTime = NumberInt32(_quoteData.usTime.rawValue)
            quote.postVolume = NumberUInt64(_quoteData.postVolume)
            quote.postAmount = NumberInt64(_quoteData.postAmount)
            quote.pctChng5Day = NumberInt32(_quoteData.pctChng5Day)
            quote.pctChngThisYear = NumberInt32(_quoteData.pctChngThisYear)
            quote.netChng5Day = NumberInt64(_quoteData.netChng5Day)
            quote.netChngThisYear = NumberInt64(_quoteData.netChngThisYear)
            
            switch _quoteData.qtType {
            case .qtEqty:
                if _quoteData.hasStock, let _stock = _quoteData.stock {
                    quote.in = NumberUInt64(_stock.in_p)
                    quote.out = NumberUInt64(_stock.out_p)
                    quote.pe = NumberInt32(_stock.pe)
                    quote.peTTM = NumberInt32(_stock.peTtm)
                    quote.pb = NumberInt32(_stock.pb)
                    quote.divYield = NumberInt32(_stock.divYield)
                    quote.mktCap = NumberInt64(_stock.mktCap)
                    quote.floatCap = NumberInt64(_stock.floatCap)
                    
//                    if _stock.hasAhQt, let _ahQt = _stock.ahQt {
//                        let latestPrice = NumberInt64(_ahQt.latestPrice)
//                        let netchng = NumberInt64(_ahQt.netchng)
//                        let pctchng = NumberInt32(_ahQt.pctchng)
//                        let premium = NumberInt32(_ahQt.premium)
//                        let priceBase = NumberUInt32(_ahQt.priceBase)
//                        quote.ah = Ah(latestPrice: latestPrice, premium: premium, priceBase: priceBase, netchng: netchng, pctchng: pctchng)
//                    }
                
                    if _stock.hasCas, let _cas = _stock.cas {
                        let refPrice = NumberInt64(_cas.refPrice)
                        let lowerPrice = NumberInt64(_cas.lowerPrice)
                        let upperPrice = NumberInt64(_cas.upperPrice)
                        let imbDirection = NumberInt32(_cas.imbDirection.rawValue)
                        let ordImbQty = NumberUInt64(_cas.ordImbQty)
                        let iePrice = NumberInt64(_cas.iePrice)
                        let ieVol = NumberInt64(_cas.ieVol)
                        quote.cas = Cas(refPrice: refPrice, lowerPrice: lowerPrice, upperPrice: upperPrice, imbDirection: imbDirection, ordImbQty: ordImbQty, iePrice: iePrice, ieVol: ieVol)

                    }
                    
                    if _stock.hasVcm, let _vcm = _stock.vcm {
                        let startTime = NumberUInt64(_vcm.startTime)
                        let endTime = NumberUInt64(_vcm.endTime)
                        let refPrice = NumberInt64(_vcm.refPrice)
                        let lowerPrice = NumberInt64(_vcm.lowerPrice)
                        let upperPrice = NumberInt64(_vcm.upperPrice)
                        quote.vcm = Vcm(startTime: startTime, endTime: endTime, refPrice: refPrice, lowerPrice: lowerPrice, upperPrice: upperPrice)
                    }
                    
//                    if _stock.hasAdrh, let _adr = _stock.adrh {
//                        let convPrice = NumberInt64(_adr.convPrice)
//                        let convRatio = NumberUInt32(_adr.convRatio)
//                        let relaNetchng = NumberInt64(_adr.relaNetchng)
//                        let relaPctchng = NumberInt32(_adr.relaPctchng)
//                        let latestPrice = NumberInt64(_adr.latestPrice)
//                        let netchng = NumberInt64(_adr.netchng)
//                        let pctchng = NumberInt32(_adr.pctchng)
//                        let latestTime = NumberUInt64(_adr.latestTime)
//                        let priceBase = NumberUInt32(_adr.priceBase)
//                        quote.adr = Adr(convPrice: convPrice, convRatio: convRatio, relaNetchng: relaNetchng, relaPctchng: relaPctchng, latestPrice: latestPrice, netchng: netchng, pctchng: pctchng, latestTime: latestTime, priceBase: priceBase)
//                    }
                }
            case .qtBond:
                if _quoteData.hasBond, let _bond = _quoteData.bond {
                    quote.in = NumberUInt64(_bond.in_p)
                    quote.out = NumberUInt64(_bond.out_p)
                    quote.mktCap = NumberInt64(_bond.mktCap)
                    quote.floatCap = NumberInt64(_bond.floatCap)
                }
            case .qtTrst:
                if _quoteData.hasFund, let _fund = _quoteData.fund {
                    quote.in = NumberUInt64(_fund.in_p)
                    quote.out = NumberUInt64(_fund.out_p)
                    quote.mktCap = NumberInt64(_fund.mktCap)
                    quote.floatCap = NumberInt64(_fund.floatCap)
                    quote.premium = NumberInt32(_fund.premium)
                    
                    if _fund.hasCas, let _cas = _fund.cas {
                        let refPrice = NumberInt64(_cas.refPrice)
                        let lowerPrice = NumberInt64(_cas.lowerPrice)
                        let upperPrice = NumberInt64(_cas.upperPrice)
                        let imbDirection = NumberInt32(_cas.imbDirection.rawValue)
                        let ordImbQty = NumberUInt64(_cas.ordImbQty)
                        quote.cas = Cas(refPrice: refPrice, lowerPrice: lowerPrice, upperPrice: upperPrice, imbDirection: imbDirection, ordImbQty: ordImbQty)
                    }
                    
                    if _fund.hasVcm, let _vcm = _fund.vcm {
                        let startTime = NumberUInt64(_vcm.startTime)
                        let endTime = NumberUInt64(_vcm.endTime)
                        let refPrice = NumberInt64(_vcm.refPrice)
                        let lowerPrice = NumberInt64(_vcm.lowerPrice)
                        let upperPrice = NumberInt64(_vcm.upperPrice)
                        quote.vcm = Vcm(startTime: startTime, endTime: endTime, refPrice: refPrice, lowerPrice: lowerPrice, upperPrice: upperPrice)
                    }
                }
            case .qtWrnt:
                if _quoteData.hasWarrant, let _warrant = _quoteData.warrant {
                    quote.in = NumberUInt64(_warrant.in_p)
                    quote.out = NumberUInt64(_warrant.out_p)
                    quote.wrnType = NumberInt32(_warrant.wrnType.rawValue)
                    quote.premium = NumberInt32(_warrant.premium)
                    quote.impliedVolatility = NumberInt32(_warrant.impliedVolatility)
                    quote.delta = NumberInt32(_warrant.delta)
                    quote.moneyness = NumberInt32(_warrant.moneyness)
                    quote.gearing = NumberInt32(_warrant.gearing)
                    quote.effgearing = NumberInt32(_warrant.effgearing)
                    quote.diffRatio = NumberInt32(_warrant.diffRatio)
                    quote.convertPrice = NumberInt64(_warrant.convertPrice)
                    quote.breakevenPoint = NumberInt32(_warrant.breakevenPoint)
                    quote.fromUpper = NumberInt32(_warrant.fromUpper)
                    quote.fromLower = NumberInt32(_warrant.fromLower)
                    
                    if _warrant.hasUnderlingQt, let underlingQt = _warrant.underlingQt {
                        let latestPrice = NumberInt64(underlingQt.latestPrice)
                        let netchng = NumberInt64(underlingQt.netchng)
                        let pctchng = NumberInt32(underlingQt.pctchng)
                        let priceBase = NumberUInt32(underlingQt.priceBase)
                        quote.underlingSEC = UnderlingSEC(latestPrice: latestPrice, netchng: netchng, pctchng: pctchng, priceBase: priceBase)
                    }
                }
            case .qtIndex:
                if _quoteData.hasIndex, let _index = _quoteData.index {
                    quote.up = NumberUInt32(_index.up)
                    quote.down = NumberUInt32(_index.down)
                    quote.unchange = NumberUInt32(_index.unchange)
                    quote.mktCap = NumberInt64(_index.mktCap)
                    quote.floatCap = NumberInt64(_index.floatCap)
                    quote.pe = NumberInt32(_index.pe)
                    quote.peTTM = NumberInt32(_index.peTtm)
                    quote.pb = NumberInt32(_index.pb)
                }
            case .qtOption:
                if _quoteData.hasOption, let _option = _quoteData.option {
                    quote.premium = NumberInt32(_option.premium)
                    quote.impliedVolatility = NumberInt32(_option.impliedVolatility)
                    quote.delta = NumberInt32(_option.delta)
                    quote.gamma = NumberInt32(_option.gamma)
                    quote.theta = NumberInt32(_option.theta)
                    quote.vega = NumberInt32(_option.vega)
                    quote.rho = NumberInt32(_option.rho)
                    quote.openInt = NumberUInt64(_option.openInt)
                    quote.theoryPrice = NumberInt64(_option.theoryPrice)
                }
            case .qtPlate:
                if _quoteData.hasSector, let _sector = _quoteData.sector {
                    quote.up = NumberUInt32(_sector.up)
                    quote.down = NumberUInt32(_sector.down)
                    quote.unchange = NumberUInt32(_sector.unchange)
                    quote.mktCap = NumberInt64(_sector.mktCap)
                    quote.floatCap = NumberInt64(_sector.floatCap)
                    quote.pe = NumberInt32(_sector.pe)
                    quote.peTTM = NumberInt32(_sector.peTtm)
                    quote.pb = NumberInt32(_sector.pb)
                }
            default:
                break
            }
        }
        
        if pbQuote.hasMsInfo, let _msInfo = pbQuote.msInfo {
            let mktTime = NumberUInt64(_msInfo.mktTime)
            let market = NumberInt32(_msInfo.market.rawValue)
            let status = NumberInt32(_msInfo.status.rawValue)
            var desc: String? = nil
            if _msInfo.statusDescArray_Count > 0 {
                for securityName in _msInfo.statusDescArray {
                    if let model = securityName as? OBJECT_SECUSecurityName {
                        if YXUserHelper.currentLanguage() == model.lang.rawValue {
                            desc = model.name
                            break
                        }
                    }
                }
            }
            
            quote.msInfo = MSInfo(desc: desc, market: market, mktTime: mktTime, status: status)
        }

        if pbQuote.hasInfo, let _info = pbQuote.info {
            if _info.hasStock, let _stock = _info.stock {
                if _stock.floatShare > 0 {
                    quote.floatShare = NumberUInt64(_stock.floatShare)
                }

                if (_stock.issuedShare > 0) {
                    quote.issuedShare = NumberUInt64(_stock.issuedShare)
                }
            }

            if _info.hasFund, let _fund = _info.fund {
                if _fund.floatShare > 0 {
                    quote.floatShare = NumberUInt64(_fund.floatShare)
                }

                if _fund.issuedShare > 0 {
                    quote.issuedShare = NumberUInt64(_fund.issuedShare)
                }
            }

            if _info.hasSector, let _sector = _info.sector {
                if _sector.floatShare > 0 {
                    quote.floatShare = NumberUInt64(_sector.floatShare)
                }

                if _sector.issuedShare > 0 {
                    quote.issuedShare = NumberUInt64(_sector.issuedShare)
                }
            }

            quote.hkSecuFlag = NumberInt32(_info.hkSecuFlag)
        }

        if pbQuote.hasSQuote, let _sQuote = pbQuote.sQuote {
            let seq = NumberUInt32(_sQuote.seq)
            let latestTime = NumberUInt64(_sQuote.latestTime)
            let latestPrice = NumberInt64(_sQuote.latestPrice)
            let netchng = NumberInt64(_sQuote.netchng)
            let pctchng = NumberInt32(_sQuote.pctchng)
            let high = NumberInt64(_sQuote.high)
            let low = NumberInt64(_sQuote.low)
            let volume = NumberUInt64(_sQuote.volume)
            let amount = NumberInt64(_sQuote.amount)
            
            quote.sQuote = SQuote(seq: seq, latestTime: latestTime, latestPrice: latestPrice, netchng: netchng, pctchng: pctchng, high: high, low: low, amount: amount, volume: volume)
        }
//
//        if pbQuote.hasPos, let _pos = pbQuote.pos {
//            let latestTime = NumberUInt64(_pos.latestTime)
//            let cittDiff = NumberInt64(_pos.cittDiff)
//            let cittThan = NumberInt32(_pos.cittThan)
//            let totalAskSize = NumberInt64(_pos.totalAskSize)
//            let totalBidSize = NumberInt64(_pos.totalBidSize)
//
//            var posData: [PosData]? = nil
//            if _pos.posDataArray_Count > 0 {
//                posData = _pos.posDataArray.map({ (data) -> PosData in
//                    guard let _posData = data as? OBJECT_QUOTEPositionData else { return PosData() }
//
//                    let askOrderCount = NumberUInt64(_posData.askOrderCount)
//                    let askSize = NumberUInt64(_posData.askSize)
//                    let askPrice = NumberInt64(_posData.askPrice)
//                    let bidOrderCount = NumberUInt64(_posData.bidOrderCount)
//                    let bidPrice = NumberInt64(_posData.bidPrice)
//                    let bidSize = NumberUInt64(_posData.bidSize)
//                    return PosData(askOrderCount: askOrderCount, askPrice: askPrice, askSize: askSize, bidOrderCount: bidOrderCount, bidPrice: bidPrice, bidSize: bidSize)
//                })
//            }
//            quote.pos = Pos(cittDiff: cittDiff, cittThan: cittThan, latestTime: latestTime, posData: posData, totalAskSize: totalAskSize, totalBidSize: totalBidSize)
//        }
//
//        if pbQuote.hasBrokerData, let _brokerData = pbQuote.brokerData {
//            var bidBroker: [BrokerDetail]? = nil
//            var askBroker: [BrokerDetail]? = nil
//            if _brokerData.bidBrokerArray_Count > 0 {
//                bidBroker = _brokerData.bidBrokerArray.map({ (data) -> BrokerDetail in
//                    guard let _brokerDetail = data as? OBJECT_QUOTEBrokerDetail else { return BrokerDetail() }
//
//                    let id_p = _brokerDetail.id_p
//                    let name = _brokerDetail.name
//                    return BrokerDetail(Id: id_p, Name: name)
//                })
//            }
//
//            if _brokerData.askBrokerArray_Count > 0 {
//                askBroker = _brokerData.askBrokerArray.map({ (data) -> BrokerDetail in
//                    guard let _brokerDetail = data as? OBJECT_QUOTEBrokerDetail else { return BrokerDetail() }
//
//                    let id_p = _brokerDetail.id_p
//                    let name = _brokerDetail.name
//                    return BrokerDetail(Id: id_p, Name: name)
//                })
//            }
//
//            quote.brokerData = Broker(bidBroker: bidBroker, askBroker: askBroker)
//        }
//
        return quote
    }
    
    static func rtPosQuote(from pbQuote: OBJECT_QUOTEQuote) -> Pos {
        if pbQuote.hasPos, let _pos = pbQuote.pos {
            let latestTime = NumberUInt64(_pos.latestTime)
            let cittDiff = NumberInt64(_pos.cittDiff)
            let cittThan = NumberInt32(_pos.cittThan)
            let totalAskSize = NumberInt64(_pos.totalAskSize)
            let totalBidSize = NumberInt64(_pos.totalBidSize)
            
            var posData: [PosData]? = nil
            if _pos.posDataArray_Count > 0 {
                posData = _pos.posDataArray.map({ (data) -> PosData in
                    guard let _posData = data as? OBJECT_QUOTEPositionData else { return PosData() }
                    
                    let askOrderCount = NumberUInt64(_posData.askOrderCount)
                    let askSize = NumberUInt64(_posData.askSize)
                    let askPrice = NumberInt64(_posData.askPrice)
                    let bidOrderCount = NumberUInt64(_posData.bidOrderCount)
                    let bidPrice = NumberInt64(_posData.bidPrice)
                    let bidSize = NumberUInt64(_posData.bidSize)
                    return PosData(askOrderCount: askOrderCount, askPrice: askPrice, askSize: askSize, bidOrderCount: bidOrderCount, bidPrice: bidPrice, bidSize: bidSize)
                })
            }
            return Pos(cittDiff: cittDiff, cittThan: cittThan, latestTime: latestTime, posData: posData, totalAskSize: totalAskSize, totalBidSize: totalBidSize)
        }
        
        return Pos()
    }
    
    static func rtBrokerQuote(from pbQuote: OBJECT_QUOTEQuote) -> Broker {
        if pbQuote.hasBrokerData, let _brokerData = pbQuote.brokerData {
            var bidBroker: [BrokerDetail]? = nil
            var askBroker: [BrokerDetail]? = nil
            if _brokerData.bidBrokerArray_Count > 0 {
                bidBroker = _brokerData.bidBrokerArray.map({ (data) -> BrokerDetail in
                    guard let _brokerDetail = data as? OBJECT_QUOTEBrokerDetail else { return BrokerDetail() }
                    
                    let id_p = _brokerDetail.id_p
                    let name = _brokerDetail.name
                    return BrokerDetail(Id: id_p, Name: name)
                })
            }
            
            if _brokerData.askBrokerArray_Count > 0 {
                askBroker = _brokerData.askBrokerArray.map({ (data) -> BrokerDetail in
                    guard let _brokerDetail = data as? OBJECT_QUOTEBrokerDetail else { return BrokerDetail() }
                    
                    let id_p = _brokerDetail.id_p
                    let name = _brokerDetail.name
                    return BrokerDetail(Id: id_p, Name: name)
                })
            }
            return Broker(bidBroker: bidBroker, askBroker: askBroker)
        }
        return Broker(askBroker: nil)
    }

    static func btKlQuote(from pbQuote: OBJECT_QUOTECryptosKline) -> YXKLine {
        #if OVERSEAS
        let time = NumberUInt64(pbQuote.latestTime)
        let preClose = NumberInt64(stringValue: pbQuote.preClose)
        let open = NumberInt64(stringValue: pbQuote.open)
        let close = NumberInt64(stringValue: pbQuote.close)
        let high = NumberInt64(stringValue: pbQuote.high)
        let low = NumberInt64(stringValue: pbQuote.low)
        let volume = NumberUInt64(stringValue: pbQuote.volume)
        let amount = NumberInt64(stringValue: pbQuote.amount)
        let netchng = NumberInt64(stringValue: pbQuote.netchng)
        let pctchng = NumberInt32(stringValue: pbQuote.pctchng)

        return YXKLine(latestTime: time, preClose: preClose, open: open, close: close, high: high, low: low, volume: volume, amount: amount, netchng: netchng, pctchng: pctchng)
        #else
        return YXKLine()
        #endif
    }


    static func btTkQuote(from pbQuote: OBJECT_QUOTECryptosTick) -> YXTick {
        #if OVERSEAS
        let latestTime = NumberUInt64(pbQuote.latestTime)
        let id_p = NumberUInt64(UInt64(pbQuote.id_p))
        let price = NumberInt64(stringValue: pbQuote.price)
        let volume = NumberUInt64(stringValue: pbQuote.volume)
        let direction = NumberInt32(pbQuote.direction)
        return YXTick(id: id_p, latestTime: latestTime, price: price, volume: volume, direction: direction)
        #else
        return YXTick()
        #endif
    }


    //数字货币行情
    static func btQuote(from pbQuote: OBJECT_QUOTECryptosQuote) -> YXV2Quote {
        let quote = YXV2Quote()

        if pbQuote.hasMsInfo, let _msInfo = pbQuote.msInfo {
            let mktTime = NumberUInt64(_msInfo.mktTime)
            let market = NumberInt32(_msInfo.market.rawValue)
            let status = NumberInt32(_msInfo.status.rawValue)
            var desc: String? = nil
            if _msInfo.statusDescArray_Count > 0 {
                for securityName in _msInfo.statusDescArray {
                    if let model = securityName as? OBJECT_SECUSecurityName {
                        if YXUserHelper.currentLanguage() == model.lang.rawValue {
                            desc = model.name
                            break
                        }
                    }
                }
            }

            quote.msInfo = MSInfo(desc: desc, market: market, mktTime: mktTime, status: status)
        }


        if pbQuote.hasInfo, let _info = pbQuote.info {

            let basePrecision = NumberInt32(_info.basePrecision)
            let quotePrecision = NumberInt32(_info.quotePrecision)
            let type1 = NumberInt32(_info.type1.rawValue)
            let type2 = NumberInt32(_info.type2.rawValue)
            let type3 = NumberInt32(_info.type3.rawValue)

            quote.btInfo = BTInfo(baseAsset: _info.baseAsset, quoteAsset: _info.quoteAsset, basePrecision: basePrecision, quotePrecision: quotePrecision, name: _info.name, type1: type1, type2: type2, type3: type3, iconUrl: _info.iconURL)
        }

        if pbQuote.hasRealtime, let _realtime = pbQuote.realtime {

            let latestTime = NumberUInt64(_realtime.latestTime)
            let trdStatus = NumberInt32(_realtime.trdStatus.rawValue)

            quote.btRealTime = BTRealTime(latestTime: latestTime, high: _realtime.high, low: _realtime.low, now: _realtime.now, preClose: _realtime.preClose, open: _realtime.open, avg: _realtime.avg, netchng: _realtime.netchng, pctchng: _realtime.pctchng, amount: _realtime.amount, volume: _realtime.volume, high52W: _realtime.high52W, low52W: _realtime.low52W, trdStatus: trdStatus)
        }

        if pbQuote.hasOrderBook, let _orderBook = pbQuote.orderBook {

            let latestTime = NumberUInt64(_orderBook.latestTime)

            var items: [BTOrderBookItem]? = nil
            if _orderBook.itemsArray_Count > 0 {
                var bookItems: [BTOrderBookItem] = []
                for info in _orderBook.itemsArray {
                    if let bookItem = info as? OBJECT_QUOTECryptosOrderBookItem {
                        let item = BTOrderBookItem(bidPrice: bookItem.bidPrice, bidVolume: bookItem.bidVolume, askPrice: bookItem.askPrice, askVolume: bookItem.askVolume)
                        bookItems.append(item)
                    }
                }
                items = bookItems
            }

            quote.btOrderBook = BTOrderBook(latestTime: latestTime, items: items)
        }

        return quote
    }
    
    //深度摆盘行情
    static func depthOrderQuote(from orderBook: OBJECT_QUOTEOrderBook) -> YXDepthOrderData {
        
        let depthOrderData = YXDepthOrderData()
        
        if orderBook.askArray_Count > 0 {
            var asks: [YXDepthOrder] = []
            for info in orderBook.askArray {
                if let model = info as? OBJECT_QUOTEOrder {
                    let order = YXDepthOrder(price: NumberInt64(model.price), size: NumberInt64(model.size))
                    asks.append(order)
                }
            }
            
            if asks.count > 0 {
                depthOrderData.ask = asks
            }
        }
        
        if orderBook.bidArray_Count > 0 {
            var bids: [YXDepthOrder] = []
            for info in orderBook.bidArray {
                if let model = info as? OBJECT_QUOTEOrder {
                    let order = YXDepthOrder(price: NumberInt64(model.price), size: NumberInt64(model.size))
                    bids.append(order)
                }
            }
            
            if bids.count > 0 {
                depthOrderData.bid = bids
            }
        }
        
        return depthOrderData
    }
}

