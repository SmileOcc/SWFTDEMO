//
//  YXModifyNickNameViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension String {
    func getStringGBKByteLength() -> Int {
        //GBK
        let cfEnc = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let nameStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameData = nameStr.data(using: String.Encoding(rawValue: encoding))
        return nameData?.count ?? 0
    }
}

//extension NSString {
//    //GBK
//    public func getStringGBKByteLength() -> Int {
//        let cfEnc = CFStringEncodings.GB_18030_2000
//        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
//        let nameData = nameStr.data(using: String.Encoding(rawValue: encoding))
//        return nameData?.count ?? 0
//    }
//}

class YXModifyNickNameViewController: YXHKViewController,HUDViewModelBased , UITextFieldDelegate {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXModifyNickNameViewModel!
    //暱稱输入框
    var nickNameInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "user_nickNamePlaceHolder"), type: .normal)
        inputView.textField.font  = .systemFont(ofSize: 16)
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        inputView.textField.text = YXUserManager.shared().curLoginUser?.nickname ?? ""
        
        return inputView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindHUD()
        //nickNameInputView.textField绑定到viewModel.nickName
        nickNameInputView.textField.rx.text.orEmpty.bind(to: self.viewModel.nickName).disposed(by: disposeBag)
        
        viewModel.successSubject.subscribe(onNext: {[weak self] (success) in
            guard let strongSelf = self else {return}
            
            YXUserManager.shared().curLoginUser?.nickname = strongSelf.viewModel.nickName.value
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateUserInfo), object: nil)
            
            if success {
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.defaultSubject.subscribe(onNext: {[weak self] (msg) in
            guard let strongSelf = self else {return}
            strongSelf.showErrorAlertWithMsg(msg)
        }).disposed(by: disposeBag)
        // Do any additional setup after loading the view.
        //弹起键盘
        self.nickNameInputView.textField.becomeFirstResponder()
        
        let _ = NotificationCenter.default.rx.notification(UITextField.textDidChangeNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.textFiledDidChange(noti: noti)
            })
    }
    
    
    func initUI() {
        //背景色
        self.view.backgroundColor = QMUITheme().foregroundColor()
        //右导航-保存
        //let msgItem = UIBarButtonItem.qmui_item(with: UIImage(named: "user_save"), target: self, action: nil)
        let msgItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "user_save"), target: self, action: nil)
        msgItem.tintColor = QMUITheme().mainThemeColor()
        self.navigationItem.rightBarButtonItems = [msgItem]
        msgItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            /*更新用户基本信息
             update-base-user-info/v1 */
            self.viewModel.services.userService.request(.updateUserInfo(avatar: nil, nickname: self.viewModel.nickName.value), response: self.viewModel.updateUserInfoResponse).disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        //白色背景
        let whiteBgView = UIView()//UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 116))
        whiteBgView.backgroundColor = QMUITheme().foregroundColor()
        self.view.addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            make.height.equalTo(54)
        }
        
        
        self.title = YXLanguageUtility.kLang(key: "user_modifyNickName")
        
        
        whiteBgView.addSubview(nickNameInputView)
        nickNameInputView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(0)
            make.height.equalTo(54)
        }
        
        let lineView = UIView()
        view.addSubview(lineView)
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        lineView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(whiteBgView.snp.bottom)
        }
        
    }
    //弹框错误
    func showErrorAlertWithMsg(_ msg: String) {
        self.view.endEditing(true)
        self.viewModel.hudSubject.onNext(.error(msg, false))
//        YXAlertViewController
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_isOK"), style: .cancel, handler: {[weak alertView] action in
//            alertView?.hide()
//        }))
//        alertView.showInWindow()
    }
    
    @objc func textFiledDidChange(noti:Notification) {
        if let textField = noti.object as? UITextField {
            let language = textField.textInputMode?.primaryLanguage
            
            let shouldCount = {
                if textField.text != nil {
                    let charsCount = textField.text?.getStringGBKByteLength() ?? 0
                    if charsCount >= 20 {
                        for i in 0...(textField.text?.count ?? 0) {
                            let tempStr = (textField.text as NSString?)?.substring(to: i)
                            if (tempStr?.getStringGBKByteLength() ?? 0) >= 20 {
                                textField.text = (textField.text as NSString?)?.substring(to: i-1)
                                return
                            }
                        }
                    }
                }
            }
            
            // 简体中文输入，包括简体拼音，健体五笔，简体手写
            if (language?.hasPrefix("zh-Hans") ?? false) ||
                (language?.hasPrefix("zh-Hant") ?? false) {
                guard let _:UITextRange = textField.markedTextRange else {
                    shouldCount()
                    return
                }
            } else {
                shouldCount()
            }
        }
    }
    
}

