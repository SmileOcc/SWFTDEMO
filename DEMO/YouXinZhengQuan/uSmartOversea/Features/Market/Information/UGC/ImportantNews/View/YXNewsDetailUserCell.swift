//
//  YXNewsDetailUserCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsDetailUserCell: UICollectionViewCell {
    
    
    var model: YXNewsDetailUserModel? {
        
        didSet {
            self.userView.userModel = model?.userModel
            self.userView.descLabel.text = model?.descText
        }
    }
    
    
    let userView = YXUGCPublisherView.init(style: .normal)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        contentView.addSubview(userView)
        userView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
