//
//  YXMarketStareCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketStareCell: UICollectionViewCell {
    
    @objc var model: YXStareSignalModel? {
        didSet {
            view.model = self.model
        }
    }
    
    var view = YXStareHomeView.init(frame: .zero, isMarketPage: true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        
        let bgView = UIView.init()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(bgView)
        bgView.addSubview(view)
        
        bgView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview()
        }
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
