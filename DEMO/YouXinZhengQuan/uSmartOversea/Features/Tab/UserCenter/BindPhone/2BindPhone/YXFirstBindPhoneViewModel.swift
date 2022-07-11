//
//  YXFirstBindPhoneViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXFirstBindPhoneViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService & HasYXLoginService
    var navigator: NavigatorServicesType!
    
    
    var sendCaptcha: (() -> Void)!
    /*获取手机验证码(用户输入手机号)
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
     send-phone-captcha/v1 */
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()//token-send-phone-captcha/v1接口的成功处理
    
    /* 设置登陆密码 post
     set-login-password/v1  */
//    var setLoginPwdResponse: YXResultResponse<JSONAny>?
//    let lockedSubject = PublishSubject<String>()//密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
//    let freezeSubject = PublishSubject<String>()//手机账户被冻结
//    let setLoginPwdSuccessSubject = PublishSubject<Bool>()
    /*第一次绑定手机号
     api/bind-phone/v1  */
    var bindPhoneResponse: YXResultResponse<YXLoginUser>?
    let bindPhoneSuccessSubject = PublishSubject<Bool>()
    
    
    var services: Services! {
        didSet {
            /*获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendCaptchaResponse =  { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?,
                         .authCodeRepeatSent?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                strongSelf.codeSubject.onNext(captcha)
                            } else {
                                strongSelf.codeSubject.onNext("")
                            }
                        } else {
                            strongSelf.codeSubject.onNext("")
                        }
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            /*第一次绑定手机号
             api/bind-phone/v1  */
            bindPhoneResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        //保存数据
                        YXUserManager.shared().curLoginUser?.phoneNumber = strongSelf.phone
                        MMKV.default().set(strongSelf.code, forKey: YXUserManager.YXDefCode)
                        
                        //2.2更新用户信息数据
                        YXUserManager.getUserInfo(complete: nil)
                        
                        //2.3发送通知
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        
                        //2.4绑定回调
                        if let bindCallBack = strongSelf.bindCallBack {
                            bindCallBack(YXUserManager.userInfo)
                        }
                        //回调
                        strongSelf.bindPhoneSuccessSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    
    
    var code:String
    var phone:String
    weak var sourceVC: UIViewController?
    var bindCallBack: (([String: Any])->Void)?
    
    var areaCodeRelay  = BehaviorRelay<String>.init(value: "")
    var phoneRelay = BehaviorRelay<String>.init(value: "")
    var pwdRelay = BehaviorRelay<String>.init(value: "")
    var captchaRelay = BehaviorRelay<String>.init(value: "")
    var phoneValid : Observable<Bool>?
    var everythingValid : Observable<Bool>?
    
    
    func bindView(){
        phoneValid = phoneRelay.asObservable().map{ $0.count > 0 }.share(replay: 1)
        let captchaValid = captchaRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        let pwdValid = pwdRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        everythingValid = Observable.combineLatest(phoneValid!, captchaValid, pwdValid).map{ $0 && $1 && $2}.share(replay: 1)
    }
    
    init(withCode code:String, phone:String, sourceVC:UIViewController?, callback: (([String: Any])->Void)?) {
        self.code = code
        self.phone = phone
        self.sourceVC = sourceVC
        self.bindCallBack = callback
        bindView()
    }
}
