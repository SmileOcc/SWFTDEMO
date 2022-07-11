//
//  YXNewStockPreMarketCell.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/18.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockPreMarketCell: YXTableViewCell {
    
    @objc var stockStatus: YXNewStockStatus = .purchase
    
    //MARK: - lazy load
    @objc lazy var lineView: UIView = {
        return UIView.line()
        
    }()

    @objc lazy var logoImageView: UIImageView = {
       
        let imageView = UIImageView()
        return imageView
        
    }()
    
    @objc lazy var stockTitleLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        return label
        
    }()
    
    @objc lazy var stockSymbolLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)//UIFont.systemFont(ofSize: 12)
        return label
        
    }()
    
    lazy var tipLabel: QMUILabel = {
        
        let label = QMUILabel()
        label.text = "已认购";
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
    
    lazy var grayLabel: UILabel = {
        let label = UILabel.gray() ?? UILabel()
        label.text = YXLanguageUtility.kLang(key: "grey_mkt")
        label.isHidden = true
        return label
    }()
    
    // ipo
    lazy var ipoLabel: UILabel = {
        
        let label = UILabel.ipo() ?? UILabel()
        label.text = "银行融资"
        
        return label
    }()
    
    // 国际认购
    lazy var ecmView: UIView = {
        return UIView.ecmTag()
    }()
    
    //起购资金/中签率
    @objc lazy var winLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    //招股价/认购倍数
    @objc lazy var purchaseNumLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    @objc lazy var marketDateLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        return label
        
    }()
    
    @objc lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func initialUI() {
        super.initialUI()
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        
        contentView.addSubview(lineView)
        contentView.addSubview(stockTitleLabel)
        contentView.addSubview(stockSymbolLabel)
        contentView.addSubview(winLabel)
        contentView.addSubview(purchaseNumLabel)
        contentView.addSubview(marketDateLabel)
        contentView.addSubview(grayLabel)
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(1)
        }
        
        stockTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(self.snp.top).offset(10)
            make.height.equalTo(22)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth - 250)
        }
        
        stockSymbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.stockTitleLabel)
            make.top.equalTo(stockTitleLabel.snp.bottom).offset(2)
//            make.right.lessThanOrEqualTo(self).offset(-10)
        }
        
        //起购资金/中签率
        winLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(12)
            make.height.equalTo(21)
            make.right.equalTo(self.snp.right).offset(-120)
            make.width.lessThanOrEqualTo(100)
        }
        //招股价/认购倍数
        purchaseNumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(self)
            make.width.lessThanOrEqualTo(100)
        }
        
        //认购截止日/剩余时间
        marketDateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-130)
            make.centerY.equalTo(self)
            make.height.equalTo(21)
        }
        
        grayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(stockSymbolLabel.snp.right).offset(4)
            make.centerY.equalTo(stockSymbolLabel)
        }
        
    }
    
    override func refreshUI() {
        super.refreshUI()
        
        if let model = model as? YXNewStockCenterPreMarketStockModel2 {
            
            grayLabel.isHidden = model.greyFlag != 1
            
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
            
            var priceMax: String
            var priceMin: String
            if let max = model.priceMax {
                priceMax = String(format: "%.3f", max.doubleValue)
            }else {
                priceMax = "--"
            }
            if let min = model.priceMin {
                priceMin = String(format: "%.3f", min.doubleValue)
            }else {
                priceMin = "--"
            }
            
            if priceMin == priceMax {
                purchaseNumLabel.text = priceMin
            }else {
                purchaseNumLabel.text = String(format: "%@-%@", priceMin, priceMax)
            }
            
//            purchaseNumLabel.snp.remakeConstraints { (make) in
//                make.right.equalTo(self.snp.right).offset(-12)
//                make.centerY.equalTo(self.snp.centerY)
//                make.height.equalTo(21)
//            }
            
            marketDateLabel.text = (model.listingTime != nil) ? model.listingTime : "--"
//            endDateLabel.isHidden = true
//            marketDateLabel.snp.remakeConstraints { (make) in
//                make.right.equalTo(self.snp.right).offset(-12)
//                make.centerY.equalTo(self.snp.centerY)
//                make.height.equalTo(21)
//            }
            
            
        }
    }
    
    func setTagLabel(model: YXNewStockCenterPreMarketStockModel2) {
        tipLabel.removeFromSuperview()
        ipoLabel.removeFromSuperview()
        ecmView.removeFromSuperview()
        
        var tags = [UIView]()
        
        let statusDic = [
            "0": ["text": "已认购", "color": QMUITheme().themeTextColor()],
            "1": ["text": "已中签", "color": QMUITheme().tipsColor()],
            "2": ["text": "未中签", "color": QMUITheme().textColorLevel2()]
        ]
        
        // 检查是否有状态标签
        if let status = statusDic[model.labelStatus] {
            tipLabel.text = status["text"]! as? String
            tipLabel.textColor = status["color"]! as? UIColor
            let borderColor = status["color"]! as? UIColor
            tipLabel.layer.borderColor = borderColor?.cgColor
            tags.append(tipLabel)
        }
        
        // 检查支持的认购方式 认购方式 1-公开现金认购，2-公开融资认购，3-国际配售
        if stockStatus == .purchase { //这些标签只有在认购中才显示
            if model.isCanECM() {
                tags.append(ecmView)
            }
            if model.isCanIPO() {
                ipoLabel.text = String(format: "%d倍银行融资", model.financingMultiple)
                tags.append(ipoLabel)
            }
        }
        
        // 从标签数组中取出标签 加到父视图并布局
        var preTag: UIView?
        for (index, tag) in tags.enumerated() {
            contentView.addSubview(tag)
            if (index == 0) {
                tag.snp.remakeConstraints { (make) in
                    make.top.equalTo(stockSymbolLabel.snp.bottom).offset(2)
                    make.left.equalTo(stockSymbolLabel.snp.left)
                }
            }else {
                tag.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(preTag!)
                    make.left.equalTo(preTag!.snp.right).offset(6)
                }
            }
            preTag = tag
        }
        
        // 由于有了标签cell的高度会变高，需调整winLabel的位置
//        if (tags.count > 0) {
//            winLabel.snp.updateConstraints { (make) in
//                make.top.equalTo(self.snp.top).offset(17)
//            }
//        }else {
//            winLabel.snp.updateConstraints { (make) in
//                make.top.equalTo(self.snp.top).offset(12)
//            }
//        }
    }
    
    func leftTimeString(seconds: NSInteger, endTime: String, serverTime: String) -> (NSMutableAttributedString) {
        
        var time: String = ""
        var value: Int = 0
        if seconds >= 24 * 3600 {
            if serverTime.count >= 10 {
                value = YXDateToolUtility.numberOfDaysWith(fromDate: (serverTime as NSString).substring(with: NSMakeRange(0, 10)), toDate: endTime)
            }
            time = String(format: "剩余 %ld 天", value)
            
        } else if seconds > 0 {
            
            if seconds >= 3600 {
                value = seconds / 3600
                time = String(format: "剩余 %ld 小时", value)
            } else if seconds < 3600, seconds >= 60 {
                value = seconds / 60
                time = String(format: "剩余 %ld 分钟", value)
            } else {
                value = 1
                time = String(format: "剩余 %ld 分钟", value)
            }
            
        } else {
            time = "已截止"
        }
        let attriString: NSMutableAttributedString = NSMutableAttributedString(string: time)
        attriString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(0, time.count))
        attriString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel2(), range: NSMakeRange(0, time.count))
        if seconds > 0 {
            let string = String(format: "%ld", value)
            attriString.addAttribute(.foregroundColor, value: QMUITheme().tipsColor(), range: NSMakeRange(3, string.count))
        }
        return attriString
        
    }
    
}
