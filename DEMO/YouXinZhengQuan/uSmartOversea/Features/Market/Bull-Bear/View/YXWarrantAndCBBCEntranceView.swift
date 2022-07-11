//
//  YXWarrantAndCBBCEntranceView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantAndCBBCEntranceView: UIView {
    
    var tapWrrantAction: (() -> Void)?
    var tapInlineWarrantAction: (() -> Void)?
    
    lazy var warrant: YXWarrantsEntranceCell = {
        let warrant = YXWarrantsEntranceCell()
        warrant.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_bull_bear")
        warrant.iconImageView.image = UIImage.init(named: "stock_warrants")
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapWrrantAction {
                action()
            }
        }
        warrant.addGestureRecognizer(tap)
        return warrant
    }()
    
    lazy var inlineWarrant: YXWarrantsEntranceCell = {
        let inline = YXWarrantsEntranceCell()
        inline.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_inline_warrants")
        inline.iconImageView.image = UIImage.init(named: "inline_warrants")
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapInlineWarrantAction {
                action()
            }
        }
        inline.addGestureRecognizer(tap)
        return inline
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let topSepView = UIView()
        topSepView.backgroundColor = QMUITheme().backgroundColor()
        
        let bottomSepView = UIView()
        bottomSepView.backgroundColor = QMUITheme().backgroundColor()
        
        let line = UIView.line()
        
//        self.addSubview(topSepView)
        self.addSubview(warrant)
        self.addSubview(line)
        self.addSubview(inlineWarrant)
//        self.addSubview(bottomSepView)
        
//        topSepView.snp.makeConstraints { (make) in
//            make.left.top.right.equalToSuperview()
//            make.height.equalTo(10)
//        }
        
        warrant.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(line.snp.left)
            make.top.bottom.equalToSuperview()
            
        }
        
        line.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(1)
        }
        
        inlineWarrant.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(line.snp.right)
            make.top.equalTo(warrant)
            make.bottom.equalTo(warrant)
        }
        
//        bottomSepView.snp.makeConstraints { (make) in
//            make.left.bottom.right.equalToSuperview()
//            make.height.equalTo(10)
//        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
