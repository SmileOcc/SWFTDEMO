//
//  YXUserManagerGrayExtension.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/8.
//  Copyright © 2022 RenRenDai. All rights reserved.
//


enum YXGrayStatusBit: Int64  {
    case invers = 0b00000001 
    case skip = 0b00000010 //Skip
}

extension YXUserManager{
    @objc func isInvestmentGray () -> Bool  {
        return (YXUserManager.grayStatusBit & YXGrayStatusBit.invers.rawValue) == YXGrayStatusBit.invers.rawValue
    }
    
    
   static var grayStatusBit : Int64 = 0

    static var currentShowLoginRegister : Bool = false
    static var currentShowLoginRegisterSkip : Bool = false

    @objc func fetchGrayStatusBit(_ callBack:(()->())?) {
        let requestModel = YXGrayStatusBitequestModel()
     
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: {  (response) in
            if response.code == .success, let grayStatusBitRepo = response.data?["grayStatusBit"] as? Int64  {
                YXUserManager.grayStatusBit = grayStatusBitRepo
            }
            
            var isLoginRegisterFlag = false
            let isLoginRegisterSkip = (YXUserManager.grayStatusBit & YXGrayStatusBit.skip.rawValue) == YXGrayStatusBit.skip.rawValue
            
            if response.code == .success, let grayConfigregisterFlagRepo = response.data?["grayConfigRegisterFlag"] as? Int64  {
                isLoginRegisterFlag = (grayConfigregisterFlagRepo & YXGrayStatusBit.invers.rawValue) == YXGrayStatusBit.invers.rawValue
            }
            //缓存标识到本地
            YXUserManager.saveShowLoginRegister(isLoginRegisterFlag,isLoginRegisterSkip)
            callBack?()
        }, failure: { (request) in
            callBack?()
        })
        
    }
    
    @objc class func showGrayLoginSkipState() -> Bool{
        if YXUserManager.currentShowLoginRegister {
            return YXUserManager.currentShowLoginRegisterSkip
        }
        return false
    }
    
    @objc class func endShowLoginRegister() {
        YXUserManager.currentShowLoginRegister = false
    }
    
    @objc class func getLocalShowLoginRegister() {
        if YXUserManager.isLogin() {
            YXUserManager.currentShowLoginRegister = false
            return
        }
        let isShow = MMKV.default().bool(forKey: "keyShowLoginRegister", defaultValue: false)
        YXUserManager.currentShowLoginRegister = isShow
        
        let isSkip = MMKV.default().bool(forKey: "keyShowLoginRegisterSkip", defaultValue: false)
        YXUserManager.currentShowLoginRegisterSkip = isSkip
    }
    
    //是否弹出登录注册界面
    @objc class func isShowLoginRegister() -> Bool {
        return YXUserManager.currentShowLoginRegister
    }
    
    @objc class func isGuideShowLoginRegister() -> Bool {
        return YXUserManager.currentShowLoginRegister && YXAppsFlyerService.shared.deeplinkUrl == nil
    }
    
    @objc class func saveShowLoginRegister(_ flag: Bool,_ skip: Bool) {
        MMKV.default().set(flag, forKey: "keyShowLoginRegister")
        MMKV.default().set(skip, forKey: "keyShowLoginRegisterSkip")
    }
    
    @objc class func registerLoginInitRootViewControler() {
        
        YXUserManager.endShowLoginRegister()
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            let navigator = root.navigator
            root.initRootViewController(navigator: navigator)
        }
    }
}

class YXGrayStatusBitequestModel: YXJYBaseRequestModel {
    
    
    override func yx_requestUrl() -> String {
        return "/config-manager-sg/api/get-app-gray-config/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestTimeoutInterval() -> TimeInterval {
        3
    }
    
}
