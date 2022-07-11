//
//  YXStatementHeaderFooterView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementHeaderFooterView: UITableViewHeaderFooterView {
    

    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .mediumFont12()
        
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().backgroundColor()
        contentView.backgroundColor = QMUITheme().backgroundColor()
        
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
    }

}
