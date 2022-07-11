//
//  SearchQuoteCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchQuoteCell: SearchBaseCell {

    lazy var marketImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 14.0 / 16
        return label
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()

    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "new_like_unselect"), for: .normal)
        button.setImage(UIImage(named: "new_like_select"), for: .selected)
        button.addTarget(self, action: #selector(clickAddButton(_:)), for: .touchUpInside)
        return button
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(nameLabel)
        contentView.addSubview(marketImageView)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(addButton)

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.right.lessThanOrEqualTo(addButton.snp.left).offset(-12)
        }

        marketImageView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.centerY.equalTo(symbolLabel)
            make.width.equalTo(16)
            make.height.equalTo(12)
        }

        symbolLabel.snp.makeConstraints { make in
            make.left.equalTo(marketImageView.snp.right).offset(2)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
            make.width.height.equalTo(30)
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchQuoteCellViewModel else {
            return
        }

        marketImageView.image = UIImage(named: cellViewModel.model.market.lowercased())

        nameLabel.attributedText = cellViewModel.attributedName
        nameLabel.lineBreakMode = .byTruncatingTail

        symbolLabel.attributedText = cellViewModel.attributedSymbol

        let secu = YXSecu()
        secu.symbol = cellViewModel.model.symbol
        secu.name = cellViewModel.model.name
        secu.type1 = cellViewModel.model.type1
        secu.type2 = cellViewModel.model.type2
        secu.type3 = cellViewModel.model.type3
        secu.market = cellViewModel.model.market
        addButton.isSelected = YXSecuGroupManager.shareInstance().containsSecu(secu)
    }

    @objc private func clickAddButton(_ sender: UIButton) {
        guard let cellViewModel = model as? SearchQuoteCellViewModel else {
            return
        }

        let secu = YXOptionalSecu()
        secu.symbol = cellViewModel.model.symbol
        secu.name = cellViewModel.model.name
        secu.type1 = cellViewModel.model.type1
        secu.type2 = cellViewModel.model.type2
        secu.type3 = cellViewModel.model.type3
        secu.market = cellViewModel.model.market

        if sender.isSelected {
            YXSecuGroupManager.shareInstance().remove(secu)
            sender.isSelected = false
        } else {
            YXToolUtility.addSelfStockToGroup(secu: secu) { successs in
                if successs {
                    sender.isSelected = true
                }
            }
        }
    }

}
