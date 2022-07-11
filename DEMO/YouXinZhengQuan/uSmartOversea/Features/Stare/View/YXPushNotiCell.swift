//
//  YXPushNotiCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPushNotiBtn: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        self.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
        
        self.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "FFFFFF")), for: .normal)
        self.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "2F79FF")?.withAlphaComponent(0.1)), for: .selected)
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = self.isSelected
            if self.isSelected {
                self.layer.borderColor = UIColor.clear.cgColor
            } else {
                self.layer.borderColor = QMUITheme().textColorLevel4().cgColor
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXPushNotiCell: UITableViewCell {
    
    @objc var yxNotiBtn: YXPushNotiBtn
    @objc var wetchatNotiBtn: YXPushNotiBtn
    
    @objc var clickBtnCallBack: ((_ isYxPush: Bool) -> ())?
    
    @objc var bindWetChatCallBack: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.yxNotiBtn = YXPushNotiBtn.init(type: .custom)
        self.wetchatNotiBtn = YXPushNotiBtn.init(type: .custom)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
        self.yxNotiBtn.setTitle(YXLanguageUtility.kLang(key: "push_type_app"), for: .normal)
        self.wetchatNotiBtn.setTitle(YXLanguageUtility.kLang(key: "push_type_wechat"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension YXPushNotiCell {
    func initUI() {
        
        self.yxNotiBtn.addTarget(self, action: #selector(self.selectBtnDidClick(_:)), for: .touchUpInside)
        self.wetchatNotiBtn.addTarget(self, action: #selector(self.selectBtnDidClick(_:)), for: .touchUpInside)
        self.selectionStyle = .none
//        self.yxNotiBtn.isSelected = true
//        self.wetchatNotiBtn.isSelected = false
        contentView.addSubview(self.yxNotiBtn)
        contentView.addSubview(self.wetchatNotiBtn)
        
        self.yxNotiBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        
        self.wetchatNotiBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.width.equalTo(yxNotiBtn)
            make.leading.equalTo(self.yxNotiBtn.snp.trailing).offset(19)
        }
    }
    
    @objc func selectBtnDidClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        if sender == self.wetchatNotiBtn {
            if !YXUserManager.isBindWechat() {
                // 是否绑定微信
                let alert = YXAlertView.init(message: YXLanguageUtility.kLang(key: "bind_wechat_alert"))
                let cancel = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { (action) in

                }
                let sure = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default) { (action) in
                    self.bindWetChatCallBack?()
                }
                alert.addAction(cancel)
                alert.addAction(sure)
                alert.showInWindow()
                
                return
            }
            self.wetchatNotiBtn.isSelected = true
            self.yxNotiBtn.isSelected = false
        } else {
            self.wetchatNotiBtn.isSelected = false
            self.yxNotiBtn.isSelected = true
        }
        
        clickBtnCallBack?(self.wetchatNotiBtn.isSelected)
    }
    
}
