//
//  TableViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import QMUIKit
import NSObject_Rx   

class YXHKTableViewController: QMUICommonTableViewController, HasDisposeBag {
    var forceToLandscapeRight = false
    var kStrongNoticeViewHeight: CGFloat  {
        if (strongNoticeView.noticeType == .normal && strongNoticeView.isCurrencyExchange) {
            return 52
        } else {
            return 26
        }
    }

    lazy var messageItem: UIBarButtonItem = {
        let msgItem = UIBarButtonItem.qmui_item(with: UIImage(named: "btn_black_message") ?? UIImage(), target: self, action: nil)
        msgItem.qmui_shouldShowUpdatesIndicator = !YXMessageButton.pointIsHidden
        msgItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
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
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: {
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
    
    lazy var loadingHud: YXProgressHUD = {
        let hud = YXProgressHUD()
        hud.isUserInteractionEnabled = false
        return hud
    }()
    
    var needShowStrongNotice: Bool?
    
    ///空视图顶部的偏移量
    @objc var emptyViewOffset: CGFloat {
        return 40
    }
    
    private(set) public lazy var strongNoticeView: YXStrongNoticeView = {
        let strongNoticeView = YXStrongNoticeView(frame: CGRect.zero, services: YXMessageCenterService.shared)
        self.needShowStrongNotice = true
        self.view.addSubview(strongNoticeView)
        strongNoticeView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(26)
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
                } else {
                    if (strongNoticeView.noticeType == .normal && strongNoticeView.isCurrencyExchange) {
                        make.height.equalTo(52)
                    } else {
                        make.height.equalTo(26)
                    }
                }
            })
        }).disposed(by: self.disposeBag)
        return strongNoticeView
    }()
    
    init() {
        super.init(style: .plain)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = true
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
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
    
    private lazy var emptyActionButtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_click_refresh"), for: .normal)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return btn
    }()
    
    func showEmpty(emptyType: YXEmptyType) {
        switch emptyType {
        case .netError, .serverError:
            showErrorEmptyView(emptyType: emptyType)
        case .noArticle, .noWriter, .noCourseware:
            showNoDataEmptyView(emptyType: emptyType)
        default:
            break
        }
    }
    
    override func showEmptyView() {
        if isEmptyViewShowing {
            return
        }
        super.showEmptyView()
        
        self.emptyView?.detailTextLabel.text = nil
        self.emptyView?.loadingView.isHidden = true

        if emptyActionButtn.superview == nil {
            self.emptyView?.actionButton.addSubview(emptyActionButtn)
            self.emptyActionButtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize.init(width: 118, height: 30))
                make.centerX.equalToSuperview()
            }
        }
        
        self.emptyView?.actionButtonFont = UIFont.systemFont(ofSize: 29, weight: .medium)
        self.emptyView?.actionButtonTitleColor = UIColor.white
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        self.emptyView?.textLabelFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.emptyView?.imageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        self.emptyView?.textLabelInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 13, right: 0)
       
    }
    
    @objc func showErrorEmptyView() {
        self.showEmptyView()
        
        self.emptyView?.setImage(UIImage(named: "network_nodata"))
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_loadFailed"))
        
        self.emptyView?.setActionButtonTitle("click to  ")
        
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyActionButtn.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        self.emptyActionButtn.isHidden = false
        
        if let emptyH = self.emptyView?.frame.size.height, let contentH = self.emptyView?.sizeThatContentViewFits().height {
            self.emptyView?.verticalOffset = -((emptyH - contentH)/2 - self.emptyViewOffset)
        }
    }
    
    @objc func showNoDataEmptyView() {
        self.showEmptyView()
        
        self.emptyView?.imageView.image = YXDefaultEmptyEnums.noData.image()
        self.emptyView?.setTextLabelText(YXDefaultEmptyEnums.noData.tip())
        self.emptyView?.setActionButtonTitle(nil)
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyActionButtn.isHidden = true
        
        if let emptyH = self.emptyView?.frame.size.height, let contentH = self.emptyView?.sizeThatContentViewFits().height {
            self.emptyView?.verticalOffset = -((emptyH - contentH)/2 - self.emptyViewOffset)
        }
    }
    
    @objc func showErrorEmptyView(emptyType: YXEmptyType = .netError) {
        self.showEmptyView()
        
        self.emptyView?.setImage(emptyType.image)
        self.emptyView?.setTextLabelText(emptyType.text)
        
        self.emptyView?.setActionButtonTitle(YXLanguageUtility.kLang(key: "common_click_refresh"))
        
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
        
        self.emptyView?.textLabelInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.emptyView?.textLabelFont = .systemFont(ofSize: 14)
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        
        self.emptyView?.actionButtonInsets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        self.emptyView?.actionButtonFont = .systemFont(ofSize: 16)
        self.emptyView?.actionButtonTitleColor = QMUITheme().textColorLevel3()
        self.emptyView?.actionButton.layer.borderWidth = 1
        self.emptyView?.actionButton.layer.borderColor = QMUITheme().textColorLevel3().cgColor
        self.emptyView?.actionButton.layer.cornerRadius = 8
        self.emptyView?.actionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    }
    
    @objc func showNoDataEmptyView(emptyType: YXEmptyType = .noArticle) {
        self.showEmptyView()
        
        self.emptyView?.imageView.image = emptyType.image
        self.emptyView?.setTextLabelText(emptyType.text)
        self.emptyView?.setActionButtonTitle(nil)
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    @objc func emptyRefreshButtonAction() {
        
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
    
    override func qmui_backBarButtonItemTitle(withPreviousViewController viewController: UIViewController?) -> String? {
        ""
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
}
