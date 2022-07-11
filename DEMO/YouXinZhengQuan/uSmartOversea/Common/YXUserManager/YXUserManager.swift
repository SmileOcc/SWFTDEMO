//
//  YXUserManager.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import Alamofire
import AppsFlyerLib
import CryptoSwift
import TYAlertController

enum YXQuoteAuthority: Int {
    case delay = 0
    case BMP
    case level1
    case level2
} // 行情权限等级

@objcMembers class YXUserManager: NSObject {
    static let recodeIdentify = "sgFlash"
    static let DEFAULT_GUEST_UUID: UInt64 = 0
    
    var curLoginUser: YXLoginUser? //当前登录用户信息
    var deprecatedToken = "" //退出登录接口的token
    
    @objc dynamic var isTradeLogin = false

    var userBanner: YXUserBanner?
    var guestsUUID: UInt64 = YXUserManager.DEFAULT_GUEST_UUID //游客id

    var isTradeTipsHide: Bool = false  //交易小黄条
    var isBMPTipsHide: Bool = false
    /*上传相关*/
    var qCloudToken = ""
    var qCloudSecretID = ""
    var qCloudSecretKey = ""
    var qCloudExpiredTime = ""
    var qCloudCurrentTimestamp: Int = 0
    /*end*/
    
    /*pro账户相关*/
    var proTip = ""
    var goProTip = ""
    var proOrderTip = ""
    /*end*/
    
    private var isOpenUsOption : Bool{
        set{
            let mmkv = MMKV.default()
            mmkv.set(newValue, forKey: YXUserManager.YXOpenUsOptionStatus)
        }
        get{
            let mmkv = MMKV.default()
            return mmkv.bool(forKey: YXUserManager.YXOpenUsOptionStatus)
        }
    }

    private var isOpenUsFraction : Bool{
        set{
            let mmkv = MMKV.default()
            mmkv.set(newValue, forKey: YXUserManager.YXOpenUsFractionStatus)
        }
        get{
            let mmkv = MMKV.default()
            return mmkv.bool(forKey: YXUserManager.YXOpenUsFractionStatus)
        }
    }
    
    //当前券商
    @objc var curBroker:YXBrokersBitType{
        get{
            
            let mmkv = MMKV.default()
            let broker = YXBrokersBitType.brokerValue(mmkv.string(forKey: YXUserManager.YXCurBroker) ?? "")
            return broker
        }
        set{
            let mmkv = MMKV.default()
            mmkv.set(newValue.brokerNo(), forKey: YXUserManager.YXCurBroker)
        }
    }
    
    //当前券商token
    @objc var curBrokerToken:String{
        get{
            let mmkv = MMKV.default()
            return  mmkv.string(forKey: YXUserManager.YXCurBrokerToken) ?? ""
        }
        set{
            let mmkv = MMKV.default()
            mmkv.set(newValue, forKey: YXUserManager.YXCurBrokerToken)
        }
    }
    
    @objc var brokerAccountType: YXAccountType{
        get{
            
            let mmkv = MMKV.default()
            let accontType = mmkv.int32(forKey: YXUserManager.YXCurBrokerAccountType)
            return YXAccountType(rawValue: Int(accontType)) ?? .unknown
        }
        set{
            let mmkv = MMKV.default()
            mmkv.set(Int32(newValue.rawValue), forKey: YXUserManager.YXCurBrokerAccountType)
        }
    }
    
    //当前讨论模块选择了新加坡tab还是全球tab 新加坡1 全球0
    @objc var curDiscussionTab: YXDiscussionSelectedType {
        get{
            let mmkv = MMKV.default()
            let curDiscussionTab = mmkv.int32(forKey: YXUserManager.YXCurDiscussionTab, defaultValue:Int32(YXDiscussionSelectedType.singaporeTab.rawValue))
            return YXDiscussionSelectedType(rawValue: Int(curDiscussionTab)) ?? .singaporeTab
        }
        set{
            let mmkv = MMKV.default()
            mmkv.set(Int32(newValue.rawValue), forKey: YXUserManager.YXCurDiscussionTab)
        }
    }
    
    @objc var canMargin: Bool {
        return curBroker == .sg && brokerAccountType == .financing
    }
    
    var defCode = "1"//areaCodeArr[0] //用户地区code
    static let instance: YXUserManager = YXUserManager()

    class func shared() -> YXUserManager {
        return instance
    }
    
    override init() {
        super.init()
        netConfig()
        setLocationData()
    }
    
    let disposeBag = DisposeBag()
    var refreshTokenResponse: YXResultResponse<YXToken>?
    
    public class func isBrokerLogin() ->Bool{
        return YXUserManager.shared().curBroker != .dolph && YXUserManager.isLogin()
    }
    
    class func isOpenAccount(broker:YXBrokersBitType) ->Bool {
        let t = YXUserManager.shared().curLoginUser?.securitiesOpened ?? 0
        let b = (t & broker.rawValue) == broker.rawValue
        return b
    }
    
    
    public class func isLogin() -> Bool {
        
        let token = YXUserManager.shared().curLoginUser?.token
        //print("token: \(String(describing: token))")
        return !(token?.isEmpty ?? true)   //token?.count ?? 0 > 0
    }
    
    public func token() -> String {
        YXUserManager.shared().curLoginUser?.token ?? ""
    }
    
    public func extendStatusBit() -> Int {
        YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
    }
    
    public func setExtendStatusBit(statusBit: Int) {
        YXUserManager.shared().curLoginUser?.extendStatusBit = statusBit
    }
    
    public func tradePassword() -> Bool {
        YXUserManager.shared().curLoginUser?.tradePassword ?? false
    }
    @objc public func inviteCode() -> String {
        YXUserManager.shared().curLoginUser?.invitationCode ?? ""
    }
    
    /// 用户是否已进行债券签名
    /// - Returns: 是否债券签名
    func isBondSignature() -> Bool {
        if YXUserManager.isLogin() && (self.extendStatusBit() & YXExtendStatusBitType.bondRiskAuth.rawValue) == YXExtendStatusBitType.bondRiskAuth.rawValue {
            return true
        } else {
            return false
        }
    }
    
    @objc public class func isOpenUsOption() -> Bool {
        
        return YXUserManager.isLogin() && YXUserManager.shared().isOpenUsOption
    }

    @objc public class func isOpenUsFraction() -> Bool {
        return YXUserManager.isLogin() && YXUserManager.shared().isOpenUsFraction
    }

    class var userInfo: [String : Any] {
        let userId = String(format: "%llu", YXUserManager.userUUID())
        let userName = YXUserManager.shared().curLoginUser?.nickname ?? ""
        let userToken = YXUserManager.shared().curLoginUser?.token ?? ""
        let phoneNum = YXUserManager.shared().curLoginUser?.phoneNumber ?? ""
        let openedAccount = YXUserManager.canTrade()
        let tradePassword = YXUserManager.shared().curLoginUser?.tradePassword ?? false
        let invitationCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
        let hkQuoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
        let usQuoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.US.rawValue)
        let hsQuoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.ChinaSH.rawValue)
        let bondSigned = YXUserManager.shared().isBondSignature()
        let userAutograph = YXUserManager.shared().curLoginUser?.userAutograph ?? ""
        let marketBit = String(YXUserManager.shared().curLoginUser?.marketBit ?? 0)
        let isProUser = YXUserManager.isSeniorAccount()
        let email = YXUserManager.shared().curLoginUser?.email ?? ""
        let thirdBindBit = String(YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0)
        var sourceJson:String = ""
        if  let curLoginUser = YXUserManager.shared().curLoginUser,
            let sourceJsonData = try? JSONEncoder().encode(curLoginUser),
            sourceJsonData.count > 0,
            let sourceJsonString = String(data: sourceJsonData, encoding: String.Encoding.utf8) {
            sourceJson = sourceJsonString
        }

        let userInfo = [
            "userId": userId,
            "userName": userName,
            "userToken": userToken,
            "phoneNum": phoneNum,
            "openedAccount" : openedAccount,
            "tradePassword": tradePassword,
            "invitationCode" : invitationCode,
            "trade_token": "",
            "hkQuoteLevel": hkQuoteLevel.rawValue,
            "usQuoteLevel": usQuoteLevel.rawValue,
            "hsQuoteLevel": hsQuoteLevel.rawValue,
            "bondSigned" : bondSigned,
            "userAutograph" : userAutograph,
            "marketBit": marketBit,
            "sourceJson": sourceJson,
            "isProUser" : isProUser,
            "email" : email,
            "thirdBindBit": thirdBindBit,
            "securitiesLoginType" : YXUserManager.shared().curLoginUser?.securitiesLoginType ?? "" ,
            "brokerAuthorization" : YXUserHelper.currentBrokerToken()
            ] as [String : Any]
        return userInfo as [String : Any]
    }
    //退出登录
    class func loginOut(request: Bool) {
        if YXUserManager.isLogin() {
            YXUserManager.shared().tradeLoginOut {
                if request {
                    
                    if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
                        
                        appDelegate.appServices.loginService.request(.loginOut, response: { (response) in
                        } as YXResultResponse<JSONAny>).disposed(by: YXUserManager.shared().disposeBag)
                    }
                }
            }
            YXUserManager.shared().deprecatedToken = YXUserManager.shared().curLoginUser?.token ?? ""
            YXUserManager.shared().curLoginUser = nil
            YXUserManager.shared().isTradeLogin = false
            YXUserManager.shared().curBroker = .dolph
            YXUserManager.shared().curBrokerToken = ""
            YXUserManager.shared().brokerAccountType = .unknown
            YXUserManager.shared().isOpenUsOption = false
            YXUserManager.shared().isOpenUsFraction = false
            let mmkv = MMKV.default()
            mmkv.removeValues(forKeys: [YXUser, YXUserUUID, YXUserToken,YXCurBrokerToken,YXCurBroker])
            
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiLoginOut), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUUID), object: nil)
            
            
        }
    }
    class func loginOutBroker(request: Bool) {
        
        if YXUserManager.isBrokerLogin() {
            if request {
                let requestModel = YXBrokerLogOutRequest()
                let  request = YXRequest.init(request: requestModel)
                request.startWithBlock { _ in
                    let mmkv = MMKV.default()
                    mmkv.removeValues(forKeys: [YXCurBrokerToken,YXCurBroker])
                } failure: { _ in
                }
            }
            YXUserManager.shared().isTradeLogin = false
            YXUserManager.shared().curBroker = .dolph
            YXUserManager.shared().curBrokerToken = ""
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiLogoutbroker), object: nil)
        }
    }
    
    
    class func safeDecrypt(string: String) -> String {  //RSA加密
        RSA.safeEncryptString(string, publicKey: YXSecret.lDotMotString())
    }
    
    func netConfig() { //网络设置
        
        
        refreshTokenResponse =  { [weak self] (response) in
            
            if case .success(let result, let code) = response {
                if code == .success {
                    if let token = result.data?.token, token.count > 0 {
                        self?.curLoginUser?.token = token//result.data?.token ?? ""
                        YXUserManager.saveCurLoginUser()
                    }
                }
            }
        }
    }
    
    class func saveCurLoginUser() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(YXUserManager.shared().curLoginUser)
            let mmkv = MMKV.default()
            mmkv.set(data, forKey: YXUserManager.YXUser)
            let uuid = NSNumber(value: YXUserManager.shared().curLoginUser?.uuid ?? 0)
            mmkv.set(uuid, forKey: YXUserUUID)
            mmkv.set(YXUserManager.shared().curLoginUser?.token ?? "", forKey: YXUserToken)
            
        } catch {
            
        }
    }
    
    /// 设置登录信息
    class func setLoginInfo(user: YXLoginUser?) {
        YXUserManager.shared().curLoginUser = user
        YXUserManager.saveCurLoginUser()
        //YXUserManager.getUserBanner(complete: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiLogin), object: nil, userInfo: [YXUserManager.notiFirstLogin: YXUserManager.shared().curLoginUser?.appfirstLogin ?? false])
        
        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUUID), object: nil)
        
        if let appfirstLogin = YXUserManager.shared().curLoginUser?.appfirstLogin, appfirstLogin == true {
            // 注册
            YXAppsFlyerTracker.shared.trackEvent(name: AFEventCompleteRegistration)
        } else {
            // 登录
            YXAppsFlyerTracker.shared.trackEvent(name: AFEventLogin)
        }
        //查询是否开户
        checkOpenAccount()
    }
    //MARK: 加载本地数据
    func setLocationData() { //加载本地数据
        
        let service = YXKeyChainUtil.serviceName(serviceType: .Guest, bizType: .GuestUUID)
        let account = YXKeyChainUtil.accountName(serviceType: .Guest)
        let guestsUUID = SAMKeychain.password(forService: service, account: account)
        if let guestsUUID = guestsUUID {
            self.guestsUUID = UInt64(guestsUUID) ?? YXUserManager.DEFAULT_GUEST_UUID
        }else {
            self.guestsUUID = YXUserManager.DEFAULT_GUEST_UUID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.getGuestsUUID()
            }
        }
        
        let mmkv = MMKV.default()
        let data = mmkv.data(forKey: YXUserManager.YXUser)
        do {
            let user = try JSONDecoder().decode(YXLoginUser.self, from: data ?? Data())
            self.curLoginUser = user
            let token = mmkv.string(forKey: YXUserManager.YXUserToken)
            if self.curLoginUser != nil && token?.count ?? 0 == 0{
                let uuid = NSNumber(value: self.curLoginUser?.uuid ?? 0)
                mmkv.set(uuid, forKey: YXUserManager.YXUserUUID)
                mmkv.set(self.curLoginUser?.token ?? "", forKey: YXUserManager.YXUserToken)
            }
        } catch {
            
        }
        
        let bannerData = mmkv.data(forKey: YXUserManager.YXBanner)
        do {
            let banner = try JSONDecoder().decode(YXUserBanner.self, from: bannerData ?? Data())
            self.userBanner = banner
        } catch {
            
        }
        
        let defCode = mmkv.string(forKey: YXUserManager.YXDefCode)
        if !(defCode?.isEmpty ?? true) {//defCode?.count ?? 0 > 0
            self.defCode = defCode ?? ""
        }
        setNotification()
    }
    //设置网络通知
    func setNotification() {
       
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init("kReachabilityChangedNotification"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] ntf in
                guard let strongSelf = self else { return }
                if let reachability = ntf.object as? HLNetWorkReachability {
                    let netWorkStatus = reachability.currentReachabilityStatus()
                    if netWorkStatus != HLNetWorkStatus.notReachable && strongSelf.guestsUUID == YXUserManager.DEFAULT_GUEST_UUID {
                        strongSelf.getGuestsUUID()
                    }
                }
            })
        
        //接收socket的通知，弹框退出登录，并回到主页
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("kYXSocketLogoutNotification"), object: nil, queue: OperationQueue.main, using: { (ntf) in
            if YXUserManager.isLogin() {
                YXUserManager.loginOut(request: true)
                if let message = ntf.object as? String{
                        let alertView = YXAlertView(message: message)
                        alertView.clickedAutoHide = false
                        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default, handler: {[weak alertView] action in
                            alertView?.hide()
                            
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: nil)
                           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                               if let root = UIApplication.shared.delegate as? YXAppDelegate {
                                   let navigator = root.navigator
                                   root.initRootViewController(navigator: navigator)
           
                                   let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
                                   navigator.push(YXModulePaths.defaultLogin.url, context: context)
                               }
                              // YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "login_failure"))
                           }
                        }))
                        alertView.showInWindow()
                }
            }
        })

        //接收socket的通知
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("kYXSocketQuoteLevelChangeNotification"), object: nil, queue: OperationQueue.main, using: { (ntf) in

            if YXUserManager.isLogin(), YXQuoteKickTool.shared.highestQuoteLevleIsReal() {

                if let message = ntf.object as? String {

                    YXQuoteKickTool.shared.showQuoteKickAlert(message)

                }
            }
        })
        
        
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name(TokenFailureNotification), object: nil, queue: OperationQueue.main, using: { [weak self] (ntf) in
            self?.tokenFailureAction()
        })
        
        //后台进入前台 刷新用户信息
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main, using: { (ntf) in
            if YXUserManager.isLogin() {
                YXUserManager.getUserInfo(postNotification: true, complete: nil)
            }
        })
        
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXRetryConfigManager.guestsUUIDSuccess), object: nil, queue: OperationQueue.main, using: { [weak self] (ntf) in
          
            if let uuid = ntf.object as? UInt64 {
                self?.guestsUUID = uuid
                let service = YXKeyChainUtil.serviceName(serviceType: .Guest, bizType: .GuestUUID)
                let account = YXKeyChainUtil.accountName(serviceType: .Guest)
                SAMKeychain.setPassword("\(self?.guestsUUID ?? YXUserManager.DEFAULT_GUEST_UUID)", forService: service, account: account)
                NotificationCenter.default.post(name:  NSNotification.Name(YXUserManager.notiGuestsUUID), object: nil)
                NotificationCenter.default.post(name:  NSNotification.Name(YXUserManager.notiUpdateUUID), object: nil)
            }
        })
        
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXGlobalConfigManager.shareInstance.kYXCountryAreaNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] ntf in
                guard let `self` = self else { return }
                
                let defCode = MMKV.default().string(forKey: YXUserManager.YXDefCode)
                if defCode?.isEmpty ?? true {
                    if let area = YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry?.first?.area, !area.isEmpty {
                        var areaCode = area
                        if area.hasPrefix("+") {
                            areaCode = (area as NSString).replacingOccurrences(of: "+", with: "")
                        }
                        
                        if self.defCode == "1" {
                            self.defCode = areaCode
                        }
                    }
                }
                
            })
    }
    
    //token失效 action
    public func tokenFailureAction() {
        if YXUserManager.isLogin() {
            YXUserManager.loginOut(request: false)
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let navigator = root.navigator
                    root.initRootViewController(navigator: navigator)
                    
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "login_failure_normal"))
            }
        }
        
//        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_failure"))
//
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { (action) in
//            if YXUserManager.isLogin() {
//                YXUserManager.loginOut(request: false)
//                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: nil)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    if let root = UIApplication.shared.delegate as? YXAppDelegate {
//                        let navigator = root.navigator
//                        root.initRootViewController(navigator: navigator)
//                        
//                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
//                        navigator.push(YXModulePaths.defaultLogin.url, context: context)
//                    }
//                   // YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "login_failure"))
//                }
//            }
//        }))
//
//        alertView.showInWindow()
        
    }
    
    //获取用户信息
    class func getUserInfo (postNotification: Bool = true, complete: (()-> Void)?) {

        getUserInfo(postNotification: postNotification, activateToken: false, complete: {
            complete?()
            //请求是否开户
            checkOpenAccount()
        })
    }

    class func getUserInfo (postNotification: Bool = true, activateToken: Bool = false, complete: (()-> Void)?) {
        
        if !YXUserManager.isLogin() {
            if let complete = complete {
                complete()
            }
        }
        
        /*获取用户信息
         user-info-aggregation/v1  */
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            appDelegate.appServices.aggregationService.request(.updateUserInfo(activateToken), response: { (response) in
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        //为解决 ： 已退出状态，token失效，但是还返回了用户信息，就会出现 已经退出，但是还是登录状态
                        if YXUserManager.isLogin() {
                            //拿到以前的token，保留之前的token，因为【获取用户信息】不会返回token
                            //expiration /token，刷新用戶信息时，都不会返回给我们  2019-06-06
                            let tradePassword = YXUserManager.shared().curLoginUser?.tradePassword
                            let token = YXUserManager.shared().curLoginUser?.token
                            let expiration = YXUserManager.shared().curLoginUser?.expiration
                            YXUserManager.shared().curLoginUser = result.data //更新用户信息
                            if let v = tradePassword {
                                YXUserManager.shared().curLoginUser?.tradePassword = v
                            }
                            YXUserManager.shared().curLoginUser?.token = token
                            YXUserManager.shared().curLoginUser?.expiration = expiration
                            
                            YXUserManager.saveCurLoginUser()
                            // 发送用户信息更新的通知
//                            if postNotification {
//                                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
//                            }
                            //请求是否设置交易密码
                         //   YXTradePwdManager.shared().checkSetTradePwd(nil) { (isSet) in }
                        } else {
                            
                        }
                        
                        break
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
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                    default:
                        if let msg = result.msg {
                            YXProgressHUD.showError(msg)
                        }
                    }
                case .failed(_):
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                }
                
                if let complete = complete {
                    complete()
                }
                
                } as YXResultResponse<YXLoginUser>).disposed(by: YXUserManager.shared().disposeBag)
        }
        
    }
    
    class func getProWithComplete(complete: (()-> Void)?) {
        
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            
            appDelegate.appServices.tradeService.request(.getAppSystem(["PROLAB"]), response:{(response) in
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        if let model = result.data?.list?.first {
                            YXUserManager.shared().proTip = model.content ?? ""
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        }
                        
                        if let complete = complete {
                            complete()
                        }
                        break
                    default:
                        if let complete = complete {
                            complete()
                        }
                        break
                    }
                case .failed(_):
                    if let complete = complete {
                        complete()
                    }
                }
                
                }as YXResultResponse<YXAppSystemModel>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    class func getGoProWithComplete(complete: (()-> Void)?) {
        
        guard YXUserManager.isLogin() else { return }
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            
            var str = [""]
            let type = YXUserManager.getProLevel()
            if type == .common {
               str = ["PRO0-GAC"]
            } else if type == .level1 {
               str = ["PRO1-GAC"]
            } else {
                str = ["PRO2-GAC"]
            }
            appDelegate.appServices.tradeService.request(.getAppSystem(str), response:{(response) in
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        if let model = result.data?.list?.first {
                            YXUserManager.shared().goProTip = model.content ?? ""
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        }
                        
                        if let complete = complete {
                            complete()
                        }
                        break
                    default:
                        if let complete = complete {
                            complete()
                        }
                        break
                    }
                case .failed(_):
                    if let complete = complete {
                        complete()
                    }
                }
                
                }as YXResultResponse<YXAppSystemModel>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    class func getIPOProWithComplete(_ labels: [String], complete: ((_ content: String?)-> Void)?) {
        
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            
            appDelegate.appServices.tradeService.request(.getAppSystem(labels), response:{(response) in
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        var content: String = ""
                        if let model = result.data?.list?.first {
                            content = model.content ?? ""
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        }
                        
                        if let complete = complete {
                            complete(content)
                        }
                        break
                    default:
                        if let complete = complete {
                            complete(nil)
                        }
                        break
                    }
                case .failed(_):
                    if let complete = complete {
                        complete(nil)
                    }
                }
                
                }as YXResultResponse<YXAppSystemModel>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    class func getProOrderWithComplete(complete: (()-> Void)?) {
        
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            
            appDelegate.appServices.tradeService.request(.getAppSystem(["PRO-IPO3"]), response:{(response) in
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        if let model = result.data?.list?.first {
                            YXUserManager.shared().proOrderTip = model.content ?? ""
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        }
                        
                        if let complete = complete {
                            complete()
                        }
                        break
                    default:
                        if let complete = complete {
                            complete()
                        }
                        break
                    }
                case .failed(_):
                    if let complete = complete {
                        complete()
                    }
                }
                
                }as YXResultResponse<YXAppSystemModel>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    //获取闪屏广告
    class func getSplashscreenAdvertisement(complete:(()-> Void)?) {
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            /*news-configserver -- 闪屏广告
             get请求
            */
            appDelegate.appServices.newsService.request(.splashScreenAdvertisement, response:{(response) in
                if let complete = complete {
                    complete()
                }
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let first = result.data {
                            let picUrl = URL(string: first.pictureURL ?? "")

                            SDWebImageManager.shared.loadImage(with: picUrl, options: SDWebImageOptions.retryFailed, progress: { (_, _, _) in

                            }) { (image, data, error, cacheType, finished, imageURL) in
                                if (error == nil )  {
                                    if let imgData = image?.pngData() {
                                        let mmkv = MMKV.default()
                                        mmkv.set(imgData, forKey: YXUserManager.YXSplashScreenImage)
                                    }
                                }
                            }
                        }

                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        do {
                            //返回为空也保存，覆盖之前的数据
                            let data = try encoder.encode(result.data)
                            let mmkv = MMKV.default()
                            mmkv.set(data, forKey: YXUserManager.YXSplashScreenAdvertisement)
                            
                        } catch {
                            
                        }
                        break
                    default:
                        if let msg = result.msg {
                            YXProgressHUD.showError(msg)
                        }
                    }
                case .failed(_): break
//                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                }
                }as YXResultResponse<SplashscreenList>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    //sg获取闪屏广告
    class func sg_getSplashscreenAdvertisement(hasRead: [String], pageId: Int,complete:(()-> Void)?) {
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            /*news-configserver -- 闪屏广告
             get请求
            */
            appDelegate.appServices.newsService.request(.getflashwindow(hasRead: hasRead, pageId: pageId), response:{(response) in
                if let complete = complete {
                    complete()
                }
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let dataArr = result.data?.dataList, dataArr.count > 0 {
                            let splashItem = dataArr.min { //取出优先级最靠前的广告
                                $0.adPos ?? 0 < $1.adPos ?? 0
                            }
                            let picUrl = URL(string: splashItem?.pictureURL ?? "")
                            SDWebImageManager.shared.loadImage(with: picUrl, options: SDWebImageOptions.retryFailed, progress: { (_, _, _) in

                            }) { (image, data, error, cacheType, finished, imageURL) in
                                if (error == nil )  {
                                    if let imgData = image?.pngData() {
                                        let mmkv = MMKV.default()
                                        //根据返回数据的优先级把优先级最高的那张闪屏保存起来
                                        mmkv.set(imgData, forKey: YXUserManager.YXSplashScreenImage)
                                    }
                                }
                            }
                            
                        } else {
//                            let mmkv = MMKV.default()
//                            mmkv.removeValue(forKey: YXUserManager.YXSplashScreenImage)
                        }
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        do {
                            //返回为空也保存，覆盖之前的数据
                            let data = try encoder.encode(result.data)
                            let mmkv = MMKV.default()
                            mmkv.set(data, forKey: YXUserManager.YXSplashScreenAdvertisement)
                            
                        } catch {
                            
                        }
                        break
                    default:
                        if let msg = result.msg {
                            YXProgressHUD.showError(msg)
                            MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
                        }
                    }
                case .failed(_):
//                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                    MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
                }
                }as YXResultResponse<YXSplashScreenList>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    func saveShowedFlash(_ showPage:Int ,_ adId:Int)  {
        let keepKey =  YXUserManager.recodeIdentify
        if let recodeArray:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: keepKey) as? NSMutableArray {
            recodeArray.add(adId as Any)
            MMKV.default().set(recodeArray, forKey:keepKey)
        }else {
            let recodeArray = NSMutableArray.init(capacity: 1)
            recodeArray.add(adId as Any)
            MMKV.default().set(recodeArray, forKey:keepKey)
        }
    }

    
    //获取用户banner
    class func getUserBanner (complete: (()-> Void)?) {
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            //     展示页面 1：自选股页；2：个人中心-首页；
            let oldTime = MMKV.default().double(forKey: YXUserCenterViewModel.userCenterAd, defaultValue: 0)
            let nowTime = Double(NSDate.beginOfToday().timeIntervalSince1970)
            if nowTime - oldTime > Double(24 * 60 * 60) {
                appDelegate.appServices.newsService.request(.userBannerV2(id: .personalCenterHome), response: { (response) in
                    //block通知完成请求
                    if let complete = complete {
                        complete()
                    }
                    
                    switch response {
                    case .success(let result, let code):
                        switch code {
                        case .success?:
                            YXUserManager.shared().userBanner = result.data
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            do {
                                let data = try encoder.encode(YXUserManager.shared().userBanner)
                                let mmkv = MMKV.default()
                                mmkv.set(data, forKey: YXUserManager.YXBanner)
                            } catch {
                                
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                            break
                        default:
                            if let msg = result.msg {
//                                YXProgressHUD.showError(msg)
                            }
                        }
                    case .failed(_): break
//                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                    }
                    
                    } as YXResultResponse<YXUserBanner>).disposed(by: YXUserManager.shared().disposeBag)
            } else {
                YXUserManager.shared().userBanner = nil
                if let complete = complete {
                    complete()
                }
            }
        }
    }
    
    
    //获取客户端 UUID
    func getGuestsUUID() {
        
        YXRetryConfigManager.shareInstance.requestGuestsUUID()
    }
    
    //更新token
    func refreshToken() {
        if YXUserManager.isLogin() {
            var shouldRefresh:Bool = false
            if var expiration = self.curLoginUser?.expiration, expiration > 0 {
                if (expiration > 1000000000000) { //如果是13位
                    expiration = expiration / 1000
                }
                let interval: TimeInterval = TimeInterval.init(expiration)
                let date = Date(timeIntervalSince1970: interval)
                let timeInterval = date.timeIntervalSinceNow
                // 得到的是一个负值 (加' - ' 得正以便后面计算)
                // timeInterval = -timeInterval
                if timeInterval < 7 * 24 * 60 * 60 {
                    shouldRefresh = true
                }
            } else {
                shouldRefresh = true
            }
            
            if shouldRefresh {
                let requestModel = YXTokenRequestModel()
                let tokenRequest = YXRequest(request: requestModel)
                if let url = URL(string: "\(requestModel.yx_baseUrl())\(requestModel.yx_requestUrl())") {
                    let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 3)
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = tokenRequest.requestHeaderFieldValueDictionary()
                    
                    //#pragma clang diagnostic push
                    //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    var received: Data? = nil
                    do {
                        received = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
                        //#pragma clang diagnostic pop
                        if let received = received,
                            let str = String(data: received, encoding: .utf8), !str.isEmpty,
                            let datas = str.data(using: .utf8),
                            let dictionary = try JSONSerialization.jsonObject(with: datas, options: .mutableLeaves) as? [AnyHashable : Any],
                            let code = dictionary["code"] as? Int,
                            let data = dictionary["data"] as? Dictionary<AnyHashable, Any> {
                            if YXResponseCode(rawValue: code) == .success {
                                if let token = data["token"] as? String, token.count > 0 {
                                    //为解决 ： 已退出状态，token失效，但是还返回了用户信息，就会出现 已经退出，但是还是登录状态
                                    if YXUserManager.isLogin() {
                                        self.curLoginUser?.token = token//data["token"] as? String
                                        YXUserManager.saveCurLoginUser()
                                        YXUserManager.getUserInfo(complete: nil)
        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateToken), object: nil)
                                    }
                                }
                                
                            }else {
                                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: url.urlStringValue, code: "\(code)", desc: "", extend_msg: "")
                            }
                            
                        }else {
                            YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: url.urlStringValue, code: "-2", desc: "未知错误", extend_msg: "")
                        }
                        
                    } catch {
                        
                    }
                    
                    if YXUserManager.canTrade() {
                        //交易登出
                        self.tradeLoginOut()
                    }
                }
            } else {
                if YXUserManager.canTrade() {
                    //交易登出
                    self.tradeLoginOut()
                }
            }
            
            // 重新刷新一下用户信息
            YXUserManager.getUserInfo {
                log(.info, tag: kOther, content: "refreshToken getUserInfo complete")
            }
        }
    }
    
    func tradeLoginOut(complete: (() -> Void)? = nil) {
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            appDelegate.appServices.userService.request(.tradeLogout, response: { (_) in
                complete?()
            } as YXResultResponse<JSONAny>).disposed(by: disposeBag)
        }
    }
    
    class func userUUID() -> UInt64 {
        if YXUserManager.isLogin() {
            return UInt64(YXUserManager.shared().curLoginUser?.uuid ?? 0)
        }else {
            return YXUserManager.shared().guestsUUID
        }
    }
    
    // 登录注册是否跳转开户
    class func isNeedGuideAccount() -> Bool {
        if YXUserManager.isLogin() {
            //let userIdStr = (YXUserManager.shared().curLoginUser?.uuidStr ?? "").md5()
            //let isHadShow = MMKV.default().bool(forKey: userIdStr, defaultValue: false)
            if let guideFlag = YXUserManager.shared().curLoginUser?.guideAccountFlag, guideFlag == true {
                //MMKV.default().set(true, forKey: userIdStr)
                return true
            }
        }
        
        return false
    }
    
    //是否是保证金账户
    class func isFinancing(market: String) -> Bool {
        if YXUserManager.isLogin() {
            let marketType = YXMarketType(rawValue: market) ?? .none
            switch marketType {
            case .HK:
                if YXUserManager.shared().curLoginUser?.hkAccountType == .financing {
                    return true
                }
            case .US:
                if YXUserManager.shared().curLoginUser?.usAccountType == .financing {
                    return true
                }
            case .ChinaHS,
                 .ChinaSH,
                 .ChinaSZ:
                if YXUserManager.shared().curLoginUser?.cnAccountType == .financing {
                    return true
                }
            default:
                return false
            }
        }
        return false
    }

    //是否是日内融账户
    class func isIntraday(_ market: String) -> Bool {
        if YXUserManager.isLogin(), !market.isEmpty {
            if let dic = YXUserManager.shared().curLoginUser?.intradayMarket?.value as? [String : Any], let boolValue = dic[market.uppercased()] as? Bool {
                return boolValue
            }
        }
        return false
    }
    
    //是否是期权账户(带市场)
    class func isOption(_ market: String = "us") -> Bool {
        if YXUserManager.isLogin(), !market.isEmpty {
            if let dic = YXUserManager.shared().curLoginUser?.optionMarket?.value as? [String : Any], let boolValue = dic[market.uppercased()] as? Bool {
                return boolValue
            }
        }
        return false
    }
    
    class func isShortSell(_ market: String = "us") -> Bool {
        if YXUserManager.isLogin(), !market.isEmpty {
            if let dic = YXUserManager.shared().curLoginUser?.shortSellingMarket?.value as? [String : Any], let boolValue = dic[market.uppercased()] as? Bool {
                return boolValue
            }
        }
        return false
    }
    
//    //是否是期权账户(不带市场,默认是us)
//    class func isOption() -> Bool {
//        if YXUserManager.isLogin(), !market.isEmpty {
//            if let dic = YXUserManager.shared().curLoginUser?.optionMarket?.value as? [String : Any], let boolValue = dic[market.uppercased()] as? Bool {
//                return boolValue
//            }
//        }
//        return false
//    }
    
    // 是否绑定AppleID
    class func isBindApple() -> Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.apple.rawValue) == YXLoginBindType.apple.rawValue
        return b
    }
    
    // 是否绑定微信
    class func isBindWechat() -> Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.wechat.rawValue) == YXLoginBindType.wechat.rawValue
        return b
    }
    
    // 是否绑定google
    class func isBindGoogle() -> Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.google.rawValue) == YXLoginBindType.google.rawValue
        return b
    }
    
    // 是否绑定facebook
    class func isBindFaceBook() -> Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.faceBook.rawValue) == YXLoginBindType.faceBook.rawValue
        return b
    }
    
    // 是否绑定 手机
    class func isBindPhone() -> Bool {
        if YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false {
            if YXUserManager.shared().curLoginUser?.phoneNumber?.count ?? 0 > 0 {
                return true
            }
            return false
        }
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.phone.rawValue) == YXLoginBindType.phone.rawValue
        return b
    }
    //是否绑定 邮箱
    class func isBindEmail() ->Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.email.rawValue) == YXLoginBindType.email.rawValue
        return b
    }
    
    // 是否绑定Line
    class func isBindLine() -> Bool {
        let t = YXUserManager.shared().curLoginUser?.thirdBindBit ?? 0
        let b = (t & YXLoginBindType.line.rawValue) == YXLoginBindType.line.rawValue
        return b
    }
    
    class func isGrayWithPreAfter() -> Bool {
        YXUserManager.isGray(with: .preAfter)
    }
    
    // 是否 是灰度
    @objc class func isGray(with type: YXGrayStatusBitType) -> Bool {
        let grayStatusBit = YXUserManager.shared().curLoginUser?.grayStatusBit ?? 0
        var b: Bool = false
        switch type {
        case .fund:
            b = (grayStatusBit & YXGrayStatusBitType.fund.rawValue) == YXGrayStatusBitType.fund.rawValue
        case .actualQuot:
            b = (grayStatusBit & YXGrayStatusBitType.actualQuot.rawValue) == YXGrayStatusBitType.actualQuot.rawValue
        case .bond:
            b = (grayStatusBit & YXGrayStatusBitType.bond.rawValue) == YXGrayStatusBitType.bond.rawValue
        case .pinTuan:
            b = (grayStatusBit & YXGrayStatusBitType.pinTuan.rawValue) == YXGrayStatusBitType.pinTuan.rawValue
        case .margin:
            b = (grayStatusBit & YXGrayStatusBitType.margin.rawValue) == YXGrayStatusBitType.margin.rawValue
        case .preAfter:
            b = (grayStatusBit & YXGrayStatusBitType.preAfter.rawValue) == YXGrayStatusBitType.preAfter.rawValue
        case .hsMargin:
            b = (grayStatusBit & YXGrayStatusBitType.hsMargin.rawValue) == YXGrayStatusBitType.hsMargin.rawValue
        default:
            break
        }
        return b
    }
    

    // 是否开通   A股通/港股/美股 交易
    class func isOpenHSTrade(with marketType: YXMarketBitType = .hk) -> Bool {
        let t = YXUserManager.shared().curLoginUser?.marketBit ?? 0
        
        var b = (t & YXMarketBitType.hk.rawValue) == YXMarketBitType.hk.rawValue
        switch marketType {
        case .us:
            b = (t & YXMarketBitType.us.rawValue) == YXMarketBitType.us.rawValue
        case .hs:
            b = (t & YXMarketBitType.hs.rawValue) == YXMarketBitType.hs.rawValue
        default:
            print("default_hk")
        }
        return b
    }
    class func isHighWorth() -> Bool {
        //专业投资者认证状态: 0-未申请 1-待初审 2-待终审 3-审核未通过 4-审核通过
        if YXUserManager.shared().curLoginUser?.majorStatus ?? 0 == 4 && YXUserManager.isLogin() {
            return true
        }
        return false
    }
    //是否 是高级账户
    class func isSeniorAccount() -> Bool {
        /*1, "普通账户"
        2, "高级账户-大陆"
        3, "高级账户-香港"*/
        switch YXUserManager.shared().curLoginUser?.userRoleType {
        case .seniorHK?, .seniorMainland?:
            if YXUserManager.isLogin() {
                return true
            }
        default:
            break
        }
        
        return false
    }
    //是否是专业人士
    class func isProfessional() -> Bool {
        return YXUserManager.shared().curLoginUser?.financialProfessional ?? false
    }
    

    class func getProLevel() -> YXUserProType {
        
        if YXUserManager.isLogin() {
            switch YXUserManager.shared().curLoginUser?.userRoleType {
            case .seniorHK?, .seniorMainland?:
                return .level2
            case .prolevel2? :
                return .level1
            default:
                return .common
            }
        } else {
            return .common
        }
    }
    
    /// 是否可以进行交易
    /// 满足以下条件之一即可去交易页面
    /// 1.已经开户
    /// - Returns: YES:是 NO否
    class func canTrade() -> Bool {
        if (YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false) {//机构登录
            return YXUserManager.shared().curLoginUser?.openedAccount ?? false
        }
        
        return YXUserManager.isBrokerLogin()

       // YXUserManager.isLogin() && YXUserManager.isBrokerLogin()
    }
    
//    class func isCanMargin(market: String, quote: YXV2Quote? = nil) -> Bool {
//        var canMargin = isFinancing(market: market)
//        let marketType = YXMarketType(rawValue: market) ?? .none
//        if canMargin,
//           (marketType == .ChinaHS || marketType == .ChinaSH || marketType == .ChinaSZ) {
//            canMargin = isGray(with: .hsMargin)
//            if canMargin,
//               let quote = quote, quote.market == market {
//                canMargin = quote.canMargin
//            } else {
//                canMargin = false
//            }
//        }
//        
//        return canMargin
//    }
//    
    /// 当前选择的语言
    /// 1简体2繁体3英文
    /// - Returns: 选择的语言
    class func curLanguage() -> YXLanguageType {
//        let mmkv = MMKV.default()
//        mmkv.set(Int32(YXLanguageType.EN.rawValue), forKey: YXUserManager.YXLanguage)
//        return YXLanguageType.EN
        let mmkv = MMKV.default()
        let curLanguage = mmkv.int32(forKey: YXUserManager.YXLanguage)
        
        if curLanguage == 0 { //没有存储
            var defaultLanguage:YXLanguageType = .EN
            let languages = NSLocale.preferredLanguages
            let language = languages.first
            //zh_Hans 表示简体中文
            if language?.hasPrefix("zh-Hans") ?? false {//简体
                defaultLanguage = .CN
            } else if language?.hasPrefix("zh-Hant") ?? false {//繁体
                defaultLanguage = .HK
            } else if language?.hasPrefix("ms") ?? false {//马来语
                defaultLanguage = .ML
            } else if language?.hasPrefix("th") ?? false {//泰语
                defaultLanguage = .TH
            }
            mmkv.set(Int32(defaultLanguage.rawValue), forKey: YXUserManager.YXLanguage)
            return defaultLanguage
        }
        return YXLanguageType(rawValue: Int(curLanguage)) ?? YXLanguageType.EN  //有存储
    }
    
    /// 是否当前语言是英文的模式.
    @objc class func isENMode() -> Bool {
        let lang = self.curLanguage()
        if lang == .EN || lang == .TH || lang == .ML {
            return true
        } else {
            return false
        }
    }
    
    /// 当前的涨跌幅、涨跌额的颜色设置
    /// 1 红涨绿跌 2绿涨红跌
    /// - Returns: 选择的颜色设置方式
    class func curColor(judgeIsLogin: Bool) -> YXLineColorType {
        
        return .gRaiseRFall
//        if judgeIsLogin && YXUserManager.isLogin() {
//            return YXUserManager.shared().curLoginUser?.lineColorHk ?? YXLineColorType.gRaiseRFall
//        } else {
//            let mmkv = MMKV.default()
//            let color = mmkv.int32(forKey: YXUserManager.YXColor, defaultValue: Int32(YXLineColorType.gRaiseRFall.rawValue))
//            return YXLineColorType(rawValue: Int(color)) ?? YXLineColorType.gRaiseRFall
//        }
    }
    
    // 报价图表
    class func curQuoteChartHk(judgeIsLogin: Bool) -> YXQuoteChartHkType {
        if judgeIsLogin && YXUserManager.isLogin() {
            return YXUserManager.shared().curLoginUser?.quoteChartHk ?? YXQuoteChartHkType.advanced
        } else {
            let mmkv = MMKV.default()
            let quote = mmkv.int32(forKey: YXUserManager.YXQuoteChartHk, defaultValue: Int32(YXQuoteChartHkType.advanced.rawValue))
            return YXQuoteChartHkType(rawValue: Int(quote)) ?? YXQuoteChartHkType.advanced
        }
    }
    
    // 获取 中间部分隐藏 的手机号
    class func secretPhone() -> String {
        var phone = YXUserManager.shared().curLoginUser?.phoneNumber ?? ""
        //86的，隐藏4~7位，其他，隐藏3~6位
        if YXUserManager.shared().curLoginUser?.areaCode == "86" {//中国内地
            if phone.count > 8 {
                let nsRange = NSRange(location: 3, length: 4)
                if let range = phone.toRange(nsRange) {
                    phone = phone.replacingCharacters(in: range, with: "****")
                }
            }
        } else {
            if phone.count >= 7 {
                let nsRange = NSRange(location: 2, length: 4)
                if let range = phone.toRange(nsRange) {
                    phone = phone.replacingCharacters(in: range, with: "****")
                }
            }
        }
        return phone
    }
    
    // 获取 部分隐藏的邮箱
    class func secretEmail() -> String {
        let email = YXUserManager.shared().curLoginUser?.email ?? ""
        let arr = email.components(separatedBy: "@")
        if arr.count < 2 {
            return email
        }
        var startStr = arr[0]
        if startStr.count > 3 {
            startStr = String(format: "%@****@%@", String(startStr.prefix(3)), arr[1])
        }else if startStr.count > 1{
            startStr = String(format: "%@****@%@", String(startStr.prefix(startStr.count-1)), arr[1])
        }else {
            startStr = String(format: "%@****@%@", startStr, arr[1])
        }
        return startStr
    }
    
    /// 获取用户统一行情权限等级
    ///
    /// - Parameter market: 市场
    /// - Returns: 行情权限等级
    public func getLevel(with market: String) -> QuoteLevel {
        if market == kYXMarketCryptos {
            return .level1
        }
        
        if market == kYXMarketUsOption {
            return getOptionLevel()
        }
        
        let userLevel = YXUserManager.userLevel(market)
        if userLevel == .hkLevel2 || userLevel == .hkWorldLevel2 || userLevel == .sgLevel2CN || userLevel == .sgLevel2Overseas{
            return .level2       //LV2
        } else if userLevel == .hkBMP {
            return .bmp         //BMP
        } else if userLevel == .usLevel1 || userLevel == .cnLevel1 || userLevel == .sgLevel1CN || userLevel == .sgLevel1Overseas || userLevel == .hkLevel1 {
            return .level1      //LV1
        } else if userLevel == .usNation {
            return .usNational
        }
        return .delay
    }
    
    /// 获取用户期权行情权限等级
    public func getOptionLevel() -> QuoteLevel {
        let userLevel = YXUserManager.optionLevel()
        if userLevel == .usLevel1 {
            return .level1
        }
        return .delay
    }
    
    /// 获取用户深度摆盘行情权限等级
    public func getDepthOrderLevel() -> QuoteLevel {
        
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.usaArca?.productCode, level == 14 {
            return .level2
        }
        return .delay
    }
    
    public func getHighestUsaThreeLevel() -> QuoteLevel {
        
//        case usaThreeLevel1 = 15
//
//        case hkLevel1 = 16
        
        if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.usaThree?.productCode, let userLevel = YXUserLevel(rawValue: level), userLevel == .usaThreeLevel1 {
            return .level1
        }
        return .delay
    }
    
    public func getNsdqLevel() -> QuoteLevel {
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.usa?.productCode, let userLevel = YXUserLevel(rawValue: level), (userLevel == .usLevel1 || userLevel == .cnLevel1) {
            return .level1
        }
        return .delay
    }
    
    public func getHighestNsdqLevel() -> QuoteLevel {
        if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.usa?.productCode, let userLevel = YXUserLevel(rawValue: level), (userLevel == .usLevel1 || userLevel == .cnLevel1) {
            return .level1
        }
        return .delay
    }
    
    public func getUsaThreeLevel() -> QuoteLevel {
        
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.usaThree?.productCode, let userLevel = YXUserLevel(rawValue: level), userLevel == .usaThreeLevel1 {
            return .level1
        }
        return .delay
    }
    
    //MARK: - 获取用户等级
    ///
    /// - Parameter stockCode: 股票代码或者地区 eg: "hk00700" or "hk"
    /// - Returns: 用户等级
    public class func userLevel(_ stockCode: String) -> YXUserLevel {
        
        var market: YXMarketType = .none
        if (stockCode as NSString).contains(YXMarketType.HK.rawValue) {
            market = .HK
        }
        else if (stockCode as NSString).contains(YXMarketType.US.rawValue) {
            market = .US
        }
        else if (stockCode as NSString).contains(YXMarketType.ChinaSH.rawValue) {
            market = .ChinaSH
        }
        else if (stockCode as NSString).contains(YXMarketType.ChinaSZ.rawValue) {
            market = .ChinaSZ
        }
        else if (stockCode as NSString).contains(YXMarketType.ChinaHS.rawValue) {
            market = .ChinaHS
        }
        else if (stockCode as NSString).contains(YXMarketType.SG.rawValue) {
            market = .SG
        }
        
        switch market {
        case .US:
            return usLevel()
        case .HK:
            return hkLevel()
        case .ChinaSH, .ChinaSZ, .ChinaHS:
            return hsLevel()
        case .SG:
            return sgLevel()
        default:
            return .hkDelay
        }
    }
    /// 美股等级
    public class func usLevel() -> YXUserLevel {
        /// 优先判断美股的全美, 如果有,就取全美
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.usaNation?.productCode, let userLevel = YXUserLevel(rawValue: level), userLevel == .usNation {
            return .usNation
        }
        return usNsdqLevel()
    }
    
    public class func usNsdqLevel() -> YXUserLevel {
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.usa?.productCode, let userLevel = YXUserLevel(rawValue: level) {
            return userLevel
        }
        return .usDelay
    }
    /// 港股等级
    public class func hkLevel() -> YXUserLevel {
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.hk?.productCode, let userLevel = YXUserLevel(rawValue: level) {
            return userLevel
        }
        return .hkDelay
    }
    /// A股等级
    public class func hsLevel() -> YXUserLevel {

        if !YXUserManager.isLogin() {
            return .cnLevel1   //参考大陆版
        }

        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.zht?.productCode, let userLevel = YXUserLevel(rawValue: level) {
            return userLevel
        }
        return .cnDelay
    }
    
    /// 期权等级
    public class func optionLevel() -> YXUserLevel {
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.uso?.productCode, level == 11 {
            return .usLevel1
        }
        return .usDelay
    }

    public func getHighestUserLevel(with market: String) -> QuoteLevel {
        if market == kYXMarketUsOption {
            if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.uso?.productCode, level == 11 {
                return .level1
            }
        } else if market == kYXMarketUS {
            
            if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.usaNation?.productCode, let userLevel = YXUserLevel(rawValue: level), userLevel == .usNation {
                return .usNational
            }
            
            if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.usa?.productCode, let userLevel = YXUserLevel(rawValue: level), (userLevel == .usLevel1 || userLevel == .cnLevel1) {
                return .level1
            }
        } else if market == kYXMarketHK {
            if let level = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.hk?.productCode, let userLevel = YXUserLevel(rawValue: level) {

                if userLevel == .hkLevel2 || userLevel == .hkWorldLevel2 {
                    return .level2       //LV2
                } else if userLevel == .hkBMP {
                    return .bmp         //BMP
                }
            }
        } else if market == kYXMarketChinaSH || market == kYXMarketChinaSZ || market == kYXMarketChinaHS  {
            if !YXUserManager.isLogin() {
                return .level1     //参考大陆版
            }

            if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.zht?.productCode, let userLevel = YXUserLevel(rawValue: level), (userLevel == .usLevel1 || userLevel == .cnLevel1) {
                return .level1
            }
        }

        return .delay
    }
    
    /// 新加坡等级
    public class func sgLevel() -> YXUserLevel {
        if let level = YXUserManager.shared().curLoginUser?.userQuotationVOList?.sg?.productCode, let userLevel = YXUserLevel(rawValue: level) {
            return userLevel
        }
        return .sgDelay
    }
    
    //请求用户是否开户
   class func checkOpenAccount()  {
    if let logintype = YXUserManager.shared().curLoginUser?.securitiesLoginType {
        if YXConstant.appTypeValue == .OVERSEA{
            let broker = YXBrokersBitType.brokerValue(logintype)
            let res = broker != .dolph
            //YXUserManager.shared().curLoginUser?.openedAccount = res
            YXUserManager.shared().curLoginUser?.tradePassword = res
            YXUserManager.shared().curBroker = broker
            YXUserManager.saveCurLoginUser()
        }else if YXConstant.appTypeValue == .OVERSEA_SG{
            let broker = YXBrokersBitType.brokerValue(logintype)
            if broker != .dolph {
                let broker = YXBrokersBitType.brokerValue(logintype)
               // YXUserManager.shared().curLoginUser?.openedAccount = true
               // YXUserManager.shared().curLoginUser?.tradePassword = true
                YXUserManager.shared().curBroker = broker
//                YXUserManager.shared().curBrokerToken = clientID
                YXTradePwdManager.shared().checkSetTradePwd(nil) { b in
                    YXUserManager.shared().curLoginUser?.tradePassword = b
                }
            }else {
              //  YXUserManager.shared().curLoginUser?.openedAccount = false
                YXUserManager.shared().curLoginUser?.tradePassword = false
                YXUserManager.shared().curBroker = .dolph
                YXUserManager.shared().curBrokerToken = ""
                YXUserManager.saveCurLoginUser()

            }
        }
        //查询账户类型
        YXMarginManager.shared.requestUserAccType(boker: YXUserManager.shared().curBroker.brokerNo()) { _ in }
        //查询期权是否开户
        YXUserManager.getUSOptionStatus()
        //查询碎股是否开户
        YXUserManager.getUSFractionStatus()
    }
    NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
    }
    
    public func getQuoteAuthority(_ market:String) -> YXQuoteAuthority{
        if YXUserManager.isLogin(),market == kYXMarketHK {
            let hkQuote = self.curLoginUser?.userQuotationVOList?.hk?.productCode
            switch hkQuote {
            case 2:
                return .delay
            case 3:
                return .BMP
            case 4,
                 5:
                return .level2
            default:
                return .delay
            }
        }else if market == kYXMarketUS{
            let usQuote = self.curLoginUser?.userQuotationVOList?.usa?.productCode
            switch usQuote {
            case 0:
                return .delay
            case 1:
                return .level1
            default:
                return .delay
            }
        }else if market == kYXMarketHS{
            let usQuote = self.curLoginUser?.userQuotationVOList?.zht?.productCode
            switch usQuote {
                case 6: //延時
                    return .delay
                case 7: //level1
                    return .level1
                default:
                    return .level1
            }
        }else if market == kYXMarketUsOption{
            return self.getOptionQuoteAuthority()
        }else {
            return .delay
        }
    }
    
    func getOptionQuoteAuthority() -> YXQuoteAuthority {
        if YXUserManager.isLogin() {
            let usoQuote = self.curLoginUser?.userQuotationVOList?.uso?.productCode
            if usoQuote == 11 {
                return .level1;
            }
        }
        return .delay;
    }
    
    func getDepthOrderAuthority() -> YXQuoteAuthority {
        if YXUserManager.isLogin() {
            let usoQuote = self.curLoginUser?.userQuotationVOList?.usaArca?.productCode
            if usoQuote == 14 {
                return .level2
            }
        }
        return .delay;
    }
}

//MARK: 更新token
//MARK: 更新token
extension YXUserManager {
    class func updateToken(fileName: String, region: String, bucket: String, success: @escaping () -> Void, failed: @escaping (_ errorMsg: String) -> Void) {
        YXGlobalConfigProvider.rx.request(.getFileCredAppV2(fileName: fileName, bucket: bucket, region: region))
            .map(YXResult<String>.self)
            .subscribe(onSuccess: { (response) in
                if response.code == YXResponseCode.success.rawValue, let base64EncodeData = response.data {
                    do {
                        if let decodeData = NSData(base64Encoded: base64EncodeData, options: .ignoreUnknownCharacters) as Data? {
                            let model = try JSONDecoder().decode(YXQCloudCOSModel.self, from: decodeData)
                            let aes = try AES(key: YXQCloudService.AESKey.bytes, blockMode: ECB())
                            let tmpSecretKey = try model.tmpSecretKey.decryptBase64ToString(cipher: aes)
                            let sessionToken = try model.sessionToken.decryptBase64ToString(cipher: aes)
                            YXUserManager.shared().qCloudToken = sessionToken
                            YXUserManager.shared().qCloudSecretID = model.tmpSecretID
                            YXUserManager.shared().qCloudSecretKey = tmpSecretKey
                            YXUserManager.shared().qCloudExpiredTime = model.expiredTime
                            YXUserManager.shared().qCloudCurrentTimestamp = model.currentTimestamp
                            success()
                        }
                    } catch {
                        log(.error, tag: kOther, content: "解析cos数据失败")
                        failed(YXLanguageUtility.kLang(key: "common_net_error"))
                    }
                } else if let msg = response.msg {
                    failed(msg)
                }
            } , onError: { (error) in
                failed(YXLanguageUtility.kLang(key: "common_net_error"))
            }).disposed(by: YXUserManager.shared().disposeBag)
    }
}

//MARK: 喜好设置
extension YXUserManager {
    class func checkPreferenceSet(user: YXLoginUser? , clickSet: ((_ isSame: Bool) -> Void)? ) {
        clickSet?(true)
    }
    
    /// 是否是同一天
    /// cacheNow: 是否立即保存日期字符串
    class func isTheSameDay(with key: String,cacheNow: Bool = true) -> (Bool,String) {
        //获取东八区的当前时间
        let eastEightZone = NSTimeZone.init(name: "Asia/Shanghai") as TimeZone?
        let dateFormatter = DateFormatter.en_US_POSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = eastEightZone
        let now = Date()
        
        let lastDateString = MMKV.default().string(forKey: key)
        let nowDateString = dateFormatter.string(from: now)
        
        //一天只展示一次
        if lastDateString != nowDateString {
            if cacheNow {
                MMKV.default().set(nowDateString, forKey: key)
            }
            return (false,nowDateString)
        }
        return (true,nowDateString)
    }
}

//MARK: - 越狱检测
extension YXUserManager {
    
    class func checkJailBreak() {
        let mmkv = MMKV.default()
        let isJailBreak = mmkv.bool(forKey: YXUserManager.YXJailBreak)
       
        if YXToolUtility.jailBreak() && !isJailBreak {
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "common_ios_warning_msg"))
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_exit_app"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
                exit(0)
            }))
            
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_continue_app"), style: .default, handler: {[weak alertView] action in
                alertView?.hide()
                mmkv.set(true, forKey: YXUserManager.YXJailBreak)
            }))
            
            alertView.showInWindow()
        }
    }
}
//0 手机号绑定位 1 微信绑定位 2 微博绑定位 3 Google绑定位 4 Twitter绑定位 5 脸书绑定位 6 IG绑定位 7 钉钉绑定位 8 邮箱定位 9 支付宝绑定位 10 apple 绑定位
public enum YXLoginBindType: UInt64 {
    case phone          = 0b00000001
    case wechat         = 0b00000010
    case google         = 0b00001000
    case faceBook       = 0b00100000
    case apple          = 0b10000000000
    case email          = 0b100000000
    case line           = 0b100000000000
}

extension YXLoginBindType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXLoginBindType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .phone
    }
}


extension YXUserManager {
    
    public static let notiGoogleLogin     = "noti_googleLogin"                //谷歌登录
    public static let notiGuestsUUID      = "noti_guestsUUID"                 //首次获取uuid
    public static let notiUpdateUUID      = "noti_updateUUID"                 //uuid 改变
    public static let notiLogin           = "noti_login"                      //登录成功
    public static let notiLoginOut        = "noti_loginOut"                   //退出登录
    public static let notiUpdateUserInfo        = "noti_updateUserInfo"       //更新用户信息
    public static let notiUpdateToken           = "noti_updateToken"          //token 改变
    public static let notiFirstLogin            = "noti_firstLogin"           //首次登录
    public static let notiTradeChange           = "noti_tradeChange"          //交易密码状态改变
    public static let notiUpdateResetRootView   = "noti_updateResetRootView"  //重置根视图
    public static let notiUpdateLanguage        = "noti_updateLanguage"       //语言更改
    public static let notiUpdateColor           = "noti_updateColor"          //涨跌颜色更改
    public static let notiUpdateQuoteChart      = "noti_updateQuoteChart"      //报价图表更改
    public static let notiUpdateSortHK          = "noti_updateSortHK"          //智能排序更改
    public static let notiSkinChange          = "notiSkinChange"          //主题改变

    public static let notiQuoteKick          = "noti_quoteKick"          //行情互踢
    public static let notiFollowAuthorSuccess   = "noti_FollowAuthorSuccess"   //关注取关用户成功

    public static let YXUser =  "YXUser"
    public static let YXUserToken = "YXUserToken"
    public static let YXUserUUID = "YXUser_UUID"
    public static let YXBanner =  "YXBanner"
    public static let YXSplashScreenAdvertisement = "YXSplashScreenAdvertisement" //闪屏广告
    public static let YXSplashScreenAdvertisementShowing = "YXSplashScreenAdvertisementShowing" //正在展示的闪屏广告
    public static let YXSplashScreenImage = "YXSplashScreenImage" //闪屏广告 图片
    public static let YXSplashScreenImageHasReadCodes = "YXSplashScreenImageHasReadCodes" //已经展示过的闪屏广告代码

    public static let YXDefCode =  "defCode"
    public static let YXLoginType = "defLogin"   //登录方式
    
    public static let YXLanguage =  "YXLanguage"
    public static let YXColor =  "YXColor"
    public static let YXQuoteChartHk = "YXQuoteChartHk"
    public static let YXSortHk = "YXSortHk"
    
    public static let YXAdvertiseDateCache =  "YXAdvertiseDateCache"//广告闪屏页的 日期缓存
    
    public static let YXSystemIPOAlertDateCache =  "YXSystemIPOAlertDateCache"//广告闪屏页的 日期缓存
    
    
    public static let YXJailBreak = "YXJailBreak"//是否越狱
    
    public static let YXCurBroker = "YXCurBroker"//当前登陆的券商
    public static let notiLogoutbroker   = "noti_logoutbroker"       //券商退出登陆
    public static let notiLoginbroker   = "noti_loginbroker"       //券商登陆
    public static let YXCurBrokerToken = "YXCurBrokerToken"
    public static let YXCurBrokerAccountType = "YXCurBrokerAccountType"
    public static let YXOpenUsOptionStatus = "YXOpenUsOptionStatus" //是否开通期权
    public static let YXOpenUsFractionStatus = "YXOpenUsFractionStatus" //是否开通碎股单

    public static let YXCardBannerDateCach =  "YXCardBannerDateCach"//首页卡券banner日期缓存，用户记录用户点击收起还是展开卡券，一天后重置
    public static let YXCardBannerIsClose = "YXCardBannerIsClose" //是否收起首页卡券list

    
    //当前选择的讨论tab，默认值是0，mmkv存的int，0代表全球，1代表global 。
    public static let YXCurDiscussionTab = "YXCurDiscussionTab"

    class func contactPhoneAction() {
        
        let telephoneNumber = ""
        let str = "tel:\(telephoneNumber)"
        let application = UIApplication.shared
        let URL = NSURL(string: str)
        
        if let URL = URL {
            application.open(URL as URL, options: [:], completionHandler: { success in
                //OpenSuccess=选择 呼叫 为 1  选择 取消 为0
            })
        }
    }
    
}
//MARK:- 查询用户一些信息
extension YXUserManager{
    
   class func getUSOptionStatus() {
        let requestMode = YXUSOptionStatusRequestModel()
        let request = YXRequest(request: requestMode)
        request.startWithBlock { respons in
            if respons.code == .success{
                if let res = respons as? YXUSOptionStatusResponse {
                    YXUserManager.shared().isOpenUsOption = res.openedAccount
                }
            }else{
                YXUserManager.shared().isOpenUsOption = false
            }
        } failure: { request in
            YXUserManager.shared().isOpenUsOption = false
        }
    }

    class func getUSFractionStatus() {
         let requestMode = YXUSFractionStatusRequestModel()
         let request = YXRequest(request: requestMode)
         request.startWithBlock { respons in
             if respons.code == .success{
                 if let res = respons as? YXUSFractionStatusResponse {
                     YXUserManager.shared().isOpenUsFraction = res.openedAccount
                 }
             } else{
                 YXUserManager.shared().isOpenUsFraction = false
             }
         } failure: { request in
             YXUserManager.shared().isOpenUsFraction = false
         }
     }
    
}

