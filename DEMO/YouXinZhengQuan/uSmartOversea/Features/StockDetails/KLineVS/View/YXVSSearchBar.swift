//
//  YXVSSearchBar.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXVSSearchBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = UIColor.qmui_color(withHexString: "#F8F8F8")
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true

        addSubview(iconImageView)
        addSubview(textField)

        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(20)
        }

        textField.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(45)
        }
    }

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "icon_search")
        return imageView
    }()

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
//        textField.font = UIFont.systemFont(ofSize: 14)
//        textField.textColor = QMUITheme().textColorLevel1()
//        textField.textAlignment = .left
//        textField.adjustsFontSizeToFitWidth = true
//        textField.minimumFontSize = 0.8
//
//        textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)
        return textField
    }()
}

