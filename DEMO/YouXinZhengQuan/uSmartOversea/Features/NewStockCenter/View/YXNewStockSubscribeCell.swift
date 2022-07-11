//
//  YXNewStockSubscribeCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockSubscribeCell: YXTableViewCell {
    
    @objc var stockStatus: YXNewStockStatus = .purchase
    // 专业投资者标签
    @objc var ecmLabelView: UIView?
    // 自定义标签
    @objc var customLabelView: UIView?
    
    //MARK: - lazy load
    @objc lazy var lineView: UIView = {
        
        return UIView.line()
        
    }()

    @objc lazy var logoImageView: UIImageView = {
       
        let imageView = UIImageView()
        return imageView
        
    }()
    
    @objc lazy var stockTitleLabel: YXSecuNameLabel = {
        
        let label = YXSecuNameLabel()
        label.textColor = QMUITheme().textColorLevel1()
        return label
        
    }()
    
    @objc lazy var stockSymbolLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)//UIFont.systemFont(ofSize: 12)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
        
    }()
    
    lazy var tipLabel: QMUILabel = {
        
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_center_winState_purchased")
        label.textAlignment = .center
        label.textColor = QMUITheme().themeTextColor()
        label.layer.borderWidth = 0.5
        label.layer.borderColor = QMUITheme().themeTextColor().cgColor
        label.font = UIFont.systemFont(ofSize: 10)
        label.layer.cornerRadius = 1.0
        label.layer.masksToBounds = true
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2);
        
        return label
    }()
    
    // ipo
    lazy var ipoLabel: UILabel = {
        
        let label = UILabel.ipo() ?? UILabel()
        label.text = "银行融资"
        
        return label
    }()
    
    lazy var tagBgScrollView: UIScrollView = {
        
        let scrollV = UIScrollView()
        scrollV.showsHorizontalScrollIndicator = false
        
        return scrollV
    }()
    
//    // 国际认购
//    lazy var ecmView: UIView = {
//        return UIView.ecmTag()
//    }()
    
    @objc var tags = [UIView]()
    
    //起购资金
    @objc lazy var leastMoneyTitleLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    //起购资金/中签率
    @objc lazy var leastMoneyValueLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    //国际认购起购资金
    @objc lazy var ecmLeastMoneyTitleLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    //国际认购起购资金
    @objc lazy var ecmLeastMoneyValueLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    //招股价
    @objc lazy var purchaseNumTitleLabel: UILabel = {
        
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_offer_price")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
        
    }()
    
    //招股价
    @objc lazy var purchaseNumValueLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        return label
        
    }()
    
    @objc lazy var marketDateTitleLabel: UILabel = {
        
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newstock_deadline")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    @objc lazy var marketDateValueLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        return label
        
    }()
    
    @objc lazy var endDateValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    // 每手股数
    @objc lazy var handAmountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_perNumber")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    @objc lazy var handAmountValueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override func initialUI() {
        super.initialUI()
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        
        contentView.addSubview(lineView)
        contentView.addSubview(stockTitleLabel)
        contentView.addSubview(stockSymbolLabel)

        contentView.addSubview(leastMoneyTitleLabel)
        contentView.addSubview(leastMoneyValueLabel)
        contentView.addSubview(purchaseNumTitleLabel)
        contentView.addSubview(purchaseNumValueLabel)
        contentView.addSubview(marketDateTitleLabel)
        contentView.addSubview(marketDateValueLabel)
        contentView.addSubview(endDateValueLabel)
        contentView.addSubview(handAmountTitleLabel)
        contentView.addSubview(handAmountValueLabel)
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(1)
        }
        
        stockTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(self.snp.top).offset(16)
            make.height.equalTo(22)
        }
        
        stockSymbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.stockTitleLabel)
            make.left.equalTo(stockTitleLabel.snp.right).offset(6)
            make.right.lessThanOrEqualTo(self).offset(-10)
        }
        
        //起购资金
        leastMoneyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.stockTitleLabel.snp.bottom).offset(14)
            make.height.equalTo(21)
            make.left.equalTo(stockTitleLabel)
            make.right.equalTo(leastMoneyValueLabel.snp.left).offset(-5)
        }
        
        //起购资金
        leastMoneyValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.leastMoneyTitleLabel)
            make.left.equalTo(self.snp.centerX).offset(-30)
        }
        
        //招股价
        purchaseNumTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leastMoneyTitleLabel)
            make.top.equalTo(self.leastMoneyTitleLabel.snp.bottom).offset(8)
            make.right.equalTo(purchaseNumValueLabel.snp.left).offset(-5)
        }
        
        //招股价
        purchaseNumValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leastMoneyValueLabel)
            make.centerY.equalTo(self.purchaseNumTitleLabel)
        }
        
        handAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.purchaseNumTitleLabel)
            make.top.equalTo(self.purchaseNumTitleLabel.snp.bottom).offset(8)
            make.right.equalTo(handAmountValueLabel.snp.left).offset(-5)
        }
        
        handAmountValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.purchaseNumValueLabel)
            make.centerY.equalTo(self.handAmountTitleLabel)
        }
        
        //认购截止日/剩余时间
        marketDateTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.handAmountTitleLabel)
            make.top.equalTo(self.handAmountTitleLabel.snp.bottom).offset(8)
            make.right.equalTo(marketDateValueLabel.snp.left).offset(-5)
        }
        
        //认购截止日/剩余时间
        marketDateValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.handAmountValueLabel)
            make.centerY.equalTo(self.marketDateTitleLabel)
        }
        
        endDateValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.marketDateValueLabel.snp.right).offset(8)
            make.centerY.equalTo(self.marketDateValueLabel)
        }
        
    }
    
    override func refreshUI() {
        super.refreshUI()
        
        if let model = model as? YXNewStockCenterPreMarketStockModel2 {
            
            // 标签
            setTagLabel(model: model)
            var market: String
            if model.exchangeType == YXExchangeType.hk.rawValue {
                market = "hk"
            }else {
                market = "us"
            }
            
//            if model.exchangeType == YXExchangeType.hk.rawValue {
//                logoImageView.image = UIImage(named: "hk")
//                market = "hk"
//            } else if model.exchangeType == YXExchangeType.us.rawValue {
//                logoImageView.image = UIImage(named: "us")
//            } else if model.exchangeType == YXExchangeType.sh.rawValue {
//                logoImageView.image = UIImage(named: "sh")
//            } else if model.exchangeType == YXExchangeType.sz.rawValue {
//                logoImageView.image = UIImage(named: "sz")
//            }
            stockSymbolLabel.text = model.stockCode + ".\(market.uppercased())"
            if model.exchangeType == 5 {
                stockSymbolLabel.text = (stockSymbolLabel.text ?? "") + " " + model.listExchanges
            }
            stockTitleLabel.text = model.stockName
            
            handAmountValueLabel.text = model.handAmount
            
            ecmLeastMoneyTitleLabel.removeFromSuperview()
            ecmLeastMoneyValueLabel.removeFromSuperview()
            
            if model.exchangeType == YXExchangeType.hk.rawValue {
                setHKLeastAmount(model: model)
            }else {
                setUSLeastAmount(model: model)
            }
            
            //招股价
            let priceMax = model.priceMax != nil ? String(format: "%.3f", model.priceMax!.doubleValue) : "--"
            let priceMin = model.priceMin != nil ? String(format: "%.3f", model.priceMin!.doubleValue) : "--"
            if priceMax == priceMin {
                purchaseNumValueLabel.text = priceMin
            }else {
                purchaseNumValueLabel.text = String(format: "%@-%@", priceMin, priceMax)
            }
            
            //认购截止日 + 剩余时间
            marketDateValueLabel.text = (model.latestEndtime.count > 0) ? model.latestEndtime : "--"
            if model.latestEndtime.count > 0, model.serverTime.count > 0 {
                endDateValueLabel.attributedText = leftTimeString(seconds: model.remainingTime, endTime: model.latestEndtime, serverTime: model.serverTime)
            } else {
                endDateValueLabel.text = "--"
            }
        }
    }
    
    func setHKLeastAmount(model: YXNewStockCenterPreMarketStockModel2) {
        if model.isCanECM(), model.isCanPublic() {
            leastMoneyTitleLabel.text = YXLanguageUtility.kLang(key: "ipo_admission_fee")
            contentView.addSubview(ecmLeastMoneyTitleLabel)
            contentView.addSubview(ecmLeastMoneyValueLabel)
            
            //公开认购起购资金
            if let leastAmount = model.leastAmount {
                let formattMoney = YXNewStockPurchaseUtility.moneyFormat(value: leastAmount.doubleValue)
                leastMoneyValueLabel.text = formattMoney
            } else {
                leastMoneyValueLabel.text = "--"
            }
            
            //国际认购起购资金
            if let ecmLeastAmount = model.ecmLeastAmount {
                let formattMoney = YXNewStockPurchaseUtility.moneyFormat(value: ecmLeastAmount.doubleValue)
                ecmLeastMoneyValueLabel.text = formattMoney
            } else {
                ecmLeastMoneyValueLabel.text = "--"
            }
            
            ecmLeastMoneyTitleLabel.text = YXLanguageUtility.kLang(key: "ecm_admission_fee")
            
            //国际认购起购资金title
            ecmLeastMoneyTitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.leastMoneyTitleLabel)
                make.top.equalTo(self.leastMoneyTitleLabel.snp.bottom).offset(8)
            }
            
            //国际认购起购资金value
            ecmLeastMoneyValueLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.leastMoneyValueLabel)
                make.centerY.equalTo(self.ecmLeastMoneyTitleLabel)
            }
            
            //招股价title
            purchaseNumTitleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.leastMoneyTitleLabel)
                make.top.equalTo(self.ecmLeastMoneyTitleLabel.snp.bottom).offset(8)
            }
            
        }else {
            var leastAmount: NSNumber?
            if model.isCanECM() {
                leastMoneyTitleLabel.text = YXLanguageUtility.kLang(key: "ecm_admission_fee")
                leastAmount = model.ecmLeastAmount
            }else {
                leastMoneyTitleLabel.text = YXLanguageUtility.kLang(key: "ipo_admission_fee")
                leastAmount = model.leastAmount
            }
            
            //认购起购资金
            if let least = leastAmount {
                let formattMoney = YXNewStockPurchaseUtility.moneyFormat(value: least.doubleValue)
                leastMoneyValueLabel.text = formattMoney
            } else {
                leastMoneyValueLabel.text = "--"
            }
            
            //招股价title
            purchaseNumTitleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(self.leastMoneyTitleLabel)
                make.top.equalTo(self.leastMoneyValueLabel.snp.bottom).offset(8)
            }
        }
    }
    
    func setUSLeastAmount(model: YXNewStockCenterPreMarketStockModel2) {
        leastMoneyTitleLabel.text = YXLanguageUtility.kLang(key: "newstock_minamount")
        
        //认购起购资金
        if let least = model.ecmLeastAmount {
            let formattMoney = YXNewStockPurchaseUtility.moneyFormat(value: least.doubleValue)
            leastMoneyValueLabel.text = formattMoney
        } else {
            leastMoneyValueLabel.text = "--"
        }
        
        //招股价title
        purchaseNumTitleLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(self.leastMoneyTitleLabel)
            make.top.equalTo(self.leastMoneyValueLabel.snp.bottom).offset(8)
        }
    }
    
    func setTagLabel(model: YXNewStockCenterPreMarketStockModel2) {

        tagBgScrollView.removeFromSuperview()
                
        for v in tags {
            v.removeFromSuperview()
        }
        tags.removeAll()
        
        // 1、检查是否有状态标签
        if model.labelStatus.count > 0, model.labelStatusName.count > 0 {
            tipLabel.text = model.labelStatusName
            var color = QMUITheme().textColorLevel2()
            switch model.labelStatus {
            case "0", "3":
                color = QMUITheme().themeTextColor()
            case "1":
                color = QMUITheme().tipsColor()
            case "2":
                color = QMUITheme().textColorLevel2()
            default:
                break
            }
            
            tipLabel.textColor = color
            tipLabel.layer.borderColor = color.cgColor
            
            tags.append(tipLabel)
        }
        
        for tag in model.tagList {
            tags.append(UIView.commonBlueTag(withText: tag.tagText))
//            switch tag.tagType {
//            case 1:
//                let label = UILabel.ipo() ?? UILabel()
//                label.text = tag.tagText
//                tags.append(label)
//                break
//            case 2:
//                let ecm = UIView.ecmCustomTag(withText: tag.tagText)
//                tags.append(ecm!)
//                break
//            case 3:
//                let ecm = UIView.ecmProfessionTag(withText:tag.tagText)
//                tags.append(ecm!)
//                break
//            case 4:
//                let ecm = UIView.ecmCustomTag(withText: tag.tagText)
//                tags.append(ecm!)
//                break
//            default:
//                let ecm = UIView.ecmProfessionTag(withText:tag.tagText)
//                tags.append(ecm!)
//                break
//            }
        }

        if tags.count > 0 { // 有标签，起购金额label需要下移
            contentView.addSubview(tagBgScrollView)
            tagBgScrollView.snp.makeConstraints { (make) in
                make.top.equalTo(self.stockTitleLabel.snp.bottom).offset(7)
                make.left.right.equalToSuperview()
                make.height.equalTo(22)
            }
            leastMoneyTitleLabel.snp.updateConstraints { (make) in
                make.top.equalTo(self.stockTitleLabel.snp.bottom).offset(36)
            }
        }else {
            leastMoneyTitleLabel.snp.updateConstraints { (make) in
                make.top.equalTo(self.stockTitleLabel.snp.bottom).offset(14)
            }
        }
        
        // 从标签数组中取出标签 加到父视图并布局
        var preTag: UIView?
        for (index, tag) in tags.enumerated() {
            tagBgScrollView.addSubview(tag)
            if index == 0 {
                tag.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(18)
                    if (tags.count == 1) {
                        make.right.equalToSuperview().offset(-10)
                    }
                }
            }
            else {
                tag.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(preTag!)
                    make.left.equalTo(preTag!.snp.right).offset(10)
                    if (index == tags.count - 1) {
                        make.right.equalToSuperview().offset(-10)
                    }
                }
            }
            preTag = tag
        }
    }
    
    func leftTimeString(seconds: NSInteger, endTime: String, serverTime: String) -> (NSMutableAttributedString) {
        
        var time: String = ""
        var value: Int = 0
        if seconds >= 24 * 3600 {
            if serverTime.count >= 10 {
                value = YXDateToolUtility.numberOfDaysWith(fromDate: (serverTime as NSString).substring(with: NSMakeRange(0, 10)), toDate: endTime)
            }
            time = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_day_unit"))
            
        } else if seconds > 0 {
            
            if seconds >= 3600 {
                value = seconds / 3600
                time = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_hour"))
            } else if seconds < 3600, seconds >= 60 {
                value = seconds / 60
                time = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_minute"))
            } else {
                value = 1
                time = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_minute"))
            }
            
        } else {
            time = YXLanguageUtility.kLang(key: "newStock_detail_purchase_closed")
        }
        let font = UIFont.systemFont(ofSize: 12) ?? UIFont.systemFont(ofSize: 12)
        let attriString: NSMutableAttributedString = NSMutableAttributedString(string: time)
        attriString.addAttribute(.font, value: font, range: NSMakeRange(0, time.count))
        attriString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel2(), range: NSMakeRange(0, time.count))
        if seconds > 0 {
            let string = String(format: "%ld", value)
            if YXUserManager.isENMode() {
                attriString.addAttribute(.foregroundColor, value: QMUITheme().tipsColor(), range: NSMakeRange(0, string.count))
            }else {
                attriString.addAttribute(.foregroundColor, value: QMUITheme().tipsColor(), range: NSMakeRange(2, string.count))
            }
            
        }
        return attriString
        
    }
    
}

