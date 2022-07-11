//
//  YXShortVideoMainViewController.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import Lottie
import MMKV
import RxCocoa
import TXLiteAVSDK_Professional
import YXKit

enum ShortVideoViewControllerBuinessType {
    case mutile
    case detail(id: String)
}

class YXShortVideoMainViewController: YXHKViewController {
    
    var businessType = ShortVideoViewControllerBuinessType.mutile
    
    var viewModel: YXShortVideoMainViewModel!
    
    var dataSource = [YXShortVideoRecommendItem]()
    
    var guideView: YXStockDetailGuideView?
    
    var nextVCdic: [Int: YXShortVideoItemViewController] = [:]
    
    var currentIndex = 0
    
    var unloginMaxVideo = 4
    
    var flag = true
    
    var isLast = false // 是否划到了末尾,正常情况下划不到末尾,除非请求不到数据,数组的长度固定
    //
    var isFullScreen = false {
        didSet {
            backBtn.isHidden = !isFullScreen
            moreBtn.isHidden = !isFullScreen
            if let vcs = pageVC.viewControllers {
                for vc in vcs {
                    (vc as? YXShortVideoItemViewController)?.isFullScreen = isFullScreen
                    (vc as? YXShortVideoItemViewController)?.rootView.updateUI(isFullScreen: isFullScreen)
                }
            }
            for vc in nextVCdic.values {
                vc.isFullScreen = isFullScreen
                //                vc.updateUI()
            }
        }
    }
    
    var didClickedBackBlock: (()->Void)?
    var didClickPlayBlock: (()->Void)?
    
    var currentVideoVC: YXShortVideoItemViewController? {
        if let vc = pageVC.viewControllers?.first as? YXShortVideoItemViewController {
            return vc
        }else {
            return nil
        }
    }
    
    lazy var shadowBgView: YXGradientLayerView = {
        let view = YXGradientLayerView()
        view.direction = .vertical
        view.colors = [UIColor.black.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0)]
        return view
    }()
    
    var didChangePage: ((YXShortVideoRecommendItem?)->Void)?
    
    lazy var backBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "live_back_icon"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            switch self.businessType {
            case .mutile:
                self.isFullScreen = false
                //            self.currentVideoVC?.updateUI()
                self.currentVideoVC?.pausePlayer()
                self.didClickedBackBlock?()
            default:
#if OVERSEAS
                NavigatorServices.shareInstance.popViewModel(animated: true)
#endif
#if USMART_HK
                self.navigationController?.popViewController(animated: true)
#endif
                
            }
            
        }
        return btn;
    }()
    
    lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        vc.delegate = self
        vc.dataSource = self
        vc.view.backgroundColor = QMUITheme().foregroundColor()
        for subView in vc.view.subviews {
            if let view = subView as? UIScrollView {
                //                view.backgroundColor = .black
                view.rx.willEndDragging.subscribe { [weak self](velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) in
                    guard let `self` = self else { return }
                    if velocity.y > 0, self.isLast {
                        self.loadNext(isLast: true)
                    }
                    
                    if !YXUserManager.isLogin(), self.currentIndex >= (self.unloginMaxVideo - 1) {
                        let v = view.contentOffset.y / view.frame.size.height
                        let index = floorf(Float(v))
                        
                        if v > CGFloat(index) && velocity.y > 0 {
                            let alertView = YXAlertView(title: "", message: YXLanguageUtility.kLang(key: "beerich_loginTips"))
                            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView, weak self] (_) in
                                alertView?.hide()
                            }))
                            
                            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_goLogin"), style: .default, handler: { [weak alertView, weak self] (_) in
                                guard let `self` = self else { return }
                                if self.isFullScreen {
                                    self.backBtn.sendActions(for: .touchUpInside)
                                }
                                YXToolUtility.handleBusinessWithLogin { [weak self] in
                                    guard let `self` = self else { return }
                                    self.reloadPageViewVC(index: self.currentIndex)
                                }
                            }))
                            alertView.showInWindow()
                        }
                    }
                    
                }.disposed(by: disposeBag)
                
                break
            }
        }
        
        return vc
    }()
    
    lazy var moreBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "more_icon_white"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.menuView.showWith(animated: true)
        }
        return btn;
    }()
    
    private lazy var menuView: QMUIPopupMenuView = {
        let menuView = QMUIPopupMenuView()
        menuView.cornerRadius = 2
        menuView.automaticallyHidesWhenUserTap = true
        menuView.shouldShowItemSeparator = true
        menuView.itemHeight = 44        
        menuView.itemSeparatorColor = UIColor(hexString:"#999999")
        menuView.itemTitleFont = .systemFont(ofSize: 14)
        menuView.itemTitleColor = UIColor(hexString:"#666666")
        menuView.arrowSize = CGSize(width: 9, height: 7)
        menuView.sourceView = moreBtn
        
        #if OVERSEAS
        menuView.itemSeparatorColor = QMUITheme().popSeparatorLineColor()
        menuView.backgroundColor = QMUITheme().popupLayerColor()
        menuView.borderColor = .clear
        menuView.arrowSize = CGSize.zero
        menuView.cornerRadius = 6
        menuView.minimumWidth = 75
        #endif
        
        var items: [QMUIPopupMenuButtonItem] = [
            {
                let item = QMUIPopupMenuButtonItem(image: nil, title: YXLanguageUtility.kLang(key: "report_comment"), handler: { [weak self] (item) in
                    guard let strongSelf = self else { return }
                    strongSelf.backBtn.sendActions(for: .touchUpInside)
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.shortVideoReport()]
                    if let root = UIApplication.shared.delegate as? YXAppDelegate {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            root.navigator.presentPath(YXModulePaths.webView, context: YXWebViewModel(dictionary: dic), animated: true)
                        }
                    }
                    item.menuView?.hideWith(animated: false)
                })
                item.button.contentHorizontalAlignment = .center
                item.button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                item.button.titleLabel?.font = .systemFont(ofSize: 14)
                return item
            }()
        ]
        menuView.items = items
        menuView.didHideBlock = { [weak self] (hideByUserTap) in
        }
        return menuView
    }()
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = true
        inputViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if OVERSEAS
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "onCommandCloseWebView"), object: nil).subscribe (onNext: { [weak self] noti in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: { [weak self] in
                guard let `self` = self else { return }
                switch self.businessType {
                case .mutile:
                    if let vc = UIViewController.topMost {
                        if vc is YXLearningMainViewController {
                            self.reloadPageViewVC(index: self.currentIndex+1)
                        }
                    }
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        NavigatorServices.shareInstance.popViewModel(animated: true)
                    })
                }
            })
            
        }).disposed(by: disposeBag)
        #endif
        #if USMART_HK
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "onCommandCloseWebView"), object: nil).subscribe (onNext: { [weak self] noti in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: { [weak self] in
                guard let `self` = self else { return }
                switch self.businessType {
                case .mutile:
                    if let vc = UIViewController.topMost {
                        if vc is YXHomeViewController {
                            self.reloadPageViewVC(index: self.currentIndex+1)
                        }
                    }
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    })
                }
            })
            
        }).disposed(by: disposeBag)
        #endif
        

        
        view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
        addChild(pageVC)
        
        view.addSubview(shadowBgView)
        shadowBgView.addSubview(backBtn)
        shadowBgView.addSubview(moreBtn)
        
        
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(51)
            make.size.equalTo(44)
        }
        
        backBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(51)
            make.size.equalTo(44)
        }
        
        shadowBgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(100)
        }
        
        switch self.businessType {
        case .mutile:
            getRecommend()
        case .detail(let id):
            self.isFullScreen = true
            getSingle(id: id)
        }
        view.clipsToBounds = false
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentVideoVC?.isCanPlay = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentVideoVC?.isCanPlay = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch self.businessType {
        case .mutile:
            if isFullScreen {
                currentVideoVC?.resumePlayer()
            }
        default:
            currentVideoVC?.resumePlayer()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        switch self.businessType {
        case .mutile:
            if isFullScreen {
                currentVideoVC?.pausePlayer()
            }
        default:
            currentVideoVC?.pausePlayer()
        }
        
    }
    
    func inputViewModel() {
        let viewDidLoad: Driver<()> = self.rx.methodInvoked(#selector(viewDidLoad)).map { _ in
            return ()
        }.asDriver(onErrorJustReturn: ())
        let viewDidAppear: Driver<()> = self.rx.methodInvoked(#selector(viewDidAppear)).do(onNext: { _ in
            
        }).map { _ in
            return ()
        }.asDriver(onErrorJustReturn: ())
        viewModel = YXShortVideoMainViewModel(input: (viewDidLoad: viewDidLoad,
                                                      viewDidAppear: viewDidAppear))
    }
    //
    //    func bindViewModel() {
    //
    //    }
    //
    func getRecommend(showLoading: Bool = true) {
        var hud: YXProgressHUD?
        if showLoading {
            hud = YXProgressHUD()
            hud?.showLoading(in: view, type: .netWork)
        }
        
        viewModel.getRecommend(offset: 0).subscribe { [weak self] resModel in
            guard let `self` = self else { return }
            hud?.hideHud()
            self.hideEmptyView()
            if let list = resModel?.list, list.count > 0 {
                
                self.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
                
                self.dataSource = list
                
                self.reloadPageViewVC(index: 0)
                
            }else {
                self.showErrorEmptyView()
                self.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
            }
            
        } onError: { [weak self] err in
            hud?.hideHud()
            self?.showErrorEmptyView()
            self?.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
        }.disposed(by: disposeBag)
        
    }
    
    func getSingle(id: String, showLoading: Bool = true) {
        
        var hud: YXProgressHUD?
        if showLoading {
            hud = YXProgressHUD()
            hud?.showLoading(in: view)
        }
        viewModel.getVideo(id: id).subscribe { [weak self] resModel in
            guard let `self` = self else { return }
            hud?.hideHud()
            self.hideEmptyView()
            
            if let list = resModel?.list, list.count > 0 {
                self.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
                self.dataSource = list
                self.reloadPageViewVC(index: 0)
            }else {
                self.showErrorEmptyView()
                self.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
            }
        } onError: { [weak self] err in
            guard let `self` = self else { return }
            hud?.hideHud()
            self.showErrorEmptyView()
            self.view.bringSubviewToFront(self.shadowBgView)
            self.pageVC.view.backgroundColor = QMUITheme().foregroundColor()
        }.disposed(by: disposeBag)
    }
    //
    func loadNext(isLast: Bool = false) {
        if let offset = self.dataSource.last?.offset { // 加载更多
            viewModel.getRecommend(offset: offset).subscribe { [weak self]resModel in
                guard let `self` = self else { return }
                if let list = resModel?.list, list.count > 0 {
                    let nextIndex = self.dataSource.count
                    self.dataSource = self.dataSource + list
                    if isLast { // 当划到最后划不动的时候
                        //                        self.currentVideoVC?.player.stopPlay()
                        self.reloadPageViewVC(index: nextIndex)
                        self.isLast = false
                    }
                }
                
            } onError: { err in
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_timeout"))
            }.disposed(by: disposeBag)
        }
    }
    //
    func reloadPageViewVC(index: Int) {
        let vc = self.creatVC(dataIndex: index)
        vc.isCanPlay = true
        if dataSource.count > 1 {
            let next = index + 1
            self.nextVCdic = [next: self.creatVC(dataIndex: next)]
        }
        self.pageVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    //
    override func emptyRefreshButtonAction() {
        self.hideEmptyView()
        switch self.businessType {
        case .mutile:
            getRecommend()
        case .detail(let id):
            getSingle(id: id)
        default:
            break
        }
        
    }
}


extension YXShortVideoMainViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // 注意,此方法的调用时机完全由UIPageViewController控制,不是每次都调用,UIPageViewController内部根据需要调用
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? YXShortVideoItemViewController else { return nil }
        if let item = currentVC.model, let currentIndex = self.dataSource.firstIndex(of: item) {
            let beforeIndex = currentIndex - 1
            if beforeIndex >= 0 {
                var vc = self.nextVCdic[beforeIndex]
                if vc == nil {
                    vc = creatVC(dataIndex: beforeIndex)
                }
                
                let nextIndex = beforeIndex - 1
                if nextIndex >= 0 {
                    self.nextVCdic = [nextIndex : creatVC(dataIndex: nextIndex)]
                }
                
                return vc
                
            }else {
                return nil
            }
            
        }else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for vc in pendingViewControllers {
            if let vc = vc as? YXShortVideoItemViewController {
                vc.isFullScreen = self.isFullScreen
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentVC = viewController as? YXShortVideoItemViewController else { return nil }
        if let item = currentVC.model, let currentIndex = self.dataSource.firstIndex(of: item) {
            //            print("######viewControllerAfter\(currentIndex)")
            if currentIndex == self.dataSource.count - 5 { // 加载更多
                self.loadNext()
            }
            if !YXUserManager.isLogin(), self.currentIndex > (self.unloginMaxVideo - 1) {
                return nil
            }
            let aftertIndex = currentIndex + 1
            if aftertIndex < self.dataSource.count {
                var vc = self.nextVCdic[aftertIndex]
                if vc == nil {
                    vc = creatVC(dataIndex: aftertIndex)
                }
                
                let nextIndex = aftertIndex + 1
                if nextIndex < self.dataSource.count {
                    self.nextVCdic = [nextIndex : creatVC(dataIndex: nextIndex)]
                }
                return vc
            }else {
                return nil
            }
        }else {
            return nil
        }
    }
    
    func creatVC(dataIndex: Int) -> YXShortVideoItemViewController {
        let vc = YXShortVideoItemViewController()
        if dataIndex >= 0, dataIndex < self.dataSource.count {
            vc.model = self.dataSource[dataIndex]
            vc.businessType = self.businessType
            vc.isFullScreen = self.isFullScreen
            vc.didClickedPlayBlock = self.didClickPlayBlock
            vc.backFullScreen = { [weak self] in
                self?.backBtn.sendActions(for: .touchUpInside)
            }
            vc.startPrepare()
        }
        
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            if let item = currentVideoVC?.model, let currentIndex = self.dataSource.firstIndex(of: item) {
                self.currentIndex = currentIndex
                if currentIndex == self.dataSource.count - 1 {
                    isLast = true
                }else {
                    isLast = false
                }
            }
            
            if let vc = previousViewControllers.first as? YXShortVideoItemViewController {
                vc.isCanPlay = false
                vc.isFullScreen = self.isFullScreen
                vc.pausePlayer(showMask: false)
            }
            
            currentVideoVC?.isCanPlay = true
            currentVideoVC?.isFullScreen = isFullScreen
            currentVideoVC?.didClickedPlayBlock = self.didClickPlayBlock
            //            currentVideoVC?.updateUI()
            if isFullScreen {
                currentVideoVC?.resumePlayer()
            }
        }
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
