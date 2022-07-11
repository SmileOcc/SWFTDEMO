//
//  YXHoldListHeaderView.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHoldListHeaderView: UIView {
    
    var lrMargin: Int {
        if YXConstant.screenWidth == 320 {
            return 6
        } else {
            return 18
        }
    }
    
    fileprivate lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        return label
    }()
    
    fileprivate lazy var costLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "hold_cost")
        label.textAlignment = .right;
        
        return label
    }()
    
    fileprivate lazy var profitLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "hold_position_profit_loss")
        label.textAlignment = .right;
        return label
    }()
    
    fileprivate lazy var numLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "hold_num")
        label.textAlignment = .right;
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        
        addSubview(lineView)
        addSubview(nameLabel)
        addSubview(costLabel)
        addSubview(profitLabel)
        addSubview(numLabel)
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalTo(self)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lrMargin)
            make.centerY.equalTo(self)
        }
        
        profitLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-152 - lrMargin)
            make.centerY.equalTo(self)
        }
        
        costLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-76 - lrMargin)
            make.centerY.equalTo(self)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-lrMargin)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
