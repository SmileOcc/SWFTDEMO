//
//  YXStockAnaylzeView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnaylzeBottomView: UIView {
    
    var jumpDetailCallBack: (() -> ())?
    
    let scoreLabel = QMUILabel.init(with: QMUITheme().themeTextColor(), font: .systemFont(ofSize: 18), text: "--")
    let titleLabel = QMUILabel.init(with: QMUITheme().themeTextColor(), font: UIFont.systemFont(ofSize: 18), text: YXLanguageUtility.kLang(key: "smart_ranking"))
    let iconImageView = UIImageView.init(image: UIImage(named: "analyze_score"))
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    let clickControl = UIControl.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        let arrowImageView = UIImageView.init()
        arrowImageView.image = UIImage(named: "market_more_arrow")
        
        clickControl.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        
        addSubview(lineView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(arrowImageView)
        addSubview(scoreLabel)
        addSubview(clickControl)
        
        lineView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(1)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(5)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-18)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        scoreLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-31)
            make.centerY.equalToSuperview()
        }
        
        clickControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func click(_ sender: UIControl) {
        self.jumpDetailCallBack?()
    }
}



class YXStockAnaylzeView: YXStockDetailBaseView {

    let radarView = YXRadarView.init()
    
    let scoreLabel = YYLabel.init()
    
    var jumpDetailCallBack: (() -> ())?
    
    let bottomView = YXStockAnaylzeBottomView.init()
    
    var model: YXStockAnalyzeModel? {
        
        didSet {
            
            let arr1 = [ self.getDoubleValue(self.model?.roeScore), self.getDoubleValue(self.model?.growthScore), self.getDoubleValue(self.model?.capacityScore), self.getDoubleValue(self.model?.rateDividendScore), self.getDoubleValue(self.model?.valuationScore), self.getDoubleValue(self.model?.trendScore), self.getDoubleValue(self.model?.capitalFlowsScore), self.getDoubleValue(self.model?.prospectScore) ]
            
            let arr2 = [ self.getDoubleValue(self.model?.avgRoeScore), self.getDoubleValue(self.model?.avgGrowthScore), self.getDoubleValue(self.model?.avgCapacityScore), self.getDoubleValue(self.model?.avgRateDividendScore), self.getDoubleValue(self.model?.avgValuationScore), self.getDoubleValue(self.model?.avgTrendScore), self.getDoubleValue(self.model?.avgCapitalFlowsScore), self.getDoubleValue(self.model?.prospectScore) ]
            
            let dic1 = [ "list": arr1,
                         "title": (self.model?.name ?? "--") ] as [String : Any]
            let dic2 = [ "list": arr2,
                         "title": YXLanguageUtility.kLang(key: "analytics_industry_average") ] as [String : Any]
            self.radarView.mixArr = [ dic1, dic2 ]
            
            var scoreStr = "--"
            if let score = self.model?.score {
                scoreStr = String.init(format: "%.2f", score / 100.0) + YXLanguageUtility.kLang(key: "smart_ranking_score")
            }
            
            self.bottomView.scoreLabel.text = scoreStr
        }
    }
    
    deinit {
       self.radarView.deleChartView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
//        radarView.jumpDetailCallBack = { [weak self] in
//            self?.jumpDetailCallBack?()
//        }
      
        addSubview(radarView)
        addSubview(bottomView)
        
        //bottomView.clickControl.isUserInteractionEnabled = false
        
        radarView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(340)
            if YXToolUtility.is4InchScreenWidth() {
                make.height.equalTo(280)
            } else {
                make.height.equalTo(340)
            }
            make.top.equalToSuperview().offset(10)
        }

        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        var list1 = [NSNumber]()
        var list2 = [NSNumber]()
        for _ in 0..<8 {
            list1.append(NSNumber.init(value: 0))
            list2.append(NSNumber.init(value: 0))
        }
        let dic1 = [ "list": list1,
                     "title": "--" ] as [String : Any]
        let dic2 = [ "list": list2,
                     "title": "行业均值" ] as [String : Any]
        self.radarView.mixArr = [ dic1, dic2 ]
    }

    func getDoubleValue(_ value: Double? ) -> NSNumber {
        if let value = value {
        
            return NSNumber.init(value: value / 100.0)
        }
        return NSNumber.init(value: 0)
    }
    
    @objc func arrowBtnClick(_ sender: UIButton) {
        self.jumpDetailCallBack?()
    }
    
    
}
