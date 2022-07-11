//
//  YXPushRangeCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPushRangeBtn: QMUIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        self.imagePosition = .left
        self.spacingBetweenImageAndTitle = 9
        
        self.setImage(UIImage(named: "edit_uncheck_WhiteSkin"), for: .normal)
        self.setImage(UIImage(named: "normal_selected_WhiteSkin"), for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXPushRangeCell: UITableViewCell {
    
    @objc var globalPushBtn: YXPushRangeBtn
    @objc var intelligentPushBtn: YXPushRangeBtn
    
    @objc var clickBtnCallBack: ((_ isGlobalPush: Bool) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.globalPushBtn = YXPushRangeBtn.init(type: .custom)
        self.intelligentPushBtn = YXPushRangeBtn.init(type: .custom)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXPushRangeCell {
    func initUI() {
        self.selectionStyle = .none
//        self.globalPushBtn.isSelected = true
        self.globalPushBtn.setTitle(YXLanguageUtility.kLang(key: "push_area_all"), for: .normal)
        self.intelligentPushBtn.setTitle(YXLanguageUtility.kLang(key: "push_area_smart"), for: .normal)
        
        self.globalPushBtn.addTarget(self, action: #selector(self.selectBtnDidClick(_:)), for: .touchUpInside)
        self.intelligentPushBtn.addTarget(self, action: #selector(self.selectBtnDidClick(_:)), for: .touchUpInside)
        
        let infoBtn = UIButton.init()
        infoBtn.setImage(UIImage(named: "icon_parameter_info_WhiteSkin"), for: .normal)
        infoBtn.addTarget(self, action: #selector(self.infoBtnDidClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(self.globalPushBtn)
        contentView.addSubview(self.intelligentPushBtn)
        contentView.addSubview(infoBtn)
        
        self.globalPushBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        self.intelligentPushBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(204)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        infoBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.intelligentPushBtn.snp.trailing).offset(3)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func selectBtnDidClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        if sender == self.intelligentPushBtn {
            self.intelligentPushBtn.isSelected = true
            self.globalPushBtn.isSelected = false
        } else {
            self.intelligentPushBtn.isSelected = false
            self.globalPushBtn.isSelected = true
        }
        clickBtnCallBack?(self.intelligentPushBtn.isSelected)
    }
    
    @objc func infoBtnDidClick(_ sender: UIButton) {
        let title = YXLanguageUtility.kLang(key: "monitor_smart_describe_tips")

        let alert = YXAlertView.init(message: title)
        let sure = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default) { (action) in
            
        }
        alert.addAction(sure)
        alert.showInWindow()
    }
}

