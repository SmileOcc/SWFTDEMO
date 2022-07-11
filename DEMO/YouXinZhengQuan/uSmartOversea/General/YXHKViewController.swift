//
//  ViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import QMUIKit

import NSObject_Rx


@objc enum YXEmptyType: Int {
    case netError
    case serverError
    case noArticle
    case noWriter
    case noCourseware
    case noAsk
    case noAnswer
    case noWaiting
    case noQuestion
    case noChat
    case noVideo
            
    var image: UIImage? {
        switch self {
        case .netError:
            return UIImage(named: "network_nodata")
        case .serverError:
            return UIImage(named: "server_nodata")
        case .noArticle:
            return UIImage(named: "empty_noData")
        case .noWriter:
            return UIImage(named: "writer_nodata")
        case .noCourseware:
            return UIImage(named: "courseware_empty_view")
        case .noAsk:
            return UIImage(named: "empty_noData")
        case .noAnswer:
            return UIImage(named: "empty_noData")
        case .noQuestion:
            return UIImage(named: "empty_noData")
        case .noWaiting:
            return UIImage(named: "empty_noData")
        case .noChat:
            return UIImage(named: "empty_noData")
        case .noVideo:
            return UIImage(named: "empty_noData")
        }
    }
    
    var text: String {
        switch self {
        case .netError:
            return YXLanguageUtility.kLang(key: "network_timeout")
        case .serverError:
            return YXLanguageUtility.kLang(key: "nbb_servererror")
        case .noArticle:
            return YXLanguageUtility.kLang(key: "nbb_noarticle")
        case .noWriter:
            return YXLanguageUtility.kLang(key: "nbb_nocreator")
        case .noCourseware:
            return YXLanguageUtility.kLang(key: "nbb_nocourseware")
        case .noAsk:
            return YXLanguageUtility.kLang(key: "nbb_tab_ask_question_empty")
        case .noAnswer:
            return YXLanguageUtility.kLang(key: "nbb_tab_ask_answer_empty")
        case .noQuestion:
            return YXLanguageUtility.kLang(key: "nbb_tab_ask_question_empty")
        case .noWaiting:
            return YXLanguageUtility.kLang(key: "nbb_tab_ask_waiting_empty")
        case .noChat:
            return YXLanguageUtility.kLang(key: "nbb_tips_no_chatroom")
        case .noVideo:
            return YXLanguageUtility.kLang(key: "nbb_empty_tips")
        }
    }
    
    var actionText: String {
        switch self {
        case .noQuestion, .noAnswer:
            return YXLanguageUtility.kLang(key: "nbb_tab_ask_gotoall")
        default:
            return YXLanguageUtility.kLang(key: "common_click_refresh")
        }
    }
}


class YXHKViewController: QMUICommonViewController, HasDisposeBag {
    var forceToLandscapeRight = false
    var strongNoticeViewHeight:CGFloat = 32
    var kStrongNoticeViewHeight: CGFloat  {
        if (strongNoticeView.noticeType == .normal && strongNoticeView.isCurrencyExchange) {
            return 52
        } else {
            return strongNoticeViewHeight
        }
    }
    
    lazy var messageItem: UIBarButtonItem = {
        let msgItem = UIBarButtonItem.qmui_item(with: messageImage() ?? UIImage(), target: self, action: nil)
        msgItem.qmui_shouldShowUpdatesIndicator = !YXMessageButton.pointIsHidden
//        msgItem.imageInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
        msgItem.rx.tap.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                let root = UIApplication.shared.delegate as? YXAppDelegate
                if let navigator = root?.navigator {
                    if YXUserManager.isLogin() {
                        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
                        navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    } else {
                        let callback: (([String: Any])->Void)? = { [weak self] _ in
                            guard let `self` = self else { return }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
                                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                            })
                        }
                        
                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: self))
                        navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    }
                }
            }).disposed(by: rx.disposeBag)
        YXMessageButton.messageBarButtonItems.append(WeakBox(msgItem))
        return msgItem
    }()
    
    lazy var brokerMessageItem: UIBarButtonItem = {
        let msgItem = UIBarButtonItem.qmui_item(with: messageImage() ?? UIImage(), target: self, action: nil)
        msgItem.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        msgItem.rx.tap.takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                let root = UIApplication.shared.delegate as? YXAppDelegate
                if let navigator = root?.navigator {
                    if YXUserManager.isLogin() {
                        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_BROKERS_MSG_CENTER_URL()]
                        navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    } else {
                        let callback: (([String: Any])->Void)? = { [weak self] _ in
                            guard let `self` = self else { return }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_BROKERS_MSG_CENTER_URL()]
                                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                            })
                        }
                        
                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: self))
                        navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    }
                }
            }).disposed(by: rx.disposeBag)
        YXMessageButton.brokerMessageBarButtonItems.append(WeakBox(msgItem))
        return msgItem
    }()
        
    var needShowStrongNotice: Bool?
    var strongNoticeViewHeightTmp:CGFloat = 40
    private(set) public lazy var strongNoticeView: YXStrongNoticeView = {
        let strongNoticeView = YXStrongNoticeView(frame: CGRect.zero, services: YXMessageCenterService.shared)
        self.needShowStrongNotice = true
        self.view.addSubview(strongNoticeView)
        strongNoticeView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(strongNoticeViewHeight)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
        })
         
        strongNoticeView.rx.observe(Bool.self, "hidden").subscribe(onNext: { [weak strongNoticeView, weak self] (isHidden) in
            guard let `strongNoticeView` = strongNoticeView, let `self` = self else { return }

            strongNoticeView.snp.updateConstraints({ (make) in
                if isHidden ?? false {
                    make.height.equalTo(0)
                    self.strongNoticeViewHeightTmp = 0
                } else {
                    if (strongNoticeView.noticeType == .normal && strongNoticeView.isCurrencyExchange) {
                        make.height.equalTo(52)
                        self.strongNoticeViewHeightTmp = 52
                    } else {
                        make.height.equalTo(self.strongNoticeViewHeight)
                        self.strongNoticeViewHeightTmp = self.strongNoticeViewHeight
                    }
                }
            })
        }).disposed(by: self.disposeBag)
        return strongNoticeView
    }()
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = true
//        extendedLayoutIncludesOpaqueBars = true
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.forceToLandscapeRight {
            YXToolUtility.forceToLandscapeRightOrientation()
        } else {
            YXToolUtility.forceToPortraitOrientation()
        }
        
        guard let appdelegate = UIApplication.shared.delegate as? YXAppDelegate else { return }
        if self.navigationController?.visibleViewController is YXAccountAssetViewController || self.forceToLandscapeRight {
            appdelegate.top_icon_forscreenshot.isHidden = true
        } else {
            appdelegate.top_icon_forscreenshot.isHidden = false
            appdelegate.window?.bringSubviewToFront(appdelegate.top_icon_forscreenshot)
        }
    }
    
    override func qmui_backBarButtonItemTitle(withPreviousViewController viewController: UIViewController?) -> String? {
        ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QMUITheme().foregroundColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 15.0, *) {
            let app = UINavigationBarAppearance()
            app.configureWithOpaqueBackground()
            app.backgroundColor = QMUITheme().foregroundColor()
            app.shadowImage = UIImage()
            app.shadowColor = .clear
            navigationController?.navigationBar.scrollEdgeAppearance = app
            navigationController?.navigationBar.standardAppearance = app
        }
    }
    
    func showEmpty(emptyType: YXEmptyType) {
        switch emptyType {
        case .netError, .serverError:
           // showErrorEmptyView(emptyType: emptyType)
            showErrorEmptyView()
        case .noArticle, .noWriter:
            showNoDataEmptyView()
           // showNoDataEmptyView(emptyType: emptyType)
        default:
            break
        }
    }
    
    override func showEmptyView() {
        super.showEmptyView()
        self.emptyView?.detailTextLabel.text = nil
        self.emptyView?.detailTextLabel.text = nil
        self.emptyView?.loadingView.isHidden = true
        self.emptyView?.backgroundColor = QMUITheme().foregroundColor()
        self.emptyView?.actionButtonTitleColor = QMUITheme().foregroundColor()
        self.emptyView?.actionButtonFont = UIFont.systemFont(ofSize: 29, weight: .medium)
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        self.emptyView?.textLabelFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.emptyView?.textLabelInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 13, right: 0)
        self.emptyView?.imageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        if emptyActionButtn.superview == nil {
            self.emptyView?.actionButton.addSubview(emptyActionButtn)
            self.emptyActionButtn.snp.makeConstraints { (make) in
                make.height.equalTo(30)
                make.centerX.equalToSuperview()
            }
        }
        
        if let loadingView = self.emptyView?.loadingView as? UIActivityIndicatorView {
            loadingView.style = YXThemeTool.isDarkMode() ? .white : .gray
        }
    }
//    
//    @objc func addNavUserBtn() {
//        YXNavUserButton.shared.refreshUI()
//        YXNavUserButton.shared.snp.makeConstraints { (make) in
//            make.width.equalTo(44)
//        }
//        let navItem = UIBarButtonItem.init(customView: YXNavUserButton.shared)
//        YXNavUserButton.shared.onClickMessage = {
//            YXShortCutsManager.shareInstance.shortCutsVC.show()
//        }
//        self.navigationItem.leftBarButtonItems = [navItem]
//    }
    private lazy var emptyActionButtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_click_refresh"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        
        return btn
    }()

    @objc func showNoNetworkEmptyView() {
        self.showEmptyView()

        self.emptyView?.setImage(UIImage(named: "no_network"))
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_noNetwork"))

        self.emptyView?.setActionButtonTitle(YXLanguageUtility.kLang(key: "common_click_refresh"))

        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyActionButtn.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.isHidden = false
    }
    
    @objc func showErrorEmptyView() {
        self.showEmptyView()
        
        
        self.emptyView?.setImage(UIImage(named: "network_nodata"))
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_loadFailed"))
        
        //self.emptyView?.setActionButtonTitle(YXLanguageUtility.kLang(key: "common_click_refresh"))
        self.emptyView?.setActionButtonTitle("click to  ")
        
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyActionButtn.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.isHidden = false
    }
    
    @objc func showNoDataEmptyView() {
        self.showEmptyView()
        
        self.emptyView?.imageView.image = YXDefaultEmptyEnums.noData.image()
        self.emptyView?.setTextLabelText(YXDefaultEmptyEnums.noData.tip())
        self.emptyView?.setActionButtonTitle(nil)
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyActionButtn.isHidden = true
    }
    
    @objc func emptyRefreshButtonAction() {
        
    }
    
    @objc func messageImage() -> UIImage? {
        UIImage(named: "trade_message")
    }

    override func customNavigationBarTransitionKey() -> String? {

        return NSStringFromClass(Self.self)
    }
    
    override func shouldCustomizeNavigationBarTransitionIfHideable() -> Bool {
        true
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func qmui_navigationBarBackgroundImage() -> UIImage? {
        return UIImage(named: "nav_bg")
    }

    func setTabbarVisibleIfNeed() -> Void {
        if let tabbar = self.tabBarController?.tabBar {
            log(.warning, tag: kOther, content: "[fix tabbar bugs] [tabbar: \(tabbar)], [tabbar hidden : \(tabbar.isHidden)]")
            if tabbar.isHidden {
                log(.warning, tag: kOther, content: "[fix tabbar bugs] set tabbar hidden to NO")
                tabbar.isHidden = false
            }
        }
    }
    
    func requestNoticeData(urlStr:String,complete:@escaping (_ success:[YXNoticeModel])->Void, failed:@escaping (_ errorMsg:String)->Void ) {
        
        guard let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate else {
            return
        }
        let url = YXMessageCenterService.buildUrlParam(url: urlStr)
        appDelegate.appServices.messageCenterService.request(.noteMsg(url), response: { (response) in
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    var models: [YXNoticeModel] = []
                    if let list = result.data?.list {
                        for element in list {
                            let model = YXNoticeModel(msgId: element.msgId ?? 0, title: element.title ?? "", content: element.content ?? "", pushType: element.pushType ?? .none, pushPloy: element.pushPloy ?? "", msgType: element.msgType ?? 0, contentType: element.contentType ?? 0, startTime: element.startTime ?? 0.0, endTime: element.endTime ?? 0.0, createTime: element.createTime ?? 0.0, newFlag: element.newFlag ?? 0)
                            models.append(model)
                        }
                        complete(models)
                    } else {
                        complete([])
                    }
                default:
                    failed(result.msg ?? "request noteMsg error")
                    print("request noteMsg error: \(String(describing: result.msg))")
                }
            case .failed(_):
                failed("request noteMsg error")
            }
            } as YXResultResponse<YXNoticeResponseModel>).disposed(by: self.disposeBag)
        
//        let model = YXNoticeModel.init(msgId: 0, title: "", content: "我是小黄条", pushType: YXPushType.notify, pushPloy: "", msgType: 1, contentType: 1, startTime: 0, endTime: 0, createTime: 0, newFlag: 1)
//        self.strongNoticeView.dataSource = [model]
        
    }
}
