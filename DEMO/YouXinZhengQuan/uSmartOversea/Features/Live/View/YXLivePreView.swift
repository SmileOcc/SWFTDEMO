//
//  YXLivePreView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLivePreView: UIView {

    @objc var btnClickCallBack: ((_ sender: UIButton)->())?
    @objc var beginBtn = UIButton.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        let mirrorBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_mirror"), imageStr: "icon-mirror")
        mirrorBtn.tag = 1
        let beautyBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_beautify"), imageStr: "icon-beauty")
        beautyBtn.tag = 0
        let flipBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_flip"), imageStr: "icon-flip")
        flipBtn.tag = 2
        
        beginBtn = UIButton.init(type: .custom, title: YXLanguageUtility.kLang(key: "live_start"), font: UIFont.systemFont(ofSize: 16), titleColor: UIColor.white, target: self, action: #selector(self.btnClick(_:)))!
        beginBtn.setDisabledTheme(4)
        beginBtn.tag = 3
        
        addSubview(mirrorBtn)
        addSubview(beautyBtn)
        addSubview(flipBtn)
        addSubview(beginBtn)
        
        beginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0)
            make.width.equalTo(250)
            make.height.equalTo(47)
        }
        
        mirrorBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.bottom.equalTo(beginBtn.snp.top).offset(-32)
        }
        
        beautyBtn.snp.makeConstraints { (make) in
            make.right.equalTo(mirrorBtn.snp.left).offset(-20)
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.bottom.equalTo(mirrorBtn)
        }
        flipBtn.snp.makeConstraints { (make) in
            make.left.equalTo(mirrorBtn.snp.right).offset(20)
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.bottom.equalTo(mirrorBtn)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        btnClickCallBack?(sender)
    }
    
    func getBtn(with title: String, imageStr: String) -> (QMUIButton) {
        let mirrorBtn = QMUIButton.init(type: .custom, image: UIImage(named: imageStr), target: self, action: #selector(self.btnClick(_:)))!
        mirrorBtn.imagePosition = .top
        mirrorBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        mirrorBtn.setTitleColor(UIColor.white, for: .normal)
        mirrorBtn.setTitle(title, for: .normal)
        mirrorBtn.spacingBetweenImageAndTitle = 0
        mirrorBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        mirrorBtn.titleLabel?.minimumScaleFactor = 0.3
        return mirrorBtn
    }
}
