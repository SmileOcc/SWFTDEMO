//
//  YXToolUtilityExtension.swift
//  uSmartOversea
//
//  Created by Mac on 2019/7/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

import AssetsLibrary
import AVFoundation
import TYAlertController
import RxSwift
import RxCocoa
//import CoreNFC

extension YXToolUtility {
    
    static let bottomSheetTool = YXBottomSheetViewTool()
    //@objc public static let notiInfoCourseCreateSucceed =  "noti_info_course_create_succeed"//课程，创建课程成功，通知「我的课程」刷新数据
    
    /// 检测当前是否有相机权限
    /// - Parameter vc: 当前所处的页面
    /// - Parameter closure: 回调函数
    @objc class func checkCameraPermissions(with vc: UIViewController?, closure: @escaping ()-> Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        guard authStatus != .restricted && authStatus != .denied else {
            if let info = Bundle.main.infoDictionary {
                let cameraDesc = NSString.fetchCameraUsageDescription()//跟随系统
                let bundleName = info[kCFBundleNameKey as String] as? String ?? ""
                let title = "”\(bundleName)“" + YXLanguageUtility.kLang(key: "common_system_camera_tip") // 跟随app
                let alert = UIAlertController(title: title, message: cameraDesc, preferredStyle: .alert)
                let cancel = UIAlertAction(title: YXLanguageUtility.kLang(key: "mine_no_allow"), style: .cancel) { (action) in
                    
                }
                let ok = UIAlertAction(title: YXLanguageUtility.kLang(key: "common_system_OK"), style: .default) { (action) in
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                alert.addAction(cancel)
                alert.addAction(ok)
                
                let currentVC: UIViewController = vc ?? UIViewController.current()
                currentVC.present(alert, animated: true) { }
            }
            return
        }
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async(execute: {
                        closure()
                    })
                }
            })
        } else {
            closure()
        }
    }
    
    /// 根据市场类型来获取  后台用的市场类型（exchangeType）
    /// - Parameter market: 市场类型
    class func getExchangeType(with market: YXMarketType = .HK) -> YXExchangeType {
        var exchangeType: YXExchangeType = .hk
        switch market {
        case .US:
            exchangeType = .us
        case .HK:
            exchangeType = .hk
        case .ChinaSH:
            exchangeType = .sh
        case .ChinaSZ:
            exchangeType = .sz
        case .ChinaHS:
            exchangeType = .hs
        case .USOption:
            exchangeType = .usop
        default:
            break
        }
        return exchangeType
    }
    
    /// 是否是港股、美股、上海、深圳、沪深之一
    /// - Parameter market: 需要判断的字符串
    class func oneOfSupporttedMarket(_ market: String) -> Bool {
        let markets = [YXMarketType.HK.rawValue,
                       YXMarketType.US.rawValue,
                       YXMarketType.ChinaSH.rawValue,
                       YXMarketType.ChinaSZ.rawValue,
                       YXMarketType.ChinaHS.rawValue]
        return markets.contains(where: {$0.caseInsensitiveCompare(market) == .orderedSame})
    }
    
    /// 是否是港股、美股、深圳、上海交易所之一
    /// - Parameter exchange: 需要判断的字符串
    class func oneOfSupporttedExchange(_ exchange: String) -> Bool {
        let exchanges = [YXExchangeType.hk.market,
                         YXExchangeType.us.market,
                         YXExchangeType.sh.market,
                         YXExchangeType.sz.market]
        return exchanges.contains(where: {$0.caseInsensitiveCompare(exchange) == .orderedSame})
    }
    
    /// 返回当前appsFlyer是否允许被初始化
    @objc class func appsFlyerEnable() -> Bool {
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            return true
        } else {
            return MMKV.default().bool(forKey: APPS_FLYER_MMKV_KEY, defaultValue: false)
        }
    }
    
    /// 设置appsFlyer是否允许被初始化
    /// - Parameter enable: 是否允许被初始化
    @objc class func setAppsFlyerEnable(_ enable: Bool) {
        MMKV.default().set(enable, forKey: APPS_FLYER_MMKV_KEY)
    }
    
    @objc class func yyLabelWithUnderLinelinkText(wholeText: String, linkString: [String], action: @escaping (Int) -> Void) -> YYLabel {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        let contentString = wholeText
        
        let paragraph = NSMutableParagraphStyle()
        
        paragraph.lineSpacing = 6
        
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().sell(), NSAttributedString.Key.paragraphStyle : paragraph])
        
        for (index, str) in linkString.enumerated() {
            let range = (contentString as NSString).range(of: str)
            
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().sell(), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            
            attributeString.yy_setTextHighlight(range, color: QMUITheme().sell(), backgroundColor: UIColor.clear, tapAction: { (view, attstring, range, rect) in
                action(index)
            })
        }
        
        label.attributedText = attributeString
        return label
    }
    
    
    
//    @objc class func getNFCAvailability() -> Bool {
//        if #available(iOS 13.0, *) {
//            if NFCTagReaderSession.readingAvailable {
//                return true
//            }
//        }
//        return false
//    }


    /// 添加自选股方法 带修改分组
    /// - Parameters:
    ///   - secu: 股票secu
    ///   - secuGroup: 股票分组
    ///   - completionHandler: 添加结果回调
    @objc class func addSelfStockToGroup(secu: YXOptionalSecu, secuGroup: YXSecuGroup? = nil,  completionHandler: (_ addResult: Bool) -> Void) {

        let group = secuGroup ?? YXSecuGroupManager.shareInstance().allSecuGroup
        if !YXSecuGroupManager.shareInstance().append(secu, secuGroup: group) {
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "stock_over_max"))
            completionHandler(false)
        } else {

            completionHandler(true)
            var groupName: String
            if group.id > 10 {
                groupName = group.name
            }else {
                if let fromName = secuGroup?.multiLanguageName, fromName == secu.market.uppercased(){
                    groupName = fromName
                }else{
                    groupName = YXLanguageUtility.kLang(key: "common_all")
                }
    
            }
            
            let str = String(format: YXLanguageUtility.kLang(key: "tips_add_stock_success"), groupName)

            if let window = UIApplication.shared.delegate?.window, window != nil {
                YXProgressHUD.showMessage(message: str, inView: window!, buttonTitle: YXLanguageUtility.kLang(key: "common_edit"), delay: 3, clickCallback: {

                    if YXUserManager.isLogin() {
//                        let groupSettingView = YXGroupSettingView.init(secus: [secu], secuName: secu.name , currentOperationGroup: group, settingType: YXGroupSettingTypeModify)
//                        let alertController = YXAlertController(alert: groupSettingView, preferredStyle: .actionSheet)!
//                        alertController.backgoundTapDismissEnable = true
//                        UIViewController.current().present(alertController, animated: true, completion: nil)
                        let groupSettingView = YXGroupSettingView(secus: [secu], secuName:"", currentOperationGroup: group, settingType: YXGroupSettingTypeModify)
        
                        bottomSheetTool.titleLabel.text = YXLanguageUtility.kLang(key: "add_to_group")
                        bottomSheetTool.rightButton.isHidden = false
                        bottomSheetTool.rightButtonAction = { [weak groupSettingView] in
                            groupSettingView?.sureButtonAction()
                            bottomSheetTool.hide()
                        }
                        
                        bottomSheetTool.showView(view: groupSettingView)
                        
                    } else {

                        if let root = UIApplication.shared.delegate as? YXAppDelegate {
                            let navigator = root.navigator
                            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                            navigator.push(YXModulePaths.defaultLogin.url, context: context)
                        }
                    }
                })
            }

        }

    }

    //处理需要优先判断期权行情的业务
    @objc class func handleBusinessWithOptionLevel(_ isTrade: Bool = false, callBack: (() -> Void)? = nil, excute: @escaping (() -> Void)) {

        /*能否进入期权页面
         * 1 - 要先登录, 否则去登陆
         * 2 - 要有期权账户，否则去开户界面
         * 3 - 要有期权行情权限，否则去购买行情页面
         */

        handleBusinessWithLogin {

            /*
             *  用户有期权账户且有lv1, lv2权限, 直接跳转，
             *  否则先更新用户信息，再去判断具体跳转，
             *  防止用户更新完账户权限， 后账户状态没有及时更新
             *  (购买权限是跳转safari官网购买，APP不知道结果)
             */

            var canExcute = YXUserManager.shared().getOptionLevel() != .delay
            if isTrade {
                canExcute = (canExcute && YXUserManager.isOption(kYXMarketUS))
            }

            if canExcute {

                excute()

            } else {
                
                if YXUserManager.shared().getOptionLevel() == .delay {
                    //个股详情期权不需要跳转h5链接
                    if let optionCallBack = callBack {
                        optionCallBack()
                    } else {
                        YXToolUtility.goBuyOptionOnlineAlert()
                    }
                } else {
                    excute()
                }
            }
        }
    }


    @objc class func handleBusinessWithLogin(_ excute: @escaping (() -> Void)) {
        if YXUserManager.isLogin() {

            excute()
        } else {
            let loginCallBack: (([String: Any])->Void)? = { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    excute()
                }
            }
            (YXNavigationMap.navigator as? NavigatorServices)?.pushToLoginVC(callBack: loginCallBack)
        }
    }
    
    @objc class func handleCanTradeFractional(_ excute: @escaping (() -> Void)) {
        if YXUserManager.isOpenUsFraction() {

            excute()
        } else {
            let alertView = YXAlertView.init(message: YXLanguageUtility.kLang(key: "account_open_usfraction_tips"))
            let cancelAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { _ in
                
            }
            let openAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "account_open"), style: .default) { _ in
                YXWebViewModel.pushToWebVC(YXH5Urls.OpenUsFractionURL())
            }
            alertView.addAction(cancelAction)
            alertView.addAction(openAction)
            alertView.showInWindow()
        }
    }

    @objc class func handleBusinessWithLogin(delay: TimeInterval = 1.0, _ excute: (() -> Void)?) {
        if YXUserManager.isLogin() {

            excute?()
        } else {
            let loginCallBack: (([String: Any])->Void)? = { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    excute?()
                }
            }
            (YXNavigationMap.navigator as? NavigatorServices)?.pushToLoginVC(callBack: loginCallBack)
        }
    }


    @objc class func goBuyOptionOnlineAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "online_option_buy_tip"))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "depth_order_get"), style: .default, handler: { (action) in

//            let request = YXRequest.init(request: YXGetTokenRequestModel.init())
//            request.startWithBlock { model in
//
//                if  let  model = model as? YXGetTokenResponse {
//                    var set = NSCharacterSet.urlQueryAllowed
//                    set.remove(charactersIn: "!*'();:@&=+$,/?%#[]")
//                    let jumpUrl = "/pricing?tab=2"
//                    let path = jumpUrl.addingPercentEncoding(withAllowedCharacters: set)
//
//                    if let path = path, let url = URL(string: YXH5Urls.OPTION_BUY_ON_LINE_URL(model.tokenKey, and: path)) {
//                        UIApplication.shared.open(url)
//                    }
//                }
//
//            } failure: { (_) in
//
//            }
            
            YXWebViewModel.pushToWebVC(YXH5Urls.myQuotesUrl(tab: 1, levelType: 3))

        }))

        alertView.showInWindow()
    }

    @objc class func marketFromMarketSymbol(_ marketSymbol: String) -> String {
        var market = ""
        let lowercaseStr = marketSymbol.lowercased()
        if lowercaseStr.hasPrefix(kYXMarketHK) {
            market = kYXMarketHK
        } else if lowercaseStr.hasPrefix(kYXMarketUS) {
            market = kYXMarketUS
        } else if lowercaseStr.hasPrefix(kYXMarketChinaSH) {
            market = kYXMarketChinaSH
        } else if lowercaseStr.hasPrefix(kYXMarketChinaSZ) {
            market = kYXMarketChinaSZ
        } else if lowercaseStr.hasPrefix(kYXMarketUsOption) {
            market = kYXMarketUsOption
        }

        return market
    }

    @objc class func symbolFromMarketSymbol(_ marketSymbol: String) -> String {
        let market = self.marketFromMarketSymbol(marketSymbol)
        var symbol = ""
        if (marketSymbol.count > market.count) {
            symbol = (marketSymbol as NSString).substring(from: market.count)
        }

        return symbol
    }
    
    @objc class func bottomSheetShowView(view: UIView, title: String? = nil, letfBtn: UIButton? = nil, rightBtn: UIButton? = nil) {
        let scrollV = UIScrollView()
        scrollV.addSubview(view)
        let headerV = UIView()
        headerV.backgroundColor = .red
        let sheetV = JXBottomSheetView.init(contentView: scrollV, headerView: headerV)
        sheetV.defaultMaxinumDisplayHeight = YXConstant.screenHeight - YXConstant.navBarHeight()
        sheetV.defaultMininumDisplayHeight = 0
        sheetV.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight)
        sheetV.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        UIApplication.shared.keyWindow?.addSubview(sheetV)
        sheetV.layoutIfNeeded()
        
        sheetV.displayMax()
    }
    
    /// 数字货币价格展示
    /// - Parameters:
    ///   - value: 价格 或 成效量
    ///   - decimalPoint: 值大于0， 将以decimalPoint为准，否则自动判断
    ///   - isVol: 是否是成交额 或 成交量
    ///   - showPlus: 是否展示“+”
    /// - Returns: 用于展示的String
    @objc class func btNumberString(_ numberString: String?, decimalPoint: Int = 0, isVol: Bool = false, showPlus: Bool = false) -> String {
    
        var resultStr = "--"
        if let valueStr = numberString, let value = Double(valueStr) {
            if value >= 1000 && isVol {
                resultStr = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
            } else {
                
                var pointCount = decimalPoint
                if pointCount <= 0 {
                    pointCount = self.btDecimalPoint(numberString)
                }
                
                let format = "%" + String(format: ".0%d", pointCount) + "f"
                resultStr = String(format: format, value)
            }
            
            if showPlus, value > 0 {
                resultStr = "+" + resultStr
            }
        }
        
        return resultStr
        
    }
    
    @objc class func btDecimalPoint(_ numberString: String?) -> Int {
    
        var decimalPoint = 2
        if let valueStr = numberString, let tempValue = Double(valueStr) {
            let value = fabs(tempValue)
            if value >= 100 {
                decimalPoint = 2
            } else if value >= 1 {
                decimalPoint = 4
            } else if value >= 0.01 {
                decimalPoint = 6
            } else {
                decimalPoint = 8
            }
        }
        
        return decimalPoint
        
    }
    
    class func checkLoginComplete() -> Driver<()> {
        
        let c = Observable<()>.create { observer in
               
            handleBusinessWithLogin {
                observer.onNext(())
            }
            
            return Disposables.create {}
        }
        
        return c.asDriver(onErrorJustReturn: ())
    }

}
