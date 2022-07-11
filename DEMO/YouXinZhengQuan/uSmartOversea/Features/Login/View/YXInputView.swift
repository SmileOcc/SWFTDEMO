//
//  YXInputView.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum YXInputViewType {
    case normal
    case phone
    case password
    case email
}

class YXInputView: UIView, UITextFieldDelegate {
    
    var type:YXInputViewType!
    var textField = UITextField()
    let disposeBag = DisposeBag()
    
    typealias BeginEditBlock = () -> Void
    typealias EndEditBlock = () -> Void

    var editBeginBlock: BeginEditBlock?
    var editEndBlock: EndEditBlock?
    
    var isClear = true

    private var needShowClear = true
    
    
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
        if type == .phone {
            self.textField.keyboardType = .numberPad
        }else if type == .email {
            self.textField.keyboardType = .emailAddress
        }
        else {
            self.textField.keyboardType = .default
        }
        initUI()
    }
    
    convenience init(placeHolder:String, type:YXInputViewType,showClear:Bool) {
        self.init(frame:.zero)
        self.type = type
        self.textField.placeholder = placeHolder
        self.textField.isSecureTextEntry = type == .password
        self.textField.delegate = self
        if type == .phone {
            self.textField.keyboardType = .numberPad
        }else if type == .email {
            self.textField.keyboardType = .emailAddress
        }
        else {
            self.textField.keyboardType = .default
        }
        self.needShowClear = showClear
        initUI()
    }
    
    func initUI() {
        
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.spellCheckingType = .no        
        
        self.addSubview(textField)
        self.addSubview(cleanBtn)
        self.cleanBtn.isHidden = !needShowClear
       
        if self.type == .password {
            self.addSubview(eyeBtn)
        }
        
        if self.type == .password {
            
            eyeBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(self)
                make.width.height.equalTo(25)
            }
            
            cleanBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(eyeBtn.snp.left).offset(-20)
                make.width.height.equalTo(25)
            }
            
        }else {
            
            cleanBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(self)
                make.width.height.equalTo(25)
            }
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
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
                self?.updateConstraints()
            }.disposed(by: self.disposeBag)
        
        if needShowClear {
            textField.rx.text.orEmpty.asDriver()
                .map{ $0.count == 0 }
                .drive(cleanBtn.rx.isHidden)
                .disposed(by: disposeBag)
        }
        
        textField.rx.text.orEmpty.subscribe(onNext: {[weak self] (text) in
            guard let strongSelf = self else { return }
            strongSelf.updateTextConstraint()
        }).disposed(by: disposeBag)
        

        textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: {
            [weak self] (_) in
            self?.cleanBtn.isHidden = true
            self?.updateTextConstraint()
        }).disposed(by: disposeBag)
    }

    func setSecretPhone() {
        isClear = false
        textField.clearsOnBeginEditing = true
    }
    //更新text约束
    func updateTextConstraint() {
        
        if !(self.textField.text?.isEmpty ?? true) && !self.cleanBtn.isHidden { //self.textField.text?.count ?? 0 > 0
            self.textField.snp.updateConstraints { (make) in
                make.right.equalTo(self.cleanBtn.snp.left).offset(-5)
            }
        }else {
            self.textField.snp.updateConstraints { (make) in
                make.right.equalTo(self.cleanBtn.snp.left).offset(25)
            }
        }
    }
    //
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
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editBeginBlock?()
    }
}
