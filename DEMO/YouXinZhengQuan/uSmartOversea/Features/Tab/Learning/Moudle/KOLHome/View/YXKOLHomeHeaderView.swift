//
//  YXKOLHomeHeaderView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit

class YXKOLHomeHeaderView: UIView {
    
    var isExpand: Bool = false {
        didSet {
            if isExpand {
                self.desLabel.numberOfLines = 5
            } else {
                self.desLabel.numberOfLines = 2
            }
            self.desLabel.text = self.desLabel.text
            self.desLabel.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        view.layer.cornerRadius = 6
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var kolHeaderView: UIImageView = {
        let image = UIImageView()
//        image.qmui_borderWidth = 2
//        image.qmui_borderColor = UIColor.white
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = 45.2
        image.layer.masksToBounds = true
        return image
    }()
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var desLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var followBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setBackgroundImage(UIImage(color: QMUITheme().mainThemeColor()), for: .normal)
//        btn.setBackgroundImage(UIImage(color:  QMUITheme().mainThemeColor().withAlphaComponent(0.1)), for: .selected)
        btn.setBackgroundImage(UIImage.init(color:  UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#F8F9FC")), for: .selected)

        
        btn.setTitle("+ \(YXLanguageUtility.kLang(key: "nbb_btn_follow"))", for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_btn_following"), for: .selected)
        btn.setTitleColor(QMUITheme().textColorLevel4(), for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        btn.setBackgroundImage(UIImage.init(color: QMUITheme().mainThemeColor()), for: .normal)
        btn.setBackgroundImage(UIImage.init(color:  UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#212129")), for: .selected)
        return btn
    }()
    
    lazy var askBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "kol_home_ask_icon"), for: .normal)
        btn.backgroundColor = UIColor(hexString: "F9A800")        
        btn.setTitleColor(.white, for: .normal)
        btn.cornerRadius = 4
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_title_ask"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return btn
    }()
    
    lazy var expandBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        btn.setTitleColor(QMUITheme().mainThemeColor(), for: .selected)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_see_more"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_see_less"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        btn.imagePosition = .right
        return btn
    }()
    
    lazy var vipLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    var isShowTipsView: Bool = false {
        didSet {
            bgView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(isShowTipsView ? -36 : 0)
            }
        }
    }
    
    lazy var tipsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F8EAD9")
        view.addSubview(vipLabel)
        vipLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addKolTags(tags: [YXKOLHomeTagType]) {
        desLabel.snp.updateConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(tags.count > 0 ? 32 : 8)
        }
        var paddingView: UIView?
        for tag in tags {
            let view = tag.tagImage()
            bgView.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(8)
                if paddingView == nil {
                    make.left.equalToSuperview().offset(16)
                } else {
                    make.left.equalTo(paddingView!.snp.right).offset(8)
                }
            }
            paddingView = view
        }
    }
    
    func setupUI() {
        addSubview(tipsView)
        addSubview(bgView)
        addSubview(kolHeaderView)

        bgView.addSubview(nameLabel)
        bgView.addSubview(desLabel)
        bgView.addSubview(followBtn)
        bgView.addSubview(askBtn)
        bgView.addSubview(expandBtn)
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().backgroundColor()
        
        bgView.addSubview(lineView)
        
        expandBtn.snp.makeConstraints { make in
            make.left.equalTo(desLabel.snp.left)
            make.top.equalTo(desLabel.snp.bottom).offset(4)
        }
        
        followBtn.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.right.equalTo(askBtn.snp.left).offset(-16)
            make.top.equalToSuperview().offset(18)
            make.width.equalTo(86)
        }
        
        askBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
            make.width.equalTo(68)
        }
        
        kolHeaderView.snp.makeConstraints { make in
            make.centerY.equalTo(bgView.snp.top)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(94)
        }
        
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(124-YXConstant.statusBarHeight())
            make.bottom.equalToSuperview()
        }
        
        tipsView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(36)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(kolHeaderView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(16)
        }
        
        desLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        lineView.snp.remakeConstraints { make in
            make.height.equalTo(8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
