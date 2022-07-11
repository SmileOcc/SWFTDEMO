//
//  YXShareOptinosCurrentPriceCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptinosCurrentPriceCell: UITableViewCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().foregroundColor()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
