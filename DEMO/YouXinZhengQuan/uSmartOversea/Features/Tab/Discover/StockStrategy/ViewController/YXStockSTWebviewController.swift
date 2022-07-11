//
//  YXStockSTWebviewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/1.
//  Copyright © 2020 RenRenDai. All rights reserved.
//
import UIKit
import WebKit
import YXKit
import MJRefresh
import QMUIKit
import RxSwift

import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

class YXStockSTWebViewModel: YXWebViewModel, HasDisposeBag {
    
    static let stockSTWebAd = "stockSTWebAd"

    var adResponse: YXResultResponse<YXUserBanner>?
    
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])
    
    //在需要banner广告的模块定义一个services网络服务，接收到中台banner数据的时候推送adListRelay信号。adListRelay接收到信号后执行。
   override var services: Services! {
        didSet {
            adResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let adList = result.data?.dataList, adList.count > 0 {
                            strongSelf.adListRelay.accept(adList)
                        } else {
                            strongSelf.adListRelay.accept([])
                        }
                    default:
                        strongSelf.adListRelay.accept([])
                        break
                    }
                case .failed(_):
                    strongSelf.adListRelay.accept([])
                    break
                }
            }
        }
    }
    
    func requestOptionalOtherAdData() {
        let oldTime = MMKV.default().double(forKey: YXStockSTWebViewModel.stockSTWebAd, defaultValue: 0)
        let nowTime = Double(NSDate.beginOfToday().timeIntervalSince1970)
        if nowTime - oldTime > Double(24 * 60 * 60) {
            services.newsService.request(.userBannerV2(id: .disover), response: adResponse).disposed(by: disposeBag)
        } else {
            adListRelay.accept([])
        }
    }
    
    func closeOtherAd() {
        MMKV.default().set(Double(NSDate.beginOfToday().timeIntervalSince1970), forKey: YXStockSTWebViewModel.stockSTWebAd)
    }
}

class YXStockSTWebviewController: YXWebViewController {

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
                let vm = self?.viewModel as! YXStockSTWebViewModel
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
//
//        scrollView.backgroundColor = .clear
////        scrollView.delegate = self;
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
        self.titleView?.title = YXLanguageUtility.kLang(key: "tab_stock_title")
        self.setupViewModel()

        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateColor))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] noti in
                guard let `self` = self else { return }
                self.updateUserAgent()
            })
        
        // 添加快捷导航手势
//        YXShortCutsManager.shareInstance.shortCutsVC.addScreenEdgePanGesture(inView: self.navigationController?.view ?? self.view)
        //弹框
//        YXPopManager.shared.checkPop(with: YXPopManager.showPageStategy, vc: self)
        YXProgressHUD.showLoading(YXLanguageUtility.kLang(key:"common_loading_with_dot"), in: self.view)

    }
    
    override var pageName: String {
          return "Opportunity"
    }
    
    func setupViewModel() {
        let vm = self.viewModel as! YXStockSTWebViewModel

        //adListRelay订阅信号的实现，banner广告展示
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


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.addNavUserBtn()
        self.setTabbarVisibleIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.cyl_clearBadge()
        YXRedDotHelper.shareInstance.updateCacheTime(with: .investSmarter)
//        //检查弹框
//        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageStategy, vc: self)
    }
    
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//    override func navigationBarBackgroundImage() -> UIImage? {
//        UIImage(named: "home_navbar_bg")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
//    }
//
//    override func titleViewTintColor() -> UIColor? {
//        return UIColor.white
//    }
//
//    override func qmui_navigationBarTintColor() -> UIColor? {
//        return UIColor.white
//    }

    override func setupNavigationBar() {
        // FIXME: 此处发现在iOS11以下如果设置过leftBarButtonItems之后，再对leftBarButtonItems设置nil就不会生效;因此在iOS11以下不调用super去设置leftBarButtonItems
        if #available(iOS 11.0, *) {
            super.setupNavigationBar()
        }

        self.navigationItem.leftBarButtonItems = nil
    }

    override func bottomGap() -> CGFloat {
        YXConstant.tabBarHeight()
    }
    
    override func setupWebView() {
        super.setupWebView()
        
//        self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - self.bottomGap())
        
        view.addSubview(adView)

        adView.isHidden = true
        adView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
//            make.top.equalTo(YXConstant.navBarHeight())
            make.top.equalToSuperview()
            make.height.equalTo(0)
        }
        
        self.webView?.snp.updateConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.adView.snp.bottom)
            make.bottom.equalToSuperview()
        })
    }
    
    //重写这个方法防止切换tab页面触发的旋转rac回调，导致的webview大小改变
    override func webViewFrame() -> CGRect {
        return self.webView?.frame ?? CGRect.zero
    }

    
    override func addRealWebView() {
        super.addRealWebView()
        self.progressView?.isHidden = true
    }
    
    func getRedDotData() {
        YXRedDotHelper.shareInstance.getRedDotData(with: .investSmarter) {
            self.cyl_showBadge()
        }
    }
    
   override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super .webView(webView, didFinish: navigation)
        let vm = self.viewModel as! YXStockSTWebViewModel
        vm.requestOptionalOtherAdData()
//    YXPopManager.shared.checkPop(with: YXPopManager.showPageStategy, vc: self)
        YXProgressHUD.hide(for: self.view, animated: true)

    }
}


extension YXStockSTWebviewController: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {

        let vm = self.viewModel as! YXStockSTWebViewModel
        if index < vm.adListRelay.value.count {
            let model = vm.adListRelay.value[index]
//            let type = model.jumpType ?? 0
            let url = model.jumpURL ?? ""
            if url.count > 0 {
                if let bannerID = model.bannerID{
                    self.trackViewClickEvent(name: "Banner_Tab",other:["banner_id":String(bannerID)])
                }
                YXBannerManager.goto(withBanner: model, navigator: self.viewModel.navigator)
            }
        }
    }
    
//    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
//        YXAdCycleViewCell.self
//    }
    
//    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {
//        let vm = self.viewModel as! YXStockSTWebViewModel
//        if let cell = cell as? YXAdCycleViewCell, index < vm.adListRelay.value.count  {
//            if let url = URL(string: adImageUrls?[index] ?? "") {
//                let transformer = SDImageResizingTransformer(size: CGSize(width: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_WIDTH * UIScreen.main.scale, height: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
////                cell.iconView.sd_setImage(with: url, placeholderImage: UIImage.init(named: "banner_placeholder"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
//            }
//        }
//    }
}
