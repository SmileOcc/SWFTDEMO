//
//  YXHotIndustryCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXHotIndustryCell: UITableViewCell, HasDisposeBag {

    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    fileprivate var linePatternLayer: CALayer?
    fileprivate var showLine: Bool = true
    var isDelay: Bool = false
    var onClickLeadStock: (() -> Void)?
    
    var config: YXNewStockMarketConfig
    
    func refreshUI(model: YXMarketRankCodeListInfo, isLast: Bool) {
        nameLabel.text = model.chsNameAbbr ?? "--"
        
        for label in self.labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model)
            }
        }
        
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXMarketRankCodeListInfo) {
        switch type {
        case .roc: //涨跌幅
            var op = ""
            if let roc = model.pctChng, roc > 0 {
                op = "+"
                label.textColor = QMUITheme().stockRedColor()
                label.textColor = QMUITheme().stockRedColor()
            } else if let roc = model.pctChng, roc < 0 {
                label.textColor = QMUITheme().stockGreenColor()
                label.textColor = QMUITheme().stockGreenColor()
            } else {
                label.textColor = QMUITheme().stockGrayColor()
                label.textColor = QMUITheme().stockGrayColor()
            }
            if let pctChng = model.pctChng {
                label.text = op + String(format: "%.2f%%", Double(pctChng)/100.0)
            }else {
                label.text = "--"
            }
        case .leadStock: //领涨股
            if let name = model.leadStock?.chsNameAbbr {
                label.text = name
                label.textColor = QMUITheme().textColorLevel1()
            }else {
                label.text = "--"
                label.textColor = QMUITheme().textColorLevel3()
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
        initializeViews()
    }
    
    func initializeViews() {
        
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(nameLabel)
        contentView.addSubview(bgView)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.config.itemMargin)
            make.top.equalToSuperview().offset(11)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
        }
        
        bgView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        
        let width = self.config.itemWidth
        for (index, type) in sortTypes.enumerated() {
            let label = QMUILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .right
            label.tag = type.rawValue
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8
            
            if type == .leadStock {
                label.font = .systemFont(ofSize: 14)
                label.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
                label.isUserInteractionEnabled = true
                _ = label.rx.tapGesture().skip(1).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](tap) in
                    if let action = self?.onClickLeadStock {
                        action()
                    }
                })
            }else {
                label.isUserInteractionEnabled = false
            }
            
            labels.append(label)
            bgView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 2)
                make.left.equalToSuperview().offset(width * CGFloat(index))
            }
        }
    }
    
    lazy var bgView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
