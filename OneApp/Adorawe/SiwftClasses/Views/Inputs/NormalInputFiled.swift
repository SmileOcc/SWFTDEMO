//
//  NormalInputFiled.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

///边框或者下划线的样式展示提示信息
enum ErrorStyle{
    case Border
    case UnderLine
}

@objc protocol NormalInputDelegate:NSObjectProtocol {
    func textFieldDidEndEditing(_ textField: UITextField,_ inputField: NormalInputFiled)
    func textFieldDidBeginEditing(_ textField: UITextField,_ inputField: NormalInputFiled)
}


class NormalInputFiled: UIView {
    
    var errorStyle:ErrorStyle = .UnderLine {
        didSet{
            updateErrStyle()
        }
    }
    
    func updateErrStyle(){
        switch errorStyle {
        case .Border:
            borderView?.isHidden = false
            messageView?.lineView?.isHidden = true
        case .UnderLine:
            borderView?.isHidden = true
            messageView?.lineView?.isHidden = false
        }
    }
    
    var normalColor:UIColor? = OSSVThemesColors.col_CCCCCC()
    var errorColor:UIColor?  = OSSVThemesColors.col_B62B21()
    
    var keyBoardType:UIKeyboardType?{
        didSet{
            if let type = keyBoardType{
                inputFiled?.keyboardType = type
                if keyBoardType == .emailAddress{
                    ///去除首字母大写
                    inputFiled?.autocapitalizationType = .none
                }
            }
        }
    }
    
    var text:String?{
        set{
            inputFiled?.text = newValue
            floatingLbl?.isHidden = newValue?.isEmpty ?? true
        }
        get{
            return inputFiled?.text
        }
    }
    
    
    weak var delegate: NormalInputDelegate?
    
    var deviderColor:UIColor? {
        didSet{
            messageView?.messageColor = deviderColor
            borderView?.borderColor = deviderColor
        }
    }
    
    var floatPlaceholderColor:UIColor?{
        didSet{
            floatingLbl?.textColor = floatPlaceholderColor
        }
    }
    
    var errorMessage:String?{
        didSet{
            deviderColor = errorMessage == nil ? normalColor ?? OSSVThemesColors.col_CCCCCC() : errorColor ?? OSSVThemesColors.col_B62B21()
            messageView?.message = errorMessage
        }
    }
    var normalMessage:String?{
        didSet{
            deviderColor = normalColor ?? OSSVThemesColors.col_CCCCCC()
            messageView?.message = normalMessage
        }
    }
    
    var placeholder:String? {
        didSet{
            floatingLbl?.text = placeholder
            inputFiled?.placeholder = placeholder
            if errorStyle == .Border{///两边留白
                floatingLbl?.text = "  \(placeholder ?? "")  "
            }
        }
    }
    
    var attributeMessage:NSAttributedString?{
        didSet{
            messageView?.attributeMessage = attributeMessage
        }
    }
    
    

    weak var floatingLbl:UILabel?
    weak var inputContainer:UIView?
    weak var messageView:UnderLineMessageView?
    
    weak var borderView:BorderView?
    
    weak var inputFiled:UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let borderView = BorderView(frame: .zero)
        addSubview(borderView)
        self.borderView = borderView
        
        borderView.borderWidth = 1
        borderView.borderColor = OSSVThemesColors.col_E1E1E1()
        
        let floatLbl = UILabel()
        
        floatLbl.setTextWidthPriorityMax()
        floatLbl.backgroundColor = OSSVThemesColors.col_FFFFFF()
        floatingLbl = floatLbl
        floatLbl.font = UIFont.systemFont(ofSize: 10)
        floatLbl.isHidden = true
        addSubview(floatLbl)
        floatLbl.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.leading.equalTo(14)
            make.height.equalTo(12)
        }
        
        let msgView = UnderLineMessageView(frame: .zero)
        messageView = msgView
        addSubview(msgView)
        msgView.snp.makeConstraints { make in
            make.bottom.equalTo(-12)
            make.leading.equalTo(14)
            make.trailing.equalTo(-14)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(floatLbl.snp.bottom).offset(-6)
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(msgView.snp.top)
        }
        
        buildContainer()
        ///测试
//        errorStyle = .Border
        updateErrStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildContainer() {
        let container = UIView()
        addSubview(container)
        inputContainer = container
        container.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.leading.trailing.equalTo(self)
            make.top.equalTo(floatingLbl!.snp.bottom).offset(0)
            make.bottom.equalTo(messageView!.snp.top).offset(-4)
        }
        
        buildInputs()
    }
    
    ///自定义输入区域在此方法内
    func buildInputs() {
        let inputField = IncreaseGateTextField()
        inputField.gate = 18 + 24
        if let clearBtn = inputField.value(forKey: "_clearButton") as? UIButton{
            clearBtn.setImage(UIImage(named: "text_field_close"), for: .normal)
        }
        
        inputField.font = UIFont.boldSystemFont(ofSize: 14)
        inputField.clearButtonMode = .whileEditing
        self.inputFiled = inputField
        let view = inputContainer!
        view.addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.leading.equalTo(14)
            make.trailing.equalTo(-14)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        inputField.delegate = self
        inputField.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? .right : .left
    }
    
}

extension NormalInputFiled:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputFiled?.placeholder = nil
        floatingLbl?.isHidden = false
        //清除🙅消息
        errorMessage = nil
        delegate?.textFieldDidBeginEditing(textField, self)
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputFiled?.placeholder = placeholder
        floatingLbl?.isHidden = (inputFiled?.text?.isEmpty ?? true)
        delegate?.textFieldDidEndEditing(textField, self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
