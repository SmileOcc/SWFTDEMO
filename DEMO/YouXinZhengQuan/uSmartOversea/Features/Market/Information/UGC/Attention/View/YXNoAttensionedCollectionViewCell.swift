//
//  YXNoAttensionedCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNoAttensionedCollectionViewCell: UICollectionViewCell {

    lazy var emptyImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage.init(named: "no_data_follows")
        return view
    }()
    
    @objc lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.65)
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(109)
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(120)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
}
