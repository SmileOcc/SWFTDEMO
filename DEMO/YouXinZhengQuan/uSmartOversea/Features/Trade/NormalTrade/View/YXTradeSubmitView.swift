//
//  YXTradeSubmitView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2021/7/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeSubmitView: UIView, YXTradeHeaderSubViewProtocol {
    
    enum SubmitType: String {
        case submit = "trade_submit"
        case buy    = "trade_buy"
        case sell   = "trade_sell"
        case unlock = "trade_unlock"
        
        var color: UIColor {
            switch self {
            case .buy:
                return QMUITheme().stockRedColor()
            case .sell:
                return QMUITheme().stockGreenColor()
            case .unlock:
                return QMUITheme().mainThemeColor()
            default:
                return QMUITheme().mainThemeColor()
            }
        }
        
        var rawString: String {
            YXLanguageUtility.kLang(key: rawValue)
        }
    }
        
    var submitType: SubmitType {
        if !YXUserManager.shared().isTradeLogin {
            return .unlock
        }
        
        if isSubmit {
            return .submit
        }
        
        switch direction {
        case .buy:
            return .buy
        case .sell:
            return .sell
        }
    }
    
    var color: UIColor {
        if submitType == .submit {
            return direction.color
        }
        return submitType.color
    }
    
    var direction: TradeDirection = .buy {
        didSet {
            submitBtn.setBackgroundImage(UIImage(color: color), for: .normal)
            submitBtn.setBackgroundImage(UIImage(color: color.withAlphaComponent(0.4)), for: .disabled)
            submitBtn.setTitle(submitType.rawString, for: .normal)
        }
    }
    
    var canSubimt: Bool = true {
        didSet {
            if !YXUserManager.shared().isTradeLogin {
                self.submitBtn.isEnabled = true
            } else {
                self.submitBtn.isEnabled = canSubimt
            }
        }
    }
    
    lazy var submitBtn: UIButton = {
        let btn =  UIButton(type: .custom)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        
        btn.setTitle(submitType.rawString, for: .normal)
        btn.setBackgroundImage(UIImage(color: submitType.color), for: .normal)
        btn.setBackgroundImage(UIImage(color: submitType.color.withAlphaComponent(0.4)), for: .disabled)
        
        btn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            var event = ""
            switch self.submitType {
            case .buy:
                event = "Buy_Tab"
            case .sell:
                event = "Sell_Tab"
            case .submit:
                event = "Submit"
            case .unlock:
                event = "Unlock to Trade"
            }
            self.trackViewClickEvent(name: event)

            if !YXUserManager.shared().isTradeLogin {
                self.unlock()
            } else {
                self.submitBlock?()
            }
        }
        
        return btn
    }()
    
    func unlock() {
        UIViewController.current().view.endEditing(true)
        
        if YXUserManager.shared().curLoginUser?.tradePassword ?? false {
            YXUserUtility.validateTradePwd(inViewController: UIViewController.current(), successBlock: { [weak self] (_) in
                self?.unLockBlock?()
            }, failureBlock: nil, isToastFailedMessage: nil)

        } else {
            YXUserUtility.noTradePwdAlert(inViewController: UIViewController.current(), successBlock: { [weak self] (_) in
                self?.unLockBlock?()
            }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: true, needToken: false)
        }
    }
    
    var submitBlock:(()->())?
    var unLockBlock:(()->())?
    
    var isSmart: Bool = false {
        didSet {
            if isSmart {
                submitBtn.snp.updateConstraints { make in
                    make.top.equalTo(24)
                }
                contentHeight = 96
            } else {
                submitBtn.snp.updateConstraints { make in
                    make.top.equalTo(18)
                }
                contentHeight = 90
            }
        }
    }
    
    private var isSubmit: Bool!
    convenience init(direction: TradeDirection, isSubmit: Bool = false) {
        self.init()
        
        self.isSubmit = isSubmit
        self.direction = direction
        
        initUI()
        checkTradeStatus()
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(submitBtn)
        submitBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(48)
            make.top.equalTo(18)
            make.right.equalToSuperview().offset(-16)
        }
    }
}


extension YXTradeSubmitView {
    
    func checkTradeStatus() {
        if YXUserManager.shared().isTradeLogin == false {
            return
        }
        let requestModel = YXTradeStatusRequestModel()
        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] (responseModel) in
            if responseModel.code == .success, let data = responseModel.data,  let dataDic: Dictionary = data as? Dictionary<String, Any> {
                if let statues:Int = dataDic["status"] as? Int , statues == 1 {
                    YXUserManager.shared().isTradeLogin = true
                } else {
                    self?.submitBtn.isEnabled = true
                    YXUserManager.shared().isTradeLogin = false
                    self?.direction = self?.direction ?? .buy
                }
            } else {
                self?.submitBtn.isEnabled = true
                YXUserManager.shared().isTradeLogin = false
                self?.direction = self?.direction ?? .buy
            }
        } failure: { (baseRequest) in
            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"))
        }
    }
}

extension TradeModel {
    var canSubmit: Bool {
        guard symbol.count != 0 else { return false }
        guard entrustQuantity.count != 0 else { return false }
        
        switch tradeType {
        case .normal:
            switch tradeOrderType {
            case .market,
                 .bidding:
                return true
            case .smart:
                let conditonPrice = Double(condition.conditionPrice ?? "") ?? 0
                let latestPrice = Double(latestPrice ?? "") ?? 0
                let amountIncrease = condition.amountIncrease?.doubleValue ?? 0

                switch condition.smartOrderType {
                case .breakBuy,
                     .highPriceSell:
                    if conditonPrice == 0 {
                        guard amountIncrease > 0 else { return false }
                    } else if conditonPrice > 0 {
                        guard conditonPrice >= latestPrice else { return false }
                    } else {
                        return false
                    }
                case .breakSell,
                     .lowPriceBuy:
                    if conditonPrice == 0 {
                        guard amountIncrease > 0 else { return false }
                    } else if conditonPrice > 0 {
                        guard conditonPrice <= latestPrice else { return false }
                    } else {
                        return false
                    }
                case .stopLossSell,
                     .stopProfitSell:
                    guard amountIncrease > 0 else { return false }
                case .tralingStop:
                    let dropPrice = condition.dropPrice?.doubleValue ?? 0
                    if dropPrice == 0 {
                        guard amountIncrease > 0 else { return false }
                    }
                default:
                    break
                }
                
                
                if condition.conditionOrderType != .market,
                   condition.entrustGear == .entrust {
                    guard let price = Double(entrustPrice), price > 0 else { return false }
                }
            default:
                guard entrustPrice.count != 0, entrustPrice.doubleValue > 0 else { return false }
            }
        case .fractional:
            switch fractionalTradeType {
            case .amount:
                guard fractionalAmount.count != 0, fractionalAmount.doubleValue > 0 else { return false }
            case .shares:
                if tradeOrderType == .market {
                    return true
                }
                guard entrustPrice.count != 0, entrustPrice.doubleValue > 0 else { return false }
            }
        default:
            break
        }
        return true
    }
}
