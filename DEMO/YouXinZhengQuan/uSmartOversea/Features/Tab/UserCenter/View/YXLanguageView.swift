//
//  YXLanguageView.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXLanguageView: UIView {

    fileprivate var curLanguage: YXLanguageType = YXUserManager.curLanguage()
    
    init(frame: CGRect, curLanguage: YXLanguageType) {
        super.init(frame: frame)
        self.curLanguage = curLanguage
        initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didSelected: (NSInteger)->() = { index in
        
    }
    
    func initView() {
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
        let h = self.frame.height/3
        for i in 0...2 {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.white
            if (curLanguage == .CN && i==1) || (curLanguage == .HK && i==0) || (curLanguage == .EN && i==2){
                btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            }else {
                btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
            }
            btn.frame = CGRect(x: 0, y: h*CGFloat(i)+CGFloat(i), width: self.frame.width, height: h)
            if i == 0 {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_traditional") , for: .normal)
            }else if i == 1 {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_simplified")  , for: .normal)
            }else {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_english") , for: .normal)
            }
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.tag = i + 10
            btn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
            self.addSubview(btn)
            
            if i != 2 {
                let line = UIView()
                line.backgroundColor = QMUITheme().separatorLineColor()
                self.addSubview(line)
                line.snp.makeConstraints { (make) in
                    make.left.right.equalTo(self)
                    make.top.equalTo(btn.snp.bottom)
                    make.height.equalTo(1)
                }
            }
        }
    }
    
    @objc func btnAction(btn: UIButton) {
        let index = btn.tag-10
        didSelected(index)
    }


}
