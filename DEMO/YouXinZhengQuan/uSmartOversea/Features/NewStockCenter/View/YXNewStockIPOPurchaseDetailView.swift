//
//  YXNewStockPurchaseDetailView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXPurchaseDetailView: UIView {
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    init(frame: CGRect, leftMargin: CGFloat, rightMargin: CGFloat) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(leftMargin)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(-rightMargin)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXNewStockPurchaseDetailView: UIView {
    
  
    func refreshUI(model: YXNewStockPurchaseDetailModel) -> Void {
        
        nameLabel.text = model.stockName ?? "--"
        symbolLabel.text = String(format: "%@", model.stockCode ?? "")
        
        //状态
        var status =  YXNewStockPurchaseType.currentStatus(model.labelCode)
        if model.applyType == YXNewStockSubsType.internalSubs.rawValue ||
            model.applyType == YXNewStockSubsType.reserveSubs.rawValue {
            status = YXNewStockPurchaseType.currentStatus(model.status)
        }
        switch status {
        case .purchased:
            //已认购
            tipLabel.textColor = QMUITheme().themeTextColor()
        case .totalWined,
             .partWined:
            //已中签
            tipLabel.textColor = QMUITheme().tipsColor()
        case .notWined:
            //未中签
            tipLabel.textColor = QMUITheme().textColorLevel2()
        case .purchaseFailed:
            //认购失败
            tipLabel.textColor = QMUITheme().textColorLevel2()
        case .canceled:
            //认购撤销
            tipLabel.textColor = QMUITheme().textColorLevel2()
        case .waitAnnounceWined:
            //待公布中签
            tipLabel.textColor = UIColor.qmui_color(withHexString: "#5B3BE8")
        case .commited:
            //待系统确认
            tipLabel.textColor = UIColor.qmui_color(withHexString: "#5B3BE8")
        default:
            //待系统确认
            tipLabel.textColor = UIColor.qmui_color(withHexString: "#5B3BE8")
        }
        
        tipLabel.text = String(format: " %@ ", model.statusName ?? "")
        
        if let reason = model.failReason, reason.count > 0,
            let status = model.labelCode, status != YXNewStockPurchaseType.purchased.rawValue {
            reasonLabel.text = reason
        } else {
            reasonLabel.text = ""
        }
        
        //单位/手续费/认购金额
        var unitString: String = ""
        if let moneyType = model.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        
        //认购金额
        styleView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_public_subscription")
        
        if let handlingFee = model.handlingFee, let applyAmount = model.applyAmount, handlingFee >= 0, applyAmount >= 0 {
            purchaseAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyAmount - handlingFee), unitString)
            
        } else {
            purchaseAmountView.valueLabel.text = "--"
        }
        
        //手续费
        if let handlingFee = model.handlingFee {
            feeAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(handlingFee), unitString)
        } else {
            feeAmountView.valueLabel.text = "--"
        }
        
        //提交认购时间
        if let createTime = model.createTime, createTime.count > 0 {
            submitView.valueLabel.text = createTime
        } else {
            submitView.valueLabel.text = "--"
        }
        
        
        //认购总额
        var deductString: String = ""
        if let deductStatusName = model.deductStatusName, deductStatusName.count > 0 {
            deductString = String(format: "(%@)", deductStatusName)
        }
        
        if let applyAmount = model.applyAmount {
            if model.applyType == YXNewStockSubsType.financingSubs.rawValue, let financingAmount = model.financingAmount {
                totalAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyAmount + financingAmount), unitString)
            } else {
                totalAmountView.valueLabel.text = String(format: "%@%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyAmount), unitString, deductString)
                
            }
        } else {
            totalAmountView.valueLabel.text = "--"
        }
        
        //认购截止日期
        if let endtime = model.endTime, endtime.count > 0 {
            if endtime.count >= 16 {
                deadlineView.valueLabel.text = endtime.subString(toCharacterIndex: 16)
            } else {
               deadlineView.valueLabel.text = endtime
            }
            
        } else {
            deadlineView.valueLabel.text = "--"
        }
        
        //中签股数
        if let allottedQuantity = model.allottedQuantity {
            winNumberView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(allottedQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        } else {
            winNumberView.valueLabel.text = "--"
        }
        
        if model.applyType == YXNewStockSubsType.financingSubs.rawValue {
            //融资认购
            //认购方式
            typeView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_purchase")
            
            //已用现金
            if let cash = model.cash {
                usedCashView.valueLabel.text = String(format: "%@%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(cash), unitString, deductString)
            } else {
                usedCashView.valueLabel.text = String(format: "--")
            }
            
            //融资利率
            if let interestRate = model.interestRate {
                financeRateView.valueLabel.text = String(format: "%.02f%%", interestRate * 100.0)
            } else {
                financeRateView.valueLabel.text = "--"
            }
            
            //融资利息
            if let financingAmount = model.financingAmount {
                var deductedLabel = ""
                if model.cancelDeductInterest == 2 || model.cancelDeductInterest == 3 {
                    deductedLabel = "(" + YXLanguageUtility.kLang(key: "newStock_purchase_deducted") + ")"
                }

                financeFeeView.valueLabel.text = String(format: "%@%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(financingAmount), unitString, deductedLabel.count > 0 ? deductedLabel : deductString)
            } else {
                financeFeeView.valueLabel.text = String(format: "--")
            }
            
            //融资金额
            if let financingBalance = model.financingBalance {
                financeAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(financingBalance), unitString)
            } else {
                financeAmountView.valueLabel.text = String(format: "--")
            }
            
            //计息天数
            if let interestDay = model.interestDay {
                interestView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(interestDay), YXLanguageUtility.kLang(key: "common_day_unit"))
            } else {
                interestView.valueLabel.text = "--"
            }
            
        } else {

            //认购方式 现金认购
            typeView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_cash")
        }

        //认购数量
        if let applyQuantity = model.applyQuantity {
            numberView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        } else {
            numberView.valueLabel.text = "--"
        }
                
        //公布中签时间
        if let publishTime = model.publishTime, publishTime.count > 0 {
            if publishTime.count >= 10 {
                announceView.valueLabel.text = publishTime.subString(toCharacterIndex: 10)
            } else {
               announceView.valueLabel.text = publishTime
            }
            
        } else {
            announceView.valueLabel.text = "--"
        }

        //退还金额
        refundAmountView.valueLabel.text = "--"
        if let refundFlag = model.refundFlag {
            if refundFlag == 1 {
                refundAmountView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_pending_refund")
            } else if refundFlag == 2, let refundAmount = model.refundAmount {
                refundAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(refundAmount), unitString)
            } 
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 22.0
        return label
    }()
    
    @objc lazy var symbolLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = .systemFont(ofSize: 12)
        return label
        
    }()
    
    @objc lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().themeTextColor()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = NSTextAlignment.right
        return label
    }()
    
    @objc lazy var reasonLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    lazy var amountDetailView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        view.layer.borderColor = QMUITheme().themeTextColor().withAlphaComponent(0.5).cgColor
        return view
    }()
    
    //提交认购
    lazy var submitView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 18, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1()
        view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_submit")
        return view
    }()
    
    //认购截止
    lazy var deadlineView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 18, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1()
        view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_stop")
        return view
    }()
    
    //公布中签
    lazy var announceView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 18, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1()
        view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_announce_signing")
        return view
    }()
    
    //认购类型
    lazy var styleView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_subs_type")
        return view
    }()
    
    //认购方式
    lazy var typeView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_type")
        return view
    }()
    
    //认购数量
    lazy var numberView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_count")
        return view
    }()
    
    //认购总额
    lazy var totalAmountView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_fund")
        return view
    }()
    
    //中签股数
    lazy var winNumberView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_win_stock_num")
        return view
    }()
    
    
    //退还金额
    lazy var refundAmountView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_refund_amount")
        return view
    }()
    
    
    //已用现金
    lazy var usedCashView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_used_cash")
        return view
    }()
    
    //融资金额
    lazy var financeAmountView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_amount")
        return view
    }()
    
    //融资利率
    lazy var financeRateView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_rate")
        return view
    }()
    
    //计息天数
    lazy var interestView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 30, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().textColorLevel1()
        view.valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_interest_days")
        return view
    }()
    
    //认购金额
    lazy var purchaseAmountView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 14, rightMargin: 14)
        view.titleLabel.textColor = QMUITheme().themeTextColor()
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().themeTextColor()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_num")
        return view
    }()
    
    //手续费
    lazy var feeAmountView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 14, rightMargin: 14)
        view.titleLabel.textColor = QMUITheme().themeTextColor()
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().themeTextColor()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_handling_fee")
        return view
    }()
    
    //融资利息
    lazy var financeFeeView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 14, rightMargin: 14)
        view.titleLabel.textColor = QMUITheme().themeTextColor()
        view.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.valueLabel.textColor = QMUITheme().themeTextColor()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_interest")
        return view
    }()
    
    convenience init(applyType: YXNewStockSubsType = .cashSubs, exchangeType: YXExchangeType = .hk) {
        self.init(frame: CGRect.zero, applyType: applyType, exchangeType: exchangeType)
    }

    init(frame: CGRect, applyType: YXNewStockSubsType = .cashSubs, exchangeType: YXExchangeType = .hk ) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(symbolLabel)
        addSubview(amountDetailView)
        addSubview(tipLabel)
        addSubview(reasonLabel)
        
        let margin: CGFloat = 18
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(14)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth - 120)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel.snp.left)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.right.equalToSuperview().offset(-margin)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right)
        }
        
        reasonLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(symbolLabel.snp.centerY)
            make.right.equalTo(tipLabel.snp.right)
        }
    
        let titleViewHeight: CGFloat = 40
        let contentViewHeight: CGFloat = 30
        
        addSubview(submitView)
        submitView.snp.makeConstraints { (make) in
            make.top.equalTo(symbolLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(titleViewHeight)
        }
        
        var topViewArray: [UIView] = []
        if exchangeType == .hk {
            addSubview(styleView)
            topViewArray.append(styleView)
        }
        addSubview(typeView)
        addSubview(numberView)
        topViewArray += [typeView, numberView]
        
        var preview: UIView = submitView
        topViewArray.forEach { (view) in
            view.snp.makeConstraints { (make) in
                make.top.equalTo(preview.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(contentViewHeight)
            }
            preview = view
        }
        
        if applyType == .financingSubs {
            addSubview(usedCashView)
            addSubview(financeAmountView)
            addSubview(financeRateView)
            addSubview(interestView)
            let financeViewArray = [usedCashView, financeAmountView, financeRateView, interestView]
            financeViewArray.forEach { (view) in
                view.snp.makeConstraints { (make) in
                    make.top.equalTo(preview.snp.bottom)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(contentViewHeight)
                }
                preview = view
            }
        }
        
        addSubview(totalAmountView)
        totalAmountView.snp.makeConstraints { (make) in
            make.top.equalTo(preview.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(contentViewHeight)
        }
        preview = totalAmountView
      
        
        amountDetailView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
            make.top.equalTo(preview.snp.bottom).offset(5)
        }
        
        amountDetailView.addSubview(purchaseAmountView)
        amountDetailView.addSubview(feeAmountView)
        
        purchaseAmountView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(contentViewHeight)
        }
        
        feeAmountView.snp.makeConstraints { (make) in
            make.top.equalTo(purchaseAmountView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(contentViewHeight)
            if applyType != .financingSubs {
                make.bottom.equalToSuperview().offset(-10)
            }
        }
        
        if applyType == .financingSubs {
            amountDetailView.addSubview(financeFeeView)
            financeFeeView.snp.makeConstraints { (make) in
                make.top.equalTo(feeAmountView.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(contentViewHeight)
                make.bottom.equalToSuperview().offset(-10)
            }
        }
        
        preview = amountDetailView
        
        addSubview(deadlineView)
        deadlineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(preview.snp.bottom).offset(5)
            make.height.equalTo(titleViewHeight)
        }
        preview = deadlineView
        
        addSubview(announceView)
        announceView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(preview.snp.bottom)
            make.height.equalTo(titleViewHeight)
        }
        
        addSubview(winNumberView)
        addSubview(refundAmountView)
        
        winNumberView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(announceView.snp.bottom)
            make.height.equalTo(contentViewHeight)
        }
        
        refundAmountView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(winNumberView.snp.bottom)
            make.height.equalTo(contentViewHeight)
            make.bottom.equalToSuperview().offset(-20)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
