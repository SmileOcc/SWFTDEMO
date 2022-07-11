//
//  YXInputBaseView.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2021/3/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXInputBaseView: UIView {
    
    let lineView = UIView()
    
    var isSelect = false {
        didSet {
            if isNewStyle {
                return
            }
            
            if isSelect {
                lineView.backgroundColor = QMUITheme().themeTextColor()
            } else {
                lineView.backgroundColor = QMUITheme().separatorLineColor()
            }
        }
    }
    
    private var isNewStyle = false
    
    func useNewStyle() {
        isNewStyle = true
        lineView.removeFromSuperview()
        
        backgroundColor = QMUITheme().blockColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSuperUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSuperUI() {
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        isSelect = false
        
        clipsToBounds = true
    }
}

