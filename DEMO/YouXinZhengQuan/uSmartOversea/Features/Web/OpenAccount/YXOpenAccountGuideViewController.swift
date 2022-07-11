//
//  YXOpenAccountGuideViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import WebKit
import YXKit
import MJRefresh
import QMUIKit

class YXOpenAccountGuideViewController: YXWebViewController {
    var adImageUrls: [String]?
    var adTexts: [String]?
    
    var adList: [YXAdListModel]?
    
    lazy var adView: UIView = {
        let view = UIView()
       view.backgroundColor = QMUITheme().foregroundColor()
//         view.layer.cornerRadius = 10
//         view.layer.qmui_maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        

        view.addSubview(cycleScrollView)
        
        cycleScrollView.snp.makeConstraints({ (make) in
            make.left.top.equalTo(view)
            make.height.equalTo(uniVerLength(76))
            make.right.equalTo(view).offset(20)
        })
       
       let closeButton = UIButton.init(type: .custom)
       closeButton.setImage(UIImage.init(named: "icon_banner_close"), for: .normal)
       view.addSubview(closeButton)

       closeButton.snp.makeConstraints({ (make) in
           make.right.equalTo(view).offset(-8)
           make.top.equalTo(view).offset(8)
           make.height.equalTo(20)
           make.width.equalTo(20)
       })
       closeButton.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
           UIView.animate(withDuration: 0.5, animations: {
               self?.adView.snp.updateConstraints({ (make) in
                   make.height.equalTo(0)
               })
               self?.adView.isHidden = true
               self?.view.layoutIfNeeded()
           }, completion: { (finished) in
              if finished {
                let vm = self?.viewModel as! YXOpenAccountGuideViewModel
                vm.closeOtherAd()
                  //self?.getBanner()
              }
           })
       }).disposed(by: disposeBag)
        
        return view
    }()
    
//    lazy var cycleScrollView: YXCycleScrollView = {
////        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: uniVerLength(76)))
//        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: uniVerLength(76)), delegate: self, placeholderImage: UIImage.init(named: "banner_placeholder"))!
//        scrollView.backgroundColor = .clear
//        scrollView.delegate = self;
//        scrollView.titleLabelBackgroundColor = .clear
//        scrollView.titleLabelTextColor = QMUICMI().textColorLevel1()
//        scrollView.titleLabelTextFont = .systemFont(ofSize: 13)
//        scrollView.scrollDirection = .horizontal
//        //scrollView.onlyDisplayText = true
//        //scrollView.onlyDisplayTextWithImage = true
//        scrollView.showPageControl = true
//        scrollView.autoScrollTimeInterval = 3
////        scrollView.disableScrollGesture()
//
////        scrollView.placeholderImage = UIImage.init(named: "banner_placeholder")
////        scrollView.bannerImageViewContentMode = .scaleAspectFill
//
//        return scrollView
//    }()
    lazy var cycleScrollView: YXImageBannerView = {
//         let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: uniVerLength(76)))
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: uniVerLength(76))
        let banner = YXImageBannerView(frame: rect, delegate: self, placeholderImage: UIImage(named: "placeholder_4bi1"))!
//        banner.layer.cornerRadius = 4
//        banner.clipsToBounds = true
        banner.autoScrollTimeInterval = 3
        return banner
    }()
    
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewModel()
        setupNavigationBar()
        
//        self.titleView?.title = YXLanguageUtility.kLang(key: "open_account_title")
        
        // 添加快捷导航手势
//        YXShortCutsManager.shareInstance.shortCutsVC.addScreenEdgePanGesture(inView: self.navigationController?.view ?? self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.addNavUserBtn()
        // 每次进入到该页面都尝试获取最新的用户信息，用来确定是否该进入持仓界面了
        if YXUserManager.isLogin() {
            YXUserManager.getUserInfo(postNotification: false, complete: {
                // 如果发现用户的状态已经变为如下状态之一，则发出通知
                // 1.当用户的入金状态已经成功
                // 2.当用户的开户状态已经成功，并且是非大陆用户
                if YXUserManager.canTrade() {
                    NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                }

            })
        }
        
        self.setTabbarVisibleIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
//
//    override func navigationBarBackgroundImage() -> UIImage? {
//        UIImage(named: "home_navbar_bg")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
//    }
//
//    override func titleViewTintColor() -> UIColor? {
//        return UIColor.white
//    }
//
    func setupViewModel() {
        let vm = self.viewModel as! YXOpenAccountGuideViewModel

        vm.adListRelay.asDriver().skip(1).drive(onNext: { [weak self] (adList) in
            if adList.count > 0 {
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(uniVerLength(76))
                }
                self?.adView.isHidden = false
                var adImageUrls = [String]()
                let adTexts = [String]()
                adList.forEach({ (model) in
                    adImageUrls.append(model.pictureURL ?? "")
                    //adTexts.append(model.copywriting ?? "")
                })
                self?.adImageUrls = adImageUrls
                self?.adTexts = adTexts
                self?.cycleScrollView.imageURLStringsGroup = adImageUrls
                self?.cycleScrollView.titlesGroup = adTexts
            } else {
                self?.adView.isHidden = true
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                //self?.getBanner()
            }

        }).disposed(by: disposeBag)
    }

    
    override func setupNavigationBar() {

        self.navigationItem.leftBarButtonItems = nil
        
        let messageBtn = QMUIButton()
        messageBtn.setImage(UIImage(named: "message"), for: .normal)
        messageBtn.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        messageBtn.qmui_tapBlock = { [weak self] _ in
            self?.trackViewClickEvent(name: "Message_Tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_BROKERS_MSG_CENTER_URL())
        }
        messageBtn.rx.observeWeakly(YXMessageButton.self, "brokerRedIsHidden").subscribe {[weak messageBtn] _ in
            messageBtn?.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        }.disposed(by: disposeBag)
        messageBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let spaceItem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = 16
        
        let spaceItem12 = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem12.width = 12
        
        let searchBtn = QMUIButton()
        searchBtn.setImage(UIImage(named: "market_search"), for: .normal)
        searchBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }

            self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
            self.trackViewClickEvent(name: "Search_Tab")
        }
        searchBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let searchBarButtonItem = UIBarButtonItem(customView: searchBtn)
        
        navigationItem.rightBarButtonItems = [spaceItem12, UIBarButtonItem(customView: messageBtn), spaceItem, searchBarButtonItem]

    }
    
    override func bottomGap() -> CGFloat {
        YXConstant.tabBarHeight()
    }

//    override func setupWebView() {
//        super.setupWebView()
//
//        self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - self.bottomGap())
//    }
    
    override func setupWebView() {
        super.setupWebView()
        
//        self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - self.bottomGap())
        
        view.addSubview(adView)

        adView.isHidden = true
        adView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(YXConstant.navBarHeight())
            make.height.equalTo(0)
        }
        
        self.webView?.snp.updateConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.adView.snp.bottom)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarHeight())
        })
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        
        if let url = URL.init(string: YXH5Urls.YX_OPEN_ACCOUNT_APPLY_URL()) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        super.webView(webView, didFinish: navigation)
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
        let vm = self.viewModel as! YXOpenAccountGuideViewModel
        vm.requestOptionalOtherAdData()
        YXPopManager.shared.checkPop(with: YXPopManager.showPageAccount, vc: self)
    }
    
    override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        super.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
    }


}

extension YXOpenAccountGuideViewController: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        let vm = self.viewModel as! YXOpenAccountGuideViewModel
        if index < vm.adListRelay.value.count {
            let model = vm.adListRelay.value[index]
//            let type = model.jumpType ?? 0
            let url = model.jumpURL ?? ""
            if url.count > 0 {
                YXBannerManager.goto(withBanner: model, navigator: self.viewModel.navigator)
            }
        }
    }
    
//    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
//        YXAdCycleViewCell.self
//    }
    
//    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {
//        let vm = self.viewModel as! YXOpenAccountGuideViewModel
//        if let cell = cell as? YXAdCycleViewCell, index < vm.adListRelay.value.count  {
//            if let url = URL(string: adImageUrls?[index] ?? "") {
//                let transformer = SDImageResizingTransformer(size: CGSize(width: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_WIDTH * UIScreen.main.scale, height: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
////                cell.iconView.sd_setImage(with: url, placeholderImage: UIImage.init(named: "banner_placeholder"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
//            }
//        }
//    }
}
