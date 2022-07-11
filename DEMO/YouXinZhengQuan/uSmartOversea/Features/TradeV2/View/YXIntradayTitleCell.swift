//
//  YXIntradayTitleCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayTitleCell: YXTableViewCell {
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20)
        
        return label
    }()
    
    lazy var subTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 14)
        
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func initialUI() {
        super.initialUI()
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(lineView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(7)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(28)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(1)
            make.height.equalTo(18)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    
    override func refreshUI() {
        super.refreshUI()
        
    }
}
