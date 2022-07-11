//
//  YXNewStockPurcahseView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

import YYText

@objc protocol YXNewStockPurcahseTitleViewDelegate: class {
    func tipButtonClick(_ titleView: YXNewStockPurcahseTitleView)
}

class YXNewStockPurcahseTitleView: UIView {
    
    typealias TipBlock = () -> Void
    var tipBlock: TipBlock?
    weak var delegate: YXNewStockPurcahseTitleViewDelegate?
    
    @objc func tipButtonAction() {
        self.delegate?.tipButtonClick(self)
        tipBlock?()
    }
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 16.0
        return label
    }()
    
    @objc lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "newstock_about"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(tipButton)
        addSubview(lineView)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(18)
            make.centerY.equalTo(self.snp.centerY)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        tipButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-18)
            make.centerY.equalTo(self.snp.centerY)
            make.left.greaterThanOrEqualTo(tipButton.snp.right).offset(3)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(self.snp.left).offset(18)
            make.right.equalTo(self.snp.right).offset(-18)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXNewStockPurcahseView: UIView {
    
    typealias ClosureSaveValue = () -> Void
    typealias ClosurePurchaseFee = () -> Void
    typealias ClosurePurchaseNum = () -> Void
    typealias ClosureDeclare = () -> Void
    typealias ClosureTotalAmount = (_ amount: Double) -> Void
    typealias ClosurePurchaseEnable = (_ isEnable: Bool) -> Void
    
    
    @objc var saveValueClosure: ClosureSaveValue?
    @objc var purchaseFeeClosure: ClosurePurchaseFee?
    @objc var purchaseButtonClosure: ClosurePurchaseNum?
    @objc var purchaseDeclareClosure: ClosureDeclare?
    @objc var updateTotalAmountClosure: ClosureTotalAmount?
    @objc var purchaseEnableClosure: ClosurePurchaseEnable?
    @objc var seeMoreClosure: ClosureDeclare?
    @objc var changeOptionClosure: ClosureDeclare?
    
    //单位
    @objc var unitString = YXToolUtility.moneyUnit(2)
    //阅读申明
    @objc var hasReadDeclares: Bool = true
    //总金额
    @objc var totalAmount: Double = 0.00;
    //认购数量
    @objc var amount: Int = 0
    //认购方式
    var applyType: YXNewStockSubsType = .cashSubs //1-现金认购 2-融资认购
    //手续费
    var handlingFee: Double = 0
    
    //最低融资额度
    var leastFinanceAmount: Double = 0.0
    //可用金额
    var availbleAmount: Double = 0.0
    //融资利息
    var financeInterestAmount: Double = 0.0
    
    var stockModel: YXNewStockDetailInfoModel?
    
    let predicte = NSPredicate(format: "SELF MATCHES %@", String(format: "^([1-9]\\d{0,%ld}|0)(\\.\\d{0,%ld})?$", 11, 2))
    
    //MARK: 刷新数据
    func refreshUI(model: YXNewStockDetailInfoModel, sourceParams: YXPurchaseDetailParams, availbleAmount: Double) {

        stockModel = model
        self.initAvailableAmountData(availbleAmount)
        let isModify = sourceParams.isModify
        let applyType = sourceParams.applyType
        let financeModifyAmount = sourceParams.applied_amount

        nameLabel.text = model.stockName ?? "--"
        if let stockCode = model.stockCode {
            symbolLabel.text = String(format: "(%@)", stockCode)
        } else {
            symbolLabel.text = ""
        }

        //认购股数/金额
        if let moneyType = model.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        
        self.applyType = .cashSubs
        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开，比如0,1支持现金和融资(1-公开现金认购，2-公开融资认购，3-国际配售)
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }
        if isModify == 1 {
            if applyType == .financingSubs {
                self.applyType = .financingSubs
                subsTypeView.refreshUI(applyType: .finance)
            } else {
                self.applyType = .cashSubs
                subsTypeView.refreshUI(applyType: .cash)
            }
        } else if subscribeWayArray.contains(String(YXNewStockSubsType.financingSubs.rawValue)), let financingMultiple = model.financingMultiple, financingMultiple > 0 {
            
            subsTypeView.refreshUI(applyType: .cashAndFinance)
            
            let serverUnixTime = YXNewStockDateFormatter.unixTime(model.serverTime)
            if serverUnixTime > YXNewStockDateFormatter.unixTime(model.endTime) {
                //现金认购截止时间
                subsTypeView.refreshUI(applyType: .finance)
                self.applyType = .financingSubs
            } else if serverUnixTime > YXNewStockDateFormatter.unixTime(model.financingEndTime) {
                //融资认购截止时间
                subsTypeView.refreshUI(applyType: .cash)
            }
            
        } else {
            subsTypeView.refreshUI(applyType: .cash)
        }
        
        moneyUnitLabel.text = unitString
        let width = (unitString as NSString).boundingRect(with: CGSize(width: 200, height: 50), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : moneyUnitLabel.font], context: nil).size.width
        moneyUnitLabel.snp.updateConstraints { (make) in
            make.width.equalTo(width + 1)
        }
        
        //认购总额和利息依赖上面的认购类型来计算
        purchaseNumButton.isEnabled = false
        purchaseNumButton.setTitle("", for: .normal)
        purchaseNumButton.layoutIfNeeded()
        
        //bug1757 去掉--
        if let qtyAndCharges = model.qtyAndCharges, qtyAndCharges.count > 0, let qtyChargeModel: YXNewStockQtyAndChargeModel = qtyAndCharges.first {
            
            let purchaseNum = qtyChargeModel.purchaseNum ?? 0
            let applyNum = qtyChargeModel.sharedApplied ?? 0
            var chargeModel = qtyChargeModel
            if purchaseNum > applyNum {
                for charge in qtyAndCharges {
                    if charge.sharedApplied == purchaseNum {
                        chargeModel = charge
                        break
                    }
                }
            }
            //认购总额
            setTotalAmount(chargeModel)
        }
        
        let financeModify: Bool = (isModify == 1 && self.applyType == .financingSubs)
        //根据认购类型重新布置界面, 需要上面的总费用计算好了
        resetViewFrame(self.applyType, resetConfig: !financeModify)
        //在初始化界面数据信息后，执行融资赋值
        if financeModify {
            textField.text = String(format: "%.02f", financeModifyAmount)
            updateDataAndWarnMessage()
        }
    }
    
    
    func refreshEmptyView(availbleAmount: Double, sourceParams: YXPurchaseDetailParams) {
        
        self.initAvailableAmountData(availbleAmount)
        nameLabel.text = "--"
        symbolLabel.text = ""
        
        //认购股数/金额
        self.applyType = .cashSubs
        subsTypeView.refreshUI(applyType: .cash)
        
        if sourceParams.exchangeType == YXExchangeType.us.rawValue {
            moneyUnitLabel.text = YXToolUtility.moneyUnit(1)
        } else {
            moneyUnitLabel.text = unitString
        }
        
        let width = (moneyUnitLabel.text! as NSString).boundingRect(with: CGSize(width: 200, height: 50), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : moneyUnitLabel.font], context: nil).size.width
        moneyUnitLabel.snp.updateConstraints { (make) in
            make.width.equalTo(width + 1)
        }
        
        //认购总额和利息依赖上面的认购类型来计算
        purchaseNumButton.isEnabled = false
        purchaseNumButton.setTitle("", for: .normal)
        purchaseNumButton.layoutIfNeeded()
        
        
        //根据认购类型重新布置界面, 需要上面的总费用计算好了
        resetViewFrame(self.applyType, resetConfig: false)
    }
    
    //MARK: 设置总金额
    func setTotalAmount(_ qtyChargeModel: YXNewStockQtyAndChargeModel) {
        
        guard let model = self.stockModel else { return }
        
        if let appliedAmount = qtyChargeModel.appliedAmount, appliedAmount > 0,
            let sharedApplied = qtyChargeModel.sharedApplied, sharedApplied > 0 {
            var titelString: String = ""
            
            var bookingFee: Double = 0.0
            if self.applyType == .financingSubs {
                if let fee = model.financingFee {
                    bookingFee = Double(fee)
                }
            } else {
                if let fee = model.bookingFee {
                    bookingFee = Double(fee)
                }
            }
            
            let prefixString = String(format: "(%@%@) ", YXNewStockMoneyFormatter.shareInstance.formatterMoney(sharedApplied), YXLanguageUtility.kLang(key: "stock_unit"))
            let suffixString = YXNewStockMoneyFormatter.shareInstance.formatterMoney(appliedAmount)
            titelString = String(format: "%@%@%@", prefixString, suffixString, unitString)
            let mutString = NSMutableAttributedString.init(string: titelString)
            mutString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1(), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: 0, length: prefixString.count))
            var bigFont: UIFont = .systemFont(ofSize: 30, weight: .medium)
            if YXToolUtility.is4InchScreenWidth() {
                bigFont = .systemFont(ofSize: 24, weight: .medium)
            }
            mutString.addAttribute(.font, value: bigFont, range: NSRange(location: prefixString.count, length: suffixString.count))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: mutString.length - unitString.count, length: unitString.count))
            
            self.totalAmount = appliedAmount + bookingFee
            self.handlingFee = bookingFee
            amount = sharedApplied
            self.leastFinanceAmount = qtyChargeModel.leastCash ?? 0
            
            purchaseNumButton.setAttributedTitle(mutString, for: .normal)
            purchaseNumButton.isEnabled = true
            purchaseNumButton.layoutIfNeeded()
        }
        
        if self.applyType == .financingSubs {
            textField.text = ""
            purchaseEnableClosure?(false)
            updateLeastFinanceAmount()
            updateDataAndWarnMessage() //总金额改变。融资金额会变，导致融资利率可能有变化，需要重新计算
        }
    }
    
    //MARK: 认购模式切换时更新对应的数据
    func updateHandlingFeeAndTip() {
        
        guard let model = self.stockModel else { return }
        
        let amount = self.totalAmount - self.handlingFee
        if self.applyType == .financingSubs {
            self.handlingFee = 0.0
            if let fee = model.financingFee {
                self.handlingFee = Double(fee)
            }
            self.totalAmount = amount + self.handlingFee
            
//            if model.financingAccountDiff ?? 0 > 0 && (model.financingOrdinaryFee ?? 0 != model.financingSeniorFee ?? 0){
//                showProBookingFee(model: model)
//            } else {

                //原/现手续费, 原手续费和现手续费不等就按优惠展示
                updateFee(originalFee: model.bookFeeOriginalFinancing, nowFee: model.financingFee)
//            }
            
            //温馨提示
            modifyTips(tips: model.financingTips)
            if tipLabel.isHidden {
                seeMoreButton.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.snp.left).offset(18)
                    make.top.equalTo(declareLabel.snp.bottom).offset(10)
                    make.bottom.lessThanOrEqualToSuperview().offset(-20)
                    make.right.lessThanOrEqualToSuperview().offset(-18)
                }
            } else {
                seeMoreButton.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.snp.left).offset(18)
                    make.top.equalTo(tipTextFirstLabel.snp.bottom).offset(10)
                    make.bottom.lessThanOrEqualToSuperview().offset(-20)
                    make.right.lessThanOrEqualToSuperview().offset(-18)
                }
            }
        } else {
            self.handlingFee = 0.0
            if let fee = model.bookingFee {
                self.handlingFee = Double(fee)
            }
            self.totalAmount = amount + self.handlingFee
            //原/现手续费, 原手续费和现手续费不等就按优惠展示
            updateFee(originalFee: model.bookFeeOriginal, nowFee: model.bookingFee)
            
            //温馨提示
            modifyTips(tips: model.tips)
        }
        
        updateTotalAmountClosure?(self.totalAmount)
    }
    
    func showProBookingFee(model: YXNewStockDetailInfoModel) {
        
        bookingFeeNumLabel.isHidden = true
        bookingFeeNumImage.isHidden = true
        bookFeeOriginalLabel.isHidden = true
        
        ordinaryFeeNumBtn.isHidden = false
        proFeeNumBtn.isHidden = false
        
        var oriFeeFormatt = "--"
        var proFeeFormatt = " --"
        if let o = model.financingOrdinaryFee {
            oriFeeFormatt = YXNewStockMoneyFormatter.shareInstance.formatterMoney(o)
        }
        
        if let p = model.financingSeniorFee {
            proFeeFormatt = YXNewStockMoneyFormatter.shareInstance.formatterMoney(p)
        }
        
        let oStr1 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "current"))\(YXLanguageUtility.kLang(key: "normal"))")
        oStr1.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: oStr1.length))
        
        let oStr4 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "normal"))")
        oStr4.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: oStr4.length))
        
        let oStr2 = NSMutableAttributedString(string: "\(oriFeeFormatt)")
        oStr2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "DINPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: oStr2.length))
        
        let oStr3 = NSMutableAttributedString(string: "\(unitString) ")
        oStr3.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: oStr3.length))
        
        
        let pStr1 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "current"))PRO")
        pStr1.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: pStr1.length))
        
        let pStr4 = NSMutableAttributedString(string: " PRO")
        pStr4.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: pStr4.length))
        
        let pStr2 = NSMutableAttributedString(string: "\(proFeeFormatt)")
        pStr2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "DINPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: pStr2.length))
        
        
        if YXUserManager.shared().curLoginUser?.userRoleType == YXUserRoleType.common {
            oStr1.append(oStr2)
            oStr1.append(oStr3)
            pStr4.append(pStr2)
            pStr4.append(oStr3)
            oStr1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: oStr1.length))
            pStr4.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: pStr4.length))
            ordinaryFeeNumBtn.setAttributedTitle(oStr1, for: .normal)
            proFeeNumBtn.setAttributedTitle(pStr4, for: .normal)
        } else {
            
            oStr4.append(oStr2)
            oStr4.append(oStr3)
            pStr1.append(pStr2)
            pStr1.append(oStr3)
            oStr4.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: oStr4.length))
            pStr1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: pStr1.length))
            ordinaryFeeNumBtn.setAttributedTitle(oStr4, for: .normal)
            proFeeNumBtn.setAttributedTitle(pStr1, for: .normal)
        }
        
    }
    
    //更新手续费
    func updateFee(originalFee: String?, nowFee: Double?) {
        
        bookingFeeNumLabel.isHidden = true
        bookingFeeNumImage.isHidden = true
        ordinaryFeeNumBtn.isHidden = true
        bookFeeOriginalLabel.isHidden = false
        proFeeNumBtn.isHidden = true
        //原/现手续费, 原手续费和现手续费不等就按优惠展示
        if let bookFeeOriginal = originalFee, bookFeeOriginal.count > 0, let originalFee =  Double(bookFeeOriginal),
            let bookingFee = nowFee, fabs(originalFee - bookingFee) > 1e-6 {
            let string = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(originalFee), unitString)
            let mutString = NSMutableAttributedString.init(string: string)
            mutString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber.init(value: 1), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(NSAttributedString.Key.baselineOffset, value: NSNumber.init(value: 0), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1().withAlphaComponent(0.6), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: mutString.length))
            bookFeeOriginalLabel.attributedText = mutString
            bookingFeeNumLabel.isHidden = false
            bookingFeeNumImage.isHidden = false
        } else if let bookingFee = nowFee {
            bookFeeOriginalLabel.attributedText = NSAttributedString.init(string: String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(bookingFee), unitString), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        } else {
            bookFeeOriginalLabel.attributedText = NSAttributedString.init(string: "--", attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        }
        
        //优惠费用
        if let bookingFee = nowFee {
            bookingFeeNumLabel.text = String(format: "%@%@     ", YXNewStockMoneyFormatter.shareInstance.formatterMoney(bookingFee), unitString)
        }
    }
    
    func modifyTips(tips: String?) {
        //温馨提示
        tipLabel.isHidden = true
        tipTextFirstLabel.isHidden = true
        if let tip = tips, tip.count > 0, let data = tip.data(using: .unicode) {
            tipLabel.isHidden = false
            tipTextFirstLabel.isHidden = false
            tipTextFirstLabel.attributedText = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType :  NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
    }
    
    //普通融资利率
    @objc lazy var ordinaryRateBtn: UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.layer.cornerRadius = 2
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().textColorLevel4()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.isHidden = true
        return btn
        
    }()
    //pro融资利率
    @objc lazy var proRateBtn: UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.layer.cornerRadius = 2
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().tipsColor()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.isHidden = true
        return btn
    }()
    
    //MARK: 认购金额按钮事件
    @objc func purchaseNumButtonEvent() -> Void {
        
        textField.resignFirstResponder()
        if let closure = purchaseButtonClosure {
            closure()
        }
    }
    
    //MARK: 去入金
    @objc func currencyButtonEvent() -> Void {
        if let closure = saveValueClosure {
            closure()
        }
    }
    //MARK: 查看更多
    @objc func seeMoreButtonAction() {
        seeMoreClosure?()
    }
    
    //MARK: 同意按钮点击
    @objc func declareButtonEvent() -> Void {
        
        if hasReadDeclares {
            hasReadDeclares = false
            declareButton.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        } else {
            hasReadDeclares = true
            declareButton.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .normal)
        }
        
    }
    
    //MARK: 认购费用说明
    @objc func frrDeclareButtonEvent() -> Void {
        
        if let closure = purchaseFeeClosure {
            closure()
        }
    }
    
    //MARK: 认购金额变更时刷新相应数据
    func refreshPurchaseSelectedData(qtyModel: YXNewStockQtyAndChargeModel) -> Void {
        
        setTotalAmount(qtyModel)
    }
    
    //MARK: 认购模式切换时更新视图布局
    //type = 1 现金认购， type = 2 融资认购
    func resetViewFrame(_ type: YXNewStockSubsType, resetConfig: Bool = true) {
        
        self.applyType = type
        textField.resignFirstResponder()
        updateHandlingFeeAndTip()
        let isCashType = (type == .cashSubs)
        if isCashType {
            //手续费
            feeView.snp.updateConstraints { (make) in
                make.height.equalTo(70)
            }

            self.adjustAvailbleAmountViewLayout()
            
            declareButton.snp.remakeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(allowedAmountLabel.snp.bottom).offset(20)
                make.height.equalTo(14)
                make.width.equalTo(14)
            }
            
            warnLabel.isHidden = true
            warnImageButton.isHidden = true
            
        } else {
            let itemHeight: CGFloat = 45.0
            
            //手续费
            feeView.snp.updateConstraints { (make) in
                make.height.equalTo(itemHeight)
            }
            
            self.adjustAvailbleAmountViewLayout()
            
            declareButton.snp.remakeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(financeBottomView.snp.bottom).offset(13)
                make.height.equalTo(14)
                make.width.equalTo(14)
            }
            
            if resetConfig {
                defaultFinanceSetting()
            }
        }
        
        amountView.lineView.isHidden = isCashType ? false : true
        amountView.tipButton.isHidden = isCashType ? true : false
        feeView.lineView.isHidden = isCashType ? false : true
        
        usedCashView.isHidden = isCashType ? true : false
        financeBottomView.isHidden = isCashType ? true : false
        seeMoreButton.isHidden = isCashType ? true : false

        self.initAvailableAmountData(self.availbleAmount)
        
        purchaseEnableClosure?(isCashType)
        changeOptionClosure?()
    }
    
    //MARK: 默认或初始融资界面数据展示设置
    func defaultFinanceSetting() {
        
        guard let model = stockModel else { return }
        textField.text = ""
        
        updateLeastFinanceAmount()
        financeAmountView.valueLabel.attributedText = financeAttributeString("0.00", unitString: unitString)
        
        financeScaleLabel.text = String(format: "(%@%.02lf%%)", YXLanguageUtility.kLang(key: "newStock_finance_scale"), 0.0)
//        if (model.financingAccountDiff ?? 0 > 0) && (model.financingOrdinaryRate ?? 0 != model.financingSeniorRate ?? 0){
//            financeRateView.valueLabel.isHidden = true
//            showProRate(stockModel: model)
//        } else {
            financeRateView.valueLabel.isHidden = false
            ordinaryRateBtn.isHidden = true
            proRateBtn.isHidden = true
            if let interestRate = model.interestRate {
                financeRateView.valueLabel.text = String(format: "%.02f%%", interestRate * 100)
            } else {
                financeRateView.valueLabel.text = "--"
            }
//        }
        
        if let days = model.interestDay {
            interestDaysView.valueLabel.attributedText = financeAttributeString(String(days), unitString: YXLanguageUtility.kLang(key: "common_day_unit"))
        } else {
            interestDaysView.valueLabel.text = String(format: "--%@", YXLanguageUtility.kLang(key: "common_day_unit"))
        }
        usedCashView.lineView.backgroundColor = QMUITheme().separatorLineColor()
        interestAmountView.valueLabel.text = "0.00" + unitString
    }
    
    func showProRate(stockModel: YXNewStockDetailInfoModel) {
        ordinaryRateBtn.isHidden = false
        proRateBtn.isHidden = false
        
        var financingOrdinaryRate: Double = -1.0
        if let rate = stockModel.financingOrdinaryRate {
            financingOrdinaryRate = rate
        }
        
        var financingSeniorRate: Double = -1.0
        if let rate = stockModel.financingSeniorRate {
            financingSeniorRate = rate
        }
        
        var oStr1 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "normal"))")
        if YXUserManager.shared().curLoginUser?.userRoleType == YXUserRoleType.common {
            oStr1 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "current"))\(YXLanguageUtility.kLang(key: "normal"))")
        }
        oStr1.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: oStr1.length))
        
        var financingOrdinaryRateString = "-- "
        if financingOrdinaryRate >= 0 {
            financingOrdinaryRateString = String(format: "%.02f%% ", financingOrdinaryRate * 100)
        }

        let oStr2 = NSMutableAttributedString(string: financingOrdinaryRateString)
        oStr2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "DINPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: oStr2.length))
        oStr1.append(oStr2)
        oStr1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: oStr1.length))
        
        var pStr1 = NSMutableAttributedString(string: " PRO")
        if YXUserManager.shared().curLoginUser?.userRoleType != YXUserRoleType.common {
            pStr1 = NSMutableAttributedString(string: " \(YXLanguageUtility.kLang(key: "current"))PRO")
        }
        pStr1.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: pStr1.length))
        
        var financingSeniorRateString = "-- "
        if financingSeniorRate >= 0 {
            financingSeniorRateString = String(format: "%.02f%% ", financingSeniorRate * 100)
        }
        
        let pStr2 = NSMutableAttributedString(string: financingSeniorRateString)
        pStr2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "DINPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: pStr2.length))
        pStr1.append(pStr2)
        pStr1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: pStr1.length))
        
        ordinaryRateBtn.setAttributedTitle(oStr1, for: .normal)
        proRateBtn.setAttributedTitle(pStr1, for: .normal)
    }
    
    func financeAttributeString(_ valueString: String, unitString: String) -> NSAttributedString {
        let contentString = valueString + unitString
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
        attributeString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24)], range: (contentString as NSString).range(of: valueString))
        return attributeString
    }
    
    //MARK: 更新最低融资额度
    func updateLeastFinanceAmount() {
        
        guard let model = stockModel else { return }
        
        if self.applyType == .financingSubs {
            
            var baseOffset = 0
            if YXConstant.systemVersion.hasPrefix("10.") {
                baseOffset = -3
            }
            textField.attributedPlaceholder = NSAttributedString.init(string: String(format: YXLanguageUtility.kLang(key: "newStock_min_input_amount"), YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.leastFinanceAmount), unitString), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16) ?? UIFont.systemFont(ofSize: 16), NSAttributedString.Key.baselineOffset : baseOffset])
            
            if self.availbleAmount < self.leastFinanceAmount {
                warnLabel.isHidden = false
                warnImageButton.isHidden = false
                
                warnLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_cash_not_enough_des"), self.leastFinanceAmount, unitString, model.financingMultiple ?? 1)
            } else {
                warnLabel.isHidden = true
                warnImageButton.isHidden = true
            }
            
            self.adjustAvailbleAmountViewLayout()
        }
    }
    
    //MARK: 更新数据和提示文字
    func updateDataAndWarnMessage() {
        calculateFinanceData()
        //根据用户输入的数据来展示警告
        showOrHiddenWarnMessage()
    }
    
    //MARK: 输入框输入时数据实时变化
    //融资变化
    func calculateFinanceData() {
        
        guard let model = stockModel else { return }
        
        guard let text = textField.text, text.count > 0,  let inputAmount = Double(text), totalAmount > 0 else {
            defaultFinanceSetting()
            return
        }
        let stockAmount = totalAmount //- self.handlingFee
        let realAmount = totalAmount - self.handlingFee
        var financeAmount = stockAmount - inputAmount < 0 ? 0 : stockAmount - inputAmount
        if inputAmount < self.leastFinanceAmount || inputAmount > stockAmount  {
            financeAmount = 0.0
        }
        var financeMergeRate = 0.0
        if realAmount > 0 {
            financeMergeRate = (financeAmount * 100 / realAmount) > 100 ? 0.0 : (financeAmount * 100 / realAmount)
        }
        financeAmountView.valueLabel.attributedText = financeAttributeString(YXNewStockMoneyFormatter.shareInstance.formatterMoney(financeAmount), unitString: unitString)
        financeScaleLabel.text = String(format: "(%@%.02lf%%)", YXLanguageUtility.kLang(key: "newStock_finance_scale"), financeMergeRate)
        
        //融资利率
        var interestRate: Double = -1.0
        if let rate = model.interestRate {
            interestRate = rate
        }
        
        if let ipoRatios = model.ipoFinancingRatios, ipoRatios.count > 0 {
            let tempAmount = stockAmount - inputAmount
            for ratio in ipoRatios {
                if let financingAmountBegin = ratio.financingAmountBegin,
                    let financingAmountEnd = ratio.financingAmountEnd,
                    tempAmount >= financingAmountBegin,
                    tempAmount <= financingAmountEnd,
                    let rate = ratio.interestRate {
                    interestRate = rate
                    break
                }
            }
        }
        

        
//        if (model.financingAccountDiff ?? 0 > 0) && (model.financingOrdinaryRate ?? 0 != model.financingSeniorRate ?? 0) {
//            financeRateView.valueLabel.isHidden = true
//            showProRate(stockModel: model)
//        } else {
            financeRateView.valueLabel.isHidden = false
            ordinaryRateBtn.isHidden = true
            proRateBtn.isHidden = true
            if interestRate >= 0 {
                financeRateView.valueLabel.text = String(format: "%.02f%%", interestRate * 100)
            } else {
                financeRateView.valueLabel.text = "--"
            }
//        }
        
        //利息天数
        var interestDay: Int = 0
        if let days = model.interestDay {
            interestDay = days
            interestDaysView.valueLabel.attributedText = financeAttributeString(String(days), unitString: YXLanguageUtility.kLang(key: "common_day_unit"))
        } else {
            interestDaysView.valueLabel.text = String(format: "--%@", YXLanguageUtility.kLang(key: "common_day_unit"))
        }
        //利息
        let interestAmount = financeAmount * Double(interestDay) * interestRate / 365.0
        self.financeInterestAmount = interestAmount
        interestAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(interestAmount), unitString)
        updateTotalAmountClosure?(self.totalAmount + interestAmount)
    }
    
    //MARK: 初始化用户可用现金
    @objc func initAvailableAmountData(_ availAmount: Double) {
        
        if let doubleAmount = Double(String(format: "%.2lf", availAmount)),
            let string = moneyFormatter.string(from: NSNumber(value: doubleAmount)) {
            
            self.availbleAmount = availAmount
            if self.applyType == .financingSubs, let enableEnough = stockModel?.enableEnough, enableEnough == false, let financingMultiple = stockModel?.financingMultiple {
                allowedAmountLabel.text = String(format: YXLanguageUtility.kLang(key: "deposit_tips2"), string, unitString, financingMultiple)
                currencyButton.setTitle(YXLanguageUtility.kLang(key: "deposit_tips1"), for: .normal)
            } else {
                allowedAmountLabel.text = String(format: "%@ %@%@", YXLanguageUtility.kLang(key: "newStock_certified_funds"), string, unitString)
                currencyButton.setTitle(YXLanguageUtility.kLang(key: "newStock_save_cash"), for: .normal)
            }

        } else {
            if self.applyType == .financingSubs, let enableEnough = stockModel?.enableEnough, enableEnough == false, let financingMultiple = stockModel?.financingMultiple {
                allowedAmountLabel.text = String(format: YXLanguageUtility.kLang(key: "deposit_tips2"), "0.00", unitString, financingMultiple)
                currencyButton.setTitle(YXLanguageUtility.kLang(key: "deposit_tips1"), for: .normal)
            } else {
                allowedAmountLabel.text = String(format: "%@ 0.00%@", YXLanguageUtility.kLang(key: "newStock_certified_funds"), unitString)
                currencyButton.setTitle(YXLanguageUtility.kLang(key: "newStock_save_cash"), for: .normal)
            }
        }
    }

    func adjustAvailbleAmountViewLayout() {

        if self.applyType == .cashSubs {
            allowedAmountLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(feeView.snp.bottom).offset(10)
            }

            currencyButton.snp.remakeConstraints { (make) in
                make.centerY.equalTo(allowedAmountLabel.snp.centerY)
                make.left.equalTo(allowedAmountLabel.snp.right).offset(6)
                make.right.lessThanOrEqualTo(self.snp.right)
            }
        } else {

            var enough = true
            if let enableEnough = stockModel?.enableEnough, enableEnough == false {
                enough = false
            }
            allowedAmountLabel.snp.remakeConstraints { [weak self] (make) in
                guard let `self` = self else { return }

                if self.warnLabel.isHidden == false {
                    make.top.equalTo(warnLabel.snp.bottom).offset(20)
                } else {
                    make.top.equalTo(usedCashView.snp.bottom).offset(5)
                }

                if !enough {
                    make.right.equalTo(self.snp.right).offset(-18)
                    make.left.greaterThanOrEqualTo(self.snp.left).offset(18)
                } else {
                    make.left.equalTo(self.snp.left).offset(18)
                }
            }

            currencyButton.snp.remakeConstraints { (make) in
                if enough {
                    make.centerY.equalTo(allowedAmountLabel.snp.centerY)
                    make.left.equalTo(allowedAmountLabel.snp.right).offset(5)
                    make.right.lessThanOrEqualTo(self.snp.right)
                } else {
                    make.right.equalTo(self.snp.right).offset(-18)
                    make.left.greaterThanOrEqualTo(self.snp.left).offset(18)
                    make.top.equalTo(allowedAmountLabel.snp.bottom).offset(6)
                }
            }

        }

    }
    
    //MARK: 输入框文字变化事件处理
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateDataAndWarnMessage()
    }
    
    func showOrHiddenWarnMessage() {
        
        guard let model = stockModel else { return }
        if let text = self.textField.text ,text.count > 0 , let amount = Double(text) {
            
            if self.availbleAmount < self.leastFinanceAmount {
                
                changeWarnMessageState()
                warnLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_cash_not_enough_des"), self.leastFinanceAmount, unitString, model.financingMultiple ?? 1)
            } else if amount < self.leastFinanceAmount {
                
                changeWarnMessageState()
                warnLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_min_input_amount"), YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.leastFinanceAmount), unitString)
            } else if amount > self.totalAmount + self.financeInterestAmount {
                
                changeWarnMessageState()
                warnLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_suggest_cash_type"), YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.totalAmount + self.financeInterestAmount)) + unitString
            } else if amount > self.availbleAmount {
                
                changeWarnMessageState()
                var financingMultiple: Int = 1
                if let model = self.stockModel, let multiple = model.financingMultiple {
                    financingMultiple = multiple
                }
                warnLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_cash_not_enough_des"), amount, unitString, financingMultiple)
            } else {
                changeWarnMessageState(isWarn: false)
            }
            
            self.adjustAvailbleAmountViewLayout()
        }
    }
    
    func changeWarnMessageState(isWarn: Bool = true) {
        
        if isWarn {
            usedCashView.lineView.backgroundColor = QMUITheme().tipsColor()
            purchaseEnableClosure?(false)
            warnImageButton.isHidden = false
            warnLabel.isHidden = false
        } else {
            usedCashView.lineView.backgroundColor = QMUITheme().separatorLineColor()
            purchaseEnableClosure?(true)
            warnImageButton.isHidden = true
            warnLabel.isHidden = true
        }
    }
    
    
    func adjustPurchaseButtonEnable() {
        if self.applyType == .cashSubs {
            purchaseEnableClosure?(true)
        } else {
            purchaseEnableClosure?(false)
            showOrHiddenWarnMessage()
        }
    }
    
    //用户需要从可取现金中支付的总金额
    func financeSubsTotalAmount() -> Double {

        financeSubsInputAmount() + self.financeInterestAmount
    }
    
    //认购金额
    func financeSubsInputAmount() -> Double {
        var subsMoney = self.leastFinanceAmount
        if let text = self.textField.text, let amount = Double(text) {
            subsMoney = amount
        }
        return subsMoney
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
        initClourse()
    }
    
    func initClourse() {
        subsTypeView.cashBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.resetViewFrame(.cashSubs)
        }
        
        subsTypeView.financeBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.resetViewFrame(.financingSubs)
        }
    }
    
    func initializer() {
        do {
            addSubview(nameLabel)
            addSubview(symbolLabel)
            //股票名
            nameLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.top.equalToSuperview().offset(25)
                make.right.lessThanOrEqualToSuperview().offset(-78)
            }
            
            //股票代码
            symbolLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(nameLabel.snp.centerY)
                make.left.equalTo(nameLabel.snp.right).offset(3)
                make.height.equalTo(20)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
            }
        }
        
        do {
            addSubview(subsTypeView)
            subsTypeView.cashButton.isSelected = true
            //现金认购
            addSubview(amountView)
            //手续费
            addSubview(feeView)
            
            //认购方式
            subsTypeView.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(25)
                make.height.equalTo(45.0)
                make.left.right.equalToSuperview()
            }
            
            //认购金额
            amountView.snp.makeConstraints { (make) in
                make.top.equalTo(subsTypeView.snp.bottom)
                make.height.equalTo(70.0)
                make.left.right.equalToSuperview()
            }
            
            amountView.addSubview(purchaseNumButton)
            purchaseNumButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(amountView.snp.centerY)
                make.right.equalTo(amountView.snp.right).offset(-18)
                make.left.greaterThanOrEqualTo(amountView.tipButton.snp.right)
            }
            
            //手续费
            feeView.snp.makeConstraints { (make) in
                make.top.equalTo(amountView.snp.bottom)
                make.height.equalTo(70.0)
                make.left.right.equalToSuperview()
            }
            
            feeView.addSubview(bookFeeOriginalLabel)
            feeView.addSubview(bookingFeeNumLabel)
            feeView.addSubview(bookingFeeNumImage)
            feeView.addSubview(ordinaryFeeNumBtn)
            feeView.addSubview(proFeeNumBtn)
            
            bookFeeOriginalLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(feeView.snp.right).offset(-18)
            }
            
            bookingFeeNumLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(bookFeeOriginalLabel.snp.left).offset(-5)
            }
            
            bookingFeeNumImage.snp.makeConstraints { (make) in
                make.center.equalTo(bookingFeeNumLabel.snp.center)
                make.height.equalTo(20)
                make.width.equalTo(bookingFeeNumLabel.snp.width)
            }
            
            ordinaryFeeNumBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(feeView.snp.right).offset(-18)
                make.height.equalTo(21)
            }
            
            proFeeNumBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(ordinaryFeeNumBtn.snp.left).offset(-12)
                make.height.equalTo(21)
            }

            feeView.bringSubviewToFront(bookingFeeNumLabel)
        }
        
        
        do {
            addSubview(usedCashView)
            usedCashView.snp.makeConstraints { (make) in
                make.height.equalTo(55)
                make.left.right.equalToSuperview()
                make.top.equalTo(feeView.snp.bottom)
            }
            
            usedCashView.addSubview(moneyUnitLabel)
            usedCashView.addSubview(textField)
            moneyUnitLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-18)
                make.centerY.equalToSuperview()
                make.width.equalTo(40)
            }
            
            textField.snp.makeConstraints { (make) in
                make.right.equalTo(moneyUnitLabel.snp.left).offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
                make.left.equalTo(usedCashView.titleLabel.snp.right).offset(6)
            }
            
            addSubview(warnLabel)
            addSubview(warnImageButton)
            warnImageButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.top.equalTo(usedCashView.snp.bottom).offset(5)
                make.width.equalTo(15)
                make.height.equalTo(15)
            }
            
            warnLabel.snp.makeConstraints { (make) in
                make.left.equalTo(warnImageButton.snp.right).offset(2)
                make.top.equalTo(usedCashView.snp.bottom).offset(5)
                make.right.equalToSuperview().offset(-18)
            }
        }
        
        addSubview(allowedAmountLabel)
        addSubview(currencyButton)
        
        allowedAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(18)
            make.top.equalTo(feeView.snp.bottom).offset(10)
        }
        
        currencyButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(allowedAmountLabel.snp.centerY)
            make.left.equalTo(allowedAmountLabel.snp.right).offset(6)
            make.right.lessThanOrEqualTo(self.snp.right)
        }
        
        do {
            
            addSubview(financeBottomView)
            financeBottomView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(currencyButton.snp.bottom).offset(15)
                make.height.equalTo(4 * 45.0 + 20)
            }
            
            financeBottomView.addSubview(financeAmountView)
            financeBottomView.addSubview(financeRateView)
            financeBottomView.addSubview(interestDaysView)
            financeBottomView.addSubview(interestAmountView)
            
            financeAmountView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(45)
            }
            
            financeAmountView.addSubview(financeScaleLabel)
            financeScaleLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-18)
                make.left.equalTo(financeAmountView.titleLabel.snp.right)
                make.top.equalTo(financeAmountView.valueLabel.snp.bottom).offset(5)
            }
            
            financeRateView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(financeAmountView.snp.bottom).offset(20)
                make.height.equalTo(45)
            }
            
            financeRateView.addSubview(ordinaryRateBtn)
            financeRateView.addSubview(proRateBtn)
            
            ordinaryRateBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(financeRateView.snp.centerY)
                make.right.equalTo(financeRateView).offset(-18)
                make.height.equalTo(21)
            }
            
            proRateBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(financeRateView.snp.centerY)
                make.right.equalTo(ordinaryRateBtn.snp.left).offset(-12)
                make.height.equalTo(21)
            }
            
            interestDaysView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(financeRateView.snp.bottom)
                make.height.equalTo(45)
            }
            
            interestAmountView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(interestDaysView.snp.bottom)
                make.height.equalTo(45)
            }
        }
        
        do {
            addSubview(declareButton)
            addSubview(declareLabel)
            addSubview(tipLabel)
            addSubview(tipTextFirstLabel)
            addSubview(seeMoreButton)
            declareButton.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(allowedAmountLabel.snp.bottom).offset(20)
                make.height.equalTo(14)
                make.width.equalTo(14)
            }
            
            declareLabel.snp.makeConstraints { (make) in
                make.top.equalTo(declareButton.snp.top)
                make.left.equalTo(declareButton.snp.right).offset(3)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
                //make.height.equalTo(40)
            }
            
            tipLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(declareLabel.snp.bottom).offset(35)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
            }
            
            tipTextFirstLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(tipLabel.snp.bottom).offset(10)
                make.right.equalTo(self.snp.right).offset(-18)
            }
            
            seeMoreButton.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(tipTextFirstLabel.snp.bottom).offset(10)
                make.bottom.lessThanOrEqualToSuperview().offset(-20)
                make.right.lessThanOrEqualToSuperview().offset(-18)
            }
        }
        
        usedCashView.isHidden = true
        warnImageButton.isHidden = true
        warnLabel.isHidden = true
        financeBottomView.isHidden = true
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 14.0 / 20.0
        return label
    }()
    
    @objc lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12.0
        return label
    }()
    
    //认购方式
    lazy var subsTypeView: YXNewStockPurchaseTypeView = {
        let view = YXNewStockPurchaseTypeView()
        return view
    }()
    
    //认购金额
    lazy var amountView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.delegate = self
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_num")
        return view
    }()
    
    //手续费
    lazy var feeView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_handling_fee")
        return view
    }()
    
    
    //认购金额button
    lazy var purchaseNumButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setImage(UIImage(named: "icon_pull_down"), for: .normal)
        button.addTarget(self, action: #selector(purchaseNumButtonEvent), for: .touchUpInside)
        button.sizeToFit()
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 4.0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 10.0 / 20.0
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0)
        button.backgroundColor = QMUITheme().separatorLineColor()
        return button
    }()
    
    //原费用
    @objc lazy var bookFeeOriginalLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    //现费用
    @objc lazy var bookingFeeNumLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
        
    }()
    
    //普通手续费
    @objc lazy var ordinaryFeeNumBtn: UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.layer.cornerRadius = 2
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().textColorLevel4()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.isHidden = true
        return btn
        
    }()
    //pro手续费
    @objc lazy var proFeeNumBtn: UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.layer.cornerRadius = 2
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().tipsColor()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.isHidden = true
        return btn
    }()
    
    lazy var bookingFeeNumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "purchase_fee")
        return imageView
    }()
    
    //可用现金
    @objc lazy var allowedAmountLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //入金
    @objc lazy var currencyButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_save_cash"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(currencyButtonEvent), for: .touchUpInside)
        return button
    }()
    
    @objc lazy var declareButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .normal)
        button.addTarget(self, action: #selector(declareButtonEvent), for: .touchUpInside)
        return button
    }()
    
    lazy var declareLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        
        let normalString = YXLanguageUtility.kLang(key: "newStock_read_agree")
        var linkString = String(format: "《%@》", YXLanguageUtility.kLang(key: "newStock_purchase_instruction1"))
        if YXUserManager.isENMode() {
            linkString = String(format: "\n%@", YXLanguageUtility.kLang(key: "newStock_purchase_instruction1"))
        } else if YXToolUtility.is4InchScreenWidth() {
            linkString = String(format: "\n《%@》", YXLanguageUtility.kLang(key: "newStock_purchase_instruction1"))
        }
        
        let contentString = normalString + linkString
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.paragraphStyle : paragraph])
        let range = (contentString as NSString).range(of: linkString)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], range: range)
        attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTextColor(), backgroundColor: UIColor.clear, tapAction: { [weak self] (view, attstring, range, rect) in
            guard let `self` = self else { return }
            if let closure = self.purchaseDeclareClosure {
                closure()
            }
        })
        label.attributedText = attributeString
        return label
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = YXLanguageUtility.kLang(key: "newStock_tips") + ":"
        return label
    }()
    
    lazy var tipTextFirstLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    //使用可取现金
    lazy var usedCashView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_use_availble_cash")
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.textField.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        return view
    }()
    
    lazy var moneyUnitLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.keyboardType = .numbersAndPunctuation
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.font = .systemFont(ofSize: 24)
        textField.textColor = QMUITheme().textColorLevel1()
        textField.textAlignment = .right
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12.0 / 24.0
        return textField
    }()
    
    lazy var warnImageButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "newstock_warn_about"), for: .normal)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var warnLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().tipsColor()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var financeBottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    //融资金额
    lazy var financeAmountView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.delegate = self
        view.tipButton.isHidden = false
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_amount")
        view.lineView.isHidden = true
        return view
    }()
    
    lazy var financeScaleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    //融资利率
    lazy var financeRateView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_rate")
        view.lineView.isHidden = true
        return view
    }()
    
    //计息天数
    lazy var interestDaysView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.delegate = self
        view.tipButton.isHidden = false
        view.lineView.isHidden = true
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_interest_days")
        return view
    }()
    
    //融资利息
    lazy var interestAmountView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.delegate = self
        view.tipButton.isHidden = false
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_interest")
        return view
    }()
    
    @objc lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    
    
    lazy var seeMoreButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_see_more"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.addTarget(self, action: #selector(seeMoreButtonAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tipButtonAction() {
        showFinanceDescriptionAlert()
    }
}

extension YXNewStockPurcahseView: YXNewStockPurcahseTitleViewDelegate {
    
    func tipButtonClick(_ titleView: YXNewStockPurcahseTitleView) {
        
        showFinanceDescriptionAlert()
    }
    
    func showFinanceDescriptionAlert() {
        
        //融资比例
//        var financeRate: Double = 0
//        if let depositRate = self.stockModel?.depositRate, depositRate <= 1 {
//            financeRate = 1 - depositRate
//        }
//        String(format: YXLanguageUtility.kLang(key: "newStock_finance_description2"), financeRate * 100),
        let messageArray = [YXLanguageUtility.kLang(key: "newStock_finance_description1"),
                            
                            YXLanguageUtility.kLang(key: "newStock_finance_description3"),
                            YXLanguageUtility.kLang(key: "newStock_finance_description4"),
                            YXLanguageUtility.kLang(key: "newStock_finance_description5"),
                            YXLanguageUtility.kLang(key: "newStock_finance_description6")]
        let message = messageArray.joined(separator: "\n")
        let title = YXLanguageUtility.kLang(key: "newStock_finance_declare")
        //取消
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default) { (alertController, action) in
            
        }
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        
        //弹框
        let alertController = QMUIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.alertContentMargin = UIEdgeInsets(top: 0, left: uniHorLength(28), bottom: 0, right: uniHorLength(28))
        alertController.alertContentMaximumWidth = YXConstant.screenWidth
        let titleParagraph = NSMutableParagraphStyle()
        titleParagraph.alignment = .center
        alertController.alertSeparatorColor = QMUITheme().separatorLineColor()
        alertController.alertTitleAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium), NSAttributedString.Key.paragraphStyle : titleParagraph]
        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacing = 8
        paragraph.lineSpacing = 3
        paragraph.headIndent = 16
        alertController.alertMessageAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.paragraphStyle : paragraph]
        alertController.alertContentCornerRadius = 20
        alertController.alertButtonHeight = 48
        alertController.alertHeaderInsets = UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20)
        alertController.alertTitleMessageSpacing = 20
        alertController.addAction(cancel)
        alertController.showWith(animated: true)
    }
}

extension YXNewStockPurcahseView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var checkStr = textField.text
        
        let rag = checkStr?.toRange(range)
        checkStr = checkStr?.replacingCharacters(in: rag!, with: string)
        if checkStr?.isEmpty ?? true {//checkStr?.count == 0
            return true
        }
        
        return predicte.evaluate(with:checkStr ?? "")
    }
}
