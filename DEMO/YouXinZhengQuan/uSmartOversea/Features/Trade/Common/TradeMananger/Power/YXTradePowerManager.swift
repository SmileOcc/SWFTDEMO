//
//  YXTradePowerManager.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class PowerInfo {
    typealias PowerParams = (market: String, tradeType: TradeType, tradeOrderType: TradeOrderType, powerOrderType: TradeOrderType, direction: TradeDirection, tradeStatus: TradeStatus)
    
    enum PowerType: Int {
        case buy
        case marginBuy
        case optionBuy
        case sell
        case cashBuyPower
        case marginBuyPower
    }
    
    var params: PowerParams?
    
    var cashEnableAmount: Double = -1
    var marginEnableAmount: Double = -1
    var saleEnableAmount: Double = -1
    var maxCashBuyMulti : Double = -1
    
    var costPrice: Double = -1 //成本价, 止盈止损用
    
    var cashPurchasingPower: String = "--"
    var marginPurchasingPower: String = "--"
}

fileprivate extension TradeModel {
    var powerOrderType: TradeOrderType {
        var orderType = tradeOrderType
        if tradeOrderType == .smart {
            orderType = condition.conditionOrderType
        }
        return orderType
    }
    
    var powerParams: PowerInfo.PowerParams {
        return (market: market, tradeType: tradeType, tradeOrderType:tradeOrderType, powerOrderType: powerOrderType, direction: direction, tradeStatus: tradeStatus)
    }
}

extension TradeModel {
    func defaultPowerInfo() -> PowerInfo {
        let powerInfo = PowerInfo()
        powerInfo.params = powerParams
        return powerInfo
    }
}

class YXTradePowerManager: NSObject {
    
    @objc public static let shared = YXTradePowerManager()
    
    static var moneyFormatter: NumberFormatter {
        let moneyFormatter = NumberFormatter()
        moneyFormatter.positiveFormat = "###,##0.00"
        moneyFormatter.locale = Locale(identifier: "zh")
        return moneyFormatter
    }
    
    //MARK: requestCanBuy
    private var canBuyRequest: YXRequest?
    private var holdRequest: YXRequest?
    
    private var task: DispatchQueue.Task?
    func requestCanBuy(_ tradeModel: TradeModel, quote: YXV2Quote? = nil, finishBlock: @escaping (() -> Void)) {
        func request() {
            canBuyRequest?.stop()
            
            tradeModel.powerInfo = tradeModel.defaultPowerInfo()
        
            guard tradeModel.symbol.count > 0 else {
                finishBlock()
                return
            }
            
            if let value = Double(tradeModel.entrustPrice), value > 0 {
                
            } else if tradeModel.powerOrderType == .market ||
                      tradeModel.powerOrderType == .bidding {
                guard let latestPrice = tradeModel.latestPrice, latestPrice.count > 0 else {
                    finishBlock()
                    return
                }
            }
            
            if tradeModel.tradeType == .normal {
                if tradeModel.tradeStatus == .change,
                   tradeModel.tradeOrderType != .smart {
                    canBuyRequest = requestNormalChangeCanBuy(tradeModel, finishBlock: finishBlock)
                } else {
                    canBuyRequest = requestNormalCanBuy(tradeModel, finishBlock: finishBlock)
                }
            } else if tradeModel.tradeType == .fractional {
                if tradeModel.tradeStatus == .change {
                    canBuyRequest = requestFractionalChangeCanBuy(tradeModel, finishBlock: finishBlock)
                } else {
                    canBuyRequest = requestFractionalCanBuy(tradeModel, finishBlock: finishBlock)
                }
            }
        }
        
        if task != nil {
            DispatchQueue.cancel(task)
            task = DispatchQueue.delay(0.3, task: { [weak self] in
                guard let strongSelf = self else { return }
                request()
                strongSelf.task = nil
            })
        } else {
            task = DispatchQueue.delay(0.3, task: {
                request()
            })
        }
    }
    
    private func requestNormalCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        if tradeModel.market == kYXMarketUsOption {
            return requestOptionCanBuy(tradeModel, finishBlock: finishBlock)
        }
        
        guard let trdUnit = tradeModel.trdUnit, trdUnit > 0 else {
            finishBlock()
            return nil
        }
        
        let requestModel = YXTradeQuantityRequestModel()
        requestModel.entrustPrice = tradeModel.entrustPrice
        if tradeModel.powerOrderType == .bidding || tradeModel.powerOrderType == .market {
            requestModel.entrustPrice = tradeModel.latestPrice ?? ""
        }
        requestModel.market = tradeModel.market.uppercased()
        requestModel.symbol = tradeModel.symbol
        requestModel.handQty = trdUnit
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.cashEnableAmount = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                powerInfo?.marginEnableAmount = model.canBuyModel?.maxBuyQty?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.maxSellQty?.doubleValue ?? -1
                powerInfo?.maxCashBuyMulti = model.canBuyModel?.maxCashBuyMulti?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
                if let cashPurchasingPower = model.canBuyModel?.cashBalance, cashPurchasingPower.doubleValue >= 0 {
                    powerInfo?.cashPurchasingPower = Self.moneyFormatter.string(from: cashPurchasingPower) ?? "--"
                }
            }
            
            if SmartOrderType.portfolioTypes.contains(tradeModel.condition.smartOrderType) {
                self?.requestGetHoldInfo(tradeModel, finishBlock: finishBlock)
            } else {
                finishBlock()
            }
        } failure: { [weak self] (_) in
            if SmartOrderType.portfolioTypes.contains(tradeModel.condition.smartOrderType) {
                self?.requestGetHoldInfo(tradeModel, finishBlock: finishBlock)
            } else {
                finishBlock()
            }
        }
        
        return request
    }
    
    private func requestGetHoldInfo(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) {
        let requestModel = YXStockHoldInfoRequestModel()
        requestModel.stockCode = tradeModel.symbol;
        requestModel.exchangeType = tradeModel.market.uppercased()
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (res) in
            let powerInfo = tradeModel.powerInfo
            powerInfo?.costPrice = (res.data?["costPrice"] as? NSNumber)?.doubleValue ?? -1
            finishBlock()
        }, failure: { (_) in
            finishBlock()
        })
        
        holdRequest = request
    }
    
    private func requestOptionCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        guard let multiplier = tradeModel.multiplier, multiplier > 0,
              let priceValue = Double(tradeModel.entrustPrice), priceValue > 0 else {
            finishBlock()
            return nil
        }
        let requestModel = YXOptionBuyMaxRequestModel()
        requestModel.multiplier = multiplier
        requestModel.price = String(format: "%.3f", priceValue * Double(multiplier))
        requestModel.symbol = tradeModel.symbol
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.marginEnableAmount = model.canBuyModel?.buyMax?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.sellMax?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
            }
            finishBlock()
        } failure: {(_) in
            finishBlock()
        }
        return request
    }
    
    private func requestFractionalCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        guard let priceValue = Double(tradeModel.entrustPrice), priceValue > 0 else {
            finishBlock()
            return nil
        }
        let requestModel = YXFractionalBuyMaxRequestModel()
        requestModel.entrustPrice = String(format: "%.3f", priceValue)
        requestModel.symbol = tradeModel.symbol
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.marginEnableAmount = model.canBuyModel?.maxBuyQty?.doubleValue ?? -1
                powerInfo?.cashEnableAmount = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.maxSellQty?.doubleValue ?? -1
                powerInfo?.maxCashBuyMulti = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
                
                if let cashPurchasingPower = model.canBuyModel?.cashBalance, cashPurchasingPower.doubleValue >= 0 {
                    powerInfo?.cashPurchasingPower = Self.moneyFormatter.string(from: cashPurchasingPower) ?? "--"
                }
            }
            finishBlock()
        } failure: {(_) in
            finishBlock()
        }
        return request
    }

    private func requestNormalChangeCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        if tradeModel.market == kYXMarketUsOption {
            return requestOptionChangeCanBuy(tradeModel, finishBlock: finishBlock)
        }
        
        guard let entrustId = tradeModel.entrustId,
              let trdUnit = tradeModel.trdUnit, trdUnit > 0 else {
            finishBlock()
            return nil
        }

        let requestModel = YXOrderRangeRequestModel()
        requestModel.handQty = trdUnit;
        requestModel.orderId = entrustId;
        if tradeModel.tradeOrderType == .bidding || tradeModel.tradeOrderType == .market {
            requestModel.entrustPrice = tradeModel.latestPrice ?? "0";
        } else {
            requestModel.entrustPrice = tradeModel.entrustPrice;
        }
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.cashEnableAmount = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                powerInfo?.marginEnableAmount = model.canBuyModel?.maxBuyQty?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.maxSellQty?.doubleValue ?? -1
                powerInfo?.maxCashBuyMulti = model.canBuyModel?.maxCashBuyMulti?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
                if let cashPurchasingPower = model.canBuyModel?.cashBalance, cashPurchasingPower.doubleValue >= 0 {
                    powerInfo?.cashPurchasingPower = Self.moneyFormatter.string(from: cashPurchasingPower) ?? "--"
                }
            }
            finishBlock()
        } failure: { (_) in
            finishBlock()
        }
        
        return request
    }
    
    private func requestOptionChangeCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        guard let entrustId = tradeModel.entrustId,
              let multiplier = tradeModel.multiplier, multiplier > 0,
              let priceValue = Double(tradeModel.entrustPrice), priceValue > 0 else {
            finishBlock()
            return nil
        }
        
        let requestModel = YXOptionReplaceBuyMaxRequestModel()
        requestModel.orderId = entrustId
        requestModel.entrustPrice = String(format: "%.3f", priceValue * Double(multiplier))
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.marginEnableAmount = model.canBuyModel?.buyMax?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.sellMax?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
            }
            finishBlock()
        } failure: { (_) in
            finishBlock()
        }
        return request
    }
    
    private func requestFractionalChangeCanBuy(_ tradeModel: TradeModel, finishBlock: @escaping (() -> Void)) -> YXRequest? {
        guard let entrustId = tradeModel.entrustId,
              let priceValue = Double(tradeModel.entrustPrice), priceValue > 0 else {
            finishBlock()
            return nil
        }
        
        let requestModel = YXFractionalReplaceBuyMaxRequestModel()
        requestModel.orderId = entrustId
        requestModel.entrustPrice = String(format: "%.3f", priceValue)
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { (responseModel) in
            if responseModel.code == .success, let model = responseModel as? YXTradeQuantityResponseModel {
                let powerInfo = tradeModel.powerInfo
                powerInfo?.marginEnableAmount = model.canBuyModel?.maxBuyQty?.doubleValue ?? -1
                powerInfo?.cashEnableAmount = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                powerInfo?.saleEnableAmount = model.canBuyModel?.maxSellQty?.doubleValue ?? -1
                powerInfo?.maxCashBuyMulti = model.canBuyModel?.maxCashBuyQty?.doubleValue ?? -1
                if let maxPurchasingPower = model.canBuyModel?.maxPurchasePower, maxPurchasingPower.doubleValue >= 0 {
                    powerInfo?.marginPurchasingPower = Self.moneyFormatter.string(from: maxPurchasingPower) ?? "--"
                }
                if let cashPurchasingPower = model.canBuyModel?.cashBalance, cashPurchasingPower.doubleValue >= 0 {
                    powerInfo?.cashPurchasingPower = Self.moneyFormatter.string(from: cashPurchasingPower) ?? "--"
                }
            }
            finishBlock()
        } failure: { (_) in
            finishBlock()
        }
        return request
    }
}

extension DispatchQueue {
    typealias Task = (_ cancel : Bool) -> ()
    
    @discardableResult
    class func delay(_ time:TimeInterval, task:@escaping () -> ()) -> Task? {
        //定义了一个延迟函数，time秒之后调用block
        func dispatch_later(_ block:@escaping () -> ()) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                execute: block)
        }
        
        //将task block赋值给closure
        var closure: (() -> Void)? = task
        var result: Task?
        // Task 代码块的实现，别处通过delayedClosure(bool)调用此函数
        let delayedClosure: Task = { cancel in
            //将closure赋值给internalClosure
            if let internalClosure = closure {
                //如果传过来的值为false，则说明不取消，立马执行internalClosure，也即closure，
                //也即task
                if (cancel == false){
                    //此处将立即执行，传过来的代码块
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            //如果传过来的值为true，则将代码块内容为nil，result为nil
            closure = nil
            result = nil
        }
        result = delayedClosure
        //此处调用开始的dispatch_later函数，当执行完成之后调用delayedClosure（false）
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result
    }
    
    class func cancel(_ task:Task?) {
        task?(true)
    }
}
