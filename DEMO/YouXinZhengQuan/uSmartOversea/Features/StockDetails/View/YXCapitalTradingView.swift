//
//  YXCapitalTradingView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXCapitalTradingView: YXStockDetailBaseView {
    
    var market = "hk"
    
    var inLabel: QMUILabel
    var outLabel: QMUILabel
    var offsetLabel: QMUILabel
    
    var model: YXStockAnalyzeCapitalModel? {
        didSet {
            let priceBase = self.model?.priceBase ?? 0
            let base = pow(10.0, Double.init(priceBase))
            let bin = self.getDoubleValue(self.model?.bin, base: base)
            let min = self.getDoubleValue(self.model?.min, base: base)
            let sin = self.getDoubleValue(self.model?.sin, base: base)
            let bout = self.getDoubleValue(self.model?.bout, base: base)
            let mout = self.getDoubleValue(self.model?.mout, base: base)
            let sout = self.getDoubleValue(self.model?.sout, base: base)
            
            let arr = [ bin, min, sin, bout, mout, sout ]
            
            let a = arr.map{ $0.doubleValue }
            let total = a.reduce(0, +)
            
            let max = a.max()
            if let max = max, max > 0 {
                self.chartView.dataArr = [ NSNumber.init(value: bout.doubleValue / total), NSNumber.init(value: mout.doubleValue / total), NSNumber.init(value: sout.doubleValue / total), NSNumber.init(value: sin.doubleValue / total), NSNumber.init(value: min.doubleValue / total), NSNumber.init(value: bin.doubleValue / total)]
            } else {
                self.chartView.dataArr = [NSNumber]()
            }
            
            self.candleView.values = arr
            
            
            // 顶部赋值
            if let inValue = self.model?.yxStockAnalyzeCapitalModelIn {
                self.inLabel.text = YXToolUtility.stockData(inValue, deciPoint: 2, stockUnit: "", priceBase: priceBase)
            } else {
                self.inLabel.text = "--"
            }
            
            if let outValue = self.model?.out {
                self.outLabel.text = YXToolUtility.stockData(outValue, deciPoint: 2, stockUnit: "", priceBase: priceBase)
            } else {
                self.inLabel.text = "--"
            }
            
            if let offsetValue = self.model?.netin {
                self.offsetLabel.text = YXToolUtility.stockData(offsetValue, deciPoint: 2, stockUnit: "", priceBase: priceBase)
            } else {
                self.inLabel.text = "--"
            }

        }
    }

    let chartView = YXPieChartView.init()
    
    let candleView = YXCapitalVolumeView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 76))
    
    override init(frame: CGRect) {
        
        inLabel = QMUILabel.init(with: QMUITheme().stockRedColor(), font: UIFont.systemFont(ofSize: 16, weight: .medium), text: "--")
        outLabel = QMUILabel.init(with: QMUITheme().stockGreenColor(), font: UIFont.systemFont(ofSize: 16, weight: .medium), text: "--")
        offsetLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 16, weight: .medium), text: "--")
        inLabel.textAlignment = .center
        outLabel.textAlignment = .center
        offsetLabel.textAlignment = .center
        super.init(frame: frame)
        initUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
      
        let titleLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 20, weight: .medium), text: YXLanguageUtility.kLang(key: "analytics_money_flow"))
        
        let infoBtn = YXExpandAreaButton.init()
        infoBtn.setImage(UIImage(named: "stock_about"), for: .normal)
        infoBtn.addTarget(self, action: #selector(self.infoBtnClick(_:)), for: .touchUpInside)
        
        let inTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 12, weight: .regular), text: YXLanguageUtility.kLang(key: "analytics_money_inflow"))
        let outTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 12, weight: .regular), text: YXLanguageUtility.kLang(key: "analytics_money_outflow"))
        let offsetTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 12, weight: .regular), text: YXLanguageUtility.kLang(key: "analytics_money_net"))
        inTitleLabel.textAlignment = .center
        outTitleLabel.textAlignment = .center
        offsetTitleLabel.textAlignment = .center

        let containerView = UIView()
        containerView.backgroundColor = QMUITheme().blockColor()
        containerView.layer.cornerRadius = 2.0

        
        addSubview(titleLabel)
        addSubview(infoBtn)
        addSubview(containerView)
        containerView.addSubview(inTitleLabel)
        containerView.addSubview(outTitleLabel)
        containerView.addSubview(offsetTitleLabel)
        containerView.addSubview(inLabel)
        containerView.addSubview(outLabel)
        containerView.addSubview(offsetLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        infoBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(6)
            make.width.height.equalTo(16)
        }

        containerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }


        let width = (YXConstant.screenWidth - 32) / 3.0
        
        inLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
            make.width.equalTo(width)
        }
        
        outLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(width)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
            make.width.equalTo(width)
        }
        
        offsetLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(2.0 * width)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
            make.width.equalTo(width)
        }


        inTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(inLabel)
            make.top.equalTo(inLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(width)
        }

        outTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(outLabel)
            make.top.equalTo(outLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(width)
        }

        offsetTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(offsetLabel)
            make.top.equalTo(offsetLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(width)
        }
        
        addSubview(chartView)
        addSubview(candleView)
        
        chartView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(2)
            make.height.equalTo(240)
        }
        
        candleView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            //make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(76)
            make.top.equalTo(chartView.snp.bottom)
        }
        
    }
    
    func getDoubleValue(_ value: Double?, base: Double ) -> NSNumber {
        if let value = value {
            return NSNumber.init(value: value / base)
        }
        return NSNumber.init(value: 0)
    }
    
    @objc func infoBtnClick(_ sender: UIButton) {
        
        
        var str = String(format: YXLanguageUtility.kLang(key: "analytics_money_definition"), YXLanguageUtility.kLang(key: "warrants_warrants"))
        if self.market == "hk" {
            str = YXLanguageUtility.kLang(key: "analytics_money_hk_definition") + str
        } else if self.market == "sg"{
            str = String(format: YXLanguageUtility.kLang(key: "analytics_money_definition"), YXLanguageUtility.kLang(key: "market_sg_warrants_title"))
        }
        
        let alertView = YXAlertView.init(message: str, messageAlignment: .left)
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
        }))
        alertView.showInWindow()
    }
}
