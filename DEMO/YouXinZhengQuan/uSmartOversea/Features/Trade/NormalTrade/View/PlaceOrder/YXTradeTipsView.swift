//
//  YXTradeTipsView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeTipsView: UIView, YXTradeHeaderSubViewProtocol {

    private lazy var tipsLabel: UILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ tips: String) {
        if tips.count > 0 {
            tipsLabel.text = tips
            isHidden = false
            contentHeight = max(20, tips.height(.systemFont(ofSize: 12), limitWidth: width - 32) + 10)
        } else {
            isHidden = true
            contentHeight = 0
        }
    }
    
//    initwi {
//        self.init()
//
//        self.isCondition = isCondition
//        self.params = params
//
//        addSubview(tipsLabel)
//        if isCondition {
//            tipsLabel.textAlignment = .right
//        }
//
//        tipsLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(4)
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//        }
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
