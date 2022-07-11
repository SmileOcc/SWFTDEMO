//
//  YXServiceView.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXServiceView: UIView {

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
        
        backgroundColor = UIColor.white
        layer.cornerRadius = 30
        clipsToBounds = true
        let h = self.frame.height/2
        for i in 0...1 {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            btn.frame = CGRect(x: 0, y: h*CGFloat(i)+CGFloat(i), width: self.frame.width, height: h)
            if i == 0 {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_service_phone") , for: .normal)
            }else {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_contact_online_service") , for: .normal)
            }
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.tag = i + 10
            btn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
            self.addSubview(btn)
            
            if i == 0 {
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
