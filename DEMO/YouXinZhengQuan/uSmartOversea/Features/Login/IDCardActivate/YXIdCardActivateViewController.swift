//
//  YXIdCardActivateViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import Reusable
import RxSwift
import RxCocoa
import SnapKit
import YXKit

class YXIdCardActivateViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXIdCardActivateViewModel!
    
    //callBack回调
    var fillPhone: (([String]) -> Void)!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    var idNumInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "login_idPlaceHolder"), type: .normal)
        inputView.textField.font = .systemFont(ofSize: 18)
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        return inputView
    }()
    
    var loginBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "login_idNumberLogin"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:16)
        //設置按鈕是否可點擊
        btn.setDisabledTheme()
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        viewModelResponse()
        bindHUD()
        
        // Do any additional setup after loading the view.
    }
    func bindViewModel() {
        //输入框绑定viewModel.phone
        idNumInputView.textField.rx.text.orEmpty.bind(to: self.viewModel.idNumber).disposed(by: disposeBag)
        //输入框绑定loginBtn.rx.isEnabled
        let idNumberValid = self.idNumInputView.textField.rx.text.orEmpty
            .map{ $0.count > 0}
            .share(replay: 1)
        idNumberValid.bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //清除时设置loginBtn.isEnable = false
        idNumInputView.cleanBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.loginBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        //MARK: - 登录的响应
        loginBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            /* 短信验证码+证件号激活登陆聚合接口 POST请求
            captcha-activate-login-aggregation/v1 */
            let areaCode = strongSelf.viewModel.code
            let captcha = strongSelf.viewModel.captcha.removePreAfterSpace()
            var phone = (strongSelf.viewModel.phone.value as String).removePreAfterSpace()
            phone = YXUserManager.safeDecrypt(string: phone)
            let identifyCode = (strongSelf.viewModel.idNumber.value as String).removePreAfterSpace()
            strongSelf.viewModel.services.aggregationService.request(.captchaActivateLoginAggreV1(areaCode: areaCode, captcha: captcha, phoneNumber: phone, identifyCode: identifyCode),response: strongSelf.viewModel.captchaActivateLoginResponse).disposed(by:strongSelf.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(idNumInputView)
        scrollView.addSubview(loginBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalToSuperview()
        }
        let horSpace = uniSize(20)
        //【您当前账户需激活，请输入开户时输入的证件号码完成激活】
        let tipLab:UILabel = {
            let label = UILabel()
            label.text = YXLanguageUtility.kLang(key: "login_idNumberTip")
            label.font = UIFont.systemFont(ofSize: 18)//36
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.6, backgroundColor: .clear)
            return label
        }()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView).offset(uniVerLength( 35))
            make.left.equalTo(scrollView).offset(horSpace)
            make.right.equalTo(self.view).offset(-horSpace)
            //make.height.equalTo(50)
        }
        //【证件号码】
        let tipLab2:UILabel = {
            let label = UILabel()
            label.text = YXLanguageUtility.kLang(key: "login_idNumberText")
            label.font = .systemFont(ofSize: 36)
            label.numberOfLines = 0
            label.textColor = QMUITheme().textColorLevel1()
            return label
        }()
        scrollView.addSubview(tipLab2)
        tipLab2.snp.makeConstraints { (make) in
            make.leading.equalTo(scrollView).offset(horSpace)
            make.right.equalTo(self.view).offset(-horSpace)
            make.top.equalTo(tipLab.snp.bottom).offset(uniVerLength( 40))
            //make.height.equalTo(50)
            //make.size.equalTo(CGSize(width: 55, height: 35))
        }
        ///抗拉伸性 越高越不容易被拉伸
        //tipLab2.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        ///抗压缩性 越高越不容易被压缩
//        tipLab2.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //【请输入开户申请填写的证件号码】
        idNumInputView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horSpace)
            make.top.equalTo(tipLab2.snp.bottom).offset(15)
            make.trailing.equalTo(self.view).offset(-horSpace)
            make.height.equalTo(35)
        }
        //横线
        let line1 = UIView()
        line1.backgroundColor = QMUITheme().separatorLineColor()
        scrollView.addSubview(line1)
        line1.snp.makeConstraints { (make) in
            make.leading.equalTo(scrollView).offset(horSpace)
            make.trailing.equalTo(self.view).offset(-horSpace)
            make.top.equalTo(idNumInputView.snp.bottom).offset(uniVerLength( 10))
            make.height.equalTo(1)
        }
        //登入按钮
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(line1.snp.bottom).offset(uniVerLength( 50))
            make.left.equalTo(scrollView).offset(horSpace)
            make.right.equalTo(self.view).offset(-horSpace)
            make.height.equalTo(44)
        }
        
    }

}

extension YXIdCardActivateViewController {
    func viewModelResponse() {
        //登錄成功的回調
        viewModel.loginSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
            if let vc = self?.viewModel.vc {
                self?.navigationController?.popToViewController(vc, animated: true)
            }else {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        
        //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
        viewModel.lockedSubject.subscribe(onNext: { [weak self] msg in
            self?.showLockedAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        //手机账户被冻结
        viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            self?.showFreezeAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        //没有注册回调
        viewModel.unRegisteredSubject.subscribe(onNext: { [weak self] msg in
            self?.unRegisteredAlert()
        }).disposed(by: disposeBag)
        //未设置登录密码
        viewModel.unsetLoginPwdSubject.subscribe(onNext: { [weak self] msg in
            self?.unsetLoginPwdAlert()
        }).disposed(by: disposeBag)
        //抱歉，验证码已过期，请重新获取
        viewModel.codeTimeOutSubject.subscribe(onNext: { [weak self] msg in
            self?.codeTimeOutAlert(withMsg: msg)
        }).disposed(by: disposeBag)
    }
    //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    func showLockedAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_backPwd"), style: .default, handler: {[weak alertView, weak self] action in
            guard let `self` = self else { return }
            
            alertView?.hide()
            // 忘记密码-输入手机
            let loginCallBack = self.viewModel.loginCallBack
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: self.viewModel.code, phone: self.viewModel.phone.value, isLogin: false, callBack: self.fillPhone, loginCallBack: loginCallBack, fromVC:self,sourceVC:self.viewModel.vc))
            self.viewModel.navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
        }))
        alertView.showInWindow()
    }
    //手机账户被冻结
    func showFreezeAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_isOK"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
    //没有注册回调
    func unRegisteredAlert() {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_phoneUnRegistered"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_registered"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                let areaCode = self.viewModel.code
                let phone = self.viewModel.phone.value
                let context = YXNavigatable(viewModel: YXRegisterCodeViewModel(withCode: areaCode, phone: phone, sendCaptchaType: .type106, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
                self.viewModel.navigator.push(YXModulePaths.registerCode.url, context: context)
            })
        }))
        alertView.showInWindow()
        
    }
    //未设置登录密码
    func unsetLoginPwdAlert() {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(title: "", message: YXLanguageUtility.kLang(key: "login_unsetLoginPwd"), prompt: YXLanguageUtility.kLang(key: "login_unsetLoginPwdContent"), style: .default)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_captchaLogin"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            
            let areaCode = self.viewModel.code
            let phone = self.viewModel.phone.value
            let context = YXNavigatable(viewModel: YXRegisterCodeViewModel(withCode: areaCode, phone: phone, sendCaptchaType: .type106, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
            self.viewModel.navigator.push(YXModulePaths.registerCode.url, context: context)
        }))
        alertView.showInWindow()
    }
    
    //抱歉，验证码已过期，请重新获取
    func codeTimeOutAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_revalidation"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            //返回到 验证码登录页面
            let allViewControllers = self.navigationController?.viewControllers
            for vc in allViewControllers ?? [] {
                if vc.isKind(of: YXDefaultLoginViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }))
        alertView.showInWindow()
    }
}
