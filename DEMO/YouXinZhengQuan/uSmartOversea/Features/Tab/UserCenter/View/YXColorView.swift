//
//  YXColorView.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXColorView: UIView {
    
    fileprivate var curLineColor: YXLineColorType = YXUserManager.curColor(judgeIsLogin: true)

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    init(frame: CGRect, curLineColor: YXLineColorType) {
        super.init(frame: frame)
        self.curLineColor = curLineColor
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
        let h = self.frame.height/2
        for i in 0...1 {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = UIColor.white
            if (curLineColor == .rRaiseGFall && i==1) || (curLineColor == .gRaiseRFall && i==0){
                btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            }else {
                btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
            }
            
            btn.frame = CGRect(x: 0, y: h*CGFloat(i)+CGFloat(i), width: self.frame.width, height: h)
            if i == 0 {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_green_rose") , for: .normal)
                btn.setImage(UIImage(named: "user_lvzhang"), for: .normal)
            }else {
                btn.setTitle(YXLanguageUtility.kLang(key: "mine_red_rose") , for: .normal)
                btn.setImage(UIImage(named: "user_hongzhang"), for: .normal)
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
