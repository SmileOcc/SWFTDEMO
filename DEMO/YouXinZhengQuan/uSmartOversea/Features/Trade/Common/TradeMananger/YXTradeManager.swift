//
//  YXTradeManager.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import TYAlertController
import YXKit

extension YXRequest {
    func orderRequest(_ responseBlock: (@escaping (YXResponseModel) -> Void)) {
        let hud = YXProgressHUD.showLoading(nil, in: UIViewController.current().view)
        startWithBlock(success: { (responseModel) in
            hud.hideHud()
            
            responseBlock(responseModel)
            
        }, failure: { (_) in
            hud.hideHud()
            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
        })
    }
}

@objcMembers class YXTradeManager: NSObject {
        
    @objc public static let shared = YXTradeManager()
    
    static var numFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0";
        formatter.locale = Locale(identifier: "zh")
        return formatter
    }
    
    static var moneyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter
    }
    
    weak private var tradeModel: TradeModel!
    
    private var forceEntrustFlag: Bool = false
    private var successBlock: (() -> Void)?
    private var brokenBlock: (() -> Void)?
    
    private weak var currentViewController: UIViewController?
    
    private var bitcoinETFs = ["BITS.US", "BTF.US", "XBTF.US", "BITO.US"]
    
    //MARK: Main Method
    func tradeOrder(tradeModel: TradeModel, currentViewController:UIViewController? = nil, successBlock: (() -> Void)?, brokenBlock: (() -> Void)? = nil) {
        self.tradeModel = tradeModel
        self.successBlock = successBlock
        self.brokenBlock = brokenBlock
        self.currentViewController = currentViewController
        forceEntrustFlag = false
        
        let stock = tradeModel.symbol.uppercased() + "." + tradeModel.market.uppercased()
        let agreeKey = "bitcoinETFAgreeKey\(stock)"
        if bitcoinETFs.contains(stock),
           !MMKV.default().bool(forKey: agreeKey, defaultValue: false) {
            bitcoinETFAlert(agreeKey)
            return
        }
        //JIRA FOREIGN-1840 要求去掉弹窗
//        if tradeModel.isDerivatives, tradeModel.tradeStatus != .change, YXDerivativeView.needShow, YXDerivativeView.todayNeedShow {
//            derivativesAlert()
//            return
//        }
        
        if tradeModel.tradePeriod == .grey,
           (YXUserManager.shared().extendStatusBit() & YXExtendStatusBitType.actQuotRiskAuth.rawValue) != YXExtendStatusBitType.actQuotRiskAuth.rawValue {
            privatelyAlert()
            return
        }
        
        if tradeModel.market == kYXMarketHK,
           tradeModel.tradeStatus == .change,
           tradeModel.tradeOrderType != .smart {
            if changeOrderAlertIfNeedShow() {
                return
            }
        }
        
        confirmAlert()
    }
    
    //MARK: Class Method
    class func getOrderType(market: String, complete: ((TradeOrderType) -> Void)?) {
        if market != kYXMarketHK {
            complete?(.limit)
            return
        }
        let requestModel = YXGetOrderTypeRequestModel()
        let request = YXRequest(request: requestModel)
        let hud = YXProgressHUD.showLoading(nil, in: UIViewController.current().view)
        request.startWithBlock { (responseModel) in
            hud.hideHud()
            
            guard let prop = responseModel.data?["orderType"] as? String else {
                complete?(.limitEnhanced)
                return
            }
            
            complete?(prop.tradeOrderType)
            
        } failure: { (_) in
            hud.hideHud()
            complete?(.limitEnhanced)
        }
    }
    
    //MARK: Confirm
    private func confirmAlert() {
        showConfirmAlert()
//        if let useMargin = tradeModel.useMargin, useMargin == false {
//            showConfirmAlert()
//        } else {
//            getMarginQuantity()
//        }
    }
    
    private func showConfirmAlert() {
        let confirmView = YXTradeConfirmView(tradeModel: tradeModel) { [weak self] in
            (self?.currentViewController as? QMUICommonViewController)?.trackViewClickEvent(name: "Confirm_Tab")
            self?.confirmAction()
        }
        
        confirmView.cancelBlock = { [weak self] in
            (self?.currentViewController as? QMUICommonViewController)?.trackViewClickEvent(name: "Cancel_Tab")
        }
        
        confirmView.show(in: UIViewController.current())
    }
    
    private func confirmAction() {
        if tradeModel.tradeType == .normal {
            if tradeModel.tradeOrderType == .smart {
                requestConditionOrder()
            } else {
                requestTradeOrder()
            }
        } else if tradeModel.tradeType == .fractional {
            requestFractionalOrder()
        }
    }
//
//    private func getMarginQuantity() {
//        let requestModel = YXMarginQuantityRequestModel()
//        if tradeModel.tradeStatus == .change,
//           tradeModel.tradeOrderType != .condition, tradeModel.tradeOrderType != .smart {
//            guard let entrustId = tradeModel.entrustId else { return }
//
//            requestModel.entrustId = entrustId;
//            requestModel.entrustType = 5;
//        }
//        requestModel.exchangeType = tradeModel.market.exchangeType.rawValue
//        requestModel.stockCode = tradeModel.symbol
//        requestModel.entrustPrice = tradeModel.entrustPrice
//        var tradeOrderType = tradeModel.tradeOrderType
//        if tradeOrderType == .condition || tradeOrderType == .smart {
//            tradeOrderType = tradeModel.condition.conditionOrderType
//        }
//        requestModel.entrustProp = tradeOrderType.entrustProp
//        requestModel.entrustAmount = tradeModel.entrustAmount.amountValue
//
//        if tradeOrderType == .bidding || tradeOrderType == .market {
//            requestModel.entrustPrice = "0"
//        }
//
//        let request = YXRequest(request: requestModel)
//        let hud = YXProgressHUD.showLoading(nil, in: UIViewController.current().view)
//        request.startWithBlock { [weak self] (responseModel) in
//            hud.hideHud()
//            guard let strongSelf = self else { return }
//
//            if responseModel.code == .success {
//                if
//                    YXUserManager.isFinancing(market: strongSelf.tradeModel.market),
//                    let data = responseModel.data,
//                    let model = YXMarginQuantityModel.yy_model(withJSON: data) {
//                    if Double(strongSelf.tradeModel.entrustAmount.amountValue) > model.cashEnableAmount {
//                        strongSelf.tradeModel.useMargin = true
//                        strongSelf.tradeModel.marginEntrustAmount = Self.numFormatter.string(from: model.marginAmount) ?? "--"
//                        strongSelf.tradeModel.marginAmount = Self.moneyFormatter.string(from: model.marginBalance) ?? "--"
//                    } else {
//                        strongSelf.tradeModel.useMargin = false
//                    }
//                }
//            }
//            strongSelf.showConfirmAlert()
//        } failure: { [weak self] (_) in
//            hud.hideHud()
//            self?.showConfirmAlert()
//        }
//    }
    
    //MARK: TradeOrder
    private func requestTradeOrder() {
        if tradeModel.market == kYXMarketUsOption {
            requestOptionOrder()
            return
        }
        
        if tradeModel.tradeStatus == .change {
            requestChangeOrder()
            return
        }
        
        if tradeModel.tradeOrderType == .broken {
            requestBrokenOrder()
            return
        }
        
        let requestModel = YXEntrustOrderRequestModel()
        requestModel.entrustQty = tradeModel.entrustQuantity.int64Value
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.entrustProp = tradeModel.tradeOrderType.entrustProp
        requestModel.entrustSide = tradeModel.direction.entrustSide
        requestModel.market = tradeModel.market.uppercased()
        requestModel.symbol = tradeModel.symbol
        requestModel.symbolName = tradeModel.name
        requestModel.forceEntrustFlag = forceEntrustFlag
        requestModel.tradePeriod = tradeModel.tradePeriod.stringValue
        
        if tradeModel.tradeOrderType == .bidding || tradeModel.tradeOrderType == .market {
            requestModel.entrustPrice = "0"
        }
        
        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            strongSelf.moreHandle(responseModel)
        }
        
    }
    
    private func requestChangeOrder() {
        guard let entrustId = tradeModel.entrustId else {
            return
        }
        
        let requestModel = YXChangeEntrustRequestModel()
        requestModel.entrustQty = tradeModel.entrustQuantity.int64Value
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.forceEntrustFlag = forceEntrustFlag;
        requestModel.orderId = entrustId
        
        
        if tradeModel.tradeOrderType == .bidding || tradeModel.tradeOrderType == .market {
            requestModel.entrustPrice = "0"
        }
        
        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            strongSelf.handle(responseModel)
        }
    }
    
    private func requestOptionOrder() {
        if tradeModel.tradeStatus == .change {
            requestOptionChangeOrder()
            return
        }
        let requestModel = YXOptionTradeRequestModel()
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.entrustQty = tradeModel.entrustQuantity.int64Value
        requestModel.entrustSide = tradeModel.direction.entrustSide
        requestModel.entrustProp = tradeModel.tradeOrderType.entrustProp
        requestModel.symbol = tradeModel.symbol
        requestModel.forceEntrustFlag = forceEntrustFlag

        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            strongSelf.handle(responseModel)
        }
    }
    
    private func requestOptionChangeOrder() {
        guard let entrustId = tradeModel.entrustId else {
            return
        }
        
        let requestModel = YXOptionChangeOrderRequestModel()
        requestModel.orderId = entrustId
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.entrustQty = tradeModel.entrustQuantity.int64Value

        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }

            strongSelf.simpleHandle(responseModel)
        }
    }
    
    private func requestFractionalOrder() {
        if tradeModel.tradeStatus == .change {
            requestFractionalChangeOrder()
            return
        }
        let requestModel = YXFractionalTradeRequestModel()
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.entrustTab = tradeModel.fractionalTradeType.rawValue
        if tradeModel.fractionalTradeType == .amount {
            requestModel.entrustAmount = tradeModel.fractionalAmount.stringValue
        } else {
            requestModel.entrustQty = tradeModel.fractionalQuantity.stringValue
        }
        requestModel.entrustSide = tradeModel.direction.entrustSide
        requestModel.entrustProp = tradeModel.tradeOrderType.entrustProp
        requestModel.symbol = tradeModel.symbol
        requestModel.forceEntrustFlag = forceEntrustFlag
        
        if tradeModel.tradeOrderType == .market {
            requestModel.entrustPrice = "0"
        }

        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            strongSelf.handle(responseModel)
        }
    }
    
    private func requestFractionalChangeOrder() {
        guard let entrustId = tradeModel.entrustId else {
            return
        }
        
        let requestModel = YXFractionalChangeOrderRequestModel()
        requestModel.orderId = entrustId
        requestModel.entrustPrice = tradeModel.entrustPrice
        if tradeModel.fractionalTradeType == .amount {
            requestModel.entrustAmount = tradeModel.fractionalAmount.stringValue
        } else {
            requestModel.entrustQty = tradeModel.fractionalQuantity.stringValue
        }
        
        if tradeModel.tradeOrderType == .market {
            requestModel.entrustPrice = "0"
        }

        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }

            strongSelf.simpleHandle(responseModel)
        }
    }
    
    private func requestBrokenOrder() {
        let requestModel = YXBrokenOrderRequestModel()
        requestModel.entrustAmount = tradeModel.entrustQuantity.int64Value
        requestModel.entrustPrice = tradeModel.entrustPrice
        requestModel.stockCode = tradeModel.symbol
        requestModel.requestId = NSUUID().uuidString
        
        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            strongSelf.simpleHandle(responseModel)
        }
    }
    
    private func requestConditionOrder() {
        if tradeModel.tradeStatus == .change, tradeModel.entrustId == nil {
            return
        }
        
        guard let latestPrice = tradeModel.latestPrice else {
            return
        }
        
        let requestModel = YXConditionOrderRequestModel()
        requestModel.conId = tradeModel.entrustId
        requestModel.market = tradeModel.market.uppercased()
        requestModel.stockCode = tradeModel.symbol
        requestModel.stockName = tradeModel.name
        requestModel.strategyEnddateDesc = tradeModel.condition.strategyEnddateDesc
        
        requestModel.conditionType = tradeModel.condition.smartOrderType
        requestModel.conditionPrice = tradeModel.condition.conditionPrice
        if requestModel.conditionPrice == nil
            || requestModel.conditionPrice == "" {
            requestModel.conditionPrice = "0"
        }

        requestModel.marketPrice = latestPrice
        
        switch tradeModel.condition.smartOrderType
        {
        case .breakBuy,
             .breakSell,
             .highPriceSell,
             .lowPriceBuy:
            requestModel.amountIncrease = tradeModel.condition.amountIncrease
        case .stopProfitSell,
             .stopLossSell:
            requestModel.amountIncrease = tradeModel.condition.amountIncrease
            if let costPrice = tradeModel.powerInfo?.costPrice {
                requestModel.costPrice = String(format: "%.3f", costPrice)
            }
        case .tralingStop:
            requestModel.amountIncrease = tradeModel.condition.amountIncrease
            requestModel.dropPrice = tradeModel.condition.dropPrice
            if tradeModel.entrustId != nil {
                requestModel.marketPrice = tradeModel.condition.highestPrice
            }
        case .stockHandicap:
            requestModel.relatedStockCode = tradeModel.condition.releationStockCode
            requestModel.relatedStockMarket = tradeModel.condition.releationStockMarket
            requestModel.relatedStockName = tradeModel.condition.releationStockName
            requestModel.marketPrice = tradeModel.condition.trackMarketPrice
            requestModel.entrustSide = tradeModel.direction.entrustSide
        default:
            break
        }
        
        requestModel.entrustAmount = tradeModel.entrustQuantity.int64Value
        requestModel.entrustPrice = tradeModel.entrustPrice
        
        if tradeModel.condition.entrustGear != .entrust {
            requestModel.entrustPrice = "0"
            requestModel.entrustGear = NSNumber(value: tradeModel.condition.entrustGear.rawValue)
        }
        
        requestModel.tradePeriod = tradeModel.tradePeriod.stringValue
        requestModel.strategyEnddateDesc = tradeModel.condition.strategyEnddateDesc

        let request = YXRequest(request: requestModel)
        request.orderRequest { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            if strongSelf.tradeModel.tradeStatus == .change {
                strongSelf.simpleHandle(responseModel)
            } else {
                strongSelf.moreHandle(responseModel)
            }
        }
    }
    
    //MARK: Handle
    private func simpleHandle(_ responseModel: YXResponseModel) {
        let code = responseModel.code
        let msg = responseModel.msg
        switch code {
        case .success:
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "trading_order_submit_success"))
            successBlock?()
        case .tradePwdInvalid,
             .tradePwdInvalid1,
             .optionTradePwdInvalid:
            passwordAlert()
        default:
            failedAlert(with: msg)
        }
    }
    
    private func handle(_ responseModel: YXResponseModel) {
        let code = responseModel.code
        let msg = responseModel.msg
        switch code {
        case .success:
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "trading_order_submit_success"))
            successBlock?()
        case .tradePwdInvalid,
             .tradePwdInvalid1,
             .optionTradePwdInvalid:
            passwordAlert()
        case .moreThanNineMultiple,
             .moreThanThreePercentage,
             .creditLimit,
             .optionForceEntrust:
            moreThanNineMultipleAlert(with: msg)
        default:
            failedAlert(with: msg)
        }
    }
    
    private func moreHandle(_ responseModel: YXResponseModel) {
        let code = responseModel.code
        let msg = responseModel.msg

        switch code {
        case .success:
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "trading_order_submit_success"))
            successBlock?()
        case .noOpenHSAccount:
            noOpenHSAccountAlert(with: msg)
        case .tradePwdInvalid,
             .tradePwdInvalid1,
             .optionTradePwdInvalid:
            passwordAlert()
        case .moreThanNineMultiple,
             .moreThanThreePercentage,
             .creditLimit,
             .optionForceEntrust:
            moreThanNineMultipleAlert(with: msg)
        case .orderBroken:
            if tradeModel.tradePeriod != .grey,
               tradeModel.tradeOrderType != .smart {
                brokenAlert(with: msg)
            } else {
                failedAlert(with: msg)
            }
        default:
            failedAlert(with: msg, code: code)
        }
    }
    
    //MARK: Alert
    private func moreThanNineMultipleAlert(with msg: String?) {
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "common_tips"), message: msg)
        let alertController = YXAlertController(alert: alertView)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] (_) in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "trading_continue_submit"), style: .default, handler: { [weak alertView, weak alertController] (_) in
            
            alertController?.dismissComplete = { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.forceEntrustFlag = true
                strongSelf.confirmAction()
            }
            
            alertView?.hide()
        }))
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
    
    private func failedAlert(with msg: String?, code: YXResponseStatusCode? = nil) {
        var title: String? = YXLanguageUtility.kLang(key: "confirm_failed")
        if code == .tradeSpacError
            || code == .smartTradeSpacError {
            title = nil
        }
        let alertView = YXAlertView.alertView(title: title, message: msg)

        let alertController = YXAlertController(alert: alertView)
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (_) in
            
        }))
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
    
    private func brokenAlert(with msg: String?) {
        let alertView = YXAlertView.alertView(message: msg ?? "")
        let alertController = YXAlertController(alert: alertView)
        alertView.clickedAutoHide = false;
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] (_) in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "trading_add_broken_order"), style: .default, handler: { [weak alertView, weak alertController] (_) in
            
            alertController?.dismissComplete = { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.brokenBlock?()
            }
        
            alertView?.hide()
        }))
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
    
    private func passwordAlert() {
        YXUserUtility.validateTradePwd(inViewController: UIViewController.current(), successBlock: nil, failureBlock: nil, isToastFailedMessage: nil)
    }
    
    private func noOpenHSAccountAlert(with msg: String?) {
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "common_tips"), message: msg)
        let alertController = YXAlertController(alert: alertView)
        alertView.clickedAutoHide = false;
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] (_) in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_open_now"), style: .default, handler: { [weak alertView, weak alertController] (_) in
            
            alertController?.dismissComplete = {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index": YXTabIndex.holding, "moduleTag": 2])
            }
        
            alertView?.hide()
        }))
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
    
    private func changeOrderAlertIfNeedShow() -> Bool {
        guard let latestPrice = Double(tradeModel.latestPrice ?? "0"), latestPrice > 0,
              let entrustPrice = Double(tradeModel.entrustPrice), entrustPrice > 0 else {
            return false
        }
        
        var message = ""
        var cacheKey = ""
        var needShow = false
        if tradeModel.direction == .buy, entrustPrice > latestPrice {
            message = YXLanguageUtility.kLang(key: "trading_buy_up_best_price")
            cacheKey = "\(YXUserManager.userUUID())" + "trading_buy_up_best_price_key"
            needShow = true
        } else if tradeModel.direction == .sell, entrustPrice < latestPrice {
            message = YXLanguageUtility.kLang(key: "trading_sell_down_best_price")
            cacheKey = "\(YXUserManager.userUUID())" + "trading_sell_down_best_price_key"
            needShow = true
        }
        
        if needShow, MMKV.default().bool(forKey: cacheKey) == false {
            var viewHeight: CGFloat = 239
            if (YXUserManager.isENMode()) {
                viewHeight = 270
            }
            let viewWidth: CGFloat = 285;
            let alertView = YXChangeOrderAlertView(frame: CGRect(x: (YXConstant.screenWidth - viewWidth) / 2.0, y: 0, width: viewWidth, height: viewHeight))
            alertView.updateContent(with: message)
            let alertController = TYAlertController(alert: alertView, preferredStyle: .alert, transitionAnimation: .scaleFade)
            alertController?.backgoundTapDismissEnable = true
            
            alertView.confirmBlock = { [weak alertView, weak alertController] (isSelected) in
                alertController?.dismissComplete =  { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.confirmAlert()
                }
                alertView?.hide()
                MMKV.default().set(isSelected, forKey: cacheKey)
            }
            
            alertView.cancelBlock = { [weak alertView] in
                alertView?.hide()
            }
            
            UIViewController.current().present(alertController!, animated: true, completion: nil)
            return true
        }
        
        return false
    }
    
    private func bitcoinETFAlert(_ agreeKey: String) {
        let customView = BitcoinETFAlertView()
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "common_risk_disclosures"), message: nil)
        alertView.clickedAutoHide = false
        alertView.addCustomView(customView)

        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] _ in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak customView, weak alertView] (action) in
            if customView?.chooseBtn.isSelected ?? false {
                MMKV.default().set(true, forKey: agreeKey)
                alertView?.hide()
            } else {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "otc_risk_agree_tip"))
            }
        }))
        alertView.show(in: UIViewController.current())
    }
    
    private func derivativesAlert() {
        
        func show() {
            let alertView = YXDerivativeView()
            let alertController = TYAlertController(alert: alertView, preferredStyle: .alert, transitionAnimation: .scaleFade)
            alertController?.backgoundTapDismissEnable = true
            
            alertView.confirmBlock = {  [weak alertView, weak alertController, weak self] in
                alertController?.dismissComplete =  {
                    YXDerivativeView.todayNeedShow = false
                    self?.confirmAlert()
                }
                alertView?.hide()
            }
            
            alertView.clickDerivativeBlock = { [weak alertView, weak alertController]  in
                alertController?.dismissComplete =  {
                    YXWebViewModel.pushToWebVC(YXH5Urls.DERIVATIVES_TRADING_RISK_DISCLOSURE_URL())
                }
                alertView?.hide()
            }
            
            UIViewController.current().present(alertController!, animated: true, completion: nil)
        }
        
        let requestModel = YXDerivativeInfoRequestModel()
        let request = YXRequest(request: requestModel)
        
        let hud = YXProgressHUD.showLoading(nil, in: UIViewController.current().view)
        request.startWithBlock { [weak self] (responseModel) in
            hud.hide(animated: true)
            
            guard let strongSelf = self else { return }

            if responseModel.code == .success {
                let hasDerivativesExp = (responseModel.data?["hasDerivativesExp"] as? NSNumber)?.boolValue ?? false
                let threeYearSixTradeTimes = (responseModel.data?["threeYearSixTradeTimes"] as? NSNumber)?.boolValue ?? false

                if !hasDerivativesExp, !threeYearSixTradeTimes {
                    show()
                } else {
                    YXDerivativeView.needShow = false
                    strongSelf.confirmAlert()
                }
            } else {
                show()
            }
        } failure: { (_) in
            hud.hide(animated: true)
            show()
        }
        
    }
    
    private func privatelyAlert() {
        let alertView = YXPrivatelyView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 40.0, height: 400.0))
        let alertController = TYAlertController(alert: alertView, preferredStyle: .alert, transitionAnimation: .scaleFade)
        alertController?.backgoundTapDismissEnable = true
        
        alertView.cancelBtn.addBlock(for: .touchUpInside) { [weak alertView] (_) in
            alertView?.hide()
        }
        
        alertView.confirmBtn.addBlock(for: .touchUpInside) { [weak alertView, weak alertController] (_) in
            alertController?.dismissComplete =  {
                let requestModel = YXPrivatelyRequestModel()
                let request = YXRequest(request: requestModel)
                
                let hud = YXProgressHUD.showLoading(nil, in: UIViewController.current().view)
                request.startWithBlock { [weak self] (responseModel) in
                    hud.hideHud()
                    
                    guard let strongSelf = self else { return }

                    if responseModel.code == .success {
                        YXUserManager.shared().setExtendStatusBit(statusBit: YXUserManager.shared().extendStatusBit() | YXExtendStatusBitType.actQuotRiskAuth.rawValue)
                        YXUserManager.saveCurLoginUser()
                        YXUserManager.getUserInfo(postNotification: true, complete: nil)
                        
                        strongSelf.confirmAlert()
                    } else {
                        YXProgressHUD.showError(responseModel.msg)
                    }
                } failure: { (_) in
                    hud.hideHud()
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
                }
            }
            alertView?.hide()
        }
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
}

extension Double {
    func value(priceBase: UInt32?) -> String {
        let priceBaseFormat = "%.\(priceBase ?? 3)f"
        let powValue = pow(10.0, Double(priceBase ?? 3))
        return String(format: priceBaseFormat, self/powValue)
    }
}

extension String {
    var int64Value: Int64 {
        Int64(stringValue) ?? 0
    }
    
    var doubleValue: Double {
        Double(stringValue) ?? 0
    }
    
    var stringValue: String {
        replacingOccurrences(of: ",", with: "")
    }
}
