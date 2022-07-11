//
//  YXNewsContentCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsRichTextContentCell: UICollectionViewCell {
    
    var attText: NSAttributedString? {
        didSet {
            if let att = attText {
                richView.attText = att
            }
        }
    }
    
    let richView = YXRichTextView()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        contentView.addSubview(richView)
        richView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

