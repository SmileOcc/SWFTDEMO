//
//  YXCryptosTableViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCryptosTableViewCell: UITableViewCell {
    
    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    var isDelay: Bool = false
    var config: YXNewStockMarketConfig
    
    
    func refreshUI(model: YXV2Quote, isLast: Bool) {
        
        nameLabel.text = model.btInfo?.name ?? "--"
        codeLabel.text = model.btInfo?.displayedSymbol ?? "--"
        if let url = model.btInfo?.iconUrl {
            iconImageView.sd_setImage(with: URL.init(string: url), completed: nil)
        }
        
        for label in self.labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model)
            }
        }
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXV2Quote) {
        switch type {
        
        case .now: //最新价
            if let latestPrice = model.btRealTime?.now {
                label.text = YXToolUtility.btNumberString(latestPrice)
            }
            
            if let roc = model.btRealTime?.pctchng, let rocValue = Double(roc) {
                label.textColor = YXStockColor.currentColor(rocValue)
            } else {
                label.textColor = QMUITheme().stockGrayColor()
            }
            
        case .roc:
            if let roc = model.btRealTime?.pctchng, let rocValue = Double(roc) {
                label.text = String(format: "%@%@%%", rocValue > 0 ? "+" : "", roc)
                label.textColor = YXStockColor.currentColor(rocValue)
            } else {
                label.textColor = QMUITheme().stockGrayColor()
            }
            
        default:
            break
        }
    }
    
    //MARK: initialization Method
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        
        self.sortTypes = sortTypes
        self.config = config
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        initializeViews()
    }
    
    func initializeViews() {
        
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(codeLabel)
        contentView.addSubview(scrollView)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        codeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin - self.config.itemMargin - 48)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(codeLabel)
            make.bottom.equalTo(iconImageView)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin - self.config.itemMargin - 48)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        
        let width = self.config.itemWidth
        for (index, type) in sortTypes.enumerated() {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .right
            label.tag = type.rawValue
            
            labels.append(label)
            scrollView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 2)
                make.left.equalToSuperview().offset(width * CGFloat(index))
            }
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(labels.count) + self.config.itemMargin, height: self.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
