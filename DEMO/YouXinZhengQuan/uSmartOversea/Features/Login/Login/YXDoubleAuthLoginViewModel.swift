//
//  YXDoubleAuthLoginViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class YXDoubleAuthLoginViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXAggregationService
    var navigator: NavigatorServicesType!
    var services: Services!
    var didSetSubject = PublishSubject<Bool>()
    var loginUser:YXLoginUser?
    var loginCallBack: (()->Void)?
    var loginType : YXMemberAccountType = .email
    var didSendSubject = PublishSubject<String>()
    var didCheckSubject = PublishSubject<String>()
    var captchaBehaviorRelay:BehaviorRelay<String> = BehaviorRelay<String>.init(value: "")
//    var sendCaptchaPubsuject
    init(user: YXLoginUser?,loginType:YXMemberAccountType,callBack: (()->Void)?) {
        loginUser = user
        loginCallBack = callBack
        self.loginType = loginType
    }
    
    func sendCaptcha(){
        if loginType == .mobile{
            sendPhoneCaptcha()
        }else {
            sendEmailCaptcha()
        }
    }
    
    func checkCaptcha(){
        if loginType == .mobile{
            checkPhoneCaptcha()
        }else {
            checkEmailCaptcha()
        }
    }
    func sendPhoneCaptcha(){
        let phone = YXUserManager.safeDecrypt(string: self.loginUser?.phoneNumber ?? "")
        let areaCode = loginUser?.areaCode ?? ""
        let requsetMode = YXLoginSendPhoneCaptchaRequestModel()
        requsetMode.areaCode = areaCode
        requsetMode.phoneNumber = phone
        requsetMode.token = loginUser?.token ?? ""
        let request = YXRequest(request: requsetMode)
        request.startWithBlock(success: {[weak self] (responseModel) in
            if responseModel.code == .success {
                
                if let dic = responseModel.data {
                    if let captcha = dic["captcha"] as? String {
                        self?.didSendSubject.onNext(captcha)
                        return
                    }
                }
                self?.didSendSubject.onNext("")
            } else {
                YXProgressHUD.showSuccess(responseModel.msg)
            }
        }, failure: { (request) in
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
        })
    }
  
    
    func checkPhoneCaptcha(){
       // let phone = YXUserManager.safeDecrypt(string: self.loginUser?.phoneNumber ?? "")
        let requsetMode = YXLoginCheckPhoneCaptchaRequestModel()
       // requsetMode.phoneNumber = phone
        requsetMode.captcha = self.captchaBehaviorRelay.value
        requsetMode.token = loginUser?.token ?? ""
        let request = YXRequest(request: requsetMode)
        request.startWithBlock(success: {[weak self] (responseModel) in
            if responseModel.code == .success {
                self?.didCheckSubject.onNext("")
            } else {
                YXProgressHUD.showSuccess(responseModel.msg)
            }
        }, failure: { (request) in
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
        })
    }
    
    
    func sendEmailCaptcha(){
        let requsetMode = YXLoginSendEmailCaptchaRequestModel()
        requsetMode.email = loginUser?.email ?? ""
        requsetMode.token = loginUser?.token ?? ""
        let request = YXRequest(request: requsetMode)
        request.startWithBlock(success: {[weak self] (responseModel) in
            if responseModel.code == .success {
                if let dic = responseModel.data {
                    if let captcha = dic["captcha"] as? String {
                        self?.didSendSubject.onNext(captcha)
                        return
                    }
                }
                self?.didSendSubject.onNext("")
            } else {
                YXProgressHUD.showSuccess(responseModel.msg)
            }
        }, failure: { (request) in
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
        })
    }
    func checkEmailCaptcha(){
        let requsetMode = YXLoginCheckEmailCaptchaRequestModel()
        requsetMode.email = loginUser?.email ?? ""
        requsetMode.token = loginUser?.token ?? ""
        requsetMode.captcha = self.captchaBehaviorRelay.value
        let request = YXRequest(request: requsetMode)
        request.startWithBlock(success: {[weak self] (responseModel) in
            if responseModel.code == .success {
                self?.didCheckSubject.onNext("")
            } else {
                YXProgressHUD.showSuccess(responseModel.msg)
            }
        }, failure: { (request) in
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
        })
    }
}
