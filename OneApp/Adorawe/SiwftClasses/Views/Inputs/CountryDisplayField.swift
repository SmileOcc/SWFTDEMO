//
//  CountryDisplayField.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class CountryDisplayField: CustomTalingTextField {
    
    override var text: String?{
        set{
            contentText = newValue
        }
        get{
            return contentText
        }
    }
    
    weak var displayLbl:UILabel?
    
    weak var touchButton:UIButton?
    
    var contentText:String? {
        didSet{
            if contentText != nil && !(contentText!.isEmpty) {
                displayLbl?.text = contentText ?? placeholder
                floatingLbl?.isHidden = false
                displayLbl?.textColor = OSSVThemesColors.col_0D0D0D()
            }else{
                displayLbl?.text = placeholder
                displayLbl?.textColor = normalColor
                floatingLbl?.isHidden = true
            }
            
        }
    }
    
    

    override func buildInputs() {
        super.buildInputs()
        inputFiled?.removeFromSuperview()
        floatingLbl?.snp.remakeConstraints({ make in
            make.top.equalTo(14)
            make.leading.equalTo(14)
            make.height.equalTo(12)
        })
        inputContainer?.snp.remakeConstraints{ make in
            make.leading.equalTo(self)
            make.trailing.equalTo(traillingView!).offset(-4)
            make.top.equalTo(floatingLbl!.snp.bottom).offset(8)
            make.bottom.equalTo(messageView!.snp.top).offset(-8)
        }
        
        
        
        let label = UILabel()
        inputContainer?.addSubview(label)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        displayLbl = label
        displayLbl?.textColor = OSSVThemesColors.col_B2B2B2()
        label.snp.makeConstraints { make in
            make.leading.equalTo(14)
            make.top.equalTo(0)
            make.bottom.equalTo(-8)
            make.trailing.equalTo(0)
//            make.height.greaterThanOrEqualTo(24)
        }
        displayLbl?.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? .right : .left
//        contentText = nil
        
        let button = UIButton()
        inputContainer?.addSubview(button)
        button.isEnabled = false
        button.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        self.touchButton = button
    }
}
