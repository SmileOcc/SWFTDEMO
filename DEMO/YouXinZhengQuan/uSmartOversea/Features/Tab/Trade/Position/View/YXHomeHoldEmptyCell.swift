//
//  YXHomeHoldEmptyCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXHomeHoldEmptyCell: YXTableViewCell {

    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = YXDefaultEmptyEnums.noPositon.image()
        imageView.sizeToFit()
        return imageView
    }()

    @objc lazy var emptyTipLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = YXDefaultEmptyEnums.noPositon.tip()
        return label
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

        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(emptyImageView)
        contentView.addSubview(emptyTipLabel)

        emptyImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(8)
        }

        emptyTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
        }

    }
    
}
