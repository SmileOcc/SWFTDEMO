//
//  YXWebViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import QMUIKit
import YXKit
import WebKit
//import SensorsAnalyticsSDK
import SwiftyJSON

import MobileCoreServices
import MessageUI
import AVFoundation //相机权限
import Photos //照片 权限

import SnapKit

import MGFaceIDLiveDetect
import Lottie


enum YXOpenAccountChooseImageMode {
    case camera
    case album // 单选
    case albumMulti(_ count: Int) // 多选
}

class YXWebViewController: YXHKViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXWebViewModel!
    
    var webView: YXWKWebView?
    
    var progressView: UIProgressView?
    
    let progressViewHeight: CGFloat = 0.5
    
    var bridge: (YXJSActionBridge & WKScriptMessageHandler)?
    
//    var imagePicker: UIImagePickerController?

    var chooseImageOrFileSuccessCallback: String?

    var chooseImageOrFileErrorCallback: String?
    
    var IAPSuccessCallback: String?

    var IAPErrorCallback: String?
    
    var fileMode: Bool?
    
    var positionOneItem: UIBarButtonItem?
    
    var positionTwoItem: UIBarButtonItem?
        
    var backItem, closeItem: UIBarButtonItem?
    
    //var screenShotView: YXScreenShotShareView?
    
    var publishTime: String?
    
    var refreshHeader: YXRefreshHeader?
    
    var startedNavigation: Bool = false
    
    var megLiveSuccessCallback: String?, megLiveErrorCallback: String?

    var isFundDetail = false
    var fundID = ""
    var fundName = ""
    
    var liveStill: YXFaceIDLiveStill = {
        YXFaceIDLiveStill()
    }()

    lazy var jumioRecognizer: YXJumioRecognizer = {
        return YXJumioRecognizer()
    }()
    var portraitSuccessCallback: String?, portraitErrorCallback: String?, nationalEmblemSuccessCallback: String?, nationalEmblemErrorCallback: String?
    var idCardQualityFront: YXFaceIdIDCardQuality = {
        YXFaceIdIDCardQuality()
    }()
    
    var idCardQualityBack: YXFaceIdIDCardQuality = {
        YXFaceIdIDCardQuality()
    }()
    
    lazy var noDataView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight-YXConstant.navBarHeight()))
        view.backgroundColor = QMUITheme().foregroundColor()
        let imageView = UIImageView.init(image: UIImage(named: "network_nodata"))
        imageView.center = CGPoint(x: view.center.x, y: view.center.y - YXConstant.screenHeight * 0.2)
        view.addSubview(imageView)
        
        let tipLab = UILabel(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 20))
        tipLab.textAlignment = .center
        tipLab.textColor = QMUITheme().textColorLevel3()
        tipLab.text = YXLanguageUtility.kLang(key: "common_loadFailed")
        tipLab.font = UIFont.systemFont(ofSize: 14)
        tipLab.center = CGPoint(x: view.center.x, y: imageView.center.y+imageView.frame.height/2 + 40);
        view.addSubview(tipLab)
        
        let btn = UIButton(type: .custom)
        
        btn.setTitle(YXLanguageUtility.kLang(key: "common_click_refresh"), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.bounds = CGRect(x: 0, y: 0, width: 118, height: 30);
        btn.center = CGPoint(x: view.center.x, y: tipLab.center.y+tipLab.frame.height/2 + 28);
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().themeTextColor().cgColor
        btn.layer.cornerRadius = 4
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.addTarget(self, action: #selector(noDataBtnAction), for: .touchUpInside)
        view.addSubview(btn)
        
        return view
    }()
    
    @objc func noDataBtnAction() {
        self.noDataView.isUserInteractionEnabled = false
        self.refreshWebview()
    }
    
    deinit {
        print("deinit YXWebViewController")
        self.unregisterJavaScriptInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    func initUI() {
        self.bindHUD()
        
        self.setupNavigationBar()
        
        self.changeWKWebViewUserAgent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bridge?.onActivityStatusChange(isVisible: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bridge?.onActivityStatusChange(isVisible: true)
        
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        if viewModel.titleBarVisible {
            return false
        } else {
            return true
        }
    }
    
    override func willDealloc() -> Bool {
        false
    }

    override func forceEnableInteractivePopGestureRecognizer() -> Bool {
        true
    }
    

    fileprivate func registerJavaScriptInterface() {
        if let webView = self.webView {
            self.bridge = YXJSActionBridge(webView: webView, gotoNativeManager: YXGoToNativeManager.shared)
            if let bridge = self.bridge {
                webView.configuration.userContentController.add(bridge, name: "JSActionBridge")
            }
        }
    }

    fileprivate func unregisterJavaScriptInterface() {
        if let webView = self.webView {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "JSActionBridge")
        }
        self.bridge = nil
    }
    
    func setupNavigationBar() {
        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            if let webView = self?.webView {
                YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [
                    "canGoBack": NSNumber(value: webView.canGoBack)
                    ], callback: "javascript:window.h5HistoryBack", completionCallback: { (result, error) in
                        let resultBool: Bool = (result as? NSNumber)?.boolValue ?? false
                        if result != nil && resultBool {
                            log(.verbose, tag: kModuleViewController, content: "window.h5HistoryBack running")
                        } else {
                            if webView.canGoBack {
                                webView.goBack()
                                self?.handleGoBackOrFinishEvent()
                            } else {
                                self?.finish()
                            }
                        }
                        
                })
            }
            }.disposed(by: disposeBag)
        
        let closeItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_close") ?? UIImage(), target: self, action: nil)
        closeItem.rx.tap.bind { [weak self] in
            if let webView = self?.webView {
                YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [:], callback: "javascript:window.h5ClosePage", completionCallback: { result, error in
                    let resultBool: Bool = (result as? NSNumber)?.boolValue ?? false
                    if result != nil && resultBool {
                        log(.verbose, tag: kModuleViewController, content: "window.h5ClosePage running")
                    } else {
                        self?.finish()
                    }
                })
            } else {
                self?.finish()
            }
            }.disposed(by: disposeBag)
        
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -3.0, bottom: 0, right: 3.0)
        closeItem.imageInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
        self.navigationItem.leftBarButtonItems = [backItem, closeItem]
        
        self.backItem = backItem
        self.closeItem = closeItem
        
        // titleView的最大宽度为减去左右两边预留的按钮宽度；
        self.titleView?.maximumWidth = YXConstant.screenWidth - ((44 + 8) * 2 * 2)
    }

    fileprivate func finish() {
        let top: UIViewController? = navigationController?.viewControllers.last
        if top == self && self.qmui_isViewLoadedAndVisible() {
            // 该ViewController是navigationController的根视图，并且该navigationController是由某个ViewController present出来的
            // 那么，就将该navigationController进行dismiss的操作
            // 出现该场景的地方：衍生品风险提示
            if navigationController?.viewControllers.count == 1 && navigationController?.presentingViewController != nil {
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            var array = navigationController?.viewControllers
            var i = (array?.count ?? 0) - 1
            while i >= 0 {
                if array?[i] == self {
                    array?.remove(at: i)
                    if let array = array {
                        navigationController?.viewControllers = array
                    }
                    break
                }
                i -= 1
            }
        }

        self.handleGoBackOrFinishEvent()
    }

    
    func addRealWebView() {
        setupWebView()

        if viewModel.titleBarVisible {
            self.progressView = UIProgressView(frame: CGRect(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: self.progressViewHeight))
        } else {
            self.progressView = UIProgressView(frame: CGRect(x: 0, y: YXConstant.statusBarHeight(), width: YXConstant.screenWidth, height: self.progressViewHeight))
        }
        
        if let progressView = self.progressView  {
            progressView.progressTintColor = QMUITheme().progressTintColor()
            progressView.progress = 0.05
            self.view.addSubview(progressView)
            progressView.trackTintColor = QMUITheme().separatorLineColor()
            
            // 设置progressView的高度，因为系统的UIProgressView的高度是固定的。因此这里采用transform的方式进行设置
            let transform : CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 0.25)
            progressView.transform = transform
        }

        self.webView?.rx.observe(Double.self, "estimatedProgress").subscribe(onNext: { [weak self] (estimatedProgress) in
            guard let strongSelf = self else { return }
            
            if let progressView = strongSelf.progressView {
                let animated: Bool = (strongSelf.webView?.estimatedProgress ?? 0.0) > Double(progressView.progress)
                progressView.setProgress(Float(strongSelf.webView?.estimatedProgress ?? 0.0), animated: animated)
                
                // Once complete, fade out UIProgressView
                if (strongSelf.webView?.estimatedProgress ?? 0.0) >= 1.0 {
                    UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseOut, animations: {
                        progressView.alpha = 0.0
                    }) { finished in
                        progressView.setProgress(0.0, animated: false)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        //监听 title ，并设置
        self.webView?.rx.observe(String.self, "title").subscribe(onNext: { [weak self] (title) in
            guard let strongSelf = self else { return }
            //标题颜色
            if !(strongSelf.viewModel.webTitle?.isEmpty ?? true) {
                strongSelf.titleView?.title = strongSelf.viewModel.webTitle
            } else {
                strongSelf.titleView?.title = (!(strongSelf.webView?.title?.isEmpty ?? true)) ? strongSelf.webView?.title : ""
            }
        }).disposed(by: disposeBag)
    }
    
    func bottomGap() -> CGFloat {
        0
    }
    
    func topGap() -> CGFloat {
        if self.viewModel.titleBarVisible {
            return YXConstant.navBarHeight()
        } else {
            if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate, !appDelegate.rotateScreen {
                return YXConstant.statusBarHeight()
            } else {
                return 0
            }
        }
    }
    
    func webViewFrame() -> CGRect {
        let screenWidth = YXToolUtility.screenWidth()
        let screenHeight = YXToolUtility.screenHeight()
        
        var frame: CGRect = self.webView?.frame ?? CGRect.zero
        
        if self.viewModel.titleBarVisible {
            frame.origin.y = self.topGap()
            frame.size.width = screenWidth
            frame.size.height = screenHeight - self.topGap() - self.bottomGap()
        } else {
            if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate, !appDelegate.rotateScreen {
                frame.origin.y = self.topGap()
                frame.size.width = screenWidth
                frame.size.height = screenHeight - self.topGap() - self.bottomGap()
            } else {
                frame.origin.y = self.topGap()
                frame.size.width = screenWidth
                frame.size.height = screenHeight - self.topGap() - self.bottomGap()
            }
        }
        return frame
    }
    
    func progressViewFrame() -> CGRect {
        let screenWidth = YXToolUtility.screenWidth()

        return CGRect(x: 0, y: self.topGap(), width: screenWidth, height: self.progressViewHeight)
    }
    
    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.allowsInlineMediaPlayback = true

        self.viewModel.titleBarVisibleSubject.asObservable().subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            
            self.webView?.frame = self.webViewFrame()
        }).disposed(by: disposeBag)
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            appDelegate.rx.observe(Bool.self, "rotateScreen").subscribe(onNext: { [weak self] (rotateScreen) in
                guard let `self` = self else { return }
                
//                if rotateScreen ?? false {
//                    UIApplication.shared.setStatusBarHidden(false, with: .fade)
//                }

                self.progressView?.frame = self.progressViewFrame()
                self.webView?.frame = self.webViewFrame()
                
            }).disposed(by: disposeBag)
        }
        
        if viewModel.titleBarVisible {
            self.webView = YXWKWebView(frame: CGRect(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight()), configuration: config)
            if let webView = self.webView {
                view.addSubview(webView)
            }
        } else {
            self.webView = YXWKWebView(frame: CGRect(x: 0, y: YXConstant.statusBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.statusBarHeight()), configuration: config)
            if let webView = self.webView {
                view.addSubview(webView)
            }
        }

        self.webView?.backgroundColor = QMUITheme().foregroundColor()
        self.webView?.scrollView.backgroundColor = QMUITheme().foregroundColor()
        self.webView?.allowsBackForwardNavigationGestures = false
        ///黑色皮肤,webview会闪烁
        if YXThemeTool.isDarkMode() {
            self.webView?.isOpaque = false
        }
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        self.webView?.jsDelegate = self

        if #available(iOS 11.0, *) {
            self.webView?.scrollView.contentInsetAdjustmentBehavior = .never
            self.webView?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            if let contentInset = self.webView?.scrollView.contentInset {
                self.webView?.scrollView.scrollIndicatorInsets = contentInset
            }
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.refreshHeader = YXRefreshHeader.init(refreshingBlock: { [weak self] in
            self?.refreshWebview()
        })
        
        self.webView?.scrollView.mj_header = self.refreshHeader
    }

    /**
     修改WKWebView的UserAgent
     先通过一个临时的YXWKWebView执行JS脚本，得到当前的userAgent
     然后设置userAgent后，再加载最终的YXWKWebView
     */
    fileprivate func changeWKWebViewUserAgent() {
        self.webView = YXWKWebView(frame: CGRect.zero)
        
        self.webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { [weak self] result, error in
            guard let strongSelf = self else { return }
            
            var userAgent = result as? String
            if userAgent?.contains(" appVersion") ?? false {
                // 如果包含这个字符串，则认为已经添加过，则擦除后面的再重新设置一次
                let array = userAgent?.components(separatedBy: " appVersion")
                if (array?.count ?? 0) > 0 {
                    userAgent = array?[0]
                }
            }
            let infoStr = strongSelf.getDeviceInfoStr()
            let newUserAgent = "\(userAgent ?? "")\(infoStr)"
            let dictionary = [
                "UserAgent" : newUserAgent
            ]

            UserDefaults.standard.register(defaults: dictionary)

            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                // 重新初始化WKWebView
                strongSelf.webViewWillLoadRequest()
                // 1.重新注册JS Interface
                strongSelf.unregisterJavaScriptInterface()
                strongSelf.addRealWebView()
                // 2.重新注册JS Interface
                strongSelf.registerJavaScriptInterface()
                strongSelf.webViewLoadRequest()
                strongSelf.webViewDidLoadRequest()
            })
        })
    }

    func updateUserAgent() {
        self.webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { [weak self] result, error in
            guard let strongSelf = self else { return }

            var userAgent = result as? String
            if userAgent?.contains(" appVersion") ?? false {
                // 如果包含这个字符串，则认为已经添加过，则擦除后面的再重新设置一次
                let array = userAgent?.components(separatedBy: " appVersion")
                if (array?.count ?? 0) > 0 {
                    userAgent = array?[0]
                }
            }
            let infoStr = strongSelf.getDeviceInfoStr()
            let newUserAgent = "\(userAgent ?? "")\(infoStr)"
            let dictionary = [
                "UserAgent" : newUserAgent
            ]

            UserDefaults.standard.register(defaults: dictionary)
            strongSelf.webView?.customUserAgent = newUserAgent
            strongSelf.webView?.reload()
        })
    }
    
    /**
     获取设备信息

     @return 设备信息
     */
    fileprivate func getDeviceInfoStr() -> String {
        let appVersion = " appVersion/\(YXConstant.appVersion ?? "")"
        let softwareVersion = "softwareVersion/\(YXConstant.appBuild ?? "")"
        let platform = "platform/\("yxzq-iOS")"
        let model = "model/\(YXConstant.deviceModel)"
        let uuid = "uuid/\(YXConstant.deviceUUID)"
        let appId = "appId/\(YXConstant.bundleId ?? "")"
        let nt = "nt/\(YXNetworkUtil.sharedInstance().networkType())"
        let systemVersion = "systemVersion/\(YXConstant.systemVersion)"
        let sp = "sp/\(YXNetworkUtil.operatorInfomation())"
        let tn = "tn/\(YXUserManager.shared().curLoginUser?.phoneNumber ?? "")"
        let env = "environment/\(YXConstant.targetModeName() ?? "")"
        let langType = "langType/\(YXUserManager.curLanguage().rawValue)"
        let appType = "appType/\(YXConstant.appTypeValue.rawValue)"
        let stockColorType = "stockColorType/\(YXUserManager.curColor(judgeIsLogin: true).rawValue)"
        let launchChannel = "inviteChannelId/\(YXConstant.launchChannel ?? "")"
        let brokerNo = "xBrokerNo/sg"
        var overseaType = ""
        if YXConstant.appTypeValue == .OVERSEA {
            overseaType = "overseaType/dolphin"
        }else if YXConstant.appTypeValue == .OVERSEA_SG {
             overseaType = "overseaType/sg"
        }


        
        return "\(appVersion) \(softwareVersion) \(platform) \(model) \(uuid) \(appId) \(nt) \(systemVersion) \(sp) \(tn) \(env) \(langType) \(appType) \(stockColorType) \(launchChannel) \(brokerNo) \(overseaType)"
    }

    func handleLoadRequest(url: URL?, reload: Bool = false) {
        
        if self.webView?.isLoading ?? false {
            self.webView?.stopLoading()
        }
        
        if #available(iOS 13.0, *) {
            var windinUrl = url
            if windinUrl == nil {
                windinUrl = self.originalUrl()
            }
            if let windinUrl = windinUrl, self.isWindinPDFUrl(url: windinUrl) {
                if let data = try? Data(contentsOf: windinUrl) {
                    self.webView?.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: windinUrl)
                } else {
                    self.addNoDataViewAndEnable()
                }
                return
            }
        }
        
        if reload && url != nil {
            self.webView?.reload()
        } else {
            var requestUrl = url
            if requestUrl == nil {
                requestUrl = self.originalUrl()
            }
            if let requestUrl = requestUrl {
                if self.viewModel.cachePolicy == .useProtocolCachePolicy {
                    self.webView?.load(URLRequest(url: requestUrl))
                } else {
                    self.webView?.load(URLRequest(url: requestUrl, cachePolicy: self.viewModel.cachePolicy))
                }
            } else {
                // 兼容子类处理自己的加载逻辑
                self.webViewLoadRequest()
            }
        }
    }
    
    func addNoDataViewAndEnable() {
        if self.noDataView.superview != nil {
            self.noDataView.removeFromSuperview()
        }
        self.webView?.addSubview(self.noDataView)
        self.noDataView.isUserInteractionEnabled = true
    }
    
    func removeNoDataViewAndDisable() {
        if self.noDataView.superview != nil {
            self.noDataView.isUserInteractionEnabled = false
            self.noDataView.removeFromSuperview()
        }
    }
    
    func originalUrl() -> URL? {
        if let urlString = self.viewModel.url, let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    func webViewLoadRequest() {
        log(.verbose, tag: kModuleViewController, content: "WebViewLoadRequest")
        if let url = self.originalUrl() {
            self.handleLoadRequest(url: url)
        }
    }

    func webViewWillLoadRequest() {
        log(.verbose, tag: kModuleViewController, content: "WebViewWillLoadRequest")
    }

    func webViewDidLoadRequest() {
        log(.verbose, tag: kModuleViewController, content: "WebViewDidLoadRequest")
    }
    //选中图片
    func chooseImage(withTitle title: String?, showFileAction: Bool = false, multiSelect: Bool = false, maxSelectCount: Int = 1) {
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .default, handler: { aAlertController, action in

            })
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]

        let camera = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_taking_pictures"), style: .default, handler: { aAlertController, action in
                let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
                if (authStatus == .restricted || authStatus == .denied) {
                    if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback, let webView = self.webView {
                        if !chooseImageErrorCallback.isEmpty {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: chooseImageErrorCallback)
                        }
                    }
                } else if authStatus == .notDetermined {
                    // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                        if granted {
                            DispatchQueue.main.async(execute: {
                                self.chooseImage(withMode: .camera)
                            })
                        }
                    })
                } else {
                    self.chooseImage(withMode: .camera)
                }
            })
        camera.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]

        let album = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "camera_up"), style: .default, handler: { aAlertController, action in
            if multiSelect {
                self.chooseImage(withMode: .albumMulti(maxSelectCount))
            }else {
                self.chooseImage(withMode: .album)
            }
        })
        
        album.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]

        let alertController = YXAlertViewController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.defaultSheetConfig()
        alertController.addAction(camera)
        alertController.addAction(album)
        if (showFileAction) {
            let file = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "upload_from_file"), style: .default, handler: { [weak self] aAlertController, action in
                guard let `self` = self else { return }
                    YXICloudManager.shared.pickerDocument(documentTypes: YXICloudManager.documentTypes, inViewController: self, successBlock: { [weak self] (fileName, fileData) in
                        guard let `self` = self else { return }
                        let encodeData = fileData.base64EncodedString(options: [])
                        
                        let fileInfo = [
                            "fileName" : fileName,
                            "fileData" : encodeData
                        ]
                        if let chooseImageSuccessCallback = self.chooseImageOrFileSuccessCallback,
                            let jsonData = try? JSONSerialization.data(withJSONObject: fileInfo, options: .prettyPrinted),
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                            let webView = self.webView {
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: chooseImageSuccessCallback)
                        } else {
                            if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback, let webView = self.webView {
                                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "choose_failed"), callback: chooseImageErrorCallback)
                            }
                        }
                    }) { (error) in
                        if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback, let webView = self.webView {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "choose_failed"), callback: chooseImageErrorCallback)
                        }
                    }
                })
            file.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
            alertController.addAction(file)
        }
        alertController.addAction(cancel)
        alertController.showWith(animated: true)
    }

    func chooseImage(withMode mode: YXOpenAccountChooseImageMode) {
        switch mode {
        case .camera:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .rear
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "fail_pls_retry"), in: self.view)
            }
        case .album:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        case .albumMulti(let maxCount):
            let multiPicker = TZImagePickerController.init(maxImagesCount: maxCount, delegate: nil)
            guard let vc = multiPicker else { return }
            vc.preferredLanguage = YXUserManager.curLanguage().identifier
            vc.iconThemeColor = QMUITheme().themeTextColor()
            vc.naviBgColor = QMUITheme().foregroundColor()
            vc.naviTitleColor = QMUITheme().textColorLevel1()
            vc.barItemTextColor = QMUITheme().textColorLevel1()
            vc.oKButtonTitleColorNormal = QMUITheme().themeTextColor()
            vc.oKButtonTitleColorDisabled = QMUITheme().themeTextColor().withAlphaComponent(0.4)
            vc.navLeftBarButtonSettingBlock = { leftBtn in
                leftBtn?.setImage(UIImage(named: "nav_back"), for: .normal)
                leftBtn?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -32, bottom: 0, right: 0)
            }
            vc.sortAscendingByModificationDate = false
            vc.allowPickingOriginalPhoto = false
            vc.allowPickingVideo = false
            vc.allowTakePicture = false
            vc.showSelectedIndex = true
            
            vc.didFinishPickingPhotosHandle = { (images, _, _) in
                guard let imageArr = images else { return }
                var base64Arr: [String] = []
                for image in imageArr {
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        let base64Data = imageData.base64EncodedString(options: [])
                        base64Arr.append(base64Data)
                    }
                    if base64Arr.count > 0,
                        let jsonData = try? JSONSerialization.data(withJSONObject: base64Arr, options: .prettyPrinted),
                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                        let webView = self.webView,
                        let chooseImageSuccessCallback = self.chooseImageOrFileSuccessCallback {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: chooseImageSuccessCallback)
                    }else {
                        if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback, let webView = self.webView {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "choose_failed"), callback: chooseImageErrorCallback)
                        }
                    }
                }
                
            }
            
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: 截屏分享的响应
    func showScreenShotShareView(withImage image: UIImage, successCallback: String?, errorCallback: String?) {
        // 分享结束后的回调
        let shareResultBlock: (Bool) -> Void = { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            if result {
                YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "share_succeed"), in: self.view)
                if  let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                }
            }
        }
        
        // more分享去掉提示
        let shareMoreResultBlock: (Bool) -> Void = { [weak self] (result) in
            guard let `self` = self else { return }
            if result {
                if  let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                }
            }
        }
        
        //MARK: section0
//        var section0_items: [QMUIMoreOperationItemView] = []
        var thirdShareDatas:[YXShareItemModel] = []
        var toolsShareDatas:[YXShareItemModel] = []


        
        let fbModel = YXShareItemModel.init()
        fbModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeFacebook)
        fbModel.shareImageName = "share-fb"
        fbModel.shareType = "facebook"
        thirdShareDatas.append(fbModel)
        
        if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
            
            let moreModel = YXShareItemModel.init()
            moreModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)
            moreModel.shareImageName = "share-whatsapp"
            moreModel.shareType = "whatsapp"
            thirdShareDatas.append(moreModel)
        }

        if YXShareSDKHelper.isClientIntalled(.typeTwitter){
            
            let twModel = YXShareItemModel.init()
            twModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTwitter)
            twModel.shareImageName = "share-twitter"
            twModel.shareType = "twitter"
            thirdShareDatas.append(twModel)
            
        }
        
        if YXShareSDKHelper.isClientIntalled(.typeInstagram) {
            
            let moreModel = YXShareItemModel.init()
            moreModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeInstagram)
            moreModel.shareImageName = "share-Instagram"
            moreModel.shareType = "instagram"
            thirdShareDatas.append(moreModel)
        }
        
        let communityModel = YXShareItemModel.init()
        communityModel.shareName = YXLanguageUtility.kLang(key: "share_usmart_community")
        communityModel.shareImageName = "share-usmart-community"
        communityModel.shareType = "shareUsmartCommunity"
        thirdShareDatas.append(communityModel)
        
        let telegramModel = YXShareItemModel.init()
        telegramModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTelegram)
        telegramModel.shareImageName = "share-telegram"
        telegramModel.shareType = "telegram"
        thirdShareDatas.append(telegramModel)
        
        if YXShareSDKHelper.isClientIntalled(.typeLine) {
            let moreModel = YXShareItemModel.init()
            moreModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeLine)
            moreModel.shareImageName = "share-line"
            moreModel.shareType = "line"
            thirdShareDatas.append(moreModel)
        }
        
//        let messageModel = YXShareItemModel.init()
//        messageModel.shareName = YXLanguageUtility.kLang(key: "share_message")
//        messageModel.shareImageName = "share-message"
//        messageModel.shareType = "sms"
//        thirdShareDatas.append(messageModel)
        

        ///
        let saveImageModel = YXShareItemModel.init()
        saveImageModel.shareName = YXLanguageUtility.kLang(key: "share_save_pic")
        saveImageModel.shareImageName = "share-save"
        saveImageModel.shareType = "saveImage"
        toolsShareDatas.append(saveImageModel)
        
        
        
        let moreModel = YXShareItemModel.init()
        moreModel.shareName = YXLanguageUtility.kLang(key: "share_more")
        moreModel.shareImageName = "share-more"
        moreModel.shareType = "more"
        toolsShareDatas.append(moreModel)
        
        
        for (i,item) in thirdShareDatas.enumerated() {
            item.shareTag = 1000+i
        }
        for (i,item) in toolsShareDatas.enumerated() {
            item.shareTag = 100+i
        }
        
        let shareView = YXShareImageContentView(frame: UIScreen.main.bounds, shareType: .image, items: toolsShareDatas,thirdItems: thirdShareDatas) { [weak self] shareItem in
            
            guard let `self` = self else { return }
            //print("\(shareItem.shareName ?? "")")

            guard let shareType = shareItem.shareType else { return }
            if shareType == "whatsapp" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    guard let `self` = self else { return }
 
                    self.sharingImage(.typeWhatsApp, image, shareResultBlock)
                })
            } else if shareType == "line" {
                self.sharingImage(.typeLine, image, shareResultBlock)
                
            } else if shareType == "instagram" {
                self.sharingImage(.typeInstagram, image, shareResultBlock)
                
            } else if shareType == "sms" {
                self.shareToMessage(content: nil, sharingImage: image, imageUrlString: nil, shareResultBlock: shareResultBlock)
                
            } else if shareType == "more" || shareType == "telegram" {//telegram 图片分享暂时用more功能
                self.shareToMore(activityItems: [image], shareResultBlock: shareMoreResultBlock)
                
            } else if shareType == "facebook" {
                // facebook messenger 图片只支持网络图片
                self.sharingImage(.typeFacebookMessenger, image, shareResultBlock)
                
            } else if shareType == "twitter" {
                self.sharingImage(.typeTwitter, image, shareResultBlock)
                
            }
//            else if shareType == "telegram" {
//                self.sharingImage(.typeTelegram, image, shareResultBlock)
//
//            }
            else if shareType == "saveImage" {
                
                YXToolUtility.saveImage(toAlbum: image) { (res) in
                    if res {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "user_saveSucceed"), in: self.view)
                        if  let webView = self.webView,
                            let successCallback = successCallback,
                            successCallback.count > 0 {
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                        }
                        
                    }else {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "user_saveFailed"),in: self.view)
                        if let errorCallback = errorCallback,
                            errorCallback.count > 0,
                            let webView = self.webView {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                        }
                    }
                }
                
                
            } else if shareType == "shareUsmartCommunity" {
                self.shareToUsmartCommunity(image, shareResultBlock: shareResultBlock)
            }
            
        } cancelCallBlock: {
            
        }
        shareView.isDefaultShowMessage = false
        shareView.shareImage = image
        shareView.showShareView()
    }
    
    func isNotificationEnabled(handle: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (setting) in
            //如果授权状态是notDetermined，那其他所有的setting都是0（notSupported）
            //如果授权状态是deny，那所有其他的setting都是1（disabled）
            //如果授权状态是authorized，其他设置的值才有意义
            DispatchQueue.main.async(execute: {
                if setting.authorizationStatus == .authorized {
                    handle(true)
                } else {
                    handle(false)
                }
            })
        })
    }
    
    func isWindinPDFUrl(url: URL) -> Bool {
        let queryItems = url.queryItems
        if url.host == "news.windin.com" &&
            queryItems?.contains(where: {$0.name == "mediatype" && $0.value == "03"}) ?? false {
            return true
        }
        return false
    }
    
    func refreshWebview() {
        let url = self.webView?.url
        if self.startedNavigation {
            return
        }
        self.handleLoadRequest(url: url, reload: true)
    }

    func handleGoBackOrFinishEvent() {
        if isFundDetail {
        }
        self.isFundDetail = false
    }

    func handleCurrentWebURL(_ url: URL) {
        let urlString = url.absoluteString
        if urlString.contains("/fund/index.html#/fund-details"), !isFundDetail {
            self.isFundDetail = true
            // 神策事件：开始记录
            YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)

            let param = self.getParametersFromURL(urlString)
            if let id = param["id"] {
                self.fundID = id
            }

            if let title = param["name"] {
                self.fundName = title
            }
        }
    }

    func getParametersFromURL(_ url: String) -> [String : String]  {
        let urlString = url as NSString
        let range = urlString.range(of: "?")

        var param: [String : String] = [:]

        if range.location == NSNotFound {
            return param
        } else {
            let subString = urlString.substring(from: range.location + 1)
            if subString.contains("&") {
                //多个参数
                let array = subString.components(separatedBy: "&")
                for str in array {
                    let subArray = str.components(separatedBy: "=")
                    if subArray.count > 1, let key = subArray.first?.removingPercentEncoding, let value = subArray.last?.removingPercentEncoding {
                        param[key] = value
                    }
                }

            } else {
                //只含有一个或0个参数
                let subArray = subString.components(separatedBy: "=")
                if subArray.count > 1, let key = subArray.first?.removingPercentEncoding, let value = subArray.last?.removingPercentEncoding {
                    param[key] = value
                }
            }
        }

        return param

    }

}

extension YXWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: YXLanguageUtility.kLang(key: "common_tips"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in
            completionHandler()
        }))
        self.present(alert, animated: true)
    }
}

extension YXWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startedNavigation = true
        if !(self.viewModel.webTitle?.isEmpty ?? true) {
            self.titleView?.title = self.viewModel.webTitle
        } else {
            self.titleView?.title = YXLanguageUtility.kLang(key: "common_loading")
        }
        
        self.progressView?.alpha = 1.0
        
        self.removeNoDataViewAndDisable()
        log(.verbose, tag: kModuleViewController, content: "YXWebViewController didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if SensorsAnalyticsSDK.sharedInstance()?.showUpWebView(webView, with: navigationAction.request, enableVerify: true) ?? false {
//            decisionHandler(.cancel)
//            return
//        } else
        if navigationAction.request.url?.scheme == "sms" || navigationAction.request.url?.scheme == "tel" || navigationAction.request.url?.scheme == "mailto" || navigationAction.request.url?.scheme == "itms-appss" {
            //url中是否含有拨打电话和邮件
            let app = UIApplication.shared
            if let url = navigationAction.request.url {
                if app.canOpenURL(url) {
                    //是被是否可以打开
                    app.open(url, options: [:], completionHandler: { success in
                    })
                }
            }
            decisionHandler(.cancel)
            return
        }

        if let url = navigationAction.request.url {
            self.handleCurrentWebURL(url)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let urlString = webView.url?.absoluteString,
            YXGoToNativeManager.shared.schemeHasPrefix(string: urlString),
            YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: urlString) {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        log(.verbose, tag: kModuleViewController, content: "YXWebViewController didFinishNavigation")
        self.startedNavigation = false
        self.removeNoDataViewAndDisable()
        if !(self.viewModel.webTitle?.isEmpty ?? true) {//self.viewModel.webTitle?.count ?? 0 > 0
            self.titleView?.title = self.viewModel.webTitle
        } else if self.titleView?.title == YXLanguageUtility.kLang(key: "common_loading") {
            self.titleView?.title = ""
        }
        
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.titleView?.title = YXLanguageUtility.kLang(key: "webview_detailTitle")
        
        self.startedNavigation = false
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
        
        if (((error as NSError).code <= NSURLErrorBadURL && (error as NSError).code >= NSURLErrorNoPermissionsToReadFile)) || ((error as NSError).code <= NSURLErrorSecureConnectionFailed && (error as NSError).code >= NSURLErrorCannotLoadFromNetwork) || ((error as NSError).code <= NSURLErrorCannotCreateFile && (error as NSError).code >= NSURLErrorDownloadDecodingFailedToComplete) {
            self.addNoDataViewAndEnable()
        }
    }
}

extension YXWebViewController: YXWKWebViewDelegate {
    //MARK: - onGet
    func onGetUserInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: YXUserManager.userInfo, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8), let webView = self.webView, let successCallback = successCallback {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
    }
    
    func onGetDeviceInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let deviceInfo = [
            "deviceId": YXConstant.deviceInfo(),
            "platform": "iOS",
            "appId": YXConstant.bundleId,
            "appVersion": YXConstant.appVersion,
            "systemVersion": YXConstant.systemVersion,
            "networkType": YXNetworkUtil.sharedInstance().networkType(),
            "sp": YXNetworkUtil.operatorInfomation()
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: deviceInfo, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8), let webView = self.webView, let successCallback = successCallback {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
    }
    
    func onGetAllOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        log(.verbose, tag: kModuleViewController, content: "YXWebViewController onGetAllOptionalStockWithParamsJsonValue:successCallback:errorCallback:")
    }
    
    func onGetNotificationStatus(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
        self.isNotificationEnabled { [weak self] (result) in
            guard let `self` = self else { return }
            
            let status = [
                "status": result ? "true" : "false"
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: status, options: .prettyPrinted),
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8), let webView = self.webView, let successCallback = successCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
            }
        }
    }
    
    func onGetAppConnectEnvironment(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let connectEnv = [
            "value": YXConstant.targetModeName()
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: connectEnv, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8), let webView = self.webView, let successCallback = successCallback {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
    }
    
    func onGetHttpSign(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if
            let xTransId = paramsJsonValue?["transId"] as? String,
            let xTime = paramsJsonValue?["timeStamp"] as? String,
            let xDt = paramsJsonValue?["devType"] as? String,
            let xDevId = paramsJsonValue?["devId"] as? String,
            let xUid = paramsJsonValue?["xUid"] as? String,
            let xLang = paramsJsonValue?["langType"] as? String,
            let xType = paramsJsonValue?["appType"] as? String,
            let xVer = paramsJsonValue?["version"] as? String
        {
            let xToken = YXToolUtility.xTokenGenerate(withXTransId: xTransId, xTime: xTime, xDt: xDt, xDevId: xDevId, xUid: xUid, xLang: xLang, xType: xType, xVer: xVer)
            
            let datas = [
                "xToken" : xToken
            ]
            
            if  let webView = self.webView,
                let jsonData = try? JSONSerialization.data(withJSONObject: datas, options: .prettyPrinted),
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                let successCallback = successCallback,
                successCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "get http sign failed", callback: errorCallback)
                }
            }
        } else {
            if let errorCallback = errorCallback,
                errorCallback.count > 0,
                let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "get http sign failed", callback: errorCallback)
            }
        }
    }
    
    func onGetNFCRecognitionAvailability(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

//        var datas = ["enable" : true,"support": false]
//        if YXToolUtility.getNFCAvailability() {
//            datas["support"] = true
//        }
//        if let jsonData = try? JSONSerialization.data(withJSONObject: datas, options: .prettyPrinted),
//            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8), let webView = self.webView, let successCallback = successCallback {
//            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
//        }
        
    }
    
    func onGetPassiveMegLiveData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var imageRef1: String = ""
        var bizToken: String?
        if let paramsJsonValue = paramsJsonValue {
            imageRef1 = paramsJsonValue["image_ref1"] as? String ?? ""
            bizToken = paramsJsonValue["biz_token"] as? String
        }
        
        self.megLiveSuccessCallback = successCallback
        self.megLiveErrorCallback = errorCallback
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard authStatus != .restricted && authStatus != .denied else {
            if let webView = self.webView, let errorCallback = self.megLiveErrorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(MGFaceIDLiveDetectErrorNotCameraPermission.rawValue), errorMessage: "NO_CAMERA_PERMISSION", callback: errorCallback)
            }
            return
        }
        
        if let imgData = Data(base64Encoded: imageRef1, options: Data.Base64DecodingOptions.ignoreUnknownCharacters),
        let image = UIImage(data: imgData) {
            
            QMUITips.showLoading(YXLanguageUtility.kLang(key: "common_loading"), in: self.view)
            //无源比对
            self.liveStill.startPassiveDetect(with: image, bizToken: bizToken, currentVC: self) { [weak self] (dictionary, error) in
                guard let `self` = self else { return }
                
                QMUITips.hideAllTips(in: self.view)
                if let dictionary = dictionary {
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
                        let jsonText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                        
                        if let webView = self.webView, let successCallback = self.megLiveSuccessCallback {
                            
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonText, callback: successCallback)
                        }
                    }
                } else {
                    if let errorCallback = self.megLiveErrorCallback {
                        
                        if let webView = self.webView, let error = error {
                            
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(error.code.rawValue), errorMessage: error.errorMessageStr, callback: errorCallback)
                        }
                    }
                }
            }
        } else {
            if let webView = self.webView, let errorCallback = errorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(MGFaceIDLiveDetectErrorUnknown.rawValue), errorMessage: YXLanguageUtility.kLang(key: "common_unknown_error"), callback: errorCallback)
            }
        }
    }
    
    
    //face++校验返回的key
    func onCommandFaceidVerifyResult(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?){
        
        if let paramsJsonValue = paramsJsonValue {
            guard let  verifyKey = paramsJsonValue["verifyKey"] as? String else { return }
            //0 1 是否成功
            //_  flag = paramsJsonValue["flag"] as? String

            self.liveStill.decryVideoPath(decryptKey: verifyKey)
            if  let webView = self.webView,
                let successCallback = successCallback,
                successCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
            }
            return
        }
        
        if let errorCallback = errorCallback,
            errorCallback.count > 0,
            let webView = self.webView {
            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
        }
    }
    
    //MARK: - onCommand
    //MARK: 执行分享
    func onCommandShare(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var resultDic = paramsJsonValue
        // shareType如果没有的话，则默认使用freedom
        let shareType: String = (paramsJsonValue?["shareType"] as? String) ?? "freedom"
        
        let title = (paramsJsonValue?["title"] as? String) ?? ""
        let description = paramsJsonValue?["description"] as? String
        let pageUrl = paramsJsonValue?["pageUrl"] as? String
        var shortUrl = paramsJsonValue?["shortUrl"] as? String
        //如果shortUrl没有值，那就用pageUrl
        if shortUrl?.isEmpty ?? true {//shortUrl?.count == 0
            shortUrl = pageUrl
        }
        let overseaPageUrl = paramsJsonValue?["overseaPageUrl"] as? String  //页面url
        
        let thumbUrl = paramsJsonValue?["thumbUrl"] as? String
        let image: Any = (thumbUrl?.isEmpty ?? true) ? UIImage(named: "icon")! : thumbUrl!
        
        let wxUserName = paramsJsonValue?["wxUserName"] as? String
        let wxPath = paramsJsonValue?["wxPath"] as? String
        let withShareTicket = paramsJsonValue?["withShareTicket"] as? Bool
        let miniProgramType = paramsJsonValue?["miniProgramType"] as? UInt
        
        let isDialogBgNone = paramsJsonValue?["isDialogBgNone"] as? Bool
        
        let sharingImage = YXToolUtility.conventToImage(withBase64String: paramsJsonValue?["imageData"])
        
        // 分享结束后的回调
        let shareResultBlock: (Bool) -> Void = { [weak self] (result) in
            guard let `self` = self else { return }
            
            if result {
                YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "share_succeed"), in: self.view)
                if  let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                }
            }
        }
        
        // more分享去掉提示
        let shareMoreResultBlock: (Bool) -> Void = { [weak self] (result) in
            guard let `self` = self else { return }
            if result {
                if  let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                }
            }
        }
        
        var pageURL = URL(string: pageUrl ?? "")
        
        //改变url的block
        let changeUrlBlock = {
            //let overseaLength = overseaPageUrl?.count, overseaLength > 0
            if !(overseaPageUrl?.isEmpty ?? true) {
                pageURL = URL(string: overseaPageUrl!)!
            }
        }
        
        if shareType == "freedom" {
            //MARK: section0
//            var section0_items: [QMUIMoreOperationItemView] = []
            
            var thirdShareDatas:[YXShareItemModel] = []
            var toolsShareDatas:[YXShareItemModel] = []

            
            
            let fbModel = YXShareItemModel.init()
            fbModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeFacebook)
            fbModel.shareImageName = "share-fb"
            fbModel.shareType = "facebook"
            thirdShareDatas.append(fbModel)
            
            if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                
                let model = YXShareItemModel.init()
                model.shareName = YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)
                model.shareImageName = "share-whatsapp"
                model.shareType = "whatsapp"
                thirdShareDatas.append(model)
            }
            
            if YXShareSDKHelper.isClientIntalled(.typeTwitter){

                let twModel = YXShareItemModel.init()
                twModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTwitter)
                twModel.shareImageName = "share-twitter"
                twModel.shareType = "twitter"
                thirdShareDatas.append(twModel)
            }
            
//            if YXShareSDKHelper.isClientIntalled(.typeInstagram) {
//
//                let model = YXShareItemModel.init()
//                model.shareName = YXShareSDKHelper.title(forPlatforms: .typeInstagram)
//                model.shareImageName = "share-Instagram"
//                model.shareType = "instagram"
//                thirdShareDatas.append(model)
//            }
            
            if YXShareSDKHelper.isClientIntalled(.typeTelegram) {
                
                let telegramModel = YXShareItemModel.init()
                telegramModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTelegram)
                telegramModel.shareImageName = "share-telegram"
                telegramModel.shareType = "telegram"
                thirdShareDatas.append(telegramModel)
            }
            
            if YXShareSDKHelper.isClientIntalled(.typeLine) {
                
                let model = YXShareItemModel.init()
                model.shareName = YXShareSDKHelper.title(forPlatforms: .typeLine)
                model.shareImageName = "share-line"
                model.shareType = "line"
                thirdShareDatas.append(model)
            }
            
            
            //去掉sms
//            let messageModel = YXShareItemModel.init()
//            messageModel.shareName = YXLanguageUtility.kLang(key: "share_message")
//            messageModel.shareImageName = "share-message"
//            messageModel.shareType = "sms"
//            thirdShareDatas.append(messageModel)


            let copyModel = YXShareItemModel.init()
            copyModel.shareName = YXLanguageUtility.kLang(key: "share_copy_url")
            copyModel.shareImageName = "share-copyurl"
            copyModel.shareType = "copyurl"
            toolsShareDatas.append(copyModel)
            
            let moreModel = YXShareItemModel.init()
            moreModel.shareName = YXLanguageUtility.kLang(key: "share_more")
            moreModel.shareImageName = "share-more"
            moreModel.shareType = "more"
            toolsShareDatas.append(moreModel)
            
            
            for (i,item) in thirdShareDatas.enumerated() {
                item.shareTag = 1000+i
            }
            for (i,item) in toolsShareDatas.enumerated() {
                item.shareTag = 100+i
            }
            
            let shareView = YXShareImageContentView(frame: UIScreen.main.bounds, shareType: .link, items: toolsShareDatas, thirdItems: thirdShareDatas) { [weak self] shareItem in
                
                guard let `self` = self else { return }
                //print("\(shareItem.shareName ?? "")")

                guard let shareType = shareItem.shareType else { return }
                if shareType == "copyurl" {
                    
                    // 点击后执行的block
                    if let shortUrl = shortUrl {
                        let pab = UIPasteboard.general
                        pab.string = title + "\n\n" + (description ?? "") + "\n" + shortUrl
                    }
                    
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "copy_success"))
                    
                    if  let webView = self.webView,
                        let successCallback = successCallback,
                        successCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                    }
                } else if shareType == "whatsapp" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        resultDic?["shareType"] = "whatsapp"
                        self.onCommandShare(withParamsJsonValue: resultDic, successCallback: successCallback, errorCallback: errorCallback)
                    })
                }  else {
                    resultDic?["shareType"] = shareType
                    self.onCommandShare(withParamsJsonValue: resultDic, successCallback: successCallback, errorCallback: errorCallback)
                    
                }
 
            } cancelCallBlock: {
                
            }
            shareView.isDefaultShowMessage = false
            shareView.showShareView()
            
        } else if shareType == "wechat_friend" {
            if YXShareSDKHelper.isClientIntalled(.typeWechat) {
                if let sharingImage = sharingImage {
                    self.sharingImage(.typeWechat, sharingImage, shareResultBlock)
                } else {
                    YXShareSDKHelper.shareInstance()?.share(.typeWechat, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "wechat_friends_circle" {
            if YXShareSDKHelper.isClientIntalled(.subTypeWechatTimeline) {
                if let sharingImage = sharingImage {
                    self.sharingImage(.subTypeWechatTimeline, sharingImage, shareResultBlock)
                } else {
                    YXShareSDKHelper.shareInstance()?.share(.subTypeWechatTimeline, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "whatsapp" {
            if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                if let sharingImage = sharingImage {
                    self.sharingImage(.typeWhatsApp, sharingImage, shareResultBlock)
                } else {
                    let shareText = "\(title)\n\(description ?? "")\n\(shortUrl ?? "")"
                    YXShareSDKHelper.shareInstance()?.share(.typeWhatsApp, text: shareText, images: nil, url: nil, title: nil, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "facebook" {
            // facebook 只支持网络图片
            if let sharingImage = sharingImage {
                self.sharingImage(.typeFacebook, sharingImage, shareResultBlock)
            } else {
                changeUrlBlock()
                if YXShareSDKHelper.isClientIntalled(.typeFacebook) {
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            }
        } else if shareType == "twitter" {
            if let sharingImage = sharingImage {
                self.sharingImage(.typeTwitter, sharingImage, shareResultBlock)
            } else {
                changeUrlBlock()
                if let shortURL = URL(string:shortUrl ?? "") {//分享链接
                    YXProgressHUD.showLoading("", in: self.view)
                    YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: nil, url: shortURL, title: nil, type: .webPage, withCallback: {[weak self] (success, userInfo, _) in
                        guard let `self` = self else { return }
                        YXProgressHUD.hide(for: self.view, animated: false)
                        shareResultBlock(success)
                    })
                } else { //分享图片+文字
                    YXProgressHUD.showLoading("", in: self.view)
                    YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: {[weak self] (success, userInfo, _) in
                        guard let `self` = self else { return }
                        YXProgressHUD.hide(for: self.view, animated: false)
                        shareResultBlock(success)
                    })
                }
            }
        } else if shareType == "messenger" {
            // facebook messenger 图片只支持网络图片
            if YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {
                if let sharingImage = sharingImage {
                    self.sharingImage(.typeFacebookMessenger, sharingImage, shareResultBlock)
                } else {
                    changeUrlBlock()
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebookMessenger, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "qq" {
            shareResultBlock(false)
        } else if shareType == "weibo" {
            shareResultBlock(false)
        } else if shareType == "sms" {
            self.shareToMessage(content: "\(title) \(shortUrl ?? "")", sharingImage: sharingImage, imageUrlString: thumbUrl, shareResultBlock: shareResultBlock)
        } else if shareType == "more" {
            //block回调 present
            let presentBlock: (_ image:UIImage?) -> Void = {[weak self] (image) in
                if let shortURL = URL(string: shortUrl ?? "") {
                    self?.shareToMore(activityItems: [title + "\n\n" + (description ?? ""), image as Any, shortURL], shareResultBlock: shareMoreResultBlock)
                }
            }
            if let sharingImage = sharingImage {
                presentBlock(sharingImage)
            } else {
                //下载图片
                if let tempThumbUrl = thumbUrl,tempThumbUrl.isEmpty == false, let temp = URL(string: tempThumbUrl) {
                    self.networkingHUD.showLoading("", in: self.view)
                    //let temp = URL(string: tempThumbUrl)!
                    SDWebImageManager.shared.loadImage(with: temp, options: [], progress: { (_, _, _) in
                        
                    }) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                        self?.networkingHUD.hideHud()
                        presentBlock(image)
                    }
                } else {
                    presentBlock(nil)
                }
            }
        } else if shareType == "wx_mini_program" {
            if YXShareSDKHelper.isClientIntalled(.typeWechat) {
                YXShareSDKHelper.shareInstance()?.shareMiniProgram(by: .typeWechat, title: title, description: description, webpageUrl: URL(string: pageUrl ?? ""), path: wxPath, thumbImage: image, hdThumbImage: image, userName: wxUserName, withShareTicket: withShareTicket ?? false, miniProgramType: miniProgramType ?? 0, forPlatformSubType: .subTypeWechatSession, callback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "line" {
            if YXShareSDKHelper.isClientIntalled(.typeLine) {
                
                if let sharingImage = sharingImage {
                    self.sharingImage(.typeLine, sharingImage, shareResultBlock)
                } else {
                    changeUrlBlock()
                    YXShareSDKHelper.shareInstance()?.share(.typeLine, text: description, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        } else if shareType == "telegram" {
            if YXShareSDKHelper.isClientIntalled(.typeTelegram) {
                
                if let sharingImage = sharingImage {//telegram 图片分享暂时用more功能
                    self.shareToMore(activityItems: [sharingImage], shareResultBlock: shareMoreResultBlock)
                } else {
                    changeUrlBlock()
                    YXShareSDKHelper.shareInstance()?.share(.typeTelegram, text: description, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else {
                shareResultBlock(false)
            }
        }
    }
    
    func onCommandCheckClientInstallStatus(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let clients = paramsJsonValue?["clients"] as? [String]
        
        var status: [Bool] = []
        
        clients?.forEach({ (client) in
            if (client == "wechat" && YXShareSDKHelper.isClientIntalled(.typeWechat)) ||
                (client == "whatsapp" && YXShareSDKHelper.isClientIntalled(.typeWhatsApp)) ||
                (client == "facebook" && YXShareSDKHelper.isClientIntalled(.typeFacebook)) ||
                (client == "twitter" && YXShareSDKHelper.isClientIntalled(.typeTwitter)) ||
                (client == "messenger" && YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger)) ||
                (client == "qq" && YXShareSDKHelper.isClientIntalled(.typeQQ)) ||
                (client == "weibo" && YXShareSDKHelper.isClientIntalled(.typeSinaWeibo)) {
                status.append(true)
            } else {
                status.append(false)
            }
        })
        
        let data = [
            "status" : status
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
            let webView = self.webView,
            let successCallback = successCallback,
            successCallback.count > 0
        {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        } else {
            if let errorCallback = errorCallback,
                errorCallback.count > 0,
                let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "获取第三方客户端状态失败", callback: errorCallback)
            }
        }
    }
    
    func onCommandCloseWebView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onCommandCloseWebView"), object: nil, userInfo: nil)
        self.finish()
    }
    
    func onCommandGoBack(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if self.webView != nil {
            if self.webView?.canGoBack ?? false {
                self.webView?.goBack()
                self.handleGoBackOrFinishEvent()
            } else {
                self.finish()
            }
        } else {
            self.finish()
        }
    }

    //设置title
    func onCommandSetTitle(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.titleView?.title = paramsJsonValue?["title"] as? String
    }
    
    func onCommandUserLogin(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if !YXUserManager.isLogin() {
            let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                guard let `self` = self else { return }
                
                let jsonString = YXJSActionUtil.convertToJsonString(dict: userInfo)
                if YXUserManager.isLogin() {
                    if let jsonString = jsonString,
                        let webView = self.webView,
                        let successCallback = successCallback,
                        successCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
                    }
                } else {
                    if let errorCallback = errorCallback,
                        errorCallback.count > 0,
                        let webView = self.webView {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "登录失败", callback: errorCallback)
                    }
                }
            }
            
            let cancelCallBack: (() -> Void)? = { [weak self] in
                guard let `self` = self else { return }
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "登录失败", callback: errorCallback)
                }
            }
            
            // UIViewController.current() 防止控制器是其他控制器的子集
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, cancelCallBack: cancelCallBack, vc: UIViewController.current()))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
        } else {
            if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "webview_js_userAlreadyLogin"), callback: errorCallback)
            }
        }
    }
    
    func onCommandUserLogout(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        YXUserManager.loginOut(request: true)
    }
    
    func validateTradePwd(_ needToken: Bool?, successCallback: String?, errorCallback: String?) {
        YXUserUtility.validateTradePwd(inViewController: self, successBlock: { [weak self] (token) in
            guard let `self` = self else { return }
            
            if
                let webView = self.webView,
                let successCallback = successCallback, successCallback.count > 0 {
                
                if let token = token, !token.isEmpty {
                    let dic = [
                        "token": token
                    ]
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
                    }
                } else {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            }
            }, failureBlock: { [weak self] (errorCode, errorMessage) in
                guard let `self` = self else { return }
                
                if
                    let webView = self.webView,
                    let errorCallback = errorCallback, errorCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: errorCode, errorMessage: errorMessage, callback: errorCallback)
                }
            }, isToastFailedMessage: { () -> Bool in
            false
        }, needToken: needToken ?? false)
    }

    func onCommandTradeLogin(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let needToken = paramsJsonValue?["needToken"] as? Bool
        if YXUserManager.shared().curLoginUser?.tradePassword ?? false {
            validateTradePwd(needToken, successCallback: successCallback, errorCallback: errorCallback)
        } else {
            if YXUserManager.isLogin() {
                YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { [weak self] (token) in
                        guard let `self` = self else { return }
                        if
                            let webView = self.webView,
                            let successCallback = successCallback, successCallback.count > 0 {
                            if let token = token, !token.isEmpty {
                                let dic = ["token" : token]
                                let jsonString = YXJSActionUtil.convertToJsonString(dict: dic)
                                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString ?? "success", callback: successCallback)
                            } else {
                                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                            }
                        }
                    }, failureBlock: { [weak self] (errorCode, errorMessage) in
                        guard let `self` = self else { return }
                        
                        if
                            let webView = self.webView,
                            let errorCallback = errorCallback, errorCallback.count > 0 {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: errorCode, errorMessage: errorMessage, callback: errorCallback)
                        }
                    }, isToastFailedMessage: { () -> Bool in
                    false
                }, autoLogin: true, needToken: needToken ?? false)
            } else {
                // 否则提示告知js失败了
                if
                    let webView = self.webView,
                    let errorCallback = errorCallback, errorCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                }
            }
        }
    }
    
    func onCommandWatchNetwork(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
    }
    
    func onCommandBindMobilePhone(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if YXUserManager.isLogin() {
            let context = YXNavigatable(viewModel: YXCheckPhoneViewModel(sourceVC: self, callback: { [weak self] (userInfo) in
                guard let `self` = self else { return }
                
                let jsonString = YXJSActionUtil.convertToJsonString(dict: userInfo)
                if YXUserManager.isLogin() {
                    if let jsonString = jsonString,
                        let webView = self.webView,
                        let successCallback = successCallback,
                        successCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
                    }
                } else {
                    if let errorCallback = errorCallback,
                        errorCallback.count > 0,
                        let webView = self.webView{
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "绑定失败", callback: errorCallback)
                    }
                }
            }))
            self.viewModel.navigator.push(YXModulePaths.bindCheckPhone.url, context: context)
        } else {
            if
                let errorCallback = errorCallback, errorCallback.count > 0,
                let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "用户未登录,不能绑定手机号", callback: errorCallback)
            }
        }
    }
    
    func onCommandAddOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
    }
    
    func onCommandDeleteOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
    }
    
    func onCommandCopyToPasteboard(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let content = paramsJsonValue?["content"] as? String
        if let content = content {
            let pab = UIPasteboard.general
            pab.string = content
            if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
            }
        } else {
            if let errorCallback = errorCallback, let webView = self.webView, !errorCallback.isEmpty {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "copy_failed"), callback: errorCallback)
            }
        }
    }
    
    func onCommandOpenNotification(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let application = UIApplication.shared
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url {
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
        
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    
    func onCommandSetTitlebarButton(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let position = paramsJsonValue?["position"] as? Int
        let type = paramsJsonValue?["type"] as? String
        if
            let position = position,
            let type = type,
            position != 1 || position != 2,
            type != "text" || type != "icon" || type != "custom_icon" || type != "hide" {
            
            var item: UIBarButtonItem?
            if type == "text" {
                item = UIBarButtonItem.qmui_item(withTitle: paramsJsonValue?["text"] as? String ?? "", target: self, action: nil)
            } else if type == "icon" {
                if let icon = paramsJsonValue?["icon"] as? String {
                    if icon == "search" {
                        item = UIBarButtonItem.qmui_item(with: UIImage(named: "market_search") ?? UIImage(), target: self, action: nil)
                    } else if icon == "message" {
                        item = self.messageItem
                    } else if icon == "service" {
                        item = UIBarButtonItem.qmui_item(with: UIImage(named: "service") ?? UIImage(), target: self, action: nil)
                    } else if icon == "setting" {
                        item = UIBarButtonItem.qmui_item(with: UIImage(named: "user_setting") ?? UIImage(), target: self, action: nil)
                    } else if icon == "more" {
                        item = UIBarButtonItem.qmui_item(with: UIImage(named: "more") ?? UIImage(), target: self, action: nil)
                    } else {
                        // 否则提示告知js失败了
                        if
                            let webView = self.webView,
                            let errorCallback = errorCallback, errorCallback.count > 0 {
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                        }
                        return
                    }
                } else {
                    // 否则提示告知js失败了
                    if
                        let webView = self.webView,
                        let errorCallback = errorCallback, errorCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                    }
                    return
                }
            } else if type == "custom_icon" {
                if let custom_icon = paramsJsonValue?["custom_icon"] as? String {
                    //转换尝试判断，有可能返回的数据丢失"=="，如果丢失，swift校验不通过
                    var imageData = Data(base64Encoded: custom_icon, options: .ignoreUnknownCharacters)
                    if imageData == nil {
                        //如果数据不正确，添加"=="重试
                        imageData = Data(base64Encoded: custom_icon + "==", options: .ignoreUnknownCharacters)
                    }
                    
                    var size = CGSize.init(width: 20, height: 20)
                    
                     if let width = paramsJsonValue?["custom_icon_width"] as? CGFloat,
                        let height = paramsJsonValue?["custom_icon_height"] as? CGFloat {
                        size = CGSize.init(width: width, height: height)
                     }
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        var scaledImage: UIImage? = nil
                        if let cg = image?.cgImage,
                            let image = image {
                            scaledImage = UIImage(cgImage: cg, scale: image.scale * 2.0, orientation: image.imageOrientation).qmui_imageResized(inLimitedSize: size)
                        }
                        
                        item = UIBarButtonItem.qmui_item(with: scaledImage ?? UIImage(), target: self, action: nil)
                    }
                } else {
                    // 否则提示告知js失败了
                    if
                        let webView = self.webView,
                        let errorCallback = errorCallback, errorCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                    }
                    return
                }
            } else if type == "hide" {
                // type == hide ,just let item = nil
            } else {
                // 否则提示告知js失败了
                if
                    let webView = self.webView,
                    let errorCallback = errorCallback, errorCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                }
                return
            }
            
            if item != self.messageItem {
                item?.rx.tap.throttle(RxTimeInterval.seconds(1), latest: false, scheduler: MainScheduler.instance).bind{ [weak self] in
                    guard let `self` = self else { return }
                    
                    if let callback = paramsJsonValue?["clickCallback"] as? String,
                        let webView = self.webView {
                        YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [:], callback: callback, completionCallback: { result, error in
                                log(.info, tag: kModuleViewController, content: "result = \(String(describing: result)), error = \(String(describing: error))")
                            })
                    }
                }.disposed(by: disposeBag)
            }
            
            if position == 1 {
                self.positionOneItem = item
            } else {
                self.positionTwoItem = item
            }
            
            var items: [UIBarButtonItem] = []
            if let positionTwoItem = self.positionTwoItem {
                items.append(positionTwoItem)
            }
            
            if let positionOneItem = self.positionOneItem {
                items.append(positionOneItem)
            }
            
            self.navigationItem.rightBarButtonItems = items
            
            if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
            }
        } else {
            // 否则提示告知js失败了
            if
                let webView = self.webView,
                let errorCallback = errorCallback, errorCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
            }
        }
    }
    //MARK: 截屏分享
    func onCommandScreenshotShareSave(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if let webView = self.webView {
            webView.swContentCapture { [weak self] (image) in
                guard let `self` = self else { return }
                
                if let image = image {
                    self.showScreenShotShareView(withImage: image, successCallback: successCallback, errorCallback: successCallback)
                }
            }
        } else {
            // 否则提示告知js失败了
            if
                let webView = self.webView,
                let errorCallback = errorCallback, errorCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
            }
        }
    }
    //联系客服
    func onCommandContactService(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.serviceAction()
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    
    func onCommandSavePicture(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        enum SavePicCompleteType: Int {
            case success       = 0
            case noPermission  = 1
            case failed        = 2
        }
        let completionBlock: (SavePicCompleteType) -> Void = {[weak self] (type) in
            switch type {
            case .success:
                if let successCallback = successCallback, let webView = self?.webView, !successCallback.isEmpty {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            case .noPermission:
                if let webView = self?.webView,
                    let errorCallback = errorCallback, errorCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "no permission", callback: errorCallback)
                }
            default:
                if let webView = self?.webView,
                    let errorCallback = errorCallback, errorCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
                }
            }
        }
        
        let image = YXToolUtility.conventToImage(withBase64String: paramsJsonValue?["pictureData"])
        if let image = image {
            if QMUIAssetsManager.authorizationStatus() == .notDetermined {
                QMUIAssetsManager.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self.save(image, completionHandler: { (result) in
                                completionBlock(result ? .success : .noPermission)
                            })
                        } else {
                            // 否则提示告知js失败了
                            completionBlock(.noPermission)
                        }
                    }
                }
            }
            else if QMUIAssetsManager.authorizationStatus() == .notAuthorized {
                // 否则提示告知js失败了
                completionBlock(.noPermission)
            }
            else {
                self.save(image, completionHandler: { (result) in
                    completionBlock(result ? .success : .noPermission)
                })
            }
        } else {
            // 否则提示告知js失败了
            completionBlock(.failed)
            return
        }
    }
    
    func onCommandAllMsgRead(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let read = paramsJsonValue?["read"] as? Bool
        let broker = paramsJsonValue?["broker"] as? String
        if broker == "dolphin" {//个人中心入口
            YXMessageButton.pointIsHidden = read ?? true
        }else {
            YXMessageButton.brokerRedIsHidden = read ?? true
        }
       
        
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    
    //从相机或相册中 获取图片
    func onGetImageFromCameraOrAlbum(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.chooseImageOrFileSuccessCallback = successCallback
        self.chooseImageOrFileErrorCallback = errorCallback
        self.fileMode = false
        //选中图片
        chooseImage(withTitle: paramsJsonValue?["title"] as? String)
    }
    
    //拍照从相册中获取多张图片
    func onGetMultiImageFromAlbum(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.chooseImageOrFileSuccessCallback = successCallback
        self.chooseImageOrFileErrorCallback = errorCallback
        self.fileMode = false
        
        var maxCount = 1
        if let count = paramsJsonValue?["maxCount"] as? String {
            maxCount = Int(count) ?? 1
        }else if let count = paramsJsonValue?["maxCount"] as? Int {
            maxCount = count
        }
        chooseImage(withTitle: paramsJsonValue?["title"] as? String, multiSelect: true, maxSelectCount: maxCount)
    }
    
    func onGetMegLiveData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?){
        var  bizToken: String?
        if let paramsJsonValue = paramsJsonValue {
            bizToken = paramsJsonValue["bizToken"] as? String
        }
        
        self.megLiveSuccessCallback = successCallback
        self.megLiveErrorCallback = errorCallback
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard authStatus != .restricted && authStatus != .denied else {
            if let webView = self.webView, let errorCallback = self.megLiveErrorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(MGFaceIDLiveDetectErrorNotCameraPermission.rawValue), errorMessage: "NO_CAMERA_PERMISSION", callback: errorCallback)
            }
            return
        }
        //有源比对
        self.liveStill.startDetect(idCardName: "", idCardNumber: "", bizToken: bizToken, currentVC: self) { [weak self] (dictionary, error) in
            guard let `self` = self else { return }
            
            QMUITips.hideAllTips(in: self.view)
            if let dictionary = dictionary {
                if let theJSONData = try?  JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: .prettyPrinted
                    ),
                    let jsonText = String(data: theJSONData,
                                          encoding: String.Encoding.ascii) {
                    if let webView = self.webView, let successCallback = self.megLiveSuccessCallback {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonText, callback: successCallback)
                    }
                }
            } else {
                if let errorCallback = self.megLiveErrorCallback {
                    if let webView = self.webView, let error = error {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: Int(error.code.rawValue), errorMessage: error.errorMessageStr, callback: errorCallback)
                    }
                }
            }
        }
        
    }

    
    func onGetImageOrFileFromCameraOrAlbumOrFileManager(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.chooseImageOrFileSuccessCallback = successCallback
        self.chooseImageOrFileErrorCallback = errorCallback
        self.fileMode = true
        //选中图片
        chooseImage(withTitle: paramsJsonValue?["title"] as? String, showFileAction: true)
    }
    
    func onCommandUploadElkLog(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
        
        YXRealLogger.shareInstance.realH5Log(paramsJsonValue)
    }
    
    func onCommandEnablePullRefresh(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let enable = paramsJsonValue?["enable"] as? Bool
        
        if enable ?? false {
            self.webView?.scrollView.mj_header = self.refreshHeader
        } else {
            self.webView?.scrollView.mj_header = nil
        }
    }
    
    func onCommandRefreshUserInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if YXUserManager.isLogin() {
            YXUserManager.getUserInfo { [weak self] in
                guard let `self` = self else { return }
                
                if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            }
        } else {
            // 否则提示告知js失败了
            if
                let webView = self.webView,
                let errorCallback = errorCallback, errorCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "failed", callback: errorCallback)
            }
        }
    }
    //MARK: 打开NFC识别护照
    func onCommandNFCRecognizePassport(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
//        var errorDesc: String = ""
//
//        if #available(iOS 13.0, *), YXToolUtility.getNFCAvailability() {
//
//            let passportNumber = paramsJsonValue?["passport_number"] as? String ?? ""
//            let dateOfBirth = paramsJsonValue?["date_of_birth"] as? String ?? ""
//            let expiryDate = paramsJsonValue?["expiry_date"] as? String ?? ""
//
//            let mrzKey = YXPassportDetailManager.getMRZKey(with: passportNumber, dateOfBirth, expiryDate)
//            let dataGroups : [DataGroupId] = [.COM, .DG1, .DG2, .SOD]
//
//            self.passportReader = PassportReader()
//
//            let readerTip = YXPassportReaderTip()
//            readerTip.readyTip = YXLanguageUtility.kLang(key: "nfc_ready_tip")
//            readerTip.readingTip = YXLanguageUtility.kLang(key: "nfc_reading_tip")
//            readerTip.errorTip = YXLanguageUtility.kLang(key: "nfc_error_tip")
//            readerTip.oneMoreTagsTip = YXLanguageUtility.kLang(key: "nfc_one_more_tags_tip")
//            readerTip.notValidTip = YXLanguageUtility.kLang(key: "nfc_not_valid_tip")
//            readerTip.connectErrorTip = YXLanguageUtility.kLang(key: "nfc_connect_error_tip")
//            readerTip.authenticatingTip = YXLanguageUtility.kLang(key: "nfc_authenticating_tip")
//
//            self.passportReader?.readPassport(mrzKey: mrzKey, tags: dataGroups,tip: readerTip, completed: { [weak self] (passport, error) in
//                guard let `self` = self else { return }
//                if let passport = passport {
//                    // All good, we got a passport 很好，我们有护照了
//                    let passportModel = Passport( fromNFCPassportModel: passport)
//
//                    var params = [String: String]()
//                    params["nationality"] = passportModel.nationality
//                    params["date_of_birth"] = passportModel.dateOfBirth
//                    params["gender"] = passportModel.gender
//                    params["document_expiry_date"] = passportModel.documentExpiryDate
//                    params["personal_number"] = passportModel.personalNumber
//                    params["last_name"] = passportModel.lastName
//                    params["first_name"] = passportModel.firstName
//                    params["issuing_authority"] = passportModel.issuingAuthority
//
//                    params["document_number"] = passportModel.documentNumber
//
//                    if let imageData = passportModel.image.pngData() {
//                        params["passport_image"] = imageData.base64EncodedString(options: [])
//                    } else {
//                        params["passport_image"] = ""
//                    }
//
//                    if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
//                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
//                        let webView = self.webView, let successCallback = successCallback {
//
//                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
//                    } else {
//                        errorDesc = "other error"
//                    }
//
//                } else {
//                    errorDesc = error?.errorDescription ?? "Invalid response"
//                }
//
//                if errorDesc.count > 0,
//                    let webView = self.webView,
//                    let errorCallback = errorCallback, errorCallback.count > 0 {
//                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: errorDesc, callback: errorCallback)
//                }
//            })
//        } else {
//            errorDesc = "The system version is less than iOS 13.0 ,or your device is not support NFC."
//        }
//
//        if errorDesc.count > 0,
//            let webView = self.webView,
//            let errorCallback = errorCallback, errorCallback.count > 0 {
//            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: errorDesc, callback: errorCallback)
//        }
        
        
    }

    //MARK: appsflyer事件上传
    func onCommandUploadAppsflyerEvent(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        if let eventName = paramsJsonValue?["event_name"] as? String {
            var params: [String : Any]? = nil
            if let tempParams = paramsJsonValue?["params"] as? [String : Any] {
                params = tempParams
            }
            YXAppsFlyerTracker.shared.trackEvent(name: eventName, withValues: params)


            if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
            }
        } else {
            if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "upload appsflyer Event error", callback: errorCallback)
            }
        }
    }
    
    func onCommandBuyInAppProductEvent(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let productId = paramsJsonValue?["productId"] as? String
        let orderId = paramsJsonValue?["orderId"] as? String
        let product = Product()
        product.itunes_product_id = productId ?? ""
        product.orderId = orderId ?? ""
        product.userId = "\(YXUserManager.userUUID())" //[NSString stringWithFormat:@"%lld", [YXUserManager userUUID]];
        
        self.IAPSuccessCallback = successCallback;
        self.IAPErrorCallback = errorCallback;
        
        YXIAPManager.shared().delegate = self
        YXIAPManager.shared().request(product)
    }
    
    func onCommandProductConsumeResult(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
        if
            let orderId = paramsJsonValue?["orderId"] as? String,
            let result = paramsJsonValue?["result"] as? Bool, result == true {
            YXIAPManager.shared().removeReceipt(withOrderId: orderId)
        } else {
            YXIAPManager.shared().checkIAPFiles()
        }
    }

    func onCommandAddOptionalStockEvent(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        if let market = paramsJsonValue?["stockMarket"] as? String,  let symbol = paramsJsonValue?["stockCode"] as? String {

            let secu = YXOptionalSecu()
            secu.market = market
            secu.symbol = symbol
            if YXSecuGroupManager.shareInstance().containsSecu(secu) == false,
                YXSecuGroupManager.shareInstance().append(secu) == true {
                if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "upload appsflyer Event error", callback: errorCallback)
                }
            }

        } else {
            if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "upload appsflyer Event error", callback: errorCallback)
            }
        }
    }
    
    func onCommandHideTitlebar(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.viewModel.titleBarVisible = false
        
        if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    
    func onCommandShowTitlebar(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.viewModel.titleBarVisible = true
        
        if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    
    func onCommandSetScreenOrientation(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if let orientation = paramsJsonValue?["orientation"] as? Int {
            if orientation == 0 {
                // 竖屏
                YXToolUtility.forceToPortraitOrientation()
                
                if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else if orientation == 1 {
                // 横屏
                YXToolUtility.forceToLandscapeRightOrientation()
                
                if let successCallback = successCallback, successCallback.count > 0, let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                }
            } else {
                if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "upload appsflyer Event error", callback: errorCallback)
                }
            }
        } else {
            if let errorCallback = errorCallback, errorCallback.count > 0, let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "upload appsflyer Event error", callback: errorCallback)
            }
        }
    }

    func onCommandJumioRecognize(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        guard self.jumioRecognizer.netverifyViewController == nil else {
            return
        }

        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if (authStatus == .restricted || authStatus == .denied) {

            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "no_camera"))

            alertView.addAction(YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (_) in

            }))

            alertView.addAction(YXAlertAction.init(title: YXLanguageUtility.kLang(key: "strong_notice_go"), style: .default, handler: { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))

            alertView.showInWindow()

            if let webView = self.webView,
               let errorCallback = errorCallback, errorCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "no_camera"), callback: errorCallback)
            }
        } else if authStatus == .notDetermined {
            // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    DispatchQueue.main.async(execute: {
                        self.startJumioVerify(paramsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
                    })
                }
            })
        } else {
            startJumioVerify(paramsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
        }

    }

    func startJumioVerify(paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        if let apiToken = paramsJsonValue?["apiToken"] as? String {
            self.jumioRecognizer.apiToken = apiToken
        }

        if let apiSecret = paramsJsonValue?["apiSecret"] as? String {
            self.jumioRecognizer.apiSecret = apiSecret
        }

        if let callBackUrl = paramsJsonValue?["callBackUrl"] as? String {
            self.jumioRecognizer.callBackUrl = callBackUrl
        }

        self.jumioRecognizer.startToJumioRecognize(fromVC: self, successBlock: { (scanReference) in
            let dic = ["scanReference" : scanReference]
            if let webView = self.webView, let successCallback = successCallback, successCallback.count > 0, let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: []), let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {

                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
            }

        }, errorBlock: { (errorMsg) in

            if let webView = self.webView,
               let errorCallback = errorCallback, errorCallback.count > 0 {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: errorMsg, callback: errorCallback)
            }
        })
    }

    func onCommandShowFloatingView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let dict: [String: Any] = ["code": 0, "desc": "success"]
        if let webView = self.webView, let successCallback = successCallback, successCallback.count > 0, let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []), let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {

            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
        
        if let json = paramsJsonValue {
            YXFloatingAudioView.shared().startH5Play(json)
        }
    }
    
    func onCommandDismissFloatingView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        YXFloatingAudioView.shared().hideFloating()
        YXFloatingView.shared().hideFloating()
    }
    
    func onCommandBindEmail(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if YXUserManager.isLogin() {
            let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.bind,sourceVC: self, callBack: { [weak self] (userInfo) in
                guard let `self` = self else { return }
                
                let jsonString = YXJSActionUtil.convertToJsonString(dict: userInfo)
                if YXUserManager.isLogin() {
                    if let jsonString = jsonString,
                        let webView = self.webView,
                        let successCallback = successCallback,
                        successCallback.count > 0 {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
                    }
                } else {
                    if let errorCallback = errorCallback,
                        errorCallback.count > 0,
                        let webView = self.webView{
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "bind failed", callback: errorCallback)
                    }
                }
            }))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.navigator.push(YXModulePaths.bindEmail.url, context: context)
            }
        } else {
            if
                let errorCallback = errorCallback, errorCallback.count > 0,
                let webView = self.webView {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "用户未登录,不能绑定Email", callback: errorCallback)
            }
        }
    }
    
    func onCommandLoginBroker(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
        if let broker = paramsJsonValue?["broker"] as? String{
            let context = YXNavigatable(viewModel: YXBrokerLoginViewModel(broker: YXBrokersBitType.brokerValue(broker.lowercased()), vc: self))
            self.viewModel.navigator.push(YXModulePaths.brokerLogin.url, context:context)
        } 
       
    }
    
    func onCommandSetTraderPassword(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        if let broker = paramsJsonValue?["broker"] as? String {
            
            let setTradePwdModel = YXSetTradePwdViewModel(.set, oldPwd: "", captcha:"", sourceVC: self,successBlock: nil)
            setTradePwdModel.pwdSuccessSubject.subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
               if let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    let jsonString = "{ \"code\":0, \"desc\":\"success\" }"
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
                }
                
            }).disposed(by: disposeBag)
            setTradePwdModel.brokerNo = broker
            let context = YXNavigatable(viewModel:setTradePwdModel)
            self.viewModel.navigator.push(YXModulePaths.setTradePwd.url, context:context)
        }

    }
    
    func onCommandAppSearch(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {

        var mkts:[String]?
        var showHistory =  true
        var showLike = false
        var showPopular = false
        var type1s:[String]?
        var type2s:[String]?
        var type3s:[String]?
        
        if let data = try? JSONSerialization.data(withJSONObject: paramsJsonValue, options: []) {
            
            do {
                let model =  try JSONDecoder().decode(YXH5CallSearchModel.self, from: data)
                if let obj = model.showHistory {
                    showHistory = obj
                }
                if let obj = model.showLike {
                    showLike = obj
                }
                if let obj = model.showPopular {
                    showPopular = obj
                }
                
                if let obj = model.market {
                    mkts = obj
                }
                
                if let obj = model.type1s {
                    type1s = obj.map {"\($0)"}
                }
                
                if let obj = model.type2s {
                    type2s = obj.map {"\($0)"}
                }
                
                if let obj = model.type3s {
                    type3s = obj.map {"\($0)"}
                }
            } catch  {
                print("解析h5失败")
                return
            }
        }

        let searchParam = YXSearchParam(q: nil, markets: mkts, type1: type1s, type2: type2s, type3: type3s, size: nil)

        let types = mkts?.map{ YXSearchType(rawValue: $0) } ?? []
        let dic: [String : Any] = [
            "param" : searchParam,
            "showPopular": showPopular,
            "showLike": showLike,
            "showHistory": showHistory,
            "types": types
        ]
        
        let nv = self.viewModel.navigator.present(YXModulePaths.search.url, context: dic, animated: false) as? YXNavigationController

        if let vc = nv?.qmui_rootViewController as? YXNewSearchViewController {
            vc.didSelectedItem = { [weak vc] (item:YXSearchItem) in
                if let vc = vc {
                    vc.dismiss(animated: true, completion: nil)
                }
                if let webView = self.webView,
                   let successCallback = successCallback,
                   successCallback.count > 0 {
                    let jsonStr = YXSearchItem.getJsonData(dataModel: item)
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonStr as! String, callback: successCallback)
                }
                
            }
        }
        
    }
    
    func onCommandCreatePost(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let market = paramsJsonValue?["market"] as? String;
        let symbol = paramsJsonValue?["code"] as? String;
        let name = paramsJsonValue?["name"] as? String;
        
        let viewModel = YXReportViewModel(services: self.viewModel.navigator, params: nil)
        viewModel.successBlock = { [weak self] in
            if let webView = self?.webView, let successCallback = successCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
            }
        }
        viewModel.cancelBlock = { [weak self] in
            if let webView = self?.webView, let errorCallback = errorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: -2, errorMessage: "cancel", callback: errorCallback)
            }
        }
        let secu = YXSecu()
        secu.market = market ?? ""
        secu.symbol = symbol ?? ""
        secu.name = name ?? ""
        viewModel.secu = secu
        self.viewModel.navigator.push(viewModel, animated: true)
    }
    
    func onCommandGotoBeerich(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        let dict: [String: Any] = ["code": 0, "desc": "success"]
        if let webView = self.webView, let successCallback = successCallback, successCallback.count > 0, let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []), let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {

            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
        
//        if UIApplication.shared.canOpenURL(URL(string: "usmart-goto://")!) {
//            UIApplication.shared.open(URL(string: "usmart-goto://berich.stock.app/main?tag=course")!)
//        } else {
//            UIApplication.shared.open(URL(string: "https://itunes.apple.com/cn/app/id1590293090?mt=8")!)
//        }
        
        let url = paramsJsonValue?["url"] as? String ?? "";
        if UIApplication.shared.canOpenURL(URL(string: "usmart-goto://")!) {
            UIApplication.shared.open(URL(string: url)!)
        } else {
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/cn/app/id1590293090?mt=8")!)
        }
    }
    
    func onCommandSetAskStockLocation(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if let regionNo = paramsJsonValue?["regionNo"] as? Int {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "onCommandSetAskStockLocation"), object: regionNo, userInfo: nil)
        }
    }
    
    func onCommandAppOpenUrl(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        var success = false
        if let url = paramsJsonValue?["url"] as? String, let URL = URL.init(string: url) {
            let app = UIApplication.shared
            if app.canOpenURL(URL) {
                app.open(URL, options: [:], completionHandler: { success in
                    
                })
                success = true
            }
        }
        
        if let webView = self.webView,
           let successCallback = successCallback,
           successCallback.count > 0 {
            var jsonString = "{ \"code\":0, \"desc\":\"success\" }"
            if !success {
                jsonString = "{ \"code\":-1, \"desc\":\"请检查url格式\" }"
            }
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
         }
    }
    
    // Onfido人脸识别
    func onCommandStartOnfido(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        
        if let sdkToken = paramsJsonValue?["token"] as? String {
            
            self.megLiveSuccessCallback = successCallback
            self.megLiveErrorCallback = errorCallback
            
            QMUITips.showLoading(YXLanguageUtility.kLang(key: "common_loading"), in: self.view)
            YXOnfidoManager.shared.showFaceCheck(sdkToken, currentVC: self) {[weak self] (dictionary, error) in
                
                guard let `self` = self else { return }
                
                QMUITips.hideAllTips(in: self.view)
                if let dictionary = dictionary {
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
                        let jsonText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                        
                        if let webView = self.webView, let successCallback = self.megLiveSuccessCallback {
                            
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonText, callback: successCallback)
                        }
                    }
                } else {
                    if let errorCallback = self.megLiveErrorCallback {
                        
                        if let webView = self.webView, let error = error {
                            
                            YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorCode: error.code, errorMessage: error.errorMessageStr, callback: errorCallback)
                        }
                    }
                }
            }
        }
        
        
    }
}

extension YXWebViewController: YXIApRequestResultsDelegate {
    func failedWithErrorCode(_ errorCode: Int, andError error: String) {
        let dict: [String : Any] = ["code": errorCode, "desc": error]
        if
            let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
            let webView = self.webView,
            let successCallback = self.IAPSuccessCallback {
            
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
    }
    
    func success(withResult result: Dictionary<String, Any>) {
        let dict: [String : Any] = ["code": 0, "desc": "success", "data":result]
        if
            let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
            let webView = self.webView,
            let successCallback = self.IAPSuccessCallback {
            
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: successCallback)
        }
    }
}

var kPassportReaderKey = 101
@available(iOS 13.0, *)
extension YXWebViewController {
    fileprivate var passportReader: PassportReader? {
        set {
            objc_setAssociatedObject(self, &kPassportReaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            objc_getAssociatedObject(self, &kPassportReaderKey) as? PassportReader
        }
    }
}

extension YXWebViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as? String
        
        if (mediaType == kUTTypeImage as String) {
            let image: UIImage?
            if picker.allowsEditing {
                image = info[.editedImage] as? UIImage
            } else {
                image = info[.originalImage] as? UIImage
            }
            
            if let imageOriginal = image,
                let webView = self.webView {
                
                let image = self.normalizedImage(image: imageOriginal)
                
                let imageData = image.jpegData(compressionQuality: 0.7)
                if let imageData = imageData, let chooseImageSuccessCallback = self.chooseImageOrFileSuccessCallback {
                    let encodeData = imageData.base64EncodedString(options: [])
                    if self.fileMode ?? false {
                        let fileInfo = [
                            "fileName" : "",
                            "fileData" : encodeData
                        ]
                        if let chooseImageSuccessCallback = self.chooseImageOrFileSuccessCallback,
                            let jsonData = try? JSONSerialization.data(withJSONObject: fileInfo, options: .prettyPrinted),
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                            let webView = self.webView {
                            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: jsonString, callback: chooseImageSuccessCallback)
                        } else {
                            if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback, let webView = self.webView {
                                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "choose_failed"), callback: chooseImageErrorCallback)
                            }
                        }
                    } else {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: encodeData, callback: chooseImageSuccessCallback)
                    }
                } else {
                    if let chooseImageErrorCallback = self.chooseImageOrFileErrorCallback {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "choose_failed"), callback: chooseImageErrorCallback)
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func save(_ image: UIImage, completionHandler: ((_ result: Bool) -> Void)? = nil) {
        QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(image, QMUIAssetsGroup(phCollection: YXToolUtility.assetCollection()), { asset, error in
            if asset != nil {
                if completionHandler != nil {
                    completionHandler?(true)
                }
            } else {
                if completionHandler != nil {
                    completionHandler?(false)
                }
            }
        })
    }

    // MARK: - 解决图片自动旋转问题
    func normalizedImage(image: UIImage) -> UIImage {
        
        return image
        
//        if image.imageOrientation == UIImage.Orientation.up {
//            return image
//        }
        // 以下代码使用后,会使内存占用暴增,会导致在有些手机上内存紧张使webview被系统kill,所以注释此代码
//        UIGraphicsBeginImageContextWithOptions(image.size, _: false, _: image.scale)
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        let normalizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return normalizedImage ?? image
    }
    
    func getPublishTime() -> Observable<String> {
        Observable.create({ [weak self] (observer) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            if let webView = self.webView {
                YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [:], callback: "javascript:window.getPublishTime", completionCallback: { (result, error) in
                    if self.publishTime?.isEmpty ?? true {
                        if let result = result as? Int {
                            self.publishTime = String(result)
                            observer.onNext(self.publishTime ?? "")
                        } else {
                            self.publishTime = ""
                            observer.onNext(self.publishTime ?? "")
                        }
                        observer.onCompleted()
                    } else {
                        observer.onNext(self.publishTime ?? "")
                        observer.onCompleted()
                    }
                })
            }
            return Disposables.create()
        })
    }
    
}
//MARK: - MFMessageComposeViewControllerDelegate
extension YXWebViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            controller.shareResultBlock!(true)
            print("webview: send message success")
        case .failed:
            controller.shareResultBlock!(false)
            print("webview: send message failed")
        default:
            controller.shareResultBlock!(false)
            print("webview: default")
        }
    }
}


extension YXWebViewController {
    
    //分享图片社区
    func shareToUsmartCommunity(_ image: UIImage?,shareResultBlock: ((Bool) -> Void)?) {
        
        
        if let modalVC =  UIViewController.current() as? QMUIModalPresentationViewController {
            modalVC.hideWith(animated: false, completion: { finished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !YXUserManager.isLogin() {
                        YXToolUtility.handleBusinessWithLogin {

                        }
                        return
                    }

                    
                    if let root = UIApplication.shared.delegate as? YXAppDelegate {
                        let navigator = root.navigator
                        let viewModel = YXReportViewModel.init(services: navigator, params: nil)
                        if let image = image {
                            viewModel.images = [image]
                        }
                        viewModel.successBlock = {
                            shareResultBlock?(true)
                        }
                        viewModel.cancelBlock = {
                            shareResultBlock?(false)
                        }
                        self.viewModel.navigator.push(viewModel, animated: true)
                        //shareResultBlock?(true)
                    }
                }
            })
            return
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !YXUserManager.isLogin() {
                    YXToolUtility.handleBusinessWithLogin {
                    }
                    return
                }

                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let navigator = root.navigator
                    let viewModel = YXReportViewModel.init(services: navigator, params: nil)
                    if let image = image {
                        viewModel.images = [image]
                    }
                    viewModel.successBlock = {
                        shareResultBlock?(true)
                    }
                    viewModel.cancelBlock = {
                        shareResultBlock?(false)
                    }
                    navigator.push(viewModel, animated: true)
                    
                }
            }
        }
    }
    //MARK: 分享函数封装
    
    //MARK: 1.分享到短信
    fileprivate func shareToMessage(content: String?, sharingImage: UIImage?, imageUrlString: String?, shareResultBlock: ((Bool) -> Void)?) {
        // 分享短信
        // 1.判断能不能发短信
        if MFMessageComposeViewController.canSendText() {
            // 开始转菊花，进行图片下载
            
            let c = MFMessageComposeViewController()
            c.shareResultBlock = shareResultBlock
            c.body = content
            c.messageComposeDelegate = self
            let presentBlock: (_ image:UIImage?) -> Void = {[weak c,self] (image) in
                guard let strongC = c else {return}
                if let data = image?.pngData(), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.png", filename: "icon.png")
                    self.present(strongC, animated: true, completion: nil)
                }
                else if let data = image?.jpegData(compressionQuality: 1), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.jpeg", filename: "icon.png")
                    self.present(strongC, animated: true, completion: nil)
                }
                else {
                    self.present(strongC, animated: true, completion: nil)
                }
            }
            if MFMessageComposeViewController.canSendAttachments() {
                // 1. 仅支持jpg、png图片的短信分享
                // 2. 图片需要做缓存
                // 3. 图片下载完成后，present vc && 隐藏菊花
                // 4. 图片下载失败后，present vc (without image) && 隐藏菊花
                // 5. 没有需要分享的图片链接时，不需要分享图片
                // https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller/1614075-issupportedattachmentuti
                if MFMessageComposeViewController.isSupportedAttachmentUTI("public.png") ||
                    MFMessageComposeViewController.isSupportedAttachmentUTI("public.jpeg") {
                    if let sharingImage = sharingImage {
                        presentBlock(sharingImage)
                    } else {
                        if let imageUrlString = imageUrlString,imageUrlString.isEmpty == false {
                            self.networkingHUD.showLoading("", in: self.view)
                            let temp = URL(string: imageUrlString)!
                            SDWebImageManager.shared.loadImage(with: temp, options: SDWebImageOptions.retryFailed, progress: { (_, _, _) in
                                
                            }) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                                self?.networkingHUD.hideHud()
                                presentBlock(image)
                            }
                        } else {
                            presentBlock(nil)
                        }
                    }
                } else {
                    presentBlock(nil)
                }
            } else {
                presentBlock(nil)
            }
        } else {
            // 不能发短信时
            shareResultBlock?(false)
            self.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "share_not_support_message"), false))
        }
    }
    
    //MARK: 2.分享到更多
    fileprivate func shareToMore(activityItems: [Any], shareResultBlock: ((Bool) -> Void)?) {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let completeBlock: UIActivityViewController.CompletionWithItemsHandler = { [weak vc] (activityType, completed, items, error) in
            guard let strongVC = vc else { return }
            shareResultBlock?(completed)
            if completed {
                log(.verbose, tag: kModuleViewController, content: "information: send success")
            } else {
                log(.verbose, tag: kModuleViewController, content: "information: send failed")
            }
            strongVC.dismiss(animated: true, completion: nil)
        }
        vc.completionWithItemsHandler = completeBlock
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: 2.分享图片到指定平台
    fileprivate func sharingImage(_ type: SSDKPlatformType, _ sharingImage: UIImage, _ shareResultBlock: ((Bool) -> Void)?) {
        if type == .typeTwitter {
            YXProgressHUD.showLoading("", in: self.view)
        }
        var shareAppText = ""
        if YXShareManager.shared.isShareImageWithTitleSSDKType(type) {
            shareAppText = YXLanguageUtility.kLang(key: "share_image_recommend_text")
        }
        
        YXShareSDKHelper.shareInstance()?.share(type, text: shareAppText, images: [sharingImage], url: nil, title: "", type: .image, withCallback: {
            [weak self] (success, userInfo, _) in
            guard let `self` = self else { return }
            if type == .typeTwitter {
                YXProgressHUD.hide(for: self.view, animated: false)
            }
            shareResultBlock?(success)
        })
    }
}

extension YXWebViewController:YXFaceIdIDCardQualityProtocol{

// MARK: - YXFaceIdIDCardQualityProtocol
func detectFinish(portraitImage: UIImage?) {
    if let portraitImage = portraitImage {
        let imageData = portraitImage.jpegData(compressionQuality: 0.7)
        if let encodeData = imageData?.base64EncodedString() {
            if let webView = self.webView, let successCallback = self.portraitSuccessCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: encodeData, callback: successCallback)
            }
        } else {
            if let webView = self.webView, let errorCallback = self.portraitErrorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "identify_failure"), callback: errorCallback)
            }
        }
    }
}

func detectFinish(emblemImage: UIImage?) {
    if let emblemImage = emblemImage {
        let imageData = emblemImage.jpegData(compressionQuality: 0.7)
        if let encodeData = imageData?.base64EncodedString() {
            if let webView = self.webView, let successCallback = self.nationalEmblemSuccessCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: encodeData, callback: successCallback)
            }
        } else {
            if let webView = self.webView, let errorCallback = self.nationalEmblemErrorCallback {
                YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: YXLanguageUtility.kLang(key: "identify_failure"), callback: errorCallback)
            }
        }
    }
}
}
