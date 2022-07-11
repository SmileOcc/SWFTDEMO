//
//  YXProLevelUpPopHandel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXProLevelUpPopHandel: NSObject {
  
    var data:YXProLevelUpModel?
    let proLevelUpSubject = PublishSubject<Bool>()
    var popShowed: Bool = false
    var isHttpResponsed: Bool = false
    
    func reqProLevelUpData() {
        
        if isHttpResponsed {
            self.proLevelUpSubject.onNext(true)
            return
        }
        
        let (sameDay, _) =  YXUserManager.isTheSameDay(with: YXProLevelUpPopHandel.proLevelUpSaveKey(), cacheNow: false)
        if sameDay {
            self.proLevelUpSubject.onNext(true)
            return
        }
        
        let requestModel: YXProLevelUpReq = YXProLevelUpReq()
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { [weak self] model in
            guard let `self` = self else { return }
            
            guard let modeData = model as? YXProLevelUpModel, model.code == .success else {
                self.proLevelUpSubject.onNext(true)
                return
            }
            self.data = modeData
            self.isHttpResponsed = true
            self.proLevelUpSubject.onNext(true)
        } failure: { request in
            self.isHttpResponsed = true
            self.proLevelUpSubject.onNext(true)
        }

    }
    

    @objc func showProLevelUpPop() {
        
        guard let data = self.data else {
            return
        }
        
        self.popShowed = true
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        bgView.frame = UIScreen.main.bounds
        
        //图片
        let popView = YXPopImageView(frame: .zero)
        let transformer = SDImageResizingTransformer(size: CGSize(width: popView.frame.size.width * UIScreen.main.scale, height: popView.frame.size.height * UIScreen.main.scale), scaleMode: .aspectFill)
        popView.sd_setImage(with: URL.init(string: data.popUpPicUrl), placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
        bgView.addSubview(popView)
        popView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
        }
        //关闭按钮
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_close"), for: .normal)
        bgView.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(28)
            make.top.equalTo(popView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bgView.frame = CGRect(x: 0, y: 0, width: popView.frame.size.width, height: popView.frame.size.height + 20 + 28)
        let (_, _) =  YXUserManager.isTheSameDay(with: YXProLevelUpPopHandel.proLevelUpSaveKey(), cacheNow: true)
        UIView.hideOldShowAlertView()
        bgView.showInWindow()
        //点击跳转响应
        if data.skipUrl.count > 0 {
            let ges = UITapGestureRecognizer(actionBlock: { [weak bgView] (ges) in
                bgView?.hide()
                
                let root = UIApplication.shared.delegate as? YXAppDelegate
                if let navigator = root?.navigator {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: data.skipUrl]
                    navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            })
            popView.addGestureRecognizer(ges)
        }
        //关闭响应
        button.rac_command = RACCommand.init(signal: {[weak bgView] (_) -> RACSignal<AnyObject> in
            bgView?.hide()
            return RACSignal.empty()
        })
    }
    
    @objc class func proLevelUpSaveKey() -> String {
        if YXUserManager.isLogin() {
            let key:String = String(format: "proLevelUp_%ld", YXUserManager.userUUID())
            return key
        }
        return ""
    }

      
}
