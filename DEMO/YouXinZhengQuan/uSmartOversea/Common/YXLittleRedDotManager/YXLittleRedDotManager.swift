//
//  YXLittleRedDotManager.swift
//  uSmartOversea
//
//  Created by Mac on 2019/11/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

let YX_Noti_Ipo_Red_Point = "YX_Noti_Ipo_Red_Point" //新股获取小红点
let YX_Noti_New_Coupon = "YX_Noti_New_Coupon"       //查看用户是否有新优惠券
let YX_Noti_Act_Center = "YX_Noti_Act_Center"       //活动中心小红点
let YX_Noti_Ecm_Sub_Red_Point = "YX_Noti_Ecm_Sub_Red_Point"   //新股获取小红点


class YXLittleRedDotManager: NSObject {
    @objc static let shared = YXLittleRedDotManager()

    
    enum YXLittleRedDotType {
        case newCoupon
        case activityCenter
        case ipo
        case ecmSub
    }
    
    
    private var newCouponKey: String {
        if YXUserManager.isLogin(),
            let phone = YXUserManager.shared().curLoginUser?.phoneNumber,
            let areaCode = YXUserManager.shared().curLoginUser?.areaCode {
            return areaCode + "_" + phone + "YXNewCouponRedDotKey"
        }
        return "YXNewCouponRedDotKey"
    }
    
    private var ipoKey:String {
        if YXUserManager.isLogin(),
            let phone = YXUserManager.shared().curLoginUser?.phoneNumber,
            let areaCode = YXUserManager.shared().curLoginUser?.areaCode {
            return areaCode + "_" + phone + "YXIpoRedPointModelKey"
        }
        return "YXIpoRedPointModelKey"
    }
    
    private var ecmSubKey:String {
        if YXUserManager.isLogin(),
            let phone = YXUserManager.shared().curLoginUser?.phoneNumber,
            let areaCode = YXUserManager.shared().curLoginUser?.areaCode {
            return areaCode + "_" + phone + "YXECMRedPointModelKey"
        }
        return "YXECMRedPointModelKey"
    }
    
    private var actCenterKey: String {
        if YXUserManager.isLogin(),
            let phone = YXUserManager.shared().curLoginUser?.phoneNumber,
            let areaCode = YXUserManager.shared().curLoginUser?.areaCode {
            return areaCode + "_" + phone + "YXActivityCenterRedDotKey"
        }
        return "YXActivityCenterRedDotKey"
    }
    
    @objc func checkLittleRedDot() {
        
//        checkNewCoupon()
//        checkIpo()
//        checkActCenter()
    }
    
    
    //MARK:checkActivityCenter
    func checkActCenter() {
        
        var lastClickTime: Int64 = 0
        let data = MMKV.default().data(forKey: self.actCenterKey)
        var lastDict = [String: Any]()
        
        if let tempData = data,
            let tempDic = ((try? JSONSerialization.jsonObject(with: tempData, options: []) as? [String: Any]) as [String : Any]??),
            let dic = tempDic {
            lastDict = dic
            lastClickTime = dic["effective_time"] as? Int64 ?? 0
        }
        
        let requestModel = YXRedDotActCenterReqModel()
        requestModel.last_effective_time = lastClickTime
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel)  in
            guard let strongSelf = self else { return }
            
            if let dic = responseModel.data as? [String: Any] {
                
                let saveNew = strongSelf.shouldSaveNewWith(lastDict)
                
                if saveNew {
                    lastDict = dic
                } else {
                    lastDict["effective_time"] = dic["effective_time"]
                }
                if let data = try? JSONSerialization.data(withJSONObject: lastDict, options: []) {
                    MMKV.default().set(data, forKey: strongSelf.actCenterKey)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Act_Center), object: lastDict)
                
            }
            
        }) { (request) in
        }
    }
    
    //是否隐藏ActCenter的小红点
    @objc func isHiddenActCenter() -> Bool {
        isHiddenRedDot(with: .activityCenter)
    }
    
    //隐藏ActCenter的小红点
    @objc func hiddenActCenter() {
        hiddenRedDot(with: .activityCenter)
    }
    
    
    //MARK:checkNewCoupon
    func checkNewCoupon() {
        guard YXUserManager.isLogin() else {
            return
        }
        
        var lastClickTime: Int64 = 0
        let data = MMKV.default().data(forKey: self.newCouponKey)
        var lastDict = [String: Any]()
        
        if let tempData = data,
            let tempDic = ((try? JSONSerialization.jsonObject(with: tempData, options: []) as? [String: Any]) as [String : Any]??),
            let dic = tempDic {
            lastDict = dic
            lastClickTime = dic["now"] as? Int64 ?? 0
        }
        
        let requestModel = YXRedDotNewCouponRequestModel()
        requestModel.lastClickTime = lastClickTime
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel)  in
            guard let strongSelf = self else { return }
            
            if let dic = responseModel.data as? [String: Any] {
                
                let saveNew = strongSelf.shouldSaveNewWith(lastDict)
                
                if saveNew {
                    lastDict = dic
                } else {
                    lastDict["now"] = dic["now"]
                }
                //缓存
                if let data = try? JSONSerialization.data(withJSONObject: lastDict, options: []) {
                    MMKV.default().set(data, forKey: strongSelf.newCouponKey)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_New_Coupon), object: lastDict)
            }
            
        }) { (request) in
        }
        
    }
    
    //是否隐藏NewCoupon的小红点
    @objc func isHiddenNewCoupon() -> Bool {
        isHiddenRedDot(with: .newCoupon)
    }
    
    //隐藏NewCoupon的小红点
    @objc func hiddenNewCoupon() {
        hiddenRedDot(with: .newCoupon)
    }
    
    
    
    //MARK:checkIpo
    func checkIpo() {
        let requestModel = YXRedDotIpoRequestModel()
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel)  in
            guard let strongSelf = self else { return }
            let dict = responseModel.data as? [String: Any] ?? [String: Any]()
            strongSelf.saveIpoRedPointWith(dict)
            
        }) { (request) in
        }
    }
    
    //
    fileprivate func saveIpoRedPointWith(_ dic: [String: Any]) {
      //拿缓存的dict
              let lastData = MMKV.default().data(forKey: self.ipoKey)
              if let tempData = lastData {
                  
                  //比较2个timestamp，不一致时说明有更新
                  if let lastDic = ((try? JSONSerialization.jsonObject(with: tempData, options: []) as? [String: Any]) as [String : Any]??),
                      let lastTamp:Int64 = lastDic?["timestamp"] as? Int64,
                      let nowTamp:Int64 = dic["timestamp"] as? Int64,
                      lastTamp != nowTamp {
                      
                      if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                          MMKV.default().set(data, forKey: self.ipoKey)   //更新dict
                      }
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Ipo_Red_Point), object: dic)
                  }
              } else {
                  //存新数据
                  if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                      MMKV.default().set(data, forKey: self.ipoKey)   //更新dict
                  }
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Ipo_Red_Point), object: dic)
              }
              
              let ecmLastData = MMKV.default().data(forKey: self.ecmSubKey)
              if let tempData = ecmLastData {
                  //比较2个timestamp，不一致时说明有更新
                  if let lastDic = ((try? JSONSerialization.jsonObject(with: tempData, options: []) as? [String: Any]) as [String : Any]??),
                      let lastTamp:Int64 = lastDic?["ecmSubTimestamp"] as? Int64,
                      let nowTamp:Int64 = dic["ecmSubTimestamp"] as? Int64,
                      lastTamp != nowTamp {
                      
                      if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                          MMKV.default().set(data, forKey: self.ecmSubKey)   //更新dict
                      }
                      NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Ecm_Sub_Red_Point), object: dic)
                  }
              } else {
                  //存新数据
                  if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                      MMKV.default().set(data, forKey: self.ecmSubKey)   //更新dict
                  }
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Ecm_Sub_Red_Point), object: dic)
              }
    }
    
    //是否隐藏ipo的小红点
    @objc func isHiddenIpoRedPoint() -> Bool {
        isHiddenRedDot(with: .ipo)
    }
    //隐藏ipo的小红点
    @objc func hiddenIpoRedPoint() {
        hiddenRedDot(with: .ipo)
    }
    
    @objc func isHiddenEcmSubRedPoint() -> Bool {
        isHiddenRedDot(with: .ecmSub)
    }
    
    @objc func hiddenEcmSub() {
        hiddenRedDot(with: .ecmSub)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_Ecm_Sub_Red_Point), object: nil)
    }
    
}

extension YXLittleRedDotManager {
    
    fileprivate func hiddenRedDot(with type: YXLittleRedDotType) {
        var key: String = ""
        switch type {
        case .activityCenter:
            key = self.actCenterKey
        case .ipo:
            key = self.ipoKey
        case .newCoupon:
            if YXUserManager.isLogin() {
                key = self.newCouponKey
            }
        case .ecmSub:
            key = self.ecmSubKey
        }
        
        let data = MMKV.default().data(forKey: key)
        if let tempData = data,
            let jsonObject = try? JSONSerialization.jsonObject(with: tempData, options: []) {
            var dic = jsonObject as? [String: Any]
            if dic != nil {
                dic?["hasWatch"] = true
                
                if let dic = dic, let newData = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                    MMKV.default().set(newData, forKey: key)   //更新dict
                }
            }
        }
    }
    
    fileprivate func isHiddenRedDot(with type: YXLittleRedDotType) -> Bool {
        var data: Data? = nil
        switch type {
        case .activityCenter:
            data = MMKV.default().data(forKey: self.actCenterKey)
        case .ipo:
            data = MMKV.default().data(forKey: self.ipoKey)
        case .newCoupon:
            if YXUserManager.isLogin() {
                data = MMKV.default().data(forKey: self.newCouponKey)
            }
        case .ecmSub:
            data = MMKV.default().data(forKey: self.ecmSubKey)
        }
        
        if let tempData = data, let dic = ((try? JSONSerialization.jsonObject(with: tempData, options: []) as? [String: Any]) as [String : Any]??) {
            
            let hasWatch = dic?["hasWatch"] as? Bool ?? false   //获取hasWatch
            let count = dic?["count"] as? Int32 ?? 0  //获取count
            if hasWatch {
                return true
            } else if count > 0 {
                return false
            }
        }
        return true //默认隐藏
    }
    
    
    fileprivate func shouldSaveNewWith(_ lastDict: [String: Any]) -> Bool {
        var saveNew = false //是否存储全新的数据
        
        if lastDict.count > 0 { //lastDict有值
            if let count = lastDict["count"] as? Int32,count > 0 {//count有值
                if let hasWatch = lastDict["hasWatch"] as? Int {//有hasWatch
                    if (hasWatch) == 0 {
                        //有红点，但是没有查看
                        saveNew = false
                    } else { //已查看
                        saveNew = true
                    }
                } else {//没有hasWatch
                    saveNew = false
                }
            } else {//count没有值
                saveNew = true
            }
        } else {//lastDict没有值
            saveNew = true
        }
        return saveNew
    }
}
