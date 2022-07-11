//
//  YXChinaMarketOverViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXChinaMarketOverViewCell: UICollectionViewCell, HasDisposeBag {
    
    let barChartViewHeight = 170.0
    
    var shapeLayers = [CAShapeLayer]()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_overview")
        return label
    }()
    
    fileprivate lazy var barChartView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var titles: [String] = {
        let titles = [YXLanguageUtility.kLang(key: "markets_news_limit_down"), "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1", "0", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", YXLanguageUtility.kLang(key: "markets_news_limit_up")]
        return titles
    }()
    
    fileprivate lazy var topLabels: [UILabel] = {
        var labels = [UILabel]()
        for _ in 1...titles.count {
            labels.append(barChartLabel())
        }
        return labels
    }()
    
    fileprivate lazy var bottomLabels: [UILabel] = {
        var labels = [UILabel]()
        for _ in 1...titles.count {
            labels.append(barChartLabel())
        }
        return labels
    }()
    
    fileprivate lazy var fallLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_down")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var fallValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = QMUITheme().stockGreenColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var fallStayingLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_limit_down")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var fallStayingValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = QMUITheme().stockGreenColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var flatLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_flat")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var flatValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var suspendLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_suspended")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var suspendValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var goUpLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_up")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var goUpValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockRedColor()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "        "
        return label
    }()
    
    fileprivate lazy var goUpStayingLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_limit_up")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var goUpStayingValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = QMUITheme().stockRedColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    var overViewData: YXMarketRankCodeList? {
        didSet {
            updateData()
        }
    }
    
    func updateData() {
        fallValueLabel.textColor = QMUITheme().stockGreenColor()
        fallStayingValueLabel.textColor = QMUITheme().stockGreenColor()
        goUpValueLabel.textColor = QMUITheme().stockRedColor()
        goUpStayingValueLabel.textColor = QMUITheme().stockRedColor()
        
        let unit = YXLanguageUtility.kLang(key: "markets_news_homes")
        if let data = overViewData {
            fallValueLabel.text = "\(data.down ?? 0)\(unit)"
            fallStayingValueLabel.text = "\(data.limitDown ?? 0)\(unit)"
            flatValueLabel.text = "\(data.unchange ?? 0)\(unit)"
            suspendValueLabel.text = "\(data.suspend ?? 0)\(unit)"
            goUpValueLabel.text = "\(data.up ?? 0)\(unit)"
            goUpStayingValueLabel.text = "\(data.limitUp ?? 0)\(unit)"
            
            if var detailList = data.detail {
                // 插入跌停到首位
                detailList.insert(data.limitDown ?? 0, at: 0)
                // 插入涨停到末尾
                detailList.append(data.limitUp ?? 0)
                
                drawBarChart(titles: titles, values: detailList)
            }
        }
        
    }
    
    func drawBarChart(titles: [String], values: [Int]) {
        
        if values.count < 3 {
            return
        }
        let maxValue = Double(values.max() ?? 1)
        guard maxValue > 0 else { return }
        let count = Double(values.count)
        let leftMargin = 16.0 // 柱状图距离父视图左边距离
        let topMargin = 20.0  // 柱状图距离父视图顶部距离
        let bottomMargin = 20.0 // 柱状图距离父视图底部距离
        let barWidth = 10.0 // 柱子宽度
        let w: Double = Double(YXConstant.screenWidth) - (2.0 * leftMargin) - (count * barWidth) // 去掉柱状图左右边距和所有柱子宽度后剩下的宽度
        let distance: Double = w/(count - 1) // 得到柱子间的间距
        
        for layer in shapeLayers {
            layer.removeFromSuperlayer()
        }
        
        for (index, value) in values.enumerated() {
            let x = leftMargin + (barWidth + distance) * Double(index)
            let h = Double(value) * ((barChartViewHeight - topMargin - bottomMargin)/maxValue) // 需要根据最大值计算出每根柱子的高度
            let y = barChartViewHeight - h - bottomMargin // 柱子的Y坐标（这样才能使柱子的底部在一个水平上）
            let barRect = CGRect.init(x: x, y: y, width: barWidth, height: h)
            let path = UIBezierPath.init(rect: barRect)
        
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.clear.cgColor
            if (index < values.count/2) { // 左绿右红
                shapeLayer.fillColor = QMUITheme().stockGreenColor().cgColor
            }else {
                shapeLayer.fillColor = QMUITheme().stockRedColor().cgColor
            }
            
            barChartView.layer.addSublayer(shapeLayer)
            shapeLayers.append(shapeLayer)
            
            if index < titles.count {
                
                let topLabel = topLabels[index]
                topLabel.text = "\(value)"
                topLabel.frame = CGRect.init(x: barRect.origin.x, y: barRect.origin.y - 15.0, width: 30.0, height: 10.0)
                
                if topLabel.superview == nil {
                    barChartView.addSubview(topLabel)
                }
            }
            
            if index < titles.count {
                let bottomLabel = bottomLabels[index]
                bottomLabel.text = titles[index]
                var x = Double(barRect.origin.x)
                if index == 0 { // 第一个往左挪一点
                   x = x - 8
                }
                bottomLabel.frame = CGRect.init(x: x, y: (barChartViewHeight - 15.0), width: 20.0, height: 10.0)
                
                if index == 0 {
                    bottomLabel.textColor = QMUITheme().stockGreenColor()
                }else if index == titles.count - 1 {
                    bottomLabel.textColor = QMUITheme().stockRedColor()
                }
                
                if bottomLabel.superview == nil {
                    barChartView.addSubview(bottomLabel)
                }
            }
        }
    }
    
    func barChartLabel() -> UILabel {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        contentView.addSubview(barChartView)
        contentView.addSubview(fallLabel)
        contentView.addSubview(fallValueLabel)
        contentView.addSubview(fallStayingLabel)
        contentView.addSubview(fallStayingValueLabel)
        contentView.addSubview(flatLabel)
        contentView.addSubview(flatValueLabel)
        contentView.addSubview(suspendLabel)
        contentView.addSubview(suspendValueLabel)
        contentView.addSubview(goUpLabel)
        contentView.addSubview(goUpValueLabel)
        contentView.addSubview(goUpStayingLabel)
        contentView.addSubview(goUpStayingValueLabel)
        
        let width = YXConstant.screenWidth/3.0-20.0
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(18)
            make.top.equalTo(self).offset(15)
        }
        
        barChartView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(barChartViewHeight)
            make.bottom.equalTo(fallLabel.snp.top).offset(-30)
        }
        
        fallLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(barChartView.snp.bottom).offset(30)
            make.width.lessThanOrEqualTo(width)
        }
        
        fallValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(fallLabel)
            make.top.equalTo(fallLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
        fallStayingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(fallLabel)
            make.top.equalTo(fallValueLabel.snp.bottom).offset(10)
            make.width.lessThanOrEqualTo(width)
        }
        
        fallStayingValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(fallStayingLabel)
            make.top.equalTo(fallStayingLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
        flatLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).offset(-20)
            make.top.equalTo(fallLabel)
            make.width.lessThanOrEqualTo(width)
        }
        
        flatValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(flatLabel)
            make.top.equalTo(flatLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
        suspendLabel.snp.makeConstraints { (make) in
            make.left.equalTo(flatLabel)
            make.top.equalTo(fallStayingLabel)
            make.width.lessThanOrEqualTo(width)
        }
        
        suspendValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(suspendLabel)
            make.top.equalTo(suspendLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
        goUpLabel.snp.makeConstraints { (make) in
            make.left.equalTo(goUpValueLabel)
            make.top.equalTo(fallLabel)
            make.width.lessThanOrEqualTo(width)
        }
        
        goUpValueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-30)
            if YXUserManager.isENMode() {
                make.right.equalTo(self).offset(-40)
            }
            make.top.equalTo(goUpLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
        goUpStayingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(goUpValueLabel)
            make.top.equalTo(fallStayingLabel)
            make.width.lessThanOrEqualTo(width)
        }
        
        goUpStayingValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(goUpStayingLabel)
            make.top.equalTo(goUpStayingLabel.snp.bottom).offset(2)
            make.width.lessThanOrEqualTo(width)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
