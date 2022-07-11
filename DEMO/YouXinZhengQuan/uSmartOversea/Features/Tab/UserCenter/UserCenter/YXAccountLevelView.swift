//
//  YXAccountLevelView.swift
//  uSmartOversea
//
//  Created by ysx on 2022/1/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

extension YXAccountLevelType{
    func title() -> String {
        switch self {
        case .trade:
            return YXLanguageUtility.kLang(key: "mine_account_trade_lv")
        case .stantard:
            return YXLanguageUtility.kLang(key: "mine_account_standart_lv")
        case .intel:
            return YXLanguageUtility.kLang(key: "mine_account_intel_lv")
        case .unkonw:
            return ""
        }
    }
    
    func icon() -> UIImage? {
        
        switch self {
        case .trade:
            return UIImage.init(named: "account_trade_icon")
        case .stantard:
            return UIImage.init(named: "account_standart_icon")
        case .intel:
            return UIImage.init(named: "account_intel_icon")
        case .unkonw:
            return nil
        }
    }
    func bgImage() -> UIImage? {
        switch self {
        case .trade:
            return UIImage.init(named: "account_trade_bg")
        case .stantard:
            return UIImage.init(named: "account_standar_bg")
        case .intel:
            return UIImage.init(named: "account_intel_bg")
        case .unkonw:
            return nil
        }
    }
    
    func arrowImage() -> UIImage? {
        switch self {
        case .trade:
            return UIImage.init(named: "mine_update_arrow_trade")
        case .stantard:
            return UIImage.init(named: "mine_update_arrow_standar")
        case .intel:
            return UIImage.init(named: "mine_update_arrow_intel")
        case .unkonw:
            return nil
        }
    }

    
    func detailColor() -> UIColor? {
        switch self {
        case .trade:
            return UIColor.qmui_color(withHexString: "#1755A2")?.withAlphaComponent(0.85)
        case .stantard:
            return UIColor.qmui_color(withHexString: "#213A58")?.withAlphaComponent(0.65)
        case .intel:
            return UIColor.qmui_color(withHexString: "#622F02")?.withAlphaComponent(0.65)
        case .unkonw:
            return nil
        }
    }
    
    func titleColor() -> UIColor? {
        switch self {
        case .trade:
            return UIColor.qmui_color(withHexString: "#1755A2")
        case .stantard:
            return UIColor.qmui_color(withHexString: "#213A58")
        case .intel:
            return UIColor.qmui_color(withHexString: "#622F02")
        case .unkonw:
            return nil
        }
    }
    
    func jampUrl() -> String {
        YXH5Urls.accountDetailUrl(accountType: self.rawValue)
    }
    
    func detailTip() -> String {
        switch self {
        case .trade,
             .stantard:
            return YXLanguageUtility.kLang(key: "account_to_upgrade")
        case .intel:
            return YXLanguageUtility.kLang(key: "account_to_detail")
        case .unkonw:
            return ""
        }
    }
}

class YXAccountLevelView: UIView {

    static var height : CGFloat {
        get {
            if YXUserManager.canTrade() && accountType != .unkonw {
             return  64
            }else {
             return  0
            }
        }
    }
    
    static var accountType : YXAccountLevelType = .unkonw
    
    
    typealias Click = ((_ type:YXAccountLevelType)->())
    
    var onClick:Click?
    
    var type:YXAccountLevelType {
        didSet{
            refreshUI()
        }
    }
    
    lazy var bgImageView : UIImageView = {
       let imageView = UIImageView()
       return imageView
    }()
    
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        return lab
    }()
    
    private lazy var detailBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_account_viwe_detail"), for: .normal)
        btn.imagePosition = .right
        btn.spacingBetweenImageAndTitle = 4
        btn.setImage(UIImage.init(named: "mine_update_arrow"), for: .normal)
        return btn
    }()
    
    lazy var iconView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        type = .unkonw
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func refreshUI(){
        titleLabel.text = type.title()
        titleLabel.textColor = type.titleColor()
        
        iconView.image = type.icon()
        bgImageView.image = type.bgImage()
        
        detailBtn.setTitleColor(type.detailColor(), for: .normal)
        detailBtn.setTitle(type.detailTip(), for: .normal)
        detailBtn.setImage(type.arrowImage(), for: .normal)

        
        if type == .unkonw {
            self.isHidden = true
        }else {
            self.isHidden = false
        }
    }
    
    func setupUI() {
        isUserInteractionEnabled = true
        addSubview(bgImageView)
        bgImageView.addSubview(titleLabel)
        bgImageView.addSubview(iconView)
        bgImageView.addSubview(detailBtn)
        
        bgImageView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(4)
        }
        
        detailBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        tap.addActionBlock {[weak self] _ in
            guard let `self` = self else { return }
            self.onClick?(self.type)
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
