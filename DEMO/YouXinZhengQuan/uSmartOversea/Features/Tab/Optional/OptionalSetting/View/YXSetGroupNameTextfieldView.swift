//
//  YXSetGroupNameTextfieldView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSetGroupNameTextfieldView: UIView, QMUITextFieldDelegate {
    
    @objc var sureAction: (() -> Void)?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().popupLayerColor()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 16
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.shadowColor = QMUITheme().foregroundColor().withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 16.0
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "add_group")
        return label
    }()

    @objc lazy var textField: YXSecuGroupNameTextField = {
        let textField = self.creatTextField()
        textField.layer.borderWidth = 1
        textField.layer.borderColor = QMUITheme().separatorLineColor().cgColor

        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.textField.resignFirstResponder()
        })
        return button
    }()
    
    lazy var sureButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setTitle(YXLanguageUtility.kLang(key: "common_ok"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.init(color: QMUITheme().mainThemeColor()), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.textField.resignFirstResponder()
            let name = self.textField.text ?? ""
            if YXSecuGroupManager.shareInstance().createGroup(name) {
                
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "fail_pls_retry"))
            }
            self.sureAction?()
        })
        return button
    }()
    
    func creatTextField() -> YXSecuGroupNameTextField {
        let textField = YXSecuGroupNameTextField()
        textField.placeholder = YXLanguageUtility.kLang(key: "add_group_plaeceHold")
        textField.borderStyle = .roundedRect
        textField.keyboardType = .default
        textField.qmui_keyboardWillChangeFrameNotificationBlock = { [weak self](keyboardUserInfo) in
            guard let `self` = self else { return }
            QMUIKeyboardManager.handleKeyboardNotification(with: keyboardUserInfo, show: { (info) in
                if let keyBorardInfo = info {
                    self.showWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }) { (info) in
                if let keyBorardInfo = info {
                    self.hideWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }
        }
        
        return textField
    }
    
    func showWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = false
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            if let view = self.superview {
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: view, keyboardRect: info.endFrame)
                self.containerView.layer.transform = CATransform3DMakeTranslation(0, (-distanceFromBottom - self.containerView.frame.size.height), 0)
            }
        }, completion: nil)
    }
    
    func hideWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = true
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            self.containerView.layer.transform = CATransform3DIdentity
        }, completion: { (finish) in
            
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        self.backgroundColor = QMUITheme().shadeLayerColor()//QMUITheme().foregroundColor()
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(cancelButton)
        containerView.addSubview(sureButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.height.equalTo(48)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(sureButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(234)
            make.top.equalTo(self.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class YXSecuGroupNameTextField: QMUITextField, QMUITextFieldDelegate {
    @objc var shouldReturn: Bool = false // 点击回车时是否收起键盘
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.backgroundColor = QMUITheme().popupLayerColor()
        self.placeholderColor = QMUITheme().textColorLevel4()
        self.textColor = QMUITheme().textColorLevel1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldMaxNum = 12
        
        if string.count == 0 {
            return true
        }
        if (range.length == 1 && string.count == 0) {
            return true
        }
        let textFieldText = textField.text ?? ""
        let str = string
        
        var text = (textFieldText as NSString).substring(with: NSRange(location: 0, length: range.location))
        let lastText = (textFieldText as NSString).substring(from: range.location + range.length)

        if (text.characterLength() + lastText.characterLength()) >= textFieldMaxNum {
            return false
        }
        
        var offset = Int(textFieldMaxNum)
        text += string
        if text.characterLength() < offset {
            offset = text.count
        }

        if textFieldText.characterLength() == textFieldMaxNum {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: offset)
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        } else if textFieldText.characterLength() + str.characterLength() >= textFieldMaxNum {
            text += lastText
            textField.text = text.subString(toCharacterIndex: UInt(textFieldMaxNum))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: offset)
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return self.shouldReturn;
    }
}
