//
//  YXNewWarrantsSubFundFlowCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNewWarrantsSubFundFlowCell: UICollectionViewCell {
    
    var priceBase: Int = 0
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var inLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "analytics_money_inflow")
        return label
    }()
    
    lazy var outLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "analytics_money_outflow")
        return label
    }()
    
    lazy var inValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var outValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var data: YXWarrantCBBCFundFlowItem? {
        didSet {
            if let model = data {
//                titleLabel.text = model.type.text
                
                let inArrtStr = YXToolUtility.stocKNumberData(model.inflow, deciPoint: 2, stockUnit: "", priceBase: priceBase, number: .systemFont(ofSize: 14), unitFont: .systemFont(ofSize: 14))
                inValueLabel.attributedText = inArrtStr//addColor(color: QMUITheme().stockRedColor(), toAttrStr: inArrtStr)
                
                let outAttrStr = YXToolUtility.stocKNumberData(model.out, deciPoint: 2, stockUnit: "", priceBase: priceBase, number: .systemFont(ofSize: 14), unitFont: .systemFont(ofSize: 14))
                outValueLabel.attributedText = outAttrStr//addColor(color: QMUITheme().stockGreenColor(), toAttrStr: outAttrStr)
            }
        }
    }
    
    func addColor(color: UIColor, toAttrStr attrStr: NSAttributedString?) -> NSAttributedString? {
        if let attrStr = attrStr {
            let ori = NSMutableAttributedString.init(attributedString: attrStr)
            ori.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSMakeRange(0, ori.length))
            return ori
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        //let scale = YXConstant.screenWidth/375.0
        
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(inLabel)
        contentView.addSubview(inValueLabel)
        contentView.addSubview(outLabel)
        contentView.addSubview(outValueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        inLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        inValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(self.contentView.snp.centerX).offset(-2)
            make.top.equalTo(inLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
        
//        outLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-27.0*scale)
//            make.top.equalTo(inLabel)
//        }
        outLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.centerX).offset(2)
            make.top.equalTo(inLabel)
        }
        
        outValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outLabel)
            make.right.equalToSuperview()
            make.top.equalTo(inValueLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
