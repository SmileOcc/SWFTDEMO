//
//  YXThirdPhoneActivateViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/7/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXThirdPhoneActivateViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService
    var navigator: NavigatorServicesType!
    
    /* 三方登录预注册手机号码激活聚合接口
     three-login-guest-activate-aggregation/v1  */
    var thirdActivateLoginResponse: YXResultResponse<YXLoginUser>?
    
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功的回调
    let unRegisteredSubject = PublishSubject<Bool>()//没有注册回调
    let lockedSubject = PublishSubject<String>()//锁住 //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    let freezeSubject = PublishSubject<String>()//冻结 //手机账户被冻结
    let unsetLoginPwdSubject = PublishSubject<String>()//未设置登录密码
    let codeTimeOutSubject = PublishSubject<String>()//抱歉，验证码已过期，请重新获取
    
    var isCheckPreference: Bool = false //是否检查了喜好设置
    
    var services: Services! {
        didSet {
            //登录响应
            thirdActivateLoginResponse = { [weak self] (response) in
                guard let `self` = self else {return}
                self.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    //测试 双重验证
                    switch code {
                    case .success?:
                        if !self.isCheckPreference {
                            YXUserManager.checkPreferenceSet(user:result.data , clickSet: {[weak self] (isSame) in
                                guard let `self` = self else {return}
                                self.isCheckPreference = true
                                if isSame {
                                    self.thirdActivateLoginResponse!(response)
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
                    
                        self.loginSuccessSubject.onNext(true)
                        if let loginCallBack = self.loginCallBack {
                            loginCallBack(YXUserManager.userInfo)
                        }
                        
                    case .accountUnregistered?://帐号未注册
                        self.unRegisteredSubject.onNext(true)
                    case .codeTimeout?: //抱歉，验证码已过期，请重新获取
                        if let msg = result.msg {
                            self.codeTimeOutSubject.onNext(msg)
                        }
                        
                    case .accountDoubleCheak?://在新设备登录，需要双重认证
                        let context = YXNavigatable(viewModel: YXDoubleCheckViewModel(withCode: self.areaCode, phone: self.phone.value))
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
                    case .unsetLoginPwd?: //未设置登录密码
                        if let msg = result.msg {
                            self.unsetLoginPwdSubject.onNext(msg)
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
        }
    }
    //MARK: 元素
    var areaCode = YXUserManager.shared().defCode
    var captcha : String = ""
    var phone = Variable<String>("")
    var thirdLoginType:Int = 0
    var accessToken: String = ""
    var openId: String?
    var idNumber = Variable<String>("")
    
    var loginCallBack: (([String: Any])->Void)?
    weak var vc: UIViewController?
    
    init(with areaCode:String, _ phone:String, _ captcha:String, _ thirdLoginType:Int, _ accessToken:String, _ openId:String?,_ loginCallBack: (([String: Any])->Void)?, _ vc: UIViewController?)
    {
        self.areaCode = areaCode
        self.phone = Variable(phone)
        self.captcha = captcha
        self.thirdLoginType = thirdLoginType
        self.accessToken = accessToken
        self.openId = openId
        self.loginCallBack = loginCallBack
        self.vc = vc
    }
}
