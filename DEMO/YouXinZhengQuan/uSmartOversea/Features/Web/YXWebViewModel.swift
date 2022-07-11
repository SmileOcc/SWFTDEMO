//
//  YXWebViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa


import URLNavigator

@objcMembers class YXWebViewModel: NSObject, HUDServicesViewModel  {
    typealias Services = HasYXWebService & HasYXNewsService
    
    /// webview url key
    @objc static let kWebViewModelUrl = "url"

    /// webview title key
    @objc static let kWebViewModelTitle = "webTitle"

    /// webview titlebar visible key
    @objc static let kWebViewModelTitleBarVisible = "webTitleBarVisible"

    /// webview cache policy
    @objc static let kWebViewModelCachePolicy = "webCachePolicy"
    
    var navigator: NavigatorServicesType!
    
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
    
    var url: String?
    var webTitle: String?
    var titleBarVisible: Bool = false {
        didSet {
            titleBarVisibleSubject.onNext(titleBarVisible)
        }
    }
    var cachePolicy:URLRequest.CachePolicy = .useProtocolCachePolicy//缓存策略
    
    var titleBarVisibleSubject = PublishSubject<Bool>()

    @objc init(dictionary: Dictionary<String, Any>) {
        super.init()
        if let url = dictionary[YXWebViewModel.kWebViewModelUrl] {
            self.url = url as? String
        }
        
        if let webTitle = dictionary[YXWebViewModel.kWebViewModelTitle] {
            self.webTitle = webTitle as? String
        }
        
        if let titleBarVisible = dictionary[YXWebViewModel.kWebViewModelTitleBarVisible] {
            self.titleBarVisible = titleBarVisible as? Bool ?? true
        } else {
            self.titleBarVisible = true
        }
        
        if let cachePolicy = dictionary[YXWebViewModel.kWebViewModelCachePolicy] {
            self.cachePolicy = cachePolicy as? URLRequest.CachePolicy ?? URLRequest.CachePolicy.useProtocolCachePolicy
        }
    }
    
    weak var sourceVC: UIViewController?
    var loginCallBack: (([String: Any])->Void)?
    convenience init(dictionary: Dictionary<String, Any>, loginCallBack: (([String: Any])->Void)?, sourceVC: UIViewController?) {
        self.init(dictionary: dictionary)
        self.loginCallBack = loginCallBack
        self.sourceVC = sourceVC
    }
    
    @objc class func pushToWebVC(_ url: String) {
        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
        YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
    }
    
    @objc class func presentToWebVC(_ url: String) {
        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
        YXNavigationMap.navigator.presentPath(.webView, context: YXWebViewModel(dictionary: dic), animated: true, completion: nil)
    }
}


