//
//  YXNewStockECMPurchaseDetailView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXNewStockECMPurchaseDetailView: UIView {
    
    typealias EmptyClousure = () -> Void
    var compensateBlock: EmptyClousure?
    var status: YXNewStockPurchaseType = .commited
    var exchangeType: YXExchangeType = .hk
    
    func refreshUI(model: YXNewStockPurchaseDetailModel) -> Void {
        
        nameLabel.text = model.stockName ?? "--"
        if model.exchangeType == YXExchangeType.us.rawValue, let listExchanges = model.listExchanges, listExchanges.count > 0 {
            symbolLabel.text = String(format: "%@ %@", model.stockCode ?? "", listExchanges)
        } else {
            symbolLabel.text = String(format: "%@", model.stockCode ?? "")
        }
        
        
        //状态
        status = YXNewStockPurchaseType.currentStatus(model.labelCode)
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
        
        //认购类型
        styleView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_internal_placement")
        //认购金额，不包含手续费
        if let applyAmount = model.applyAmount {
            purchaseAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyAmount), unitString)
        } else {
            purchaseAmountView.valueLabel.text = "--"
        }
        
        //手续费
        if let handlingFee = model.ecmFee {
            feeAmountView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(handlingFee), unitString)
        } else {
            feeAmountView.valueLabel.text = "--"
        }
        
        //提交认购时间
        if let createTime = model.orderTime, createTime.count > 0 {
            submitView.valueLabel.text = createTime
        } else {
            submitView.valueLabel.text = "--"
        }
        
        var deductString: String = ""
        if let capitalStatusName = model.capitalStatusName, capitalStatusName.count > 0 {
            deductString = String(format: "(%@)", capitalStatusName)
        }
        
        //认购总额 包含手续费
        if let applyAmount = model.totalAmount {
            totalAmountView.valueLabel.text = String(format: "%@%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyAmount), unitString, deductString)
            
        } else {
            totalAmountView.valueLabel.text = "--"
        }
        
        //认购截止日期
        if let endtime = model.ecmEndTime, endtime.count > 0 {
            if endtime.count >= 16 {
                deadlineView.valueLabel.text = endtime.subString(toCharacterIndex: 16)
            } else {
               deadlineView.valueLabel.text = endtime
            }
        } else {
            deadlineView.valueLabel.text = "--"
        }
        
        //中签股数
        if let allottedQuantity = model.allocatQty {
            winNumberView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(allottedQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        } else {
            winNumberView.valueLabel.text = "--"
        }
        
        //认购方式
        typeView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_cash")

        //认购数量
        if let applyQuantity = model.applyQuantity {
            numberView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        } else {
            numberView.valueLabel.text = "--"
        }
        
        if model.applyType == YXNewStockSubsType.internalSubs.rawValue, self.exchangeType == .hk {
            numberView.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sub_quantity")
        } else {
            numberView.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_count")
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
    
    func refreshCompensateView(_ model: YXNewStockECMCompensateModel) {
        
        compensateView.isHidden = true
        
        if let couponName = model.couponName, status == .notWined {
            compensateView.isHidden = false
            compensateView.valueLabel.text = couponName
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
    
    //补偿活动
    lazy var compensateView: YXPurchaseDetailView = {
        let view = YXPurchaseDetailView(frame: CGRect.zero, leftMargin: 18, rightMargin: 18)
        view.titleLabel.textColor = QMUITheme().textColorLevel1()
        view.titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        view.valueLabel.textColor = QMUITheme().tipsColor()
        view.valueLabel.font = .systemFont(ofSize: 14)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_compensation_activity")
        view.isHidden = true
        
        
        let tapGes = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGes)
        tapGes.rx.event.asControlEvent().takeUntil(rx.deallocated)
            .subscribe(onNext: {
                [weak self] ges in
                guard let `self` = self else { return }
                self.compensateBlock?()
            }).disposed(by: rx.disposeBag)
        
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
 
    convenience init(exchangeType: YXExchangeType = .hk) {
        self.init(frame: CGRect.zero, exchangeType: exchangeType)
    }
    
    init(frame: CGRect, exchangeType: YXExchangeType = .hk) {
        super.init(frame: frame)
    
        self.exchangeType = exchangeType
        
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
            make.bottom.equalToSuperview().offset(-10)
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
        }
        
        addSubview(compensateView)
        compensateView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(refundAmountView.snp.bottom)
            make.height.equalTo(titleViewHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
