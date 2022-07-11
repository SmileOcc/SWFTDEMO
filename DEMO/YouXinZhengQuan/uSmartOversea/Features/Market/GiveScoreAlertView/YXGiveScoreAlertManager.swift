//
//  YXGiveScoreAlertManager.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/7/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXGiveScoreAlertManager: NSObject {
    
    let giveScoreSubject = PublishSubject<Bool>()
    var popShowed:Bool = false

    override init() {
        super.init()
    }
    
    //检查是否持仓收益分享
    @objc func onlyCheckShareScoreCodition() -> Bool {
        guard YXUserManager.isLogin() == true else { return false}
        if YXScoreModel.isShowed(month: Date().month()) {//一个自然季度有展示
            return false
        }else{
            var canShow = false
            if let model: YXScoreModel = YXScoreModel.getCacheData(){
                if model.isHoldShare {
                    canShow = true
                }
            }
            return canShow
        }
    }
    
    //启动检查 一个季度 总弹出次数一次
    @objc func checkCondition() -> Bool {
        guard YXUserManager.isLogin() == true else { return false}
        if YXScoreModel.isShowed(month: Date().month()) {//一个自然季度有展示
            if let model = YXScoreModel.getCacheData() {
                let day = Date.getDay(from: model.launchAppDate, to: Date.curentyyyyMMdd())
                if day == 0 {
                    model.launchAppCount = 0
                }else {
                    model.launchAppCount = 1
                }
                model.launchAppDate = YXDateToolUtility.getcurrentTime()
                model.isHoldShare = false
                YXScoreModel.saveData(model: model)
            }
            return false
        }else{
            var canShow = false
            if let model: YXScoreModel = YXScoreModel.getCacheData(){
                // day为1是连续性
                let day = Date.getDay(from: model.launchAppDate, to: Date.curentyyyyMMdd())

                if model.launchAppCount >= 2 && day == 1 {//连续3天启动 要展示
                    canShow = true
                    model.launchAppCount = 0
                    model.launchAppDate = YXDateToolUtility.getcurrentTime()
                    
                }else {//记录连续启动天数
                    if day == 1 {
                        model.launchAppCount += 1
                    }else if (day > 1 || day < 0) {
                        model.launchAppCount = 1
                    }
                    model.launchAppDate = YXDateToolUtility.getcurrentTime()
                    model.isHoldShare = false
                    YXScoreModel.saveData(model: model)
                    canShow = false
                }
            }else {
                //无对应模型 第一次计数
                let firstModel = YXScoreModel.init()
                firstModel.launchAppCount = 1
                firstModel.launchAppDate = YXDateToolUtility.getcurrentTime()
                firstModel.isHoldShare = false
                YXScoreModel.saveData(model: firstModel)
            }
            return canShow
        }
       
    }
    
    @objc func isConditionReady() {
        var isReady:Bool = true
        //本身达到条件
        if self.checkCondition() == false {
            isReady = false
        }
    
        if isReady {
            YXPopManager.shared.addLaunchPopType(type: .giveScore)
        }
        giveScoreSubject.onNext(true)
        
    }

    
    @objc func showAlter(vc:UIViewController, selectedIndex:Int) {
        guard  UIViewController.current().isKind(of: YXMarketViewController.self) else {
           return
        }
        
        self.popShowed = true
        
        let bgView = UIView()
        bgView.backgroundColor = .clear // UIColor.qmui_color(withHexString: "#17181D")?.withAlphaComponent(0.69)
        bgView.frame = UIScreen.main.bounds
        let scoreView = YXGiveScoreAlertView.init(frame: .zero)
        bgView.addSubview(scoreView)
        scoreView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        scoreView.cancelBlock = { [ weak bgView] in
            YXPopManager.shared.removeTypeInPops(type: .giveScore, needShowNextPop: true)
            bgView?.hideInWindow()
        }
        scoreView.likeBlock = { [ weak bgView] in
            YXPopManager.shared.removeTypeInPops(type: .giveScore)
            bgView?.hideInWindow()
        }
        
        scoreView.unlikeBlock = { [ weak bgView] in
            YXPopManager.shared.removeTypeInPops(type: .giveScore)
            bgView?.hideInWindow()
        }
        
        if let model = YXScoreModel.getCacheData() {
            model.launchAppCount = 0
            model.launchAppDate = YXDateToolUtility.getcurrentTime()
            model.isHoldShare = false
            YXScoreModel.saveData(model: model)
        }
        YXScoreModel.saveShow(month: Date().month())
        UIView.hideOldShowAlertView()
        bgView.showInWindow()
        
    }
    
   @objc class func sharedChangeScoreModel() {
       
       if YXScoreModel.isShowed(month: Date().month()) == false{
           //分享了持仓时 会直接显示，但也是在季度之内
           if let model:YXScoreModel = YXScoreModel.getCacheData() {
               model.launchAppCount = 2
               model.isHoldShare = true
               YXScoreModel.saveData(model: model)
           } else {
               let firstModel = YXScoreModel.init()
               firstModel.launchAppCount = 2
               firstModel.isHoldShare = true
               firstModel.launchAppDate = YXDateToolUtility.getcurrentTime()
               YXScoreModel.saveData(model: firstModel)
           }
       }
    }
    
    @objc class func hadAlterViewInWindow() -> Bool {
        var popViewHad:Bool = false
        if let arrayView = UIApplication.shared.keyWindow?.subviews {
            for item in arrayView {
                if item.isKind(of: TYShowAlertView.self) {
                    popViewHad = true
                }
            }
        }
        return popViewHad
    }
    
    @objc class func dismissAlterViewInWindow() {

         if let arrayView = UIApplication.shared.keyWindow?.subviews {
             for item in arrayView {
                 if item.isKind(of: TYShowAlertView.self) {
                    item.hide()
                 }
             }
         }
     }

//    @objc class func needFinishQuoteNotify() -> Bool {
//        let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 2
//        let hqAuthority = (extendStatusBit & YXExtendStatusBitType.hqAuthority.rawValue) == YXExtendStatusBitType.hqAuthority.rawValue
//        if hqAuthority == false {
//            return true
//        }else{
//            return false
//        }
//
//    }

}
