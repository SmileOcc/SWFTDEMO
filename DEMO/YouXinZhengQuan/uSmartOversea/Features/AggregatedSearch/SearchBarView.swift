//
//  SearchBarView.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/15.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBarView: UIView {

    lazy var textField: QMUITextField = {
        let textField = QMUITextField()
        textField.layer.cornerRadius = 6
        textField.layer.masksToBounds = true
        textField.returnKeyType = .search
        textField.textInsets = UIEdgeInsetsSetLeft(textField.textInsets, 0)

        let backgroundColor =
            YXThemeTool.isDarkMode() ? UIColor.qmui_color(withHexString: "#19191F") : UIColor.qmui_color(withHexString: "#F8F9FC")
        textField.backgroundColor = backgroundColor

        textField.font = .systemFont(ofSize: 14)

        textField.clearButtonMode = .whileEditing
        textField.qmui_clearButtonImage = UIImage(named: "login_clean")

        textField.textColor = QMUITheme().textColorLevel1()
        textField.placeholder = ""
        textField.placeholderColor = QMUITheme().textColorLevel2()
        if #available(iOS 13.0, *) {
            Thread.current.qmui_shouldIgnoreUIKVCAccessProhibited = true
        }
        if #available(iOS 13.0, *) {
            Thread.current.qmui_shouldIgnoreUIKVCAccessProhibited = false
        }

        let iconView = UIImageView()
        iconView.image = UIImage(named: "icon_search")
        iconView.contentMode = .center
        iconView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
        textField.leftView = iconView
        textField.leftViewMode = .always

        return textField
    }()

    lazy var cancelBtn: QMUIButton = {
        let button = QMUIButton(type: .custom)
        button.setTitle(YXLanguageUtility.kLang(key: "search_cancel"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.titleLabel?.font = .normalFont16()
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textField)
        addSubview(cancelBtn)

        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(cancelBtn.snp.left).offset(-12)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }

        cancelBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let backgroundColor =
            YXThemeTool.isDarkMode() ? UIColor.qmui_color(withHexString: "#19191F") : UIColor.qmui_color(withHexString: "#F8F9FC")
        textField.backgroundColor = backgroundColor
    }

}
