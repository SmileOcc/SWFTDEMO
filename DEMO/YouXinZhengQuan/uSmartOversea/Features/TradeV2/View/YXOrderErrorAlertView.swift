//
//  YXOrderErrorAlertView.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/1/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderErrorAlertView: UIView {
    
    @objc var title = ""
    @objc var content = ""
    @objc var subContent = ""
    
    @objc lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    @objc lazy var contentLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    @objc lazy var subContentLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    @objc lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_iknow"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        
        self.addSubview(titleLab)
        self.addSubview(contentLab)
        self.addSubview(subContentLab)
        self.addSubview(confirmBtn)
        
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(24)
        }
        
        contentLab.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.equalTo(self).offset(25)
            make.right.equalTo(self).offset(-25)
        }
        
        subContentLab.snp.makeConstraints { (make) in
            make.top.equalTo(contentLab.snp.bottom).offset(10)
            make.left.equalTo(self).offset(25)
            make.right.equalTo(self).offset(-25)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(44)
        }
        
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        self.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.equalTo(self)
            make.bottom.equalTo(confirmBtn.snp.top).offset(0)
        }
        
    }
    
    @objc func refreshUI() {
        
        titleLab.text = title
        contentLab.text = content
        subContentLab.text = subContent
    }

}
