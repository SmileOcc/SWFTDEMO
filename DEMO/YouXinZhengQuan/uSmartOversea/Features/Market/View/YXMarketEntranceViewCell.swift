//
//  YXMarketEntranceViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXMarketEntranceViewCell: UICollectionViewCell, HasDisposeBag {
    lazy var icon: UIImageView = {
        let imageV = UIImageView()
        return imageV
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        icon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
