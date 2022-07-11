//
//  YXCustomButtonToastView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCustomButtonToastView: UIView {

    lazy var infoLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "hybrid_sorting_tip")
        label.textAlignment = .center
        return label
    }()
    
    lazy var button: QMUIButton = {
        let button = QMUIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.setTitle(YXLanguageUtility.kLang(key: "turn_off_smart_sorting"), for: .normal)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(14)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(infoLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.bottom.equalTo(self).offset(-10)
        }
        self.backgroundColor = QMUITheme().foregroundColor()
        self.layer.cornerRadius = 7;
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(inView: UIView?) {
        if let view = inView {
            
            view.addSubview(self)
            
            self.snp.makeConstraints { (make) in
                make.center.equalTo(view)
                make.width.equalTo(200)
//                make.height.equalTo(90)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.removeFromSuperview()
            })
        }
        
    }
    
    @objc func clickButton() {
        YXSecuGroupManager.shareInstance().userSetSortflag(0)
        self.removeFromSuperview()
    }

}
