//
//  YXQuoteSelectView.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXQuoteSelectView: UIView {

    var selectedIndex: Int = 0

    init(frame: CGRect, selectedIndex: Int) {
        super.init(frame: frame)
        
        self.selectedIndex = selectedIndex
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
        
        let quoteTitles = [YXLanguageUtility.kLang(key: "index_roc"), YXLanguageUtility.kLang(key: "index_change"), YXLanguageUtility.kLang(key: "index_vol"), YXLanguageUtility.kLang(key: "index_turnover"), YXLanguageUtility.kLang(key: "index_after_or_before")]
        let h = self.frame.height/CGFloat(quoteTitles.count)
        for i in 0..<quoteTitles.count {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.white
            if (self.selectedIndex == i){
                btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            }else {
                btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            }
            btn.frame = CGRect(x: 0, y: h*CGFloat(i)+CGFloat(i), width: self.frame.width, height: h)
            btn.setTitle(quoteTitles[i], for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.tag = i + 10
            btn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
            self.addSubview(btn)
            
            if i < quoteTitles.count - 1 {
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
