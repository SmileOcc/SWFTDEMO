//
//  YXInfoCardBaseCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXInfoCardBaseCell: UITableViewCell {
    
    var bgView: YXStockCornerShadowView
    
    // 0 无边角  1 上  2 下
    var type = 0 {
        didSet {
            var topPadding: CGFloat = 0
            var bottomPadding: CGFloat = 0
            if type == 0 {
                bgView.topLeft = false
                bgView.topRight = false
                bgView.bottomLeft = false
                bgView.bottomRight = false
            } else if type == 1 {
                topPadding = 5
                bgView.topLeft = true
                bgView.topRight = true
                bgView.bottomLeft = false
                bgView.bottomRight = false
            } else if type == 2 {
                bgView.topLeft = false
                bgView.topRight = false
                bgView.bottomLeft = true
                bgView.bottomRight = true
                bottomPadding = 10
            }
            bgView.margins = UIEdgeInsets.init(top: topPadding, left: 18, bottom: bottomPadding, right: 18)
            contentView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(topPadding)
                make.bottom.equalToSuperview().offset(-bottomPadding)
            }
            self.setNeedsDisplay()
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        bgView = YXStockCornerShadowView.init()
        bgView.topLeft = false
        bgView.topRight = false
        bgView.bottomLeft = false
        bgView.bottomRight = false
        bgView.cornerRadius = 8
        bgView.shadowColor = QMUITheme().separatorLineColor()
        bgView.shadowOffset = CGSize.init(width: 0, height: -1)
        bgView.shadowRadius = 5
        bgView.margins = UIEdgeInsets.init(top: 0, left: 18, bottom: 0, right: 18)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSuperUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSuperUI() {
        
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().backgroundColor()
        
        contentView.addSubview(bgView)
        
        contentView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
