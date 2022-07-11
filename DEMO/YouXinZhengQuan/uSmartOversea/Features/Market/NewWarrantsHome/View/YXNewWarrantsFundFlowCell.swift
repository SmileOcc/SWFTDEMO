//
//  YXNewWarrantsFundFlowCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNewWarrantsFundFlowCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "quote_hk_warrants_tip")
        label.numberOfLines = 2
        return label
    }()
    
    lazy var longPositionItem: YXPositionItemView = {
        let view = YXPositionItemView()
        view.positionType = "long"
        return view
    }()
    
    lazy var shortPositionItem: YXPositionItemView = {
        let view = YXPositionItemView()
        view.positionType = "short"
        return view
    }()
    
    var data: YXWarrantCBBCFundFlowResModel? {
        didSet {
            if let model = data {
                let longColor = model.longPosNetInflow >= 0 ? QMUITheme().stockRedColor() : QMUITheme().stockGreenColor()
                let shortColor = model.shortPosNetInflow >= 0 ? QMUITheme().stockRedColor() : QMUITheme().stockGreenColor()
                longPositionItem.positionValueLabel.attributedText = YXToolUtility.stocKNumberData(model.longPosNetInflow, deciPoint: 2, stockUnit: "", priceBase: model.priceBase, number: .systemFont(ofSize: 16, weight: .medium), unitFont: .systemFont(ofSize: 16, weight: .medium), color: longColor)
                shortPositionItem.positionValueLabel.attributedText = YXToolUtility.stocKNumberData(model.shortPosNetInflow, deciPoint: 2, stockUnit: "", priceBase: model.priceBase, number: .systemFont(ofSize: 16, weight: .medium), unitFont: .systemFont(ofSize: 16, weight: .medium), color: shortColor)
                
                for item in model.capFlow {
                    switch item.type {
                    case .buy:
                        longPositionItem.flowItem1.priceBase = model.priceBase
                        longPositionItem.flowItem1.data = item
                    case .bull:
                        longPositionItem.flowItem2.priceBase = model.priceBase
                        longPositionItem.flowItem2.data = item
                    case .sell:
                        shortPositionItem.flowItem1.priceBase = model.priceBase
                        shortPositionItem.flowItem1.data = item
                    case .bear:
                        shortPositionItem.flowItem2.priceBase = model.priceBase
                        shortPositionItem.flowItem2.data = item
                    default:
                        break
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(longPositionItem)
        contentView.addSubview(shortPositionItem)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        longPositionItem.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(contentView.snp.centerX).offset(-8)
            make.height.equalTo(273)
        }
        
        shortPositionItem.snp.makeConstraints { (make) in
            make.top.height.equalTo(longPositionItem)
            make.right.equalToSuperview().offset(-16)
            make.left.equalTo(contentView.snp.centerX).offset(8)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXPositionItemView: UIView {
    // long short
    var positionType: String = "long" {
        didSet {
            if positionType == "long" {
                containerView.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.1)
                positionLabel.text = YXLanguageUtility.kLang(key: "longposition_capital_inflows")
                flowItem1.titleLabel.text = YXLanguageUtility.kLang(key: "bullbear_call_mark")
                flowItem1.titleLabel.textColor = QMUITheme().stockRedColor()
                flowItem2.titleLabel.text = YXLanguageUtility.kLang(key: "bullbear_bull_mark")
                flowItem2.titleLabel.textColor = QMUITheme().stockRedColor()
            }else {
                containerView.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.1)
                positionLabel.text = YXLanguageUtility.kLang(key: "shortpoition_capital_inflows")
                flowItem1.titleLabel.text = YXLanguageUtility.kLang(key: "bullbear_put_mark")
                flowItem1.titleLabel.textColor = QMUITheme().stockGreenColor()
                flowItem2.titleLabel.text = YXLanguageUtility.kLang(key: "bullbear_bear_mark")
                flowItem2.titleLabel.textColor = QMUITheme().stockGreenColor()
            }
        }
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    lazy var positionValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        return label
    }()
    
    lazy var flowItem1: YXNewWarrantsSubFundFlowCell = {
        return YXNewWarrantsSubFundFlowCell()
    }()
    
    lazy var flowItem2: YXNewWarrantsSubFundFlowCell = {
        return YXNewWarrantsSubFundFlowCell()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = QMUITheme().pointColor().cgColor
        
        containerView.addSubview(positionLabel)
        containerView.addSubview(positionValueLabel)
        
        addSubview(containerView)
        addSubview(flowItem1)
        addSubview(flowItem2)
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(87)
        }
        
        positionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        positionValueLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(positionLabel.snp.bottom).offset(12)
        }
        
        flowItem1.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(containerView.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(62)
        }
        
        flowItem2.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(flowItem1.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(62)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
