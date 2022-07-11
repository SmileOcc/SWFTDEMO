//
//  YXNewStockDeliveredListCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockDeliveredListCell: UITableViewCell {
    
    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    fileprivate var linePatternLayer: CALayer?
    fileprivate var showLine: Bool = true
    var isDelay: Bool = false

    var config: YXNewStockMarketConfig
    
    func refreshUI(model: YXNewStockDeliveredInfo, isLast: Bool) {
        
        nameLabel.text = model.applyCompnay ?? "--"
        
        if let booked = model.booked {
            
            statusLabel.isHidden = !booked
            
            if !booked, model.subscribeFlag == 1, model.subscribeStatus == 20 {
                subLabel.isHidden = false
            } else {
                subLabel.isHidden = true
            }
            
        } else {
            statusLabel.isHidden = true
            subLabel.isHidden = true
        }
        
      
        for label in self.labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model)
            }
        }
    
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXNewStockDeliveredInfo) {
        switch type {
        case .deliverApplyDate: //申请日期
            if let applyDate = model.applyDate {
                if applyDate.count >= 10 {
                    label.text = applyDate.subString(toCharacterIndex: 10)
                } else {
                    label.text = applyDate
                }
            }
        case .deliverStatus: //状态
            label.text = model.statusName ?? ""
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
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(scrollView)
        contentView.addSubview(subLabel)
        
        let line = UIView.line()
        contentView.addSubview(line)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.config.itemMargin)
            make.top.equalToSuperview().offset(11)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(7)
        }
        
        subLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
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
            label.textAlignment = .center
            label.tag = type.rawValue
            label.numberOfLines = (YXUserManager.isENMode()) ? 2 : 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.6
            
            labels.append(label)
            scrollView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel)
                make.width.lessThanOrEqualTo(width - 8)
                make.right.equalToSuperview().offset(width * CGFloat(index + 1))
            }
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(labels.count), height: self.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    lazy var statusLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = UIColor.qmui_color(withHexString: "#5B3BE8")
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.qmui_color(withHexString: "#5B3BE8")?.cgColor
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        label.text = YXLanguageUtility.kLang(key: "already_reserved")
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        label.isHidden = true
        return label
    }()
    
    lazy var subLabel: UIView = {
        let layerView = UIView()
        layerView.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.05, green: 0.75, blue: 0.95, alpha: 1).cgColor, UIColor(red: 0.33, green: 0.35, blue: 0.94, alpha: 1).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = layerView.bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: -0.4)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        bgLayer1.cornerRadius = 4
        bgLayer1.masksToBounds = true
        
        layerView.layer.cornerRadius = 4
        layerView.layer.masksToBounds = true
        layerView.layer.addSublayer(bgLayer1)
        
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = QMUITheme().foregroundColor()
        label.textAlignment = .center
        layerView.addSubview(label)
        
        if YXUserManager.isHighWorth() {
            label.text = YXLanguageUtility.kLang(key: "ecm_book")
        } else {
            label.text = YXLanguageUtility.kLang(key: "see_detail")
        }
        
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return layerView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
