//
//  YXDefaultLoginViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//默认登入方式  ----短讯验证(个人投资者)
import UIKit
import Reusable
import RxSwift
import RxCocoa

import SnapKit
import Firebase
import GoogleSignIn
import YXKit
import TYAlertController
import AuthenticationServices

protocol YXAreaCodeBtnProtocol {
    var areaBtn: UIButton { get }
    func buildAreaBtn() -> UIButton
    func setImageEdgeInsets()
}
extension YXAreaCodeBtnProtocol where Self: YXHKViewController {
    internal func buildAreaBtn() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setImage(UIImage.qmui_image(with: .triangle, size: CGSize(width: 6, height: 4), tintColor: QMUITheme().textColorLevel1())?.qmui_image(with: .down), for: .normal)
        btn.setTitle("+\(YXUserManager.shared().defCode)", for: .normal)
        return btn
    }
    //設置地區手機碼的圖片和文字
    internal func setImageEdgeInsets() {
        areaBtn.sizeToFit()
        if let imgWidth = areaBtn.imageView?.image?.size.width {
            areaBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imgWidth-5, bottom: 0, right: imgWidth+5)
        }
        if let titleWidth = areaBtn.titleLabel?.qmui_width {
            areaBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth, bottom: 0, right: -titleWidth)
            areaBtn.snp.updateConstraints { (make) in
                make.width.equalTo(titleWidth + 20)
            }
        }
    }
}


class YXDefaultLoginViewController: YXHKViewController, HUDViewModelBased /*YXAreaCodeBtnProtocol*/ {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXLoginViewModel!

    /**实现填充手机号、区号。
     要传给:
     1. ”密码登录页面“
     2. 密码错误次数过多要去的”找回密码页面“
     3. 三方登录的”绑定手机号页面“。*/
    var fillPhone: (([String]) -> Void)!
    
    private var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    @objc func didAppleIDBtnClicked() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let appleIDRequest = appleIDProvider.createRequest()
            appleIDRequest.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
    lazy var headTitleView : YXDoubleTitleView = {
        if self.viewModel.accoutType.value == .mobile{
        let view = YXDoubleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "mobile_acount"), subTitle: YXLanguageUtility.kLang(key: "acount_title"))
            return view
        }else {
            let view = YXDoubleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "acount_title"), subTitle: YXLanguageUtility.kLang(key: "mobile_acount"))
                return view
        }
    }()
    
    lazy var mobileSignInView : YXSignInView = {
        let view = YXSignInView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        return view
    }()
    
    lazy var emailSignInView : YXSignInView = {
        let view = YXSignInView.init(type: .emailOrDolphin)
        return view
    }()
    
    lazy var quickSignInView : YXQuickLoginView = {
        let view = YXQuickLoginView.init(hasWeChat: true)
        ///提审需要,暂时隐藏第三方入口
        view.isHidden = true
        return view
    }()
    
    lazy var declareView : YXDeclareView = {
        let view = YXDeclareView.init(frame: .zero)
        return view
    }()
    
    lazy var registBtn : QMUIButton = {
        let goRegistBtn = QMUIButton()
        goRegistBtn.setTitle(YXLanguageUtility.kLang(key: "sign_up"), for: .normal)
        goRegistBtn.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        goRegistBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        goRegistBtn.layer.borderColor = QMUITheme().mainThemeColor().cgColor
        goRegistBtn.layer.borderWidth = 1
        goRegistBtn.layer.cornerRadius = 4
        return goRegistBtn
    }()
    
    lazy var bannerView: YXLoginAdvView = {
        let view = YXLoginAdvView()
        view.isHidden = true
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

    override var pageName: String {
        //点击引导页登录注册进来的，不算灰度
        if !self.viewModel.isGuideLoginRegister && YXUserManager.isShowLoginRegister() {
            return "Login_Register"
        }
        return "Login"
    }
    
    override var pageProperties: [String : String] {
        if !self.viewModel.isGuideLoginRegister && YXUserManager.isShowLoginRegister() {
            let isShowSkip = YXUserManager.currentShowLoginRegisterSkip
            return ["skip": isShowSkip ? "hasSkip" : "noSkip"]
        }
        return [:]
    }
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forceToLandscapeRight = false
        if let appdelegate = YXConstant.sharedAppDelegate as? YXAppDelegate  {
            appdelegate.rotateScreen = false
        }
        initUI()
        bindViewModel()
        viewModelResponse()
        setupNavigationBar()
        
        bindHUD()
        
        self.viewModel.requestAdData()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        //google调用登录接口
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiGoogleLogin))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.hudSubject.onNext(.hide)
                let success = noti.userInfo?["success"] as? NSNumber ?? 0
                if success.boolValue == true {
                    strongSelf.viewModel.isThirdLogin = true
                    let code = noti.userInfo?["code"] as? String ?? ""
                    
                    strongSelf.viewModel.accessToken = code
                    strongSelf.viewModel.thirdLoginType = .google
                    
                    strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                    strongSelf.viewModel.services.aggregationService.request(.thirdLogin(code, "", nil, strongSelf.viewModel.thirdLoginType), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                } else {
                    let msg = noti.userInfo?["msg"] as? String ?? ""
                    YXProgressHUD.showError(msg)
                   // strongSelf.viewModel.hudSubject.onNext(.error(msg, false))
                }
        })
        
        
        let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)
        
        headTitleView.didChanage = { [weak self] title in
            self?.viewModel.handelAccountChanage(title: title)
        }

        self.viewModel.emailHidden.bind(to: emailSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mEverythingValid?.bind(to: mobileSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eEverythingValid?.bind(to: emailSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
       
        //清除时设置loginBtn.isEnable = false
        mobileSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.mobileSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        mobileSignInView.passWordField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.mobileSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        //清除密码输入
        emailSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.emailSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        emailSignInView.passWordField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.emailSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        mobileSignInView.fogotPasswordBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.viewModel.findPassWord(currentVC:self)
        }).disposed(by: disposeBag)
        
        emailSignInView.fogotPasswordBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.viewModel.findPassWord(currentVC:self)
        }).disposed(by: disposeBag)
        

        emailSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.grayLoginRegisterTrackViewClickEvent("Login_Register", "Login")

            self.viewModel.accountLogin()
        }).disposed(by: disposeBag)
        
        mobileSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.grayLoginRegisterTrackViewClickEvent("Login_Register", "Login")

            self.viewModel.mobileLogin()
        }).disposed(by: disposeBag)
        
        registBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.grayLoginRegisterTrackViewClickEvent("Login_Register", "Register")

            self.trackViewClickEvent(name: "Register_Tab")
            self.viewModel.gotoRegist(autoSendCaptcha: false)
        }).disposed(by: disposeBag)
        
        //MARK: 第三方登录
        quickSignInView.appleBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.grayLoginRegisterTrackViewClickEvent("Login_Register", "Apple Id")

            self?.didAppleIDBtnClicked()
        }).disposed(by: disposeBag)
        
        quickSignInView.weChatBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.grayLoginRegisterTrackViewClickEvent("Login_Register", "WeChat")

            YXShareSDKHelper.shareInstance()?.authorize(.typeWechat, withCallback: { [weak self] (success, userInfo, _) in
                            guard let strongSelf = self else { return }
                            if success {
                                //隐藏转圈
                                strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                                //请求第三方登录
                                strongSelf.viewModel.isThirdLogin = true
                                if let credential = userInfo?["credential"] as? [AnyHashable : Any],
                                    let rawData = credential["rawData"] as? [AnyHashable : Any],
                                    let access_token = rawData["access_token"] as? String,
                                    let openid = rawData["openid"] as? String {
                                    strongSelf.viewModel.accessToken = access_token
                                    strongSelf.viewModel.openId = openid
                                    strongSelf.viewModel.thirdLoginType = .weChat
                                    strongSelf.viewModel.services.aggregationService.request(.thirdLogin(access_token, openid, nil, strongSelf.viewModel.thirdLoginType), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                                }
                            }else {
                                if let _ = userInfo?["error"] {
                                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_failure"))
                                   // strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_failure"), false))
                                }else {
                                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_cancel"))
                                  //  strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_cancel"), false))
                                }
                            }
                        })
        }).disposed(by: disposeBag)
        
        quickSignInView.googleBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.grayLoginRegisterTrackViewClickEvent("Login_Register", "Google")

            self?.viewModel.hudSubject.onNext(.loading("", false))
            GIDSignIn.sharedInstance().signIn()
        }).disposed(by: disposeBag)
        
        quickSignInView.faceBookBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.grayLoginRegisterTrackViewClickEvent("Login_Register", "Facebook")

            YXShareSDKHelper.shareInstance()?.authorize(.typeFacebook, withCallback: { [weak self] (success, userInfo, _) in
                guard let strongSelf = self else { return }

                self?.viewModel.hudSubject.onNext(.hide)
                if success {
                    //隐藏转圈
                    strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                    //请求第三方登录
                    strongSelf.viewModel.isThirdLogin = true
                    if let credential = userInfo?["credential"] as? [AnyHashable : Any],
                        let rawData = credential["rawData"] as? [AnyHashable : Any],
                        let access_token = rawData["access_token"] as? String {
                        strongSelf.viewModel.accessToken = access_token
                        strongSelf.viewModel.thirdLoginType = .faceBook
                        strongSelf.viewModel.services.aggregationService.request(.thirdLogin(access_token, "", nil, strongSelf.viewModel.thirdLoginType), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                    }
                } else {
                    if let _ = userInfo?["error"] {
//                        YXLanguageUtility.kLang(key: "login_auth_failure")
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_failure"))
                       // strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_failure"), false))
                    }else {
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_cancel"))
                        //strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_cancel"), false))
                    }
                }
            })

        }).disposed(by: disposeBag)
        
        
        quickSignInView.lineBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.grayLoginRegisterTrackViewClickEvent("Login_Register", "Line")

            YXShareSDKHelper.shareInstance()?.authorize(.typeLine, withCallback: { [weak self] (success, userInfo, _) in
                guard let strongSelf = self else { return }

                self?.viewModel.hudSubject.onNext(.hide)
                if success {
                    //隐藏转圈
                    strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                    //请求第三方登录
                    strongSelf.viewModel.isThirdLogin = true
                    if let credential = userInfo?["credential"] as? [AnyHashable : Any],
                        let rawData = credential["rawData"] as? [AnyHashable : Any],
                        let uid = credential["uid"] as? String,
                        let access_token = rawData["accessToken"] as? String {
                        strongSelf.viewModel.accessToken = access_token
                        strongSelf.viewModel.thirdLoginType = .line
                        strongSelf.viewModel.lineUserId = uid
                        strongSelf.viewModel.services.aggregationService.request(.lineLogin(access_token, uid), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                    }
                } else {
                    if let _ = userInfo?["error"] {
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_failure"))
                    }else {
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "login_auth_cancel"))
                    }
                }
            })

        }).disposed(by: disposeBag)
        
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
        
        self.viewModel.accoutType.accept(self.viewModel.accoutType.value)
    }
    
    
    func initUI() {
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(headTitleView)
        scrollView.addSubview(mobileSignInView)
        scrollView.addSubview(emailSignInView)
        scrollView.addSubview(quickSignInView)
        scrollView.addSubview(declareView)
        scrollView.addSubview(registBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
//        if #available(iOS 13.0, *) {
//            let contentSize = scrollView.contentSize
//            if YXConstant.screenWidth == 320 && contentSize.height < 580 {
//                scrollView.contentSize = CGSize(width: contentSize.width, height: 580)
//            }
//        }

        headTitleView.snp.makeConstraints { (make) in
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
        
        registBtn.snp.makeConstraints { (make) in
            make.height.equalTo(48)
            make.top.equalTo(emailSignInView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
        }
        
        //提审需要暂时隐藏
        quickSignInView.snp.makeConstraints { (make) in
            //make.top.equalTo(registBtn.snp.bottom).offset(24)
            //make.height.equalTo(80)
            make.top.equalTo(registBtn.snp.bottom).offset(0)
            make.height.equalTo(0)
            make.width.equalToSuperview()
        }
        
        declareView.snp.makeConstraints { (make) in
            make.top.equalTo(quickSignInView.snp.bottom).offset(16)
            make.left.equalTo(30.sacel375())
            make.right.equalTo(-30.sacel375())
            make.height.equalTo(36.sacel375())
        }
        
        scrollView.addSubview(bannerView)
       
        
        bannerView.snp.makeConstraints { make in
            make.left.equalTo(scrollView.snp.left).offset(12)
            make.right.equalTo(self.view.snp.right).offset(-12)
            
            make.top.equalTo(declareView.snp.bottom).offset(0)
            if YXConstant.screenHeight < 812 {
                make.bottom.equalTo(self.scrollView.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(self.scrollView.snp.bottom).offset(-42)
            }
            make.height.equalTo(self.bannerView.snp.width).multipliedBy(70.0/350.0)
        }
        
        
        if self.viewModel.email.value.count > 0 {
            emailSignInView.acountField.textField.becomeFirstResponder()
        }
        if self.viewModel.mobile.value.count > 0 {
            mobileSignInView.acountField.textField.becomeFirstResponder()
        }
    }
    //MARK: - 导航栏 密码登录、返回
    func setupNavigationBar() {
        //导航栏右按钮
        let passwordLoginItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "institutional_invertor"), target: self, action: nil);
        passwordLoginItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], for: .normal)
        passwordLoginItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], for: .selected)

        passwordLoginItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
//            let userInfo:[String:Any] = ["fromDefaultData":[self.viewModel?.phone.value, self.viewModel.code],
//                                         "defaultLoginFillPhone": self.fillPhone]
//            let context = YXNavigatable(viewModel: YXOrgLoginViewModel(callBack: self.viewModel.loginCallBack, vc: self.viewModel.vc),userInfo: nil)
            
            let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
            let orgLoginViewModel = YXOrgLoginViewModel(callBack: self.viewModel.loginCallBack, vc: self.viewModel.vc, mobile: phoneTextField.textField.text ?? "", email: "", accoutType: .email)
            let context = YXNavigatable(viewModel: orgLoginViewModel,userInfo: nil)
            self.viewModel.navigator.push(YXModulePaths.orgDefaultLogin.url, context: context)
            
            }.disposed(by: self.disposeBag)
        navigationItem.rightBarButtonItems = [passwordLoginItem]
        
        //左侧返回按钮
        if !self.viewModel.isGuideLoginRegister && YXUserManager.isShowLoginRegister() {
            
            if YXUserManager.showGrayLoginSkipState() {
                
                let iconButton = UIButton()
                iconButton.setImage(UIImage(named: "group_close"), for: .normal)
                iconButton.qmui_tapBlock = { sender in
                    
                    self.grayLoginRegisterTrackViewClickEvent("Login_Register", "close")
                    
                    YXUserManager.endShowLoginRegister()
                    if let root = UIApplication.shared.delegate as? YXAppDelegate {
                        let navigator = root.navigator
                        root.initRootViewController(navigator: navigator)
                    }
                }
                navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: iconButton)]
            } else {
                let iconButton = UIButton()
                iconButton.isHidden = true
                navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: iconButton)]
            }
        }
        
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
    
    //MARK: 事件
    //登录注册灰度埋点
    func grayLoginRegisterTrackViewClickEvent(_ customPageName: String, _ name: String) {
        if !self.viewModel.isGuideLoginRegister && YXUserManager.isShowLoginRegister() {
            self.trackViewClickEvent(customPageName: customPageName, name: name)
        }
    }

}

extension YXDefaultLoginViewController {
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        if let cancelCallBack = self.viewModel.cancelCallBack {
            cancelCallBack()
        }
        if (byPopGesture && self.viewModel.unenablePopGestion) {
           return false
        }
        return true
    }
}

extension YXDefaultLoginViewController {
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
            phoneTextField.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCode.accept(code)
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        //  self.viewModel.navigator.push(YXModulePaths.areaCodeSelection.url, context: context)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)

    }
}

//MARK: 接口返回的 处理
extension YXDefaultLoginViewController {
    
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
//                if let vc = self?.viewModel.vc {
//                    if self?.navigationController?.viewControllers.contains(vc) ?? false {
//                        self?.navigationController?.popToViewController(vc, animated: true)
//                        return
//                    }
//                }
//
//                self?.navigationController?.popToRootViewController(animated: true)
//
//            } else {
//                YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//
//                // 异常返回处理
//                if let root = UIApplication.shared.delegate as? YXAppDelegate {
//                    if root.window?.rootViewController is UITabBarController {
//                        self?.navigationController?.popToRootViewController(animated: true)
//                        return
//                    }
//                }
//
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
//            }
            
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
            self?.unRegisteredAlert(withMsg: msg)
        }).disposed(by: disposeBag)
       
        //第三方登录没有绑定手机号
        viewModel.thirdLoginUnbindPhoneSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else {return}
            self.viewModel.bindAccount()
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
    
    
    //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    func showLockedAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let  alertVc = YXAlertViewFactory.errorPwdAlerView(massage:msg) {[weak self] in
            self?.viewModel.findPassWord(currentVC: self)
        }
        alertVc.backgoundTapDismissEnable = true
        self.present(alertVc, animated: true, completion: nil)
    }
    //手机账户被冻结
    func showFreezeAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let  alertVc = YXAlertViewFactory.lockAccountAlertView(massage: msg) {[weak self] in
            self?.viewModel.findPassWord(currentVC: self)
        }

        alertVc.backgoundTapDismissEnable = true
        self.present(alertVc, animated: true, completion: nil)
    }
    //没有注册回调
    func unRegisteredAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertVc = YXAlertViewFactory.notSignUPAlertView(massage: msg) {[weak self] in
            self?.viewModel.gotoRegist(autoSendCaptcha: true)
        }
        alertVc.backgoundTapDismissEnable = true
        self.present(alertVc, animated: true, completion: nil)
    }
}

extension YXDefaultLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.last ?? ASPresentationAnchor()
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = appleIDCredential.user
            var nickName: String = ""
            if let familyName = appleIDCredential.fullName?.familyName, let givenName = appleIDCredential.fullName?.givenName {
                nickName = givenName + familyName
                if (familyName as NSString).includeChinese() || (givenName as NSString).includeChinese() {
                    nickName = familyName + givenName
                }
            }
            let email = appleIDCredential.email ?? ""
             
            guard let identityToken = appleIDCredential.identityToken else { return }
            guard let authorizationCode = appleIDCredential.authorizationCode else { return }
            guard let identityTokenStr = String(data: identityToken, encoding: .utf8) else { return }
            guard let authorizationCodeStr = String(data: authorizationCode, encoding: .utf8) else { return }
            
            appleIDLogin(identityTokenStr, authorizationCodeStr, user, email, nickName)
        }
    }
    
    func appleIDLogin(_ identifyToken: String,  _ appleCode: String, _ appleUserId: String, _ email: String, _ nickName: String) {
        viewModel.isThirdLogin = true
                        
        let params = ["appleUserID": appleUserId, "email": email, "appleCode": appleCode, "identityToken": identifyToken, "nickName": nickName]
        viewModel.appleParams = params
        viewModel.thirdLoginType = .apple
        viewModel.appleUserId = appleUserId
        viewModel.services.aggregationService.request(.thirdLogin("", "", params, viewModel.thirdLoginType), response: viewModel.loginResponse).disposed(by: disposeBag)
    }
}

