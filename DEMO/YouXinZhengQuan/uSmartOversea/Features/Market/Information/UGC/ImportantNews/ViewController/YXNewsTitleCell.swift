//
//  YXNewsTitleCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsTitleCell: UICollectionViewCell {
    
    let label = YYLabel.init()
    
    
    var model: YXNewsTitleModel? {
        didSet {
            if let content = model?.content, content.count > 0, let fontSize = model?.fontSize {
                let att = NSMutableAttributedString.init(string: content)
                att.yy_lineSpacing = 5;
                att.yy_font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
                att.yy_color = QMUITheme().textColorLevel1()
                label.attributedText = att
            } else {
                label.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }
}
