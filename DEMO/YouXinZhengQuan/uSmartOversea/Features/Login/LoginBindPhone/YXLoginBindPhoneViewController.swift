//
//  YXLoginBindPhoneViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：引导绑定手机号码
 绑定手机号码 */
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import TYAlertController
import YXKit

class YXLoginBindPhoneViewController: YXHKViewController, HUDViewModelBased/*,YXAreaCodeBtnProtocol*/ {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXLoginBindPhoneViewModel!
    
    private var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var headTitleView : YXDoubleTitleView = {
        let view = YXDoubleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "mobile_acount"), subTitle: YXLanguageUtility.kLang(key: "email_acount"))
        return view
    }()
    
    lazy var mobileBindView : YXBindAccountView = {
        let view = YXBindAccountView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        view.bindBtn.setTitle(YXLanguageUtility.kLang(key: "bind_btn"), for: .normal)
        view.bindBtn.setTitle(YXLanguageUtility.kLang(key: "bind_btn"), for: .disabled)
        return view
    }()
    
    lazy var emailBindView : YXBindAccountView = {
        let view = YXBindAccountView.init(type: .email)
        view.bindBtn.setTitle(YXLanguageUtility.kLang(key: "bind_btn"), for: .normal)
        view.bindBtn.setTitle(YXLanguageUtility.kLang(key: "bind_btn"), for: .disabled)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
        viewModelResponse()
    }

    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        return false
    }
    
    func bindViewModel() {

        self.viewModel.mobile.bind(to: mobileBindView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailBindView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileBindView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailBindView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
        mobileBindView.pwdTextFeild.textField.rx.text.orEmpty.bind(to: self.viewModel.mPwd).disposed(by: disposeBag)
        emailBindView.pwdTextFeild.textField.rx.text.orEmpty.bind(to: self.viewModel.ePwd).disposed(by: disposeBag)
        
        self.viewModel.mCaptcha.bind(to: mobileBindView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        mobileBindView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.mCaptcha).disposed(by: disposeBag)

        self.viewModel.eCaptcha.bind(to: emailBindView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        emailBindView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.eCaptcha).disposed(by: disposeBag)
      
        
        let phoneTextField:YXPhoneTextField = self.mobileBindView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)
        
        headTitleView.didChanage = { [weak self] title in
            self?.viewModel.handelAccountChanage(title: title)
        }
        

        self.viewModel.emailHidden.bind(to: emailBindView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileBindView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mEverythingValid?.bind(to: mobileBindView.bindBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eEverythingValid?.bind(to: emailBindView.bindBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.ePassWordValid?.bind(to: emailBindView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mPassWordValid?.bind(to: mobileBindView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mUsernameValid?.bind(to: mobileBindView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eUsernameValid?.bind(to: emailBindView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
    
        
        mobileBindView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.alertReceiveCodeHelp()
        }).disposed(by: disposeBag)
        emailBindView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.alertReceiveCodeHelp()
        }).disposed(by: disposeBag)
        
        mobileBindView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.viewModel.sendMobileCodeRequest()
        }).disposed(by: disposeBag)
        
        emailBindView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.viewModel.sendEmailCodeRequest()
        }).disposed(by: disposeBag)
        
        mobileBindView.bindBtn.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else {return}
            self.viewModel.bindMobileRequest()
        }).disposed(by: disposeBag)
        
        emailBindView.bindBtn.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else {return}
            self.viewModel.bindEmailRequest()
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        
        //左侧返回按钮
        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            guard let strongSelf = self else { return }
//            if let fillPhone = strongSelf.viewModel.fillPhone {
//                fillPhone([strongSelf.viewModel.phone.value, strongSelf.viewModel.code])
//            }
            strongSelf.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItems = [backItem]
        

        
        self.view.addSubview(scrollView)

        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }

        
        scrollView.addSubview(headTitleView)
        headTitleView.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(60)
        }
        
        scrollView.addSubview(mobileBindView)
        mobileBindView.snp.makeConstraints { (make) in
            make.top.equalTo(headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            make.height.equalTo(332)

        }
        
        scrollView.addSubview(emailBindView)
        emailBindView.isHidden = true
        emailBindView.snp.makeConstraints { (make) in
            make.size.equalTo(mobileBindView)
            make.top.left.equalTo(mobileBindView)
        }
        
    }
    
    //该手机号码已经注册\n是否登录？
    func phoneRegisteredAlert() {
        //【手机号码已注册，如需找回，请联系客服】
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_bindRegisterTip"))//login_phoneRegistered
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            alertView?.hide()
        }))
        //login_goLogin
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: { [weak alertView, weak self] action in
            
            alertView?.hide()
            self?.serviceAction()//展示 【联系客服】 弹框
        }))
        alertView.showInWindow()
    }
   
    
    fileprivate func alertReceiveCodeHelp(){
        let  alertVC = YXAlertViewFactory.helpAlertView(type: self.viewModel.accoutType.value)
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func goLoginAlert(withMsg msg: String) {
        self.view.endEditing(true)
        let  alertVc = YXAlertViewFactory.hasSignUPAlertView(massage: msg) {[weak self] in
            self?.viewModel.gotoLogin()
        }
        alertVc.backgoundTapDismissEnable = true
        self.present(alertVc, animated: true, completion: nil)
    }
    
    func viewModelResponse() {
        
        //登錄成功的回調
        viewModel.threeTelAggSucSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
            self?.loginSuccessBack(self?.viewModel.vc, loginCallBack: self?.viewModel.loginCallBack)
//            if YXLaunchGuideManager.isGuideToLogin() == false {
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//                if let vc = self?.viewModel.vc {
//                    if self?.navigationController?.viewControllers.contains(vc) ?? false {
//                        self?.navigationController?.popToViewController(vc, animated: true)
//                        return
//                    }
//                }
//                self?.navigationController?.popToRootViewController(animated: true)
//
//            } else {
//                YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//            }
            
        }).disposed(by: disposeBag)
        
        self.viewModel.eCodeSubject.subscribe(onNext:{ [weak self] (argument) in
            guard let `self` = self else {return}
            self.emailBindView.verifictionCodeField.send()
            self.emailBindView.verifictionCodeField.textField.becomeFirstResponder()
            if argument.0 == true {
                if YXConstant.isAutoFillCaptcha() {
                    self.viewModel.eCaptcha.accept(argument.1)
                    self.emailBindView.verifictionCodeField.showDefaultTip()
                }
            }
        }).disposed(by: disposeBag)
        self.viewModel.mCodeSubject.subscribe(onNext:{ [weak self]  (argument) in
            guard let `self` = self else {return}
            self.mobileBindView.verifictionCodeField.send()
            self.mobileBindView.verifictionCodeField.textField.becomeFirstResponder()
            if argument.0 == true {
                if YXConstant.isAutoFillCaptcha() {
                    self.viewModel.mCaptcha.accept(argument.1)
                    self.mobileBindView.verifictionCodeField.showDefaultTip()
                }
            }
        }).disposed(by: disposeBag)
        
       
        //已经绑定
        self.viewModel.thirdPhoneBindedSubject.subscribe(onNext:{ [weak self] (res) in
            guard let `self` = self else {return}
            self.goLoginAlert(withMsg: res.1)
        }).disposed(by: disposeBag)
        
        //已经邮箱绑定
        self.viewModel.thirdPhoneBindedSubject.subscribe(onNext:{ [weak self] (res) in
            guard let `self` = self else {return}
            self.goLoginAlert(withMsg: res.1)
        }).disposed(by: disposeBag)
    }

}

extension YXLoginBindPhoneViewController {
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            self.viewModel.areaCode.accept(code)
            let phoneTextField:YXPhoneTextField = self.mobileBindView.acountField as! YXPhoneTextField
            phoneTextField.areaCodeLale.text = "+\(code)"
                        
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)
    }
}
