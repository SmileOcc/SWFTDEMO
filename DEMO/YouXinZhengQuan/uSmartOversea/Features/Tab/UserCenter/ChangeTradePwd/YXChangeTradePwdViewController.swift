//
//  YXChangeTradePwdViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*  模块：修改交易密码
    .old        请验证原交易密码
    .new        请设置新交易密码
    .confirm    请确认新交易密码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

enum YXChangeTradePwdType{
    case old
    case new
    case confirm
}

enum YXTradePwdFunType{
    case change
    case forget
  
}

class YXChangeTradePwdViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangeTradePwdViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var gridInputView: YXGridInputView = {
        let gridWidth:CGFloat
        switch YXConstant.screenSize {
        case .size3_5,.size4:
            gridWidth = 40
        default:
            gridWidth = 50
        }
        let view = YXGridInputView(gridWidth: gridWidth, viewWidth: UIScreen.main.bounds.width-40, isSecure: true)
        if #available(iOS 12.0, *) {
            view.textField.textContentType = .oneTimeCode
        }
        return view
    }()
    //【忘记密码？】
    var forgetPwdBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_forget_pwd"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
    //右导航栏-消息
        self.navigationItem.rightBarButtonItems = [messageItem]
        
        self.gridInputView.textField.becomeFirstResponder()
        self.view.addSubview(scrollView)
        scrollView.addSubview(gridInputView)
        scrollView.addSubview(forgetPwdBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let tipLab = UILabel()
        tipLab.numberOfLines = 0
        switch self.viewModel.type! {
        case .old://第1步
            tipLab.text = YXLanguageUtility.kLang(key: "mine_old_tpwd")
            break
        case .new://第2步
            tipLab.text = YXLanguageUtility.kLang(key: "mine_new_tpwd")
            forgetPwdBtn.isHidden = true
            break
        case .confirm://第3步
            tipLab.text = YXLanguageUtility.kLang(key: "mine_confirm_tpwd_tip")
            forgetPwdBtn.isHidden = true
            break
        }
        tipLab.font = UIFont.systemFont(ofSize: 28)
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(18)
            make.right.equalTo(strongSelf.view).offset(-18)
            //make.height.equalTo(40)
        }
        
        let tipLab2 = UILabel()
        tipLab2.text = YXLanguageUtility.kLang(key: "mine_tpwd_tip")
        tipLab2.font = UIFont.systemFont(ofSize: 14)
        tipLab2.textColor = QMUITheme().textColorLevel3()
        scrollView.addSubview(tipLab2)
        tipLab2.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(4)
            make.left.equalTo(scrollView).offset(18)
            make.height.equalTo(20)
        }
        
        gridInputView.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab2.snp.bottom).offset(50)
            make.left.equalTo(scrollView).offset(20)
            make.height.equalTo(50)
            make.right.equalTo(self.view).offset(-20)
        }
        
        forgetPwdBtn.snp.makeConstraints { (make) in
            make.right.equalTo(gridInputView)
            make.top.equalTo(gridInputView.snp.bottom).offset(12)
        }
        
    }
  
    func bindViewModel() {
        //MARK: - 输入完成，执行接口
        gridInputView.textField.rx.text.orEmpty.asObservable()
            .filter {
                $0.count >= 6
            }
            .subscribe(onNext: { [weak self] string in
                guard let `self` = self else { return }
                self.gridInputView.clearText()
                self.gridInputView.textField.resignFirstResponder()
                switch self.viewModel.type! {
                case .old:
                    self.viewModel.hudSubject.onNext(.loading("", false))
                    self.viewModel.oldPwd = string
                    let pwd = YXUserManager.safeDecrypt(string: string)
                    self.viewModel.services.userService.request(.checkTradePwd(pwd), response: self.viewModel.checkPwdResponse).disposed(by: self.disposeBag)
                    break
                case .new:
                    self.gridInputView.clearText()
                    let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .confirm, funType: self.viewModel.funType, oldPwd: self.viewModel.oldPwd, pwd: string, captcha: self.viewModel.captcha, vc: self.viewModel.vc))
                    self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
                    break
                case .confirm:
                    if string == self.viewModel.pwd {
                        self.viewModel.hudSubject.onNext(.loading("", false))
                        if self.viewModel.funType == YXTradePwdFunType.change {  //修改交易密碼
                            let oldPwd = YXUserManager.safeDecrypt(string: self.viewModel.oldPwd)
                            let pwd = YXUserManager.safeDecrypt(string: self.viewModel.pwd)
                            self.viewModel.services.userService.request(.changeTradePwd(oldPwd, pwd), response: self.viewModel.changePwdResponse).disposed(by: self.disposeBag)
                        }else { //忘記交易密碼
                            let pwd = YXUserManager.safeDecrypt(string: self.viewModel.pwd)
                            let captcha = self.viewModel.captcha.removePreAfterSpace()
                            self.viewModel.services.userService.request(.resetTradePwd(pwd, captcha), response: self.viewModel.resetPwdResponse).disposed(by: self.disposeBag)
                        }
                    } else {
                        self.showInfo(msg: YXLanguageUtility.kLang(key: "mine_pwd_diff"))
                    }
                    
                    break
                }
            })
            .disposed(by: disposeBag)
        //【忘记密码？】
        forgetPwdBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.loading("", false))
            /*获取客户开户证件类型
             1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
             get-customer-identify-type/v1 */
            strongSelf.viewModel.services.userService.request(.idType, response: strongSelf.viewModel.idTypeResponse).disposed(by: strongSelf.disposeBag)
        }).disposed(by: disposeBag)
        //MARK: - viewModel
        viewModel.checkSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .new, funType: self.viewModel.funType, oldPwd: self.viewModel.oldPwd, pwd: "", captcha: self.viewModel.captcha, vc: self.viewModel.vc))
            self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
        }).disposed(by: disposeBag)
        
        viewModel.pwdErrorSubject.subscribe(onNext: {[weak self] (msg) in
            self?.showErrorAlert(msg: msg, title: YXLanguageUtility.kLang(key: "mine_enter_again"))
        }).disposed(by: disposeBag)
        
        viewModel.pwdLockSubject.subscribe(onNext: {[weak self] (msg) in
            self?.showErrorAlert(msg: msg, title: YXLanguageUtility.kLang(key: "common_close"))
        }).disposed(by: disposeBag)
        
        viewModel.digitalErrorSubject.subscribe(onNext: {[weak self] (msg) in
            self?.showInfo(msg: msg)
        }).disposed(by: disposeBag)
        
        viewModel.changeSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            //FIXME:修改交易密码--忘记密码--输入验证码--设置新交易密码--成功，应该是直接返回到修改交易密码的前一个页面
            self.navigationController?.popToViewController(self.viewModel.vc, animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.idTypeSuccessSubject.subscribe(onNext: {[weak self] (type) in
            guard let `self` = self else { return }
            
            if YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false {
                let context = YXNavigatable(viewModel: YXOrgRegisterNumberVertifyViewModel(vc: self.viewModel.vc))
                self.viewModel.navigator.push(YXModulePaths.orgCheckRegisterNumber.url, context: context)

            } else {
                let context = YXNavigatable(viewModel: YXAuthenticateViewModel(type: type, vc: self.viewModel.vc))
                self.viewModel.navigator.push(YXModulePaths.authenticate.url, context: context)
            }
        }).disposed(by: disposeBag)
    }
    
    func showErrorAlert(msg: String, title: String) {
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: title, style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
            self.gridInputView.textField.becomeFirstResponder()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_backPwd"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            
            self.viewModel.hudSubject.onNext(.loading("", false))
            self.viewModel.services.userService.request(.idType, response: self.viewModel.idTypeResponse).disposed(by: self.disposeBag)
        }))
        alertView.showInWindow()
    }
    
    func showInfo(msg: String) {
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_enter_again"), style: .default, handler: {[weak alertView, weak self] action in
            guard let `self` = self else { return }
            alertView?.hide()
            let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .new, funType: self.viewModel.funType, oldPwd: self.viewModel.oldPwd, pwd: "", captcha: self.viewModel.captcha, vc: self.viewModel.vc))
            self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
        }))
        alertView.showInWindow()
    }
    
    func backAlert() {
        
        var msg = ""
        if viewModel.funType == .change {
            msg = YXLanguageUtility.kLang(key: "mine_giveup_change")
        }else {
            msg = YXLanguageUtility.kLang(key: "mine_giveup_forget")
        }
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_no"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_yes"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            self.back()
        }))
        alertView.showInWindow()
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        backAlert()
        return false
    }
    
    func back() {
        if self.viewModel.funType == YXTradePwdFunType.forget {

            for vc in self.navigationController?.viewControllers ?? [] {
                if let viewController = vc as? YXChangeTradePwdViewController {
                    if viewController.viewModel.funType == YXTradePwdFunType.change {
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
        }
        self.navigationController?.popToViewController(self.viewModel.vc, animated: true)
    }
 
}
