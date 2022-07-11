//
//  YXNewStockPurcahseListCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import SnapKit

class YXListValueView: UIView {
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(14)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(-14)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXNewStockPurcahseListCell: UITableViewCell {
 
    enum SubsListCellType {
        case ipo
        case ecm
        case deposit   //预约
    }
    
    var pinTuanBlock: ((YXUserGroupInfoOrderList,YXNewStockPurcahseListCell.SubsListCellType)-> ())?
    
    
    var order: YXUserGroupInfoOrderList?
    
    
    var type: SubsListCellType = .ipo
    var exchangeType: YXExchangeType = .hk
    convenience init(reuseIdentifier: String, type: SubsListCellType = .ipo, exchangeType: YXExchangeType = .hk) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier, type: type, exchangeType: exchangeType)
    }
    //MARK: initialization Method
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, type: SubsListCellType = .ipo, exchangeType: YXExchangeType) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.type = type
        self.exchangeType = exchangeType
        initialUI()
        asyncRender()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialUI() {
  
        let margin: CGFloat = 18
        let innerMargin: CGFloat = 14
        contentView.addSubview(belowView)
        contentView.backgroundColor = QMUITheme().backgroundColor()
        belowView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        belowView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        backView.addSubview(nameLabel)
        backView.addSubview(symbolLabel)
        backView.addSubview(tipButton)
        backView.addSubview(rightButton)
       
        rightButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-innerMargin)
            make.width.equalTo(6)
            make.height.equalTo(11)
        }
        
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.left.equalToSuperview().offset(innerMargin)
        }
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        tipButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(rightButton.snp.centerY)
            make.right.equalTo(rightButton.snp.left).offset(uniHorLength(-10))
        }
        tipButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        symbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.left.equalTo(nameLabel.snp.right).offset(3)
            make.right.lessThanOrEqualTo(tipButton.snp.left).offset(-3)
        }
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        var topConstraint:SnapKit.ConstraintItem? = nil
        for x in 0..<labels.count {
            let purchaseView: YXListValueView = labels[x]
            backView.addSubview(purchaseView)
            purchaseView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(34)
                make.top.equalTo(topConstraint == nil ? nameLabel.snp.bottom : topConstraint!).offset(topConstraint == nil ? 12: 0)
            }
            topConstraint = purchaseView.snp.bottom
        }
        
        //提示
        backView.addSubview(pinTuanLab)
        pinTuanLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(innerMargin)
            make.top.equalTo(topConstraint == nil ? nameLabel.snp.bottom : topConstraint!).offset(24)
            //make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        //分享按钮
        backView.addSubview(pinTuanButton)
        pinTuanButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-innerMargin)
            make.top.equalTo(topConstraint == nil ? nameLabel.snp.bottom : topConstraint!).offset(19)
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.left.greaterThanOrEqualTo(pinTuanLab.snp.right).offset(5)
            //make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        
        pinTuanButton.rx.tap.asControlEvent().subscribe(onNext: { [unowned self] (_) in
            if let block = self.pinTuanBlock, let tempOrder = self.order {
                block(tempOrder,self.type)
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    override func draw(_ rect: CGRect) {
        self.belowView.layer.shadowPath = UIBezierPath.init(rect: self.belowView.bounds.offsetBy(dx: 0, dy: 4)).cgPath
    }
    
    func asyncRender() {
        DispatchQueue.main.async {
            self.belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.belowView.layer.cornerRadius = 10
            self.belowView.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
            //self.belowView.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.belowView.layer.shadowOpacity = 1.0
            //self.belowView.layer.shadowRadius = 4
            
            self.backView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.backView.layer.cornerRadius = 10
            self.backView.layer.masksToBounds = true
        }
    }
    private func feeDiscount(with discount: Int32?) -> String {
        if let dis = discount {
            //英文的，中文8折 英文要寫20% off
            if YXUserManager.curLanguage() == .CN || YXUserManager.curLanguage() == .HK {
                if dis % 100 == 0 {
                    return String(format: "%d%%", 100 - dis / 100)
                }
            } else {
                if dis % 100 == 0 {
                    return String(format: " %d%% off", 100 - dis / 100)
                }
            }
            
        }
        return ""
    }
    
    func refreshGroupInfo(with order: YXUserGroupInfoOrderList) {
        
        self.order = order
        
        if order.status == 1 || order.status == 2 || order.status == 3 {
            pinTuanLab.isHidden = false
            pinTuanButton.isHidden = false
            
            var feeString = ""
            if let feeInfo = order.feeInfo {
                
                var dunHao = ", "
                if YXUserManager.curLanguage() == .CN || YXUserManager.curLanguage() == .HK {
                    dunHao = "，"
                }
                
                if let feeModel = feeInfo.fundFee {
                    if YXUserManager.curLanguage() == .CN || YXUserManager.curLanguage() == .HK {
                        feeString = feeString + feeDiscount(with: feeModel.discount) + YXLanguageUtility.kLang(key: "record_group_info_fee_fund")
                    } else {
                        feeString = feeString + YXLanguageUtility.kLang(key: "record_group_info_fee_fund") + feeDiscount(with: feeModel.discount)
                    }
                    
                }
                
                if let feeModel = feeInfo.ecmFee {
                    if feeString.count > 0 {
                        feeString += dunHao
                    }
                    if YXUserManager.curLanguage() == .CN || YXUserManager.curLanguage() == .HK {
                        feeString = feeString + feeDiscount(with: feeModel.discount) + YXLanguageUtility.kLang(key: "record_group_info_fee_ecm")
                    } else {
                        feeString = feeString + YXLanguageUtility.kLang(key: "record_group_info_fee_ecm") + feeDiscount(with: feeModel.discount)
                    }
                    
                }
                
                if let feeModel = feeInfo.ecmServiceFee {
                    if feeString.count > 0 {
                        feeString += dunHao
                    }
                    if YXUserManager.curLanguage() == .CN || YXUserManager.curLanguage() == .HK {
                        feeString = feeString + feeDiscount(with: feeModel.discount) + YXLanguageUtility.kLang(key: "record_group_info_fee_ecm_service")
                    } else {
                        feeString = feeString + YXLanguageUtility.kLang(key: "record_group_info_fee_ecm_service") + feeDiscount(with: feeModel.discount)
                    }
                    
                }
            }
            
            if order.status == 1 {//未成团
                if let orderCount = order.orderCount,let mostCount = order.mostCount {
                    pinTuanLab.text = String(format: YXLanguageUtility.kLang(key: "record_group_info_tip_not_full"), orderCount, mostCount - orderCount, feeString)
                    
                    pinTuanButton.setTitle(YXLanguageUtility.kLang(key: "record_group_info_btn_invite"), for: .normal)
                    pinTuanButton.isEnabled = true
                }
            } else if order.status == 2 {//已成团
                if let orderCount = order.orderCount {
                    pinTuanLab.text = String(format: YXLanguageUtility.kLang(key: "record_group_info_tip_has_cloud"), orderCount, feeString)
                    
                    pinTuanButton.setTitle(YXLanguageUtility.kLang(key: "record_group_info_btn_invite"), for: .normal)
                    pinTuanButton.isEnabled = true
                }
            } else if order.status == 3 {//已满员
                if let orderCount = order.orderCount {
                    pinTuanLab.text = String(format: YXLanguageUtility.kLang(key: "record_group_info_tip_has_full"), orderCount, feeString)
                    
                    pinTuanButton.setTitle(YXLanguageUtility.kLang(key: "record_group_info_btn_full"), for: .normal)
                    pinTuanButton.isEnabled = false
                }
            }
        }
        else {
            pinTuanLab.isHidden = true
            pinTuanButton.isHidden = true
        }
        
    }
    
    func refreshUI(model: YXNewStockPurchaseListDetailModel) {
     
        if self.type == .deposit {
            nameLabel.text = model.applyCompnay ?? "--"
            symbolLabel.text = ""
        } else {
            nameLabel.text = model.stockName ?? "--"
            var listExchanges: String = ""
            var symbol: String = ""
            if model.exchangeType == YXExchangeType.us.rawValue, let tempListExchanges = model.listExchanges, tempListExchanges.count > 0 {
                listExchanges = " " + tempListExchanges
            }
            if let stockCode = model.stockCode, stockCode.count > 0 {
                symbol = stockCode
            }
            if symbol.count > 0 || listExchanges.count > 0 {
                symbolLabel.text = String(format: "(%@%@)", symbol, listExchanges)
            } else {
                symbolLabel.text = ""
            }
        }
        
        //状态
        var status =  YXNewStockPurchaseType.currentStatus(model.labelCode)
        if model.applyType == YXNewStockSubsType.internalSubs.rawValue ||
            model.applyType == YXNewStockSubsType.reserveSubs.rawValue {
            status = YXNewStockPurchaseType.currentStatus(model.status)
        }
        var tagTitleColor: UIColor? = UIColor.qmui_color(withHexString: "#5B3BE8")
        var tagImageName: String = "tag_wait"
        
        if self.type == .deposit {
            let depositStatus = YXNewStockSubscribeStatusType.currentStatus(model.subscribeStatus)
            switch depositStatus {
            case .alreadyReserved:
                //预约成功
                tagTitleColor = QMUITheme().themeTextColor()
                tagImageName = "tag_checked"
            case .cancel:
                //预约取消
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_cancel"
            case .fail:
                //预约失败
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_fail"
            case .subscribe:
                //已认购
                tagTitleColor = QMUITheme().themeTextColor()
                tagImageName = "tag_checked"
            case .needConfirm:
                //待确认
                //待系统确认
                tagTitleColor = UIColor.qmui_color(withHexString: "#5B3BE8")
                tagImageName = "tag_wait"
            }
            
            tipButton.setTitle(String(format: " %@ ",  model.subscribeStatusName ?? ""), for: .normal)
        } else {
    
            switch status {
            case .purchased:
                //已认购
                tagTitleColor = QMUITheme().themeTextColor()
                tagImageName = "tag_checked"
            case .totalWined,
                 .partWined:
                //已中签
                tagTitleColor = QMUITheme().tipsColor()
                tagImageName = "tag_hunting"
            case .notWined:
                //未中签
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_fail"
            case .purchaseFailed:
                //认购失败
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_fail"
            case .canceled:
                //已撤销
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_cancel"
            case .waitAnnounceWined:
                //待公布中签
                tagTitleColor = UIColor.qmui_color(withHexString: "#5B3BE8")
                tagImageName = "tag_wait"
            case .commited:
                //待系统确认
                tagTitleColor = UIColor.qmui_color(withHexString: "#5B3BE8")
                tagImageName = "tag_wait"
            default:
                //待系统确认
                tagTitleColor = UIColor.qmui_color(withHexString: "#5B3BE8")
                tagImageName = "tag_wait"
                break
            }
            tipButton.setTitle(String(format: " %@ ", model.statusName ?? ""), for: .normal)
        }
        
        
        tipButton.setTitleColor(tagTitleColor, for: .normal)
        tipButton.setImage(UIImage(named: tagImageName), for: .normal)
        tipButton.layoutIfNeeded()

        for x in 0..<labels.count {
            let purchaseView: YXListValueView = labels[x]
            if purchaseView.titleLabel.tag == 3000 {
                if status == .totalWined || status == .partWined || status == .notWined {
                    purchaseView.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_win_stock_num")
                } else {
                    purchaseView.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_announced")
                }
            }
          
            if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_purchase_type") {//认购方式
              
                if let applyType = model.applyType, applyType == YXNewStockSubsType.financingSubs.rawValue {
                    purchaseView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_purchase")
                } else {
                    purchaseView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_cash")
                }
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_purchase_count") ||
                purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sub_quantity") {//认购股数
                
                if let applyQuantity = model.applyQuantity {
                    purchaseView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(applyQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
                } else {
                    purchaseView.valueLabel.text = "--"
                }
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_purchase_fund") {//认购总额
                
                if let moneyType = model.moneyType, moneyType >= 0, let applyAmount = model.totalAmount {
                    let totalAmount: Double = Double(applyAmount)
//                    if let applyType = model.applyType { //认购类型(1-现金，2-融资)
//                        if applyType == YXNewStockSubsType.financingSubs.rawValue, let financeAmount = model.financingAmount {
//                            //加上融资利息
//                            totalAmount += financeAmount
//                        }
//                    }
                    purchaseView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(totalAmount), YXToolUtility.moneyUnit(moneyType))
                } else {
                    purchaseView.valueLabel.text = "--"
                }
                
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_announced") {//公布中签
                if let publishTime = model.publishTime, publishTime.count >= 10 {
                    purchaseView.valueLabel.text = (publishTime as NSString).substring(to: 10)
                } else {
                    purchaseView.valueLabel.text = "--"
                }
                purchaseView.valueLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_win_stock_num") { //中签股数
                if status == .notWined {
                    //未中签显示0
                    purchaseView.valueLabel.text = "0" + YXLanguageUtility.kLang(key: "newStock_stock_unit")
                } else if let allottedQuantity = model.allottedQuantity {
                    purchaseView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(allottedQuantity), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
                } else {
                    purchaseView.valueLabel.text = "--"
                }
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "appointment_subscription_amount") { //预约认购金额
                if let moneyType = model.moneyType, moneyType >= 0, let applyAmount = model.subApplyAmount {
                    purchaseView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(Double(applyAmount)), YXToolUtility.moneyUnit(moneyType))
                } else {
                    purchaseView.valueLabel.text = "--"
                }

            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "appointment_intention_gold") { //预约意向金
                
               if let moneyType = model.moneyType, moneyType >= 0, let applyAmount = model.intentionAmount {
                   purchaseView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(Double(applyAmount)), YXToolUtility.moneyUnit(moneyType))
               } else {
                   purchaseView.valueLabel.text = "--"
               }
                
            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "appointment_apply_time") { //预约时间
                if let applyTime = model.applyTime, applyTime.count >= 16 {
                    purchaseView.valueLabel.text = (applyTime as NSString).substring(to: 16)
                } else {
                    purchaseView.valueLabel.text = "--"
                }
                purchaseView.valueLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)

            } else if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_subs_type") { //认购类型
                if let applyType = model.applyType, applyType == YXNewStockSubsType.internalSubs.rawValue {
                    purchaseView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_internal_placement")
                } else {
                    purchaseView.valueLabel.text = YXLanguageUtility.kLang(key: "newStock_public_subscription")
                }
            }
        }
    }
    
    lazy var belowView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 18.0
        return label
    }()
    
    @objc lazy var symbolLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12.0
        return label
        
    }()
    
    lazy fileprivate var tipButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 2.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    @objc lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "user_next"), for: .normal)
        return button
    }()
    
    @objc lazy var labels: [YXListValueView] = {
        var purchaseLabels: [YXListValueView] = [YXListValueView]()
        var titles: [String] = []
        
        if self.type == .ipo {
            if self.exchangeType == .hk {
                titles.append(YXLanguageUtility.kLang(key: "newStock_subs_type"))
            }
            titles += [YXLanguageUtility.kLang(key: "newStock_purchase_type"),
                      YXLanguageUtility.kLang(key: "newStock_purchase_count"),
                      YXLanguageUtility.kLang(key: "newStock_purchase_fund"),
                      YXLanguageUtility.kLang(key: "newStock_announced")]
        } else if self.type == .ecm {
            if self.exchangeType == .hk {
                titles.append(YXLanguageUtility.kLang(key: "newStock_subs_type"))
            }
            titles.append(YXLanguageUtility.kLang(key: "newStock_purchase_type"))
            titles.append(YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sub_quantity"))
            titles.append(YXLanguageUtility.kLang(key: "newStock_purchase_fund"))
            titles.append(YXLanguageUtility.kLang(key: "newStock_announced"))
                
        } else if self.type == .deposit {
            titles += [YXLanguageUtility.kLang(key: "appointment_subscription_amount"),
                      YXLanguageUtility.kLang(key: "appointment_intention_gold"),
                      YXLanguageUtility.kLang(key: "appointment_apply_time")]
        }
        for x in 0..<titles.count {
            
            let purchaseView: YXListValueView = YXListValueView.init(frame: CGRect.zero)
            purchaseLabels.append(purchaseView)
            purchaseView.titleLabel.text = titles[x]
            if purchaseView.titleLabel.text == YXLanguageUtility.kLang(key: "newStock_announced") {
                purchaseView.titleLabel.tag = 3000
            }
        }
        return purchaseLabels
        
    }()
    
    
    lazy fileprivate var pinTuanLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = QMUITheme().tipsColor()
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.isHidden = true
        return lab
    }()
    
    
    lazy fileprivate var pinTuanButton: QMUIButton = {
        let button = QMUIButton()
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().holdMark()), for: .normal)
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().textColorLevel4()), for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.isHidden = true
        return button
    }()
}
