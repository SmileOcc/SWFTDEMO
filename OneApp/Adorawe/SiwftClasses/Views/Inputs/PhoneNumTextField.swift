//
//  PhoneNumTextField.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class PhoneNumTextField: NormalInputFiled {
    
    var regionCode:String?{
        didSet{
            let needShowRegion = ((regionCode == nil) ? false : !(regionCode!.isEmpty))
            regionLbl?.text = regionCode
            if needShowRegion {
                regionLbl?.isHidden = false
                verticleLine?.isHidden = false
                inputFiled?.snp.remakeConstraints { make in
                    make.left.equalTo(verticleLine!.snp.right).offset(8)
                    make.right.equalTo(-14)
                    make.top.equalTo(0)
                    make.bottom.equalTo(0)
                }
            }else{
                verticleLine?.isHidden = true
                regionLbl?.isHidden = true
                
                inputFiled?.snp.remakeConstraints { make in
                    make.left.equalTo(14)
                    make.right.equalTo(-14)
                    make.top.equalTo(0)
                    make.bottom.equalTo(0)
                }
            }
        }
    }
    
    weak var regionLbl:UILabel?
    weak var verticleLine:UIView?
    
    override func buildInputs() {
//        super.buildInputs()
        let inputField = STLPhoneNumTextField()
        inputField.font = UIFont.boldSystemFont(ofSize: 14)
        inputField.clearButtonMode = .whileEditing
        self.inputFiled = inputField
        let view = inputContainer!
        view.addSubview(inputField)
        inputField.delegate = self

        
        self.inputFiled?.keyboardType = .numberPad
        self.inputFiled?.snp.makeConstraints({ make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        })
        
        let regionLbl = UILabel()
        self.regionLbl = regionLbl
        inputContainer?.addSubview(regionLbl)
        regionLbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        regionLbl.setContentHuggingPriority(.required, for: .horizontal)
        regionLbl.font = UIFont.boldSystemFont(ofSize: 14)
        regionLbl.textColor = OSSVThemesColors.col_6C6C6C()
        regionLbl.snp.makeConstraints { make in
            make.left.equalTo(14)
//            make.height.equalTo(14)
            make.top.bottom.equalTo(0)
        }
        
        let verticleLine = UIView()
        self.verticleLine = verticleLine
        inputContainer?.addSubview(verticleLine)
        verticleLine.backgroundColor = OSSVThemesColors.col_CCCCCC()
        verticleLine.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.left.equalTo(regionLbl.snp.right).offset(8)
            make.centerY.equalTo(regionLbl.snp.centerY)
        }
    }

    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
    }

}
