//
//  YYXNewStockDetailInfoView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit


class YXNewStockDetailInfoView: UIView {

    func refreshUI(_ model: YXNewStockDetailInfoModel) -> Void {

        //单位
        var unitString = YXToolUtility.moneyUnit(2)
        if let moneyType = model.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        unitLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ": " + unitString
        
        //招股价
        if let priceMax = model.priceMax, let priceMin = model.priceMin {
            stockPriceView.valueLabel.text = String(format: "%@-%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(priceMin, pointCount: 3), YXNewStockMoneyFormatter.shareInstance.formatterMoney(priceMax, pointCount: 3))
        } else {
            stockPriceView.valueLabel.text = "--"
        }
        
        //起购资金
        if let leastAmount = model.leastAmount {
            purchaseNumView.valueLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(leastAmount)
        } else {
            purchaseNumView.valueLabel.text = "--"
        }

        //保荐人
        if let sponsor = model.sponsor, sponsor.count > 0 {
            recommanderView.valueLabel.text = sponsor
        } else {
            recommanderView.valueLabel.text = "--"
        }
        
        //总股本
        if let totalQuantity = model.totalQuantity {
            totalView.valueLabel.text = YXToolUtility.stockData(totalQuantity, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
        } else {
            totalView.valueLabel.text = "--"
        }

        //一手中签率
        if let publishTime = model.publishTime, publishTime.count > 0 {
            if let successRate = model.successRate {
                if successRate >= 100.0 {
                    winView.valueLabel.text = String(format: "100%%")
                } else {
                    winView.valueLabel.text = String(format: "%.2f%%", successRate)
                }
            } else {
                if publishTime.count >= 10 {
                    let timeString = publishTime as NSString
                    let text = String(format: "%@/%@/%@",  timeString.substring(with: NSMakeRange(0, 4)), timeString.substring(with: NSMakeRange(5, 2)), timeString.substring(with: NSMakeRange(8, 2)))
                    winView.valueLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_center_will_publish"), text)
                } else {
                    winView.valueLabel.text = String(format: YXLanguageUtility.kLang(key: "newStock_center_will_publish"), "--")
                }
            }
        } else {
             winView.valueLabel.text = "--"
        }
        
        //每手股数
        if let handAmount = model.handAmount {
            perShareView.valueLabel.text = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(handAmount), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        } else {
            perShareView.valueLabel.text = "--"
        }
        
        //发行股本
        if let publishQuantity = model.publishQuantity {
            publishView.valueLabel.text = YXToolUtility.stockData(publishQuantity, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
        } else {
            publishView.valueLabel.text = "--"
        }

        //总市值
        let unit = pow(10.0, 8.0)
        
       
        if let marketValueMax = model.marketValueMax, let marketValueMin = model.marketValueMin {
            totalValueView.valueLabel.text = String(format: "%@-%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(marketValueMin / unit), YXNewStockMoneyFormatter.shareInstance.formatterMoney(marketValueMax / unit), YXLanguageUtility.kLang(key: "common_billion"))
        } else {
            totalValueView.valueLabel.text = "--"
        }

        //认购倍数
        if let bookingRatio = model.bookingRatio {
            purchasesView.valueLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(bookingRatio)
        } else {
            purchasesView.valueLabel.text = "--"
        }
        
        ecmPurchaseNumView.isHidden = true
        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }
        if let ecmLeastAmount = model.ecmLeastAmount, subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)) {
            ecmPurchaseNumView.isHidden = false
            ecmPurchaseNumView.valueLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(ecmLeastAmount)
            if subscribeWayArray.count == 1 {
                purchaseNumView.isHidden = true
            }
        }
    }
    
    var drawDone = false
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !drawDone {
            drawDone = true
            let color = UIColor.qmui_color(withHexString: "#0013BA")?.withAlphaComponent(0.07) ?? UIColor.white
            YXDrawHelper.drawDashLine(superView: firstLineView, strokeColor: color, topMargin:0, lineHeight: 1, leftMargin: 0, rightMargin: 0)
            YXDrawHelper.drawDashLine(superView: secondLineView, strokeColor: color, topMargin:0, lineHeight: 1, leftMargin: 0,rightMargin: 0)
        }
    }
    
    var scale: CGFloat {
        if YXConstant.screenWidth <= 320 {
            return YXConstant.screenWidth / 375.0
        }
        return 1.0
    }
    
    lazy var firstLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var secondLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_summary")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ":"
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    //招股价
    lazy var stockPriceView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_offer_price")
        return view
    }()
    
    lazy var purchaseNumView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "ipo_admission_fee")
        return view
    }()
    
    lazy var ecmPurchaseNumView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "ecm_admission_fee")
        view.isHidden = true
        return view
    }()
    
    lazy var recommanderView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_sponsor")
        return view
    }()
    
    lazy var totalView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_total_funds")
        return view
    }()
    
    lazy var winView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_win_rate")
        return view
    }()
    
    //每手股数
    lazy var perShareView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_perNumber")
        return view
    }()
    
    lazy var publishView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_publish_funds")
        return view
    }()
    
    lazy var totalValueView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_market_capital")
        return view
    }()
    
    lazy var purchasesView: YXStockInfoView = {
        let view = YXStockInfoView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_center_purchase_multiple")
        return view
    }()
    
    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        
        addSubview(firstLineView)
        addSubview(secondLineView)
        
        addSubview(titleLabel)
        addSubview(unitLabel)
        //招股价
        addSubview(stockPriceView)
        addSubview(purchaseNumView)
        addSubview(recommanderView)
        addSubview(totalView)
        addSubview(winView)
        //每手股数
        addSubview(perShareView)
        addSubview(ecmPurchaseNumView)
        addSubview(publishView)
        addSubview(totalValueView)
        addSubview(purchasesView)
        
        
        let topMargin: CGFloat = 13
        let largeMargin: CGFloat = 16
        
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self.snp.top)
        }
        
        unitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalTo(self.snp.right)
        }
        
        stockPriceView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(22)
            make.height.greaterThanOrEqualTo(40)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (6.0 * scale))
        }
        
        purchaseNumView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(stockPriceView.snp.bottom).offset(largeMargin)
            make.height.greaterThanOrEqualTo(40)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (6.0 * scale))
        }
        
        firstLineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(1)
            make.top.equalTo(purchaseNumView.snp.bottom).offset(topMargin)
        }
        
        recommanderView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(firstLineView.snp.bottom).offset(topMargin)
            make.height.greaterThanOrEqualTo(40)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (6.0 * scale))
        }
        
        totalView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(recommanderView.snp.bottom).offset(largeMargin)
            make.height.greaterThanOrEqualTo(40)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (6.0 * scale))
        }
        
        secondLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(1)
            make.top.equalTo(totalView.snp.bottom).offset(topMargin)
        }
        
        winView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(secondLineView.snp.bottom).offset(topMargin)
            make.height.greaterThanOrEqualTo(40)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (6.0 * scale))
        }
        //每手股数
        perShareView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(12.0 * scale)
            make.top.equalTo(stockPriceView.snp.top)
            make.bottom.equalTo(stockPriceView.snp.bottom)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (12.0 * scale))
        }
        
        ecmPurchaseNumView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(12.0 * scale)
            make.top.equalTo(purchaseNumView.snp.top)
            make.bottom.equalTo(purchaseNumView.snp.bottom)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (12.0 * scale))
        }
        
        publishView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(12.0 * scale)
            make.top.equalTo(recommanderView.snp.top)
            make.bottom.equalTo(recommanderView.snp.bottom)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (12.0 * scale))
        }
        
        totalValueView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(12.0 * scale)
            make.top.equalTo(totalView.snp.top)
            make.bottom.equalTo(totalView.snp.bottom)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (12.0 * scale))
        }
        
        purchasesView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(12.0 * scale)
            make.top.equalTo(winView.snp.top)
            make.bottom.equalTo(winView.snp.bottom)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth * 0.5 - 36 - (12.0 * scale))
        }
    }
}

class YXStockInfoView: UIView {
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.minimumScaleFactor = 10.0 / 14.0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    @objc lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self.snp.left)
            make.right.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(self.snp.left)
            make.right.equalToSuperview()
        }
    }
    
    func addTapGesture() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer.init()
        valueLabel.isUserInteractionEnabled = true
        valueLabel.addGestureRecognizer(tap)
        
        tap.rx.event
            .takeUntil(self.rx.deallocated)
            .filter({ [weak self](tap) -> Bool in
                guard let strongSelf = self else { return false }
                return !strongSelf.canShowWholeText()
            })
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.showAlertView(message: strongSelf.valueLabel.text!)
            }).disposed(by: rx.disposeBag)

    }
    
    private func showAlertView(message: String) {
        
        let alertView: YXAlertView = YXAlertView.init(title: "", message: message)
        unowned let weakAlertView = alertView
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
            weakAlertView.hide()
        }))
        let alertController = YXAlertController.init(alert: alertView)!
        let vc = UIViewController.current()
        vc.present(alertController, animated: true, completion: nil)
    }
    
    private func canShowWholeText() -> Bool {
        var canShow = true
        let height = (valueLabel.text! as NSString).boundingRect(with: CGSize.init(width: valueLabel.bounds.size.width, height: 500), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : valueLabel.font!], context: nil).size.height
        if height > valueLabel.frame.size.height {
            canShow = false
        }
        return canShow
    }
    
}
