//
//  YXRegisterCodeViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import URLNavigator


class YXRegisterCodeViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXUserService
    var navigator: NavigatorServicesType!
    
    /*获取手机验证码(用户输入手机号)
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
     send-phone-captcha/v1 */
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    let codeSubject = PublishSubject<(Bool,String)>()
    
    /*短信验证码注册登陆聚合接口
     captcha-register-aggregation/v1   */
    var captchaRegisterAggResponse: YXResultResponse<YXLoginUser>?
    let lockedSubject = PublishSubject<String>()//锁住
    let freezeSubject = PublishSubject<String>()//冻结
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功的回调
    let hasActivateSubject = PublishSubject<String>() //已激活
    /*用到的场景：
     1. 三方登录：该手机号码已经通过ipad注册了。
     2. 其他情况已激活，没有弹框提示。  */
    let hasActivateNoTopSubject = PublishSubject<String>()
    
    
    /* 三方登录绑定手机号码聚合接口
     three-login-tel-aggregation/v1 */
    var threeTelAggResponse: YXResultResponse<YXLoginUser>? // 响应
    let threeTelAggSucSubject = PublishSubject<Bool>()//成功的处理
    let thirdPhoneBindedSubject = PublishSubject<(Bool, String)>() //三方登录：该手机号码已经被绑定了。
    let thirdPhoneActivatedSubject = PublishSubject<String>() //三方登录：该手机号码已经通过ipad注册了。
    
    var isCheckPreference: Bool = false //是否检查了喜好设置
    
    var services: Services! {
        didSet {
            /*MARK: 获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        if let captcha = result.data?.captcha {
                            self?.codeSubject.onNext((true,captcha))
                        } else if let msg = result.msg {
                            self?.codeSubject.onNext((false,msg))
                        }
                    } else if let msg = result.msg {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*MARK: 短信验证码注册登陆聚合接口
             captcha-register-aggregation/v1   */
            captchaRegisterAggResponse = { [weak self] (response) in
                guard let `self` = self else { return }
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if !self.isCheckPreference {
                            YXUserManager.checkPreferenceSet(user:result.data , clickSet: {[weak self] (isSame) in
                                guard let `self` = self else {return}
                                self.isCheckPreference = true
                                if isSame {
                                    self.captchaRegisterAggResponse!(response)
                                }
                            })
                            return
                        }
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = self.areaCode
                        let mmkv = MMKV.default()
                        mmkv.set(self.areaCode, forKey: YXUserManager.YXDefCode)
                        
                        //通知 更新用户信息
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        
                        //是否有绑定美股行情权限 判断 v2.4去掉
//                        let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 2
//                        let hqAuthority = (extendStatusBit & YXExtendStatusBitType.hqAuthority.rawValue) == YXExtendStatusBitType.hqAuthority.rawValue
//                        if hqAuthority == false {
//                            let model = YXUSAuthStateWebViewModel(dictionary: [:], loginCallBack: self.loginCallBack, sourceVC: self.vc,hideSkip: false)
//                            model.isFromeRegister = true
//                            let context = YXNavigatable(viewModel: model)
//                            self.navigator.push(YXModulePaths.USAuthState.url, context: context)
//                        }
                        
                        if YXUserManager.isNeedGuideAccount() && !self.isOrg {//进入开户页
                            let context = YXNavigatable(viewModel: YXOpenAccountGuideViewModel(dictionary: [:]))
                            self.navigator.push(YXModulePaths.loginOpenAccountGuide.url, context: context)
                            
                        } else {
                            self.loginSuccessSubject.onNext(true)
                            //loginCallBack的回调
                            if let loginCallBack = self.loginCallBack {
                                loginCallBack(YXUserManager.userInfo)
                            }
                        }
                    case .accountActivation?: //预注册账号激活
                        if let msg = result.msg {
                            self.hasActivateSubject.onNext(msg)
                        }
                    case .accountActivationNoTip?://预注册账号激活/无提示
                        self.hasActivateNoTopSubject.onNext("")
                    case .accountDoubleCheak?: //在新设备登录，需要双重认证
                        let context = YXNavigatable(viewModel: YXDoubleCheckViewModel(withCode: self.areaCode , phone: self.phone, email: "", isOrg: self.isOrg))
                        self.navigator.push(YXModulePaths.doubleCheck.url, context: context)
                    case .aggregationError?,
                         .aggregationHalfError?,
                         .aggregationUserError?,
                         .aggregationStockError?,
                         .aggregationProductError?,
                         .aggregationInfoError?,
                         .aggregationLoginError?,
                         .aggregationRegistError?,
                         .aggregationMoneyError?,
                         .aggregationPermissionsError?,
                         .aggregationWechatError?,
                         .aggregationWeiboError?:
                        self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                        break
                    case .accountLockout?://密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
                        if let msg = result.msg {
                            self.lockedSubject.onNext(msg)
                        }
                    case .accountFreeze?://手机账户被冻结
                        if let msg = result.msg {
                            self.freezeSubject.onNext(msg)
                        }
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /* 三方登录绑定手机号码聚合接口
             three-login-tel-aggregation/v1 */
            threeTelAggResponse = {[weak self](response) in
                guard let `self` = self else {return}
                
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code ):
                    switch code {
                    case .success?:
                        if !self.isCheckPreference {
                            YXUserManager.checkPreferenceSet(user:result.data , clickSet: {[weak self] (isSame) in
                                guard let `self` = self else {return}
                                self.isCheckPreference = true
                                if isSame {
                                    self.threeTelAggResponse!(response)
                                }
                            })
                            return
                        }
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = self.areaCode
                        let mmkv = MMKV.default()
                        mmkv.set(self.areaCode, forKey: YXUserManager.YXDefCode)
                        
                        self.threeTelAggSucSubject.onNext(true)
                    case .thirdLoginPhoneBinded?, .thirdLoginAlertOne?://该手机号码已经被绑定了。
                        if let msg = result.msg {
                            self.thirdPhoneBindedSubject.onNext((true, msg))
                        }
                    case .thirdLoginAlertTwo?:
                        if let msg = result.msg {
                            self.thirdPhoneBindedSubject.onNext((false, msg))
                        }
                    case .thirdbindPhoneActivated?: //该手机号码已经通过ipad注册了。
                        self.thirdPhoneActivatedSubject.onNext("")
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.error(msg, false))
                        }
                    }
                default:
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    var phone = ""//手机号
    var areaCode = ""//区号
    var captcha = ""//Variable<String>("") //验证码
    //var recommendCode: String?
    var loginCallBack: (([String: Any])->Void)?
    var vc: UIViewController?
    var sendCaptchaType:YXSendCaptchaType = .type106
    
    // 是否是机构户
    var isOrg = false
    
    
    init(withCode code:String, phone: String, sendCaptchaType:YXSendCaptchaType, vc: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        self.phone = phone
        self.areaCode = code
        self.sendCaptchaType = sendCaptchaType
        self.vc = vc
        
        self.loginCallBack = loginCallBack
    }
}
