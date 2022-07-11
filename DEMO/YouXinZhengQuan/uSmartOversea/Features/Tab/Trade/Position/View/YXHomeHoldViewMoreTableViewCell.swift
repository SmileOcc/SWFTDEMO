//
//  YXHomeHoldViewMoreTableViewCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/26.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXHomeHoldViewMoreTableViewCell: UITableViewCell {

    @objc var expandButtonAction: ((_ isExpand: Bool) -> Void)?

    @objc lazy var expandButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: 0, left: -20, bottom: -20, right: -10)
        button.setImage(UIImage(named: "hold_view_more"), for: .normal)
        button.setImage(UIImage(named: "hold_view_more_close"), for: .selected)
        button.setTitle(YXLanguageUtility.kLang(key: "nbb_viewall"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "close_title"), for: .selected)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 2
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10)
        button.backgroundColor = UIColor.themeColor(withNormalHex: "#EAEAEA", andDarkColor: "#212129")
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = QMUITheme().foregroundColor()
        selectionStyle = .none

        contentView.addSubview(expandButton)
        expandButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }

        _ = contentView.rx.tapGesture().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            guard let `self` = self else { return }
            self.expandButton.isSelected = !self.expandButton.isSelected
            self.expandButtonAction?(self.expandButton.isSelected)
        })
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
