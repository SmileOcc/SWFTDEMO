//
//  YXHomeHoldOpenAccountCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXHomeHoldOpenAccountCell: UITableViewCell {

    @objc var openAction: (() -> Void)?

    @objc lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 14)
        lab.numberOfLines = 0
        return lab
    }()

    lazy var openBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "account_open"), for: .normal)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        _ = btn.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            self?.openAction?()
        })
        return btn
    }()

    func initUI()  {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F")
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }

        containerView.addSubview(titleLabel)
        containerView.addSubview(openBtn)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(openBtn.snp.left).offset(-20)
            make.height.greaterThanOrEqualTo(36)
            make.centerY.equalToSuperview()
        }

        openBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(79)
            make.height.equalTo(36)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
