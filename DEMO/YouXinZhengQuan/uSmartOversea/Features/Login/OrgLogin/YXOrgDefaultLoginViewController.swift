//
//  YXOrgDefaultLoginViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

import SnapKit
import Firebase
import YXKit
import TYAlertController

class YXOrgDefaultLoginViewController: YXHKViewController, HUDViewModelBased /*YXAreaCodeBtnProtocol*/ {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXOrgLoginViewModel!

    /**实现填充手机号、区号。
     要传给:
     1. ”密码登录页面“
     2. 密码错误次数过多要去的”找回密码页面“
     3. 三方登录的”绑定手机号页面“。*/
    var fillPhone: (([String]) -> Void)!
    
    private var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentSize.width = 0
        return scrollView
    }()
    //地区手机码
//    lazy var areaBtn: UIButton = self.buildAreaBtn()
    
    lazy var headTitleView : YXOrgTitleView = {
        if self.viewModel.accoutType.value == .mobile {
            let view = YXOrgTitleView.init(type: .mobile, title: YXLanguageUtility.kLang(key: "org_login_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_title"))
            return view
        } else {
            let view = YXOrgTitleView.init(type: .emailOrDolphin, title: YXLanguageUtility.kLang(key: "org_login_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_title"))
            return view
        }
    }()
    
    lazy var mobileSignInView : YXOrgSignInView = {
        let view = YXOrgSignInView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        return view
    }()
    
    lazy var emailSignInView : YXOrgSignInView = {
        let view = YXOrgSignInView.init(type: .emailOrDolphin)
        return view
    }()
    
    lazy var declareView : YXDeclareView = {
        let view = YXDeclareView.init(frame: .zero)
        return view
    }()

    lazy var bannerView: YXLoginAdvView = {
        let view = YXLoginAdvView()
        view.didCloseBlock = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showBanner(false)
        }
        view.tapBannerBlock = {[weak self] (index) in
            guard let strongSelf = self else { return }

            if index < strongSelf.viewModel.adListRelay.value.count {
                let model = strongSelf.viewModel.adListRelay.value[index]
                let url = model.jumpURL ?? ""
                if url.count > 0 {
                    YXBannerManager.goto(withBanner: model, navigator: strongSelf.viewModel.navigator)
                }
            }
        }
        return view
    }()
    
    
    //MARK: life cycle
    deinit {
        print("sss")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        viewModelResponse()
        setupNavigationBar()
        
        bindHUD()
        
        self.fillPhone = {[weak self] arr in
            guard let `self` = self else { return }
            if self.viewModel.accoutType.value == .email {
                
                self.emailSignInView.acountField.textField.rx.text.onNext(arr[0])
                self.viewModel.email = BehaviorRelay<String>(value: arr[0])

                self.emailSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: self.disposeBag)
                self.emailSignInView.signInBtn.isEnabled = (self.viewModel.email.value.count > 0 && self.viewModel.ePwd.value.count > 0)

            } else {
                self.mobileSignInView.acountField.textField.rx.text.onNext(arr[0])
                self.viewModel.mobile = BehaviorRelay<String>(value: arr[0])
                self.viewModel.areaCode.accept(arr[1])
                self.mobileSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: self.disposeBag)
                self.mobileSignInView.signInBtn.isEnabled = (self.viewModel.mobile.value.count > 0 && self.viewModel.mPwd.value.count > 0)
            }
//
        }
        
        self.viewModel.requestAdData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let phoneText = self.phoneInputView.textField.text,phoneText.count > 6 {
//            self.loginBtn.isEnabled = true
//        }
    }
    
    func bindViewModel() {
        
        self.viewModel.mobile.bind(to: mobileSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
        mobileSignInView.passWordField.textField.rx.text.orEmpty.bind(to: self.viewModel.mPwd).disposed(by: disposeBag)
        emailSignInView.passWordField.textField.rx.text.orEmpty.bind(to: self.viewModel.ePwd).disposed(by: disposeBag)

        viewModel.ePwd.bind(to: emailSignInView.passWordField.textField.rx.text).disposed(by: disposeBag)
        viewModel.mPwd.bind(to: mobileSignInView.passWordField.textField.rx.text).disposed(by: disposeBag)
        
        mobileSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.mobile.accept("")
        }).disposed(by: disposeBag)
        
        emailSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.email.accept("")
        }).disposed(by: disposeBag)
        
        mobileSignInView.passWordField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.mPwd.accept("")
        }).disposed(by: disposeBag)
        
        emailSignInView.passWordField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.ePwd.accept("")
        }).disposed(by: disposeBag)
        
        let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)
        
        headTitleView.didChanage = { [weak self] type in
            if type == .mobile {
                self?.viewModel.handelAccountChanage(title: YXLanguageUtility.kLang(key: "org_mobile_acount"))
            } else {
                self?.viewModel.handelAccountChanage(title: YXLanguageUtility.kLang(key: "acount_title"))
            }
        }
        
        self.viewModel.emailHidden.bind(to: emailSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mEverythingValid?.bind(to: mobileSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eEverythingValid?.bind(to: emailSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
        
       
        
        //激活
        mobileSignInView.goActivityBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.goActivate()
        }).disposed(by: disposeBag)
        
        emailSignInView.goActivityBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.goActivate()
        }).disposed(by: disposeBag)
        
        
        //忘记密码
        mobileSignInView.fogotPasswordBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.forgetPwd()
        }).disposed(by: disposeBag)
        
        emailSignInView.fogotPasswordBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.forgetPwd()
        }).disposed(by: disposeBag)
        


        
        //登录
        emailSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.loginReuqest()
            
        }).disposed(by: disposeBag)
        
        mobileSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.loginReuqest()
            
        }).disposed(by: disposeBag)
        
        self.viewModel.accoutType.accept(self.viewModel.accoutType.value)

        declareView.didClickPrivacy = {[weak self]  in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        declareView.didClickService = {[weak self] in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
    
    
    func initUI() {
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(headTitleView)
        scrollView.addSubview(mobileSignInView)
        scrollView.addSubview(emailSignInView)
        scrollView.addSubview(declareView)

        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        headTitleView.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(60)
        }
        
        mobileSignInView.snp.makeConstraints { (make) in
            make.top.equalTo(headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            make.height.equalTo(244)

        }
        
        emailSignInView.snp.makeConstraints { (make) in
            make.size.equalTo(mobileSignInView)
            make.top.left.equalTo(mobileSignInView)
        }
        
        declareView.snp.makeConstraints { (make) in
            make.top.equalTo(mobileSignInView.snp.bottom).offset(17)
            make.left.equalTo(30.sacel375())
            make.right.equalTo(-30.sacel375())
            make.height.equalTo(36.sacel375())
        }
        
        scrollView.addSubview(bannerView)
       
        bannerView.snp.makeConstraints { make in
            make.left.equalTo(scrollView.snp.left).offset(12)
            make.right.equalTo(self.view.snp.right).offset(-12)
            
            make.top.equalTo(declareView.snp.bottom).offset(0)
            if YXConstant.screenHeight < 812 {//12 mini
                make.bottom.equalTo(self.scrollView.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(self.scrollView.snp.bottom).offset(-42)
            }
            make.height.equalTo(self.bannerView.snp.width).multipliedBy(70.0/350.0)
        }

    }
    //MARK: - 导航栏 密码登录、返回
    func setupNavigationBar() {
        
    }
    
}


extension YXOrgDefaultLoginViewController {
//    func showAreaAlert() {
//        let hotAreaCount = YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry?.count ?? 0
//        let viewHeight: CGFloat = CGFloat(hotAreaCount + 1) * 48.0
//        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: YXConstant.screenWidth, height: viewHeight + 34.0 ))
//
//        let areaCodeView = YXAreaCodeAlertView(frame: CGRect(x: 20, y: 0, width: YXConstant.screenWidth - 40, height: viewHeight), selectCode: self.viewModel.code)
//        bgView.addSubview(areaCodeView)
//
//        let alertVc = TYAlertController(alert: bgView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade)
//        alertVc!.backgoundTapDismissEnable = true
//        areaCodeView.didSelected = { [weak alertVc, weak self, weak bgView] code in
//            guard let `self` = self else { return }
//            if code.count > 0 {
//                self.phoneInputView.textField.becomeFirstResponder()
//                self.viewModel.code = code
//                self.areaBtn.setTitle(String(format: "+%@", code), for: .normal)
//                self.setImageEdgeInsets()
//                alertVc?.dismissViewController(animated: true)
//            } else {
//
//                //alertVc?.dismissViewController(animated: false)
//                alertVc?.dismissComplete = {[weak self] in
//                    self?.showMoreAreaAlert()
//                }
//                bgView?.hide()
//            }
//
//        }
//
//
//        self.present(alertVc!, animated: true, completion: nil)
//    }
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
            phoneTextField.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCode.accept(code)

        }).disposed(by: self.disposeBag)

        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)

    }
}

//MARK: 接口返回的 处理
extension YXOrgDefaultLoginViewController {
    
    func viewModelResponse() {
        //登錄成功的回調
        viewModel.loginSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
            self?.loginSuccessBack(self?.viewModel.vc, loginCallBack: self?.viewModel.loginCallBack)

//            if YXLaunchGuideManager.isGuideToLogin() == false {
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//
//                if let vc = self?.viewModel.vc {
//                    if self?.navigationController?.viewControllers.contains(vc) ?? false {
//                        self?.navigationController?.popToViewController(vc, animated: true)
//                        return
//                    }
//                }
//                self?.navigationController?.popToRootViewController(animated: true)
//            } else {
//                YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//                if ((self?.viewModel.loginCallBack) == nil) {//防止异常处理，没有传入回调
//                    YXUserManager.registerLoginInitRootViewControler()
//                }
//            }

        }).disposed(by: disposeBag)
//
        //校验通过
        viewModel.checkAccountSubject.subscribe(onNext: { [weak self] msg in
            guard let `self` = self else { return }
            self.viewModel.hudSubject?.onNext(.loading(nil, false))

            //区分邮箱，手机
            if self.viewModel.accoutType.value == .email {
                
                var emaile = (self.viewModel.email.value as String).removePreAfterSpace()
                emaile = YXUserManager.safeDecrypt(string: emaile)
                let password = YXUserManager.safeDecrypt(string: self.viewModel.ePwd.value)
                self.viewModel.services.aggregationService.request(.orgEmailPwdLogin(emaile, password), response: self.viewModel.loginResponse).disposed(by: self.disposeBag)

            } else if(self.viewModel.accoutType.value == .mobile) {
                
                let code = self.viewModel.areaCode.value
                var phone = (self.viewModel.mobile.value as String).removePreAfterSpace()
                phone = YXUserManager.safeDecrypt(string: phone)
                let password = YXUserManager.safeDecrypt(string: self.viewModel.mPwd.value)
                self.viewModel.services.aggregationService.request(.orgPhoneLogin(code, phone, password), response: self.viewModel.loginResponse).disposed(by: self.disposeBag)

            }
        }).disposed(by: disposeBag)

        viewModel.jumpPersonAccontSubject.subscribe(onNext: { [weak self] msg in
            
            let alertView = YXAlertView(title: msg, message: nil, prompt: nil, style: .default)
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "org_personal_invertor_login"), style: .default, handler: {[weak alertView,self] action in
                alertView?.hide()
                self?.viewModel.navigator.popViewModel(animated: true)
            }))
            alertView.showInWindow()

        }).disposed(by: disposeBag)

        viewModel.alertMsgSubject.subscribe(onNext: { msg in
            let alertView = YXAlertView(message: msg)
            alertView.clickedAutoHide = false

            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in

                alertView?.hide()
            }))
            alertView.showInWindow()
        }).disposed(by: disposeBag)

        viewModel.activationSubject.subscribe(onNext: {[weak self] model in
            guard let `self` = self else { return }
            let alertView = YXAlertView(message: model.msg)
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_goToActivate"), style: .default, handler: {[weak alertView, weak self] action in
                guard let `self` = self else { return }
                alertView?.hide()
                if self.viewModel.accoutType.value == .email {
                    
                    
                    let email = self.emailSignInView.acountField.textField.text ?? ""
                    if email.isValidEmail() {
                        let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: "", email: self.viewModel.email.value, isEmail: true, isExitPwd: model.existPassword, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
                        self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)
                    } else {
                        self.goActivate()
                    }
                    
                } else  {
                    let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: self.viewModel.mobile.value, email: "", isEmail: false, isExitPwd: model.existPassword, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
                    self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)
                }
                
            }))
            alertView.showInWindow()

        }).disposed(by: disposeBag)
        
        viewModel.pwdErrorSubject.subscribe(onNext: {[weak self] msg in
            guard let `self` = self else { return }
            let alertView = YXAlertView(title: msg, message: nil, prompt: nil, style: .default)
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_findPwd"), style: .default, handler: {[weak alertView,self] action in
                alertView?.hide()
                self.forgetPwd()
                
            }))
            alertView.showInWindow()
            
        }).disposed(by: disposeBag)
        
        //adListRelay订阅信号的实现，banner广告展示
        viewModel.adListRelay.asDriver().skip(1).drive(onNext: { [weak self] (adList) in
            guard let `self` = self else {return}

            if adList.count > 0 {
                var adImageUrls = [String]()
                adList.forEach({ (model) in
                    adImageUrls.append(model.pictureURL ?? "")
                })
                self.bannerView.imageURLStringsGroup = adImageUrls
                self.showBanner(true)
            } else {
                self.showBanner(false)
            }

        }).disposed(by: disposeBag)
    }
    
    func loginReuqest() {
        if self.viewModel.accoutType.value == .email {
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            var email = (self.viewModel.email.value as String).removePreAfterSpace()
            email = YXUserManager.safeDecrypt(string: email)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount("", "", 2, email), response: self.viewModel.checkAccountResponse)
                .disposed(by: `self`.disposeBag)
        } else {
            
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            let areaCode = self.viewModel.areaCode.value
            var phoneNumber = (self.viewModel.mobile.value as String).removePreAfterSpace()
            phoneNumber = YXUserManager.safeDecrypt(string: phoneNumber)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount(areaCode, phoneNumber, 1, ""), response: self.viewModel.checkAccountResponse)
                .disposed(by: `self`.disposeBag)
        }
       
    }
    
    func forgetPwd() {
        
        if self.viewModel.accoutType.value == .email {
            
            let loginCallBack = self.viewModel.loginCallBack
            let fogertPwdPhoneModel = YXOrgForgetPwdCheckAccountViewModel(with: self.viewModel.accoutType.value, code: self.viewModel.areaCode.value, phone: "", email: self.emailSignInView.acountField.textField.text ?? "", isLogin: false, callBack: self.fillPhone, loginCallBack: loginCallBack, fromVC: self, sourceVC:self.viewModel.vc)
            
            let context = YXNavigatable(viewModel: fogertPwdPhoneModel)
            self.viewModel.navigator.push(YXModulePaths.orgForgetPwdCheckAccount.url, context: context)
            
        } else {
            
            let loginCallBack = self.viewModel.loginCallBack
            let fogertPwdPhoneModel = YXOrgForgetPwdCheckAccountViewModel(with: self.viewModel.accoutType.value, code: self.viewModel.areaCode.value, phone: self.mobileSignInView.acountField.textField.text ?? "", email: "", isLogin: false, callBack: self.fillPhone, loginCallBack: loginCallBack, fromVC: self, sourceVC:self.viewModel.vc)
            
            let context = YXNavigatable(viewModel: fogertPwdPhoneModel)
            self.viewModel.navigator.push(YXModulePaths.orgForgetPwdCheckAccount.url, context: context)
        }
    }
    
    func goActivate() {
        
        let loginCallBack = self.viewModel.loginCallBack
        var fogertPwdPhoneModel = YXOrgCheckActivateViewModel(with: self.viewModel.accoutType.value, code: self.viewModel.areaCode.value, phone: self.mobileSignInView.acountField.textField.text ??  "", email: "", fromVC: self.viewModel.vc, loginCallBack: loginCallBack)
        
        if self.viewModel.accoutType.value == .email {
            var email = self.emailSignInView.acountField.textField.text ?? ""
            if email.isValidEmail() == false {
                email = ""
            }
            fogertPwdPhoneModel = YXOrgCheckActivateViewModel(with: self.viewModel.accoutType.value, code: self.viewModel.areaCode.value, phone: "", email: self.emailSignInView.acountField.textField.text ?? "", fromVC: self.viewModel.vc, loginCallBack: loginCallBack)
        }
        
        let context = YXNavigatable(viewModel: fogertPwdPhoneModel)
        self.viewModel.navigator.push(YXModulePaths.orgCheckActiviteAccount.url, context: context)
    }
    
    
    @objc func closeBannerAction() {
        self.showBanner(false)
    }
    @objc func showBanner(_ show: Bool) {
        
        self.bannerView.isHidden = !show
        if show {
            bannerView.snp.remakeConstraints { make in
                make.left.equalTo(scrollView.snp.left).offset(12)
                make.right.equalTo(self.view.snp.right).offset(-12)
                make.top.equalTo(declareView.snp.bottom).offset(40)
                
                if (YXConstant.screenHeight < 812) {//12 mini
                    make.bottom.equalTo(self.scrollView.snp.bottom).offset(-20)
                }  else {
                    make.bottom.equalTo(self.scrollView.snp.bottom).offset(-42)
                }
                make.height.equalTo(self.bannerView.snp.width).multipliedBy(70.0/350.0)
            }
            
        } else {
            bannerView.snp.remakeConstraints { make in
                make.left.equalTo(scrollView.snp.left).offset(12)
                make.right.equalTo(self.view.snp.right).offset(-12)
                make.top.equalTo(declareView.snp.bottom).offset(0)
                if YXConstant.screenHeight < 812 {
                    make.bottom.equalTo(self.scrollView.snp.bottom).offset(-20)
                } else {
                    make.bottom.equalTo(self.scrollView.snp.bottom).offset(-42)
                }
                make.height.equalTo(self.bannerView.snp.width).multipliedBy(0)
            }
        }
    }
}

