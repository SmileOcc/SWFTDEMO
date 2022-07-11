//
//  YXTextFieldInputView.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2021/3/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXTextFieldInputView: YXInputBaseView {

    var type:YXInputViewType!
    var textField = UITextField()
    let disposeBag = DisposeBag()
    
    typealias BeginEditBlock = () -> Void
    typealias EndEditBlock = () -> Void

    var editBeginBlock: BeginEditBlock?
    var editEndBlock: EndEditBlock?
    
    var isClear = true
    var clearBtnClickClosure: (() -> ())?

    @objc override var isSelect: Bool {
        didSet {
            if isError {
                lineView.backgroundColor = UIColor.qmui_color(withHexString: "#EE3D3D")
            } else {
                if isSelect {
                    lineView.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
                } else {
                    lineView.backgroundColor = QMUITheme().separatorLineColor()
                }
            }
        }
    }

    @objc var isError: Bool = false {
        didSet {
            if isError {
                lineView.backgroundColor = UIColor.qmui_color(withHexString: "#EE3D3D")
            } else {
                if isSelect {
                    lineView.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
                } else {
                    lineView.backgroundColor = QMUITheme().separatorLineColor()
                }
            }
        }
    }
    
    var leftPadding: CGFloat = 15 {
        didSet {
            if self.textField.superview != nil {
                self.textField.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(leftPadding)
                }
            }
        }
    }
    
    var rightPadding: CGFloat = -10 {
        didSet {
            if self.cleanBtn.superview != nil {
                self.cleanBtn.snp.updateConstraints { (make) in
                    make.right.equalToSuperview().offset(rightPadding)
                }
            }
        }
    }

    
    var cleanBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "login_clean"), for: .normal)
        return btn
    }()
    
    var eyeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "login_closeEyes"), for: .normal)
        btn.setImage(UIImage(named: "login_openEyes"), for: .selected)
        return btn
    }()

    convenience init(placeHolder:String, type:YXInputViewType) {
        self.init(frame:.zero)
        self.type = type
        self.textField.placeholder = placeHolder
        self.textField.isSecureTextEntry = type == .password
        self.textField.delegate = self
        self.textField.tintColor = QMUITheme().themeTextColor()
        if type == .phone {
            self.textField.keyboardType = .numberPad
        }else {
            self.textField.keyboardType = .default
        }
        initUI()
    }
    
    func initUI() {
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.spellCheckingType = .no
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textColor = QMUITheme().textColorLevel1()
        
        if #available(iOS 13.0, *) {
            Thread.current.qmui_shouldIgnoreUIKVCAccessProhibited = true
        }
        self.textField.setValue(QMUITheme().textColorLevel3(), forKeyPath: "_placeholderLabel.textColor")
        if #available(iOS 13.0, *) {
            Thread.current.qmui_shouldIgnoreUIKVCAccessProhibited = false
        }
        
        self.addSubview(textField)
        self.addSubview(cleanBtn)
       
        if self.type == .password {
            self.addSubview(eyeBtn)
        }
        
        if self.type == .password {
            
            eyeBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalToSuperview().offset(-10)
                make.width.height.equalTo(25)
            }
            
            cleanBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(eyeBtn.snp.left).offset(-10)
                make.width.height.equalTo(25)
            }
            
        }else {
            
            cleanBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalToSuperview().offset(-10)
                make.width.height.equalTo(25)
            }
        }
        
        textField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(10)
            make.left.equalToSuperview().offset(leftPadding)
            make.right.equalTo(cleanBtn.snp.left).offset(-5)
        }
        
        eyeBtn.rx.tap
            .bind { [weak self] in
                self!.eyeBtn.isSelected = !self!.eyeBtn.isSelected
                self!.textField.isSecureTextEntry = !self!.eyeBtn.isSelected
        }.disposed(by: self.disposeBag)
        
        cleanBtn.rx.tap
            .bind { [weak self] in
                self?.textField.text = ""
                self?.cleanBtn.isHidden = true
                self?.isClear = true
                self?.clearBtnClickClosure?()
            }.disposed(by: self.disposeBag)
        
        textField.rx.text.orEmpty.asDriver()
            .map{ $0.count == 0 }
            .drive(cleanBtn.rx.isHidden)
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty.subscribe(onNext: {[weak self] (text) in
            guard let strongSelf = self else { return }
            strongSelf.updateTextConstraint()
        }).disposed(by: disposeBag)
        

        textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: {
            [weak self] (_) in
            self?.cleanBtn.isHidden = true
        }).disposed(by: disposeBag)
    }

    func setSecretPhone() {
        isClear = false
        textField.clearsOnBeginEditing = true
    }
    //更新text约束
    func updateTextConstraint() {
        
        if !(self.textField.text?.isEmpty ?? true) { //self.textField.text?.count ?? 0 > 0
            self.textField.snp.updateConstraints { (make) in
                make.right.equalTo(self.cleanBtn.snp.left).offset(-5)
            }
        }else {
            self.textField.snp.updateConstraints { (make) in
                make.right.equalTo(self.cleanBtn.snp.left).offset(25)
            }
        }
    }

}

extension YXTextFieldInputView: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.clearsOnBeginEditing = false
        isClear = true
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let str = textField.text as NSString?
        let str2 = str?.replacingCharacters(in: range, with: string)
       
        if self.type == .phone {
            if str2?.count ?? 0 > 11{
                return false
            }
            if string.count > 0 && !(str2?.isAllNumber() ?? false) {
                return false
            }
        }else if self.type == .password {
            if str2?.count ?? 0 > 24 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editEndBlock?()
        self.isSelect = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editBeginBlock?()
        self.isSelect = true
    }
}




