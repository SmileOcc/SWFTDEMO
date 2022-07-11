//
//  YXRegisterCodeViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/* 获取验证码  */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import SnapKit
import YXKit

import TYAlertController


class YXRegisterCodeViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXRegisterCodeViewModel!
    
    var timeCount = 60
    let timerMark = "registerCode"
    
    var tempCaptcha: String = ""
    var recommendCode: String = ""//推荐码
    var promotValue = YXPromotionValue()//促销订阅
    
    var fromDefaultLogin:Bool = false //是否来自默认短信登录页面
    
    var accessToken = ""
    var appleUserId = ""
    var openId = ""
    var thirdLoginType:YXThirdLoginType = .weChat
    
    //传给“三方登录绑定手机号”页面，以填充手机号、区号。
    var fillPhone: (([String]) -> Void)?
    
    let scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    //手机号
    let phoneLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: uniSize(18))
        lab.textColor = QMUITheme().textColorLevel1()
        return lab
    }()
    
    let gridInputView: YXGridInputView = {
        let gridWidth:CGFloat
        switch YXConstant.screenSize {
        case .size3_5,.size4:
            gridWidth = 40
        default:
            gridWidth = 50
        }
        let view = YXGridInputView(gridWidth: gridWidth, viewWidth: UIScreen.main.bounds.width-40, isSecure: false)
        if #available(iOS 12.0, *) {
            view.textField.textContentType = .oneTimeCode
        }
        return view
    }()
    
    var codeBtn: UIButton = {
        let btn = UIButton()

        btn.setTitle(YXLanguageUtility.kLang(key: "login_resend"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindHUD()
        initUI()
        bindViewModel()
        viewModelResponse()
        if self.fromDefaultLogin {
            self.startTimer()
        } else {
            self.sendCaptcha()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.gridInputView.textField.becomeFirstResponder()
        if YXConstant.isAutoFillCaptcha(), self.tempCaptcha.count > 0 {
            autoFillVerifyCode()
        } else {
            self.gridInputView.textField.becomeFirstResponder()
        }
        
    }
    
    func autoFillVerifyCode() {
        //self.gridInputView.textField.text = self.tempCaptcha
        //self.gridInputView.textField.sendActions(for: .editingChanged)
        self.gridInputView.textField.insertText(self.tempCaptcha)
        self.gridInputView.textFieldDidChange(textField: self.gridInputView.textField)
    }
    
    func bindViewModel() {
        //发送验证码
        codeBtn.rx.tap.bind { [weak self] in
            self?.sendCaptcha()
        }.disposed(by: disposeBag)
        
        //驗證碼發送成功，
        viewModel.codeSubject.subscribe(onNext: { [weak self] (argument) in
            let (_, captcha) = argument
            guard let `self` = self else { return }
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                // Toast 顯示驗證碼
                //self.viewModel.hudSubject.onNext(.message("\(captcha)", false))
                self.tempCaptcha = captcha
                self.viewModel.captcha = ""
                self.autoFillVerifyCode()
            }
            self.startTimer()
        }).disposed(by: disposeBag)
        
        
        //MARK: 登录和验证
        gridInputView.textField.rx.text.orEmpty.distinctUntilChanged().asObservable()
            .subscribe(onNext: { [weak self] string in
                guard let `self` = self else { return }
                if self.viewModel.captcha.count < 6 && string.count == 6 {
                    self.viewModel.hudSubject?.onNext(.loading(nil, false))
                    let areaCode = self.viewModel.areaCode
                    let phoneNumber = YXUserManager.safeDecrypt(string: self.viewModel.phone.removePreAfterSpace())
                    let captcha = string.removePreAfterSpace()
                    let recomCode = self.recommendCode.removePreAfterSpace() //去掉前后空格
                    
                    if self.viewModel.isOrg {
                        let request: YXAggregationAPI = .orgCaptchaLogin(areaCode, phoneNumber, captcha)
                        
                        self.viewModel.services.aggregationService.request(request, response: self.viewModel.captchaRegisterAggResponse).disposed(by: self.disposeBag)
                    } else {
                        switch self.viewModel.sendCaptchaType {
                        case .type101, .type106:
                            
                            /*短信验证码注册登陆聚合接口 POST请求
                             forceRegister  强制注册(true是 false否)
                             captcha-register-aggregation/v1   */
                            let request: YXAggregationAPI = .captchaRegister(areaCode, captcha, phoneNumber, false, recomCode, self.promotValue.phone, self.promotValue.sms, self.promotValue.email, self.promotValue.mail)
                            
                            self.viewModel.services.aggregationService.request(request, response: self.viewModel.captchaRegisterAggResponse).disposed(by: self.disposeBag)
                        case .type104:
                            /* 三方登录绑定手机号码聚合接口
                             three-login-tel-aggregation/v1 */
                            let request: YXAggregationAPI = .thirdLoginTelAggreV1("",areaCode, captcha, phoneNumber, self.thirdLoginType.rawValue, self.accessToken, self.openId, self.appleUserId, "",recomCode, self.promotValue.phone, self.promotValue.sms, self.promotValue.email, self.promotValue.mail)

                            self.viewModel.services.aggregationService.request(request, response: self.viewModel.threeTelAggResponse).disposed(by: self.disposeBag)
                        default:break
                        }
                    }
                    

                    self.view.endEditing(true)
                    self.viewModel.captcha = string
                } else {
                    self.viewModel.captcha = string
                }
            })
            .disposed(by: disposeBag)
    }
    
    func initUI() {
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(gridInputView)
        scrollView.addSubview(phoneLab)
        scrollView.addSubview(codeBtn)
        
        scrollView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(strongSelf.view.safeArea.top)
            make.left.right.bottom.equalTo(strongSelf.view)
        }
        //提示：获取验证码
        let tipLab = UILabel()
        tipLab.text = YXLanguageUtility.kLang(key: "login_codeTip")
        tipLab.numberOfLines = 0
        tipLab.font = UIFont.systemFont(ofSize: uniSize(36))
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { [weak self](make) in
            guard let strongSelf = self else {return}
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(strongSelf.view).offset(-20)
            //make.height.equalTo(50)
        }
        //提示2：验证码已发送至
        let tipLab2 = UILabel()
        tipLab2.text = YXLanguageUtility.kLang(key: "login_sendTo")
        tipLab2.font = UIFont.systemFont(ofSize: uniSize(20))
        //tipLab2.numberOfLines = 0
        tipLab2.adjustsFontSizeToFitWidth = true
        tipLab2.minimumScaleFactor = 0.3
        scrollView.addSubview(tipLab2)
        tipLab2.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(28)
        }
        
        phoneLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(tipLab2)
            make.left.equalTo(tipLab2.snp.right).offset(uniHorLength(10))
            make.height.equalTo(23)
        }
        
        gridInputView.snp.makeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(tipLab2.snp.bottom).offset(42)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(50)
            make.right.equalTo(strongSelf.view).offset(-20)
        }
        
        codeBtn.snp.makeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.right.equalTo(strongSelf.view).offset(-20)
            make.height.equalTo(20)
            make.top.equalTo(gridInputView.snp.bottom).offset(12)
        }
        
        phoneLab.text = String(format: "+%@ %@", self.viewModel.areaCode, self.viewModel.phone)
        
        codeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(codeBtn.imageView?.image?.size.width ?? 0), bottom: 0, right: (codeBtn.imageView?.image?.size.width ?? 0))
        codeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (codeBtn.titleLabel?.frame.size.width ?? 0)+3, bottom: 0, right: -(codeBtn.titleLabel?.frame.size.width ?? 0)-3)
        
    }
    
    //MARK: 发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        let areaCode = self.viewModel.areaCode
        let phoneNumber = YXUserManager.safeDecrypt(string: self.viewModel.phone)
        
        //清空 验证码
        gridInputView.clearText()
        /*获取手机验证码(用户输入手机号)
         type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
         send-phone-captcha/v1 */
        viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode, phoneNumber, self.viewModel.sendCaptchaType), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
    }
    
    func startTimer() {
        timeCount = 60
        YXTimer.shared.cancleTimer(WithTimerName: self.timerMark)
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.timerMark, timeInterval: 1, queue: .main, repeats: true) { [weak self] in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        
        if timeCount >= 0 {
            codeBtn.isEnabled = false
            codeBtn.setTitle( String(format: "%lds%@", timeCount, YXLanguageUtility.kLang(key: "login_afterSend")), for: .disabled)
            timeCount -= 1
            codeBtn.titleEdgeInsets = .zero
            codeBtn.imageEdgeInsets = .zero
            
        }else {
            codeBtn.isEnabled = true
            YXTimer.shared.cancleTimer(WithTimerName: timerMark)
            codeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(codeBtn.imageView?.image?.size.width ?? 0), bottom: 0, right: (codeBtn.imageView?.image?.size.width ?? 0))
            codeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (codeBtn.titleLabel?.frame.size.width ?? 0)+3, bottom: 0, right: -(codeBtn.titleLabel?.frame.size.width ?? 0)-3)
        }
    }
    
    deinit {
        YXTimer.shared.cancleTimer(WithTimerName: timerMark)
    }
    
}
//MARK: 接口返回的 处理
extension YXRegisterCodeViewController {
    
    func viewModelResponse() {
        //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
        viewModel.lockedSubject.subscribe(onNext: { [weak self] msg in
            self?.showLockedAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        //手机账户被冻结
        viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            self?.showFreezeAlert(withMsg: msg)
        }).disposed(by: disposeBag)
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
        //已激活的弹框
        viewModel.hasActivateSubject.subscribe(onNext: {[weak self] (msg) in
            guard let strongSelf = self else {return}
            strongSelf.showHadActivateAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        //
        //已激活的弹框
        viewModel.hasActivateNoTopSubject.subscribe(onNext: {[weak self] (msg) in
            guard let strongSelf = self else {return}
            //跳去身份证验证
            strongSelf.execute(isActivate: true)
        }).disposed(by: disposeBag)
        
        //MARK: 三方登录：绑定手机号 成功的  处理
        viewModel.threeTelAggSucSubject.subscribe(onNext: { [weak self] success in
            guard let strongSelf = self else {return}
            strongSelf.view.endEditing(true)
            //提示【绑定成功】
            strongSelf.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "mine_bind_success"), true))
            
            //设置为绑定手机号
            let third = (YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0) | YXLoginBindType.phone.rawValue
            YXUserManager.shared().curLoginUser?.thirdBindBit = third
            //更新用户信息数据
            YXUserManager.getUserInfo(complete: nil)
            //发送通知
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
            
            //是否有绑定美股行情权限 判断 v2.4去掉
//            let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 2
//            let hqAuthority = (extendStatusBit & YXExtendStatusBitType.hqAuthority.rawValue) == YXExtendStatusBitType.hqAuthority.rawValue
//            if hqAuthority == false {
//                let model = YXUSAuthStateWebViewModel(dictionary: [:], loginCallBack: strongSelf.viewModel.loginCallBack, sourceVC: strongSelf.viewModel.vc,hideSkip: false)
//                model.isFromeRegister = true
//                let context = YXNavigatable(viewModel: model)
//                strongSelf.viewModel.navigator.push(YXModulePaths.USAuthState.url, context: context)
//            }

            if YXUserManager.isNeedGuideAccount() {//进入开户页
                let context = YXNavigatable(viewModel: YXOpenAccountGuideViewModel(dictionary: [:]))
                strongSelf.viewModel.navigator.push(YXModulePaths.loginOpenAccountGuide.url, context: context)
                
            } else {
                //返回
                if let vc = strongSelf.viewModel.vc {
                    strongSelf.navigationController?.popToViewController(vc, animated: true)
                }else {
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            }
        }).disposed(by: disposeBag)
        //三方登录：该手机号码已经被绑定了。
        viewModel.thirdPhoneBindedSubject.subscribe(onNext: {[weak self] (arg0) in
            guard let strongSelf = self else {return}
            let (isBinded, msg) = arg0
            strongSelf.showThirdPhoneBindedAlert(with: msg, isBinded)
        }).disposed(by: disposeBag)
        
        //三方登录：该手机号码已经通过ipad注册了。
        viewModel.thirdPhoneActivatedSubject.subscribe(onNext: {[weak self] (msg) in
            guard let `self` = self else {return}
            
            let areaCode = self.viewModel.areaCode
            let captcha = self.viewModel.captcha //手机验证码
            let phoneNumber = self.viewModel.phone
            //跳去身份证验证
            let thirdViewModel = YXThirdPhoneActivateViewModel(with: areaCode, phoneNumber, captcha, self.thirdLoginType.rawValue, self.accessToken, self.openId, self.viewModel.loginCallBack, self.viewModel.vc)
            let context = YXNavigatable(viewModel: thirdViewModel)
            self.viewModel.navigator.push(YXModulePaths.thirdLoginIdNumActivate.url, context: context)
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
            
            let loginCallBack = self.viewModel.loginCallBack
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: self.viewModel.areaCode, phone: self.viewModel.phone, isLogin: false, callBack: self.fillPhone, loginCallBack: loginCallBack, fromVC:self,sourceVC:self.viewModel.vc))
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
    //三方登录：”该手机号码已经被绑定了。“的提示
    func showThirdPhoneBindedAlert(with msg:String, _ isBinded: Bool) {
        self.view.endEditing(true)
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        if isBinded {
            //取消
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            //去登录
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_goLogin"), style: .default, handler: {[weak alertView, weak self] action in
                guard let `self` = self else {return}
                alertView?.hide()
                if let fillPhone = self.fillPhone {
                    fillPhone([self.viewModel.phone, self.viewModel.areaCode])
                }
                //返回到三方登录之前的，登录页面
                let vcCount:Int = self.navigationController?.viewControllers.count ?? 0
                if let naviController = self.navigationController, vcCount >= 3 {
                    let loginVC = naviController.viewControllers[vcCount - 3]
                    naviController.popToViewController(loginVC, animated: true)
                }
            }))
        } else {
            //我知道了
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
                alertView?.hide()
            }))
        }
        alertView.showInWindow()
    }
    //已激活 --预注册
    func showHadActivateAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXRegisterCodeAlertView(title: YXLanguageUtility.kLang(key: "newStock_tips"), message: msg, prompt: nil, style: .default)
        alertView.clickedAutoHide = false
        //去激活
        alertView.addAction(YXRegisterCodeAlertAction(title: YXLanguageUtility.kLang(key: "login_goToActivate"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            
            //跳去身份证验证
            self.execute(isActivate: true)
        }))
        //重新注册
        alertView.addAction(YXRegisterCodeAlertAction(title: YXLanguageUtility.kLang(key: "login_reRegister"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            
            self.showreRegisterAlert()
        }))
        alertView.showInWindow()
    }
    func showreRegisterAlert() {
        //
        let msg = YXLanguageUtility.kLang(key: "login_reRegisterAlertTip")
        let alertView = YXAlertView(title: YXLanguageUtility.kLang(key: "newStock_tips"), message: msg, prompt: nil, style: .default)
        alertView.clickedAutoHide = false
        //去激活
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_goToActivate"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            
            //跳去身份证验证
            self.execute(isActivate: true)
        }))
        //完成注册
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_completeRegister"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            //生成新的userID，完成登录
            self.execute(isActivate: false)
        }))
        alertView.showInWindow()
    }
    //执行 注册或者 激活
    func execute(isActivate activate:Bool) {
        let areaCode = self.viewModel.areaCode
        let captcha = self.viewModel.captcha //手机验证码
        var phoneNumber = self.viewModel.phone
        //是激活
        if activate {
            //跳去身份证验证
            let context = YXNavigatable(viewModel: YXIdCardActivateViewModel(withCode: areaCode, phone: phoneNumber, captcha: captcha, loginCallBack: self.viewModel.loginCallBack, vc: self.viewModel.vc))
            self.viewModel.navigator.push(YXModulePaths.loginIdNumActivate.url, context: context)
        } else {
            /*短信验证码注册登陆聚合接口 POST请求
             forceRegister  强制注册(true是 false否)
             captcha-register-aggregation/v1   */
            phoneNumber = YXUserManager.safeDecrypt(string: phoneNumber) //加密
            let request: YXAggregationAPI = .captchaRegister(areaCode, captcha, phoneNumber, true, self.recommendCode, self.promotValue.phone, self.promotValue.sms, self.promotValue.email, self.promotValue.mail)
            self.viewModel.services.aggregationService.request(request, response: self.viewModel.captchaRegisterAggResponse).disposed(by: self.disposeBag)
        }
    }
}
