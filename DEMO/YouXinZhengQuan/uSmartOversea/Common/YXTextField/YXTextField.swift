//
//  YXBanPasteTextField.swift
//  uSmartOversea
//
//  Created by rrd on 2019/2/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTextField: UITextField {
    
    @objc enum InputType: Int {
        case normal = 0
        case money = 1
    }
    
    @objc var integerBitCount = 99
    @objc var decimalBitCount = 99
    @objc var inputType:InputType = .normal
    @objc var banAction = false
    @objc var maxValue = 0.0
    

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        !banAction
    }
    
    @objc func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.inputType == .money {
            var checkStr = textField.text ?? ""
            if maxValue > 0, !string.isEmpty, !checkStr.isEmpty, Double(checkStr) ?? 0 >= maxValue {
                return false
            }
            
            if let rag = checkStr.toRange(range) {
                checkStr = checkStr.replacingCharacters(in: rag, with: string)
            }
            
            if checkStr.isEmpty {
                return true
            }
            
            let regex =  String(format: "^([1-9]\\d{0,%ld}|0)(\\.\\d{0,%ld})?$", integerBitCount-1, decimalBitCount)
            
            return self.isValid(checkStr: checkStr, regex: regex)
        }else {
            return true
        }
        
    }
    
    override func willDealloc() -> Bool {
        false
    }
    
    func isValid(checkStr:String , regex:String) -> Bool {
        let predicte = NSPredicate(format: "SELF MATCHES %@",regex)
        return predicte.evaluate(with:checkStr)
    }

}

////隐藏输入框（解决ios输入账号和密码时键盘闪烁）
class YXHideTextField: UITextField {
    
    //账号和密码连续时相互切换，账号输入键盘闪烁
    @objc class func addHideTextField(sourceView: UIView, textFieldView: UIView) {
        
        let textField = YXHideTextField.init()
        //textField.isHidden = true //不能用隐藏 高度要为1以上
        textField.backgroundColor = UIColor.clear
        textField.isEnabled = false
        
        sourceView.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(textFieldView.snp.left)
            make.right.equalTo(textFieldView.snp.right)
            make.height.equalTo(1)
            make.bottom.equalTo(textFieldView.snp.top)
        }
        sourceView.sendSubviewToBack(textField)
    }
}


extension String {
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}
