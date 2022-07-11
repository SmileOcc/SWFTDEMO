//
//  StockDetailDividensSectionHeader.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StockDetailDividensSectionHeader: UITableViewHeaderFooterView {

    lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont16()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var valueLabel:UILabel = {
        let label = UILabel.init()
        label.font = .mediumFont16()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        initSubviews()
  
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        contentView.addSubview(yearLabel)
        yearLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.left.equalTo(16)
        }
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.right.equalTo(-16)
        }
        
        let lineView = UIView.init()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

    }

}

