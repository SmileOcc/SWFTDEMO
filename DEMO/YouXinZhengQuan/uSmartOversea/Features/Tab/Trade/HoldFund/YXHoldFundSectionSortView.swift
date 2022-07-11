//
//  YXHoldFundSectionSortView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHoldFundSectionSortView: UIView {
    
    var labels = [UILabel]()

    var config: YXNewStockMarketConfig!
    init(frame: CGRect, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        super.init(frame: frame)
        
        self.config = config
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        
        for (_, value) in sortTypes.enumerated() {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel3()
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.textAlignment = .right
            switch value {
            case .amountMoney:
                label.text =  YXLanguageUtility.kLang(key: "amount_of_moneny")
            case .yesterdayGains:
                label.text =  YXLanguageUtility.kLang(key: "warrants_yesterday_gains")
            case .holdGains:
                label.text =  YXLanguageUtility.kLang(key: "warrants_hold_gains")
            default:
                print("none")
            }
            labels.append(label)
        }
        initializeViews()
    }
    
    func initializeViews() {
        
        addSubview(nameLabel)
        addSubview(scrollView)
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.itemMargin)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.itemMargin)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
            make.top.bottom.right.equalToSuperview()
        }
        
        self.backgroundColor = QMUITheme().foregroundColor()
        let width = self.config.itemWidth
        for (index, button) in self.labels.enumerated() {
            scrollView.addSubview(button)
            //约束和 cell一致
            button.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 10)
                make.left.equalToSuperview().offset(width * CGFloat(index) + 10)
            }
        }
        
        scrollView.contentSize = CGSize(width: width * CGFloat(labels.count) + self.config.itemMargin, height: self.frame.height)
    }
    
    convenience init(sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        self.init(frame: CGRect.zero, sortTypes: sortTypes, config: config)
    }
    
    //MARK: lazy
    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.bounces = false
        return scrollview
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }

}
