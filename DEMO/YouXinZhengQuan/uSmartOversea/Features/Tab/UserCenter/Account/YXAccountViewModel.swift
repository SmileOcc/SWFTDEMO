//
//  YXAccountViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXAccountViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    //绑定 微信，谷歌，facebook成功响应
    var bindingResponse: YXResultResponse<JSONAny>?
    var unBindingResponse: YXResultResponse<JSONAny>?
    var unBindingWechatSignalResponse: YXResultResponse<JSONAny>?


    var unBindSubject = PublishSubject<Bool>()

    var unBindType: SSDKPlatformType = .typeWechat
    
    var bindPlatformType: SSDKPlatformType? //存储点击了的 绑定平台
    
    var services: Services! {
        didSet {
            bindingResponse =  { [weak self] (response) in
                guard let strongSelf = self else {return}
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                   
                    switch code {
                    case .success?:
                        //提示
                        strongSelf.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_bind_success"), false))
                        //2.1设置为绑定手机号
                        var thirdBindBit:UInt64 = 0
                        switch strongSelf.bindPlatformType {
                        case .typeGooglePlus?:
                            thirdBindBit = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0 | YXLoginBindType.google.rawValue
                        case .typeWechat?:
                            thirdBindBit = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0 | YXLoginBindType.wechat.rawValue
                        case .typeFacebook?:
                            thirdBindBit = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0 | YXLoginBindType.faceBook.rawValue
                        case .typeAppleAccount?:
                            thirdBindBit = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0 | YXLoginBindType.apple.rawValue
                        default:
                            print("")
                        }
                        YXUserManager.shared().curLoginUser?.thirdBindBit = thirdBindBit
                        
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                    
                    //2.2更新用户信息数据
                    YXUserManager.getUserInfo(complete: nil)
                    //2.3发送通知
                    NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            unBindingResponse =  { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_remove_bind"), false))
                        self?.unBindSubject.onNext(true)
                        YXUserManager.getUserInfo(complete: nil)
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }

            unBindingWechatSignalResponse =  { (response) in
                switch response {
                    case .success(_, _):

                            break
                    case .failed(_):
                        break
                }
            }
        }
    }
    
    init() {
        
        
    }
}
