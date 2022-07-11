//
//  YXPreferenceSetViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator


public enum YXModifyUserConfigType {
    case none       //什么都不传
    case languageCn
    case languageHk
    case lineColorHk
    case quoteChartHk
    case sortHk
}

class YXPreferenceSetViewModel: ServicesViewModel, HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var languageHk: YXLanguageType = .EN
    var lineColorHk: YXLineColorType = YXUserManager.curColor(judgeIsLogin: false)
    var sortHK: YXSortHK = YXSecuGroupManager.shareInstance().sortflag == 1 ? .on: .off
    var configType: YXModifyUserConfigType = .languageHk
    
    var configResponse: YXResultResponse<JSONAny>?
    
    let resultSubject = PublishSubject<(Bool, String)>()
    
    var services: Services! {
        didSet {
            
            configResponse =  { [weak self] (response) in
                guard let `self` = self else { return }
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        let mmkv = MMKV.default()
                        switch self.configType {
                        case .languageHk:
                            YXUserManager.shared().curLoginUser?.languageHk = self.languageHk
                            YXUserManager.saveCurLoginUser()
                            mmkv.set(Int32(self.languageHk.rawValue), forKey: YXUserManager.YXLanguage)
                            YXLanguageUtility.initUserLanguage()
                            // 通知语言有更换
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateLanguage), object: nil)
//                            // 通知重置根视图
//                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: nil)
//                            YXUserManager.getUserInfo(complete: nil)
                        
                        case .lineColorHk:
                            YXUserManager.shared().curLoginUser?.lineColorHk = self.lineColorHk
                            YXUserManager.saveCurLoginUser()
                            mmkv.set(Int32(self.lineColorHk.rawValue), forKey: YXUserManager.YXColor)
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateColor), object: nil)
                        case .sortHk:
                            YXUserManager.shared().curLoginUser?.sortHk = self.sortHK
                            YXUserManager.saveCurLoginUser()
                            YXSecuGroupManager.shareInstance().sortflag = self.sortHK.rawValue
//                            mmkv.set(Int32(self.sortHK.rawValue), forKey: YXUserManager.YXSortHk)
//                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateSortHK), object: nil)
                            
                        default:
                            print("default")
                        }
                        self.resultSubject.onNext((true, ""))
                        
                    default:
                        if let msg = result.msg {
                            self.resultSubject.onNext((false, msg))
                        }
                    }
                case .failed(_):
                    self.resultSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
                }
            }
            
            
            
            
        }
    }
    
    var finishClosure: ()->Void = {}
    
    
    init(finishClosure: @escaping ()->Void) {
        self.finishClosure = finishClosure
    }
}
