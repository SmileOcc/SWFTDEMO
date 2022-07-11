//
//  YXNewStockCenterViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

enum YXNewStockCenterTab: Int {
    // 已递表
    case delivered = 0
    // 认购中
    case purchasing
    // 待上市
    case preMarket
    // 已上市
    case marketed
    
    var text: String {
        switch self {
        case .delivered:
            return YXLanguageUtility.kLang(key: "delivered_company")
        case .purchasing:
            return YXLanguageUtility.kLang(key: "newStock_center_purchasing")
        case .preMarket:
            return YXLanguageUtility.kLang(key: "newStock_center_prelist")
        case .marketed:
            return YXLanguageUtility.kLang(key: "newStock_new_market_stock")
        }
    }
}

class YXNewStockCenterViewController: YXHKViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockCenterViewModel! = YXNewStockCenterViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var bannerModel: YXUserBanner!

    var currentExchangeType: YXExchangeType = .hk
    var hasBanner: Bool = false
    var defaultTabViewTab: YXNewStockCenterTab = .purchasing
    let tabviewTabs: [YXNewStockCenterTab] = [.delivered, .purchasing, .preMarket, .marketed]
    var tabViewSelectedTab: YXNewStockCenterTab?
    var currentVC: UIViewController?
    var shouldShowGrayIcon = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true;
        bindHUD()
        setupUI()
        
        tabView.reloadData()
        tabView.selectTab(at: UInt(self.defaultTabViewTab.rawValue))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        headerRereshing()
        queryBannerInfo()
        navigationController?.navigationBar.setBackgroundImage(UIImage.qmui_image(with: currentBackgroudColor), for: .default)
        // 神策事件：开始记录
        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().foregroundColor()), for: .default)
    
    }
    
    var currentBackgroudColor: UIColor = QMUITheme().backgroundColor()
    
    let kTableHeaderViewHeight: CGFloat = ((YXConstant.screenWidth - 18 * 2) / 4.0 + 15 + 10)
    
    
    lazy var headerView: UIView = {
   
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: kTableHeaderViewHeight)
        view.backgroundColor = currentBackgroudColor
        view.addSubview(self.bannerImageView)
        self.bannerImageView.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(kTableHeaderViewHeight - 15 - 10)
        })
        return view
    }()
    
    lazy var bannerImageView: YXImageBannerView = {
        //4:1    UIImage.qmui_image(with: UIColor.gray)!
        let view = YXImageBannerView(frame: CGRect.zero, delegate: self, placeholderImage: UIImage(named: "placeholder_4bi1"))!
        view.isUserInteractionEnabled = true
        view.autoScrollTimeInterval = 10.0
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView.init(delegate: self)
        if #available(iOS 11.0, *) {
            tabPageView.mainTableView.contentInsetAdjustmentBehavior = .automatic
        } else {
            // Fallback on earlier versions
        }
        tabPageView.mainTableView.backgroundColor = UIColor.clear
        
        return tabPageView
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.linePadding = 1
        tabLayout.lineColor = QMUITheme().themeTextColor()
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.titles = self.tabviewTabs.map({ (tabType) -> String in
            return tabType.text
        })
        tabView.delegate = self
        
        let line = UIView.line()
        tabView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        pageView.viewControllers = [self.deliverViewController, self.purchasingViewController, self.preMarketViewController, self.hkmarketedViewController]
        
        return pageView
    }()
    
    lazy var deliverViewController: YXNewStockDeliveredViewController = {
        let vc = YXNewStockDeliveredViewController()
        vc.viewModel.navigator = self.viewModel.navigator
        return vc
    }()
    
    lazy var purchasingViewModel: YXNewStockPreMarketViewModel = {
        let vm = YXNewStockPreMarketViewModel.init(services: viewModel.navigator, params: ["YXNewStockStatus" : NSNumber.init(value: YXNewStockStatus.purchase.rawValue)])
        vm.totalNewStockAmount = { [weak self](total) in
            guard let `self` = self else { return }
            self.tabView.titles = self.tabviewTabs.map({ (tabType) -> String in
                if tabType == .purchasing {
                    return tabType.text + "(\(total))"
                }
                return tabType.text
            })
            self.tabView.reloadDataKeepOffset()
        }
        return vm
    }()
    
    lazy var purchasingViewController: YXNewStockPreMarketViewController = {
        
        let vc = YXNewStockPreMarketViewController.init(viewModel: self.purchasingViewModel)
        return vc ?? YXNewStockPreMarketViewController()
    }()
    
    lazy var preMarketViewController: YXNewStockPreMarketViewController = {
        let vm = YXNewStockPreMarketViewModel.init(services: viewModel.navigator, params: ["YXNewStockStatus" : NSNumber.init(value: YXNewStockStatus.preMarket.rawValue)])
        // 需要提前请求数据以确定是否有暗盘标签
        vm.requestRemoteDataCommand.execute(NSNumber(value: 1))
        vm.hasGrayBlock = { [weak self](hasGray) in
            guard let `self` = self else { return }
            self.shouldShowGrayIcon = hasGray
            self.tabView.reloadDataKeepOffset()
        }
        let vc = YXNewStockPreMarketViewController.init(viewModel: vm)
        return vc
    }()
    
    lazy var hkmarketedViewController: YXNewStockMarketViewController = {
        let vc = YXNewStockMarketViewController()
        vc.viewModel.market = YXMarketType.HK.rawValue
        vc.viewModel.navigator = self.viewModel.navigator
        return vc
    }()
    
    lazy var usmarketedViewController: YXNewStockMarketViewController = {
        let vc = YXNewStockMarketViewController()
        vc.viewModel.market = YXMarketType.US.rawValue
        vc.viewModel.navigator = self.viewModel.navigator
        return vc
    }()
    
    lazy var popover: YXStockPopover = {
        let popover = YXStockPopover()
        
        return popover
    }()
    
    lazy var purchasingMenuView: UIView = {
        return creatMenuView()
    }()
    
    lazy var marketedMenuView: UIView = {
        return creatMenuView()
    }()
    
    lazy var grayIcon: UIImage = {
        
        let label = UILabel.gray()
        label?.text = YXLanguageUtility.kLang(key: "grey_mkt")
        label?.frame = CGRect.init(x: 0, y: 0, width: 22.5, height: 15)
        return UIImage.qmui_image(with: label ?? UILabel()) ?? UIImage()
    }()
    
    func creatMenuView() -> UIView {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: 87, height: 94)
        
        let hkButton = creatButton(with: YXMarketType.HK.name)
        hkButton.isSelected = true
        
        let usButton = creatButton(with: YXMarketType.US.name)
        usButton.rx.tap.subscribe(onNext: { (e) in
            
        }).disposed(by: disposeBag)
        
        hkButton.rx.tap.subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
            self.popover.dismiss()
            if hkButton.isSelected {
                return
            }
            hkButton.isSelected = true
            usButton.isSelected = false
            
            if self.tabViewSelectedTab == .purchasing {
                self.purchasingViewModel.exchangeType = 0
                self.purchasingViewController.loadFirstPage()
            }else {
                self.pageView.viewControllers = [self.deliverViewController, self.purchasingViewController, self.preMarketViewController, self.hkmarketedViewController]
                self.tabPageView.reloadData()
            }
            
            
        }).disposed(by: disposeBag)
        
        usButton.rx.tap.subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
            self.popover.dismiss()
            if usButton.isSelected {
                return
            }
            hkButton.isSelected = false
            usButton.isSelected = true
            
            if self.tabViewSelectedTab == .purchasing {
                self.purchasingViewModel.exchangeType = 5
                self.purchasingViewController.loadFirstPage()
            }else {
                self.pageView.viewControllers = [self.deliverViewController, self.purchasingViewController, self.preMarketViewController, self.usmarketedViewController]
                self.tabPageView.reloadData()
            }
            
        }).disposed(by: disposeBag)
        
        let line = UIView.line()
        
        view.addSubview(hkButton)
        view.addSubview(line)
        view.addSubview(usButton)
        
        hkButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        usButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        
        line.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        }
        
        
        return view
    }
    
    func creatButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        return button
    }
    
    func setupUI() {
        
        self.title = YXLanguageUtility.kLang(key: "newStock_center")
        self.view.backgroundColor = currentBackgroudColor
        self.initNavigationBar()
        
        view.addSubview(tabPageView)
        
        tabPageView.snp.makeConstraints { (make) in
//            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.top.equalToSuperview()
            make.right.left.bottom.equalToSuperview()
        }
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            self?.queryBannerInfo()
            if let vc = self?.currentVC as? YXNewStockDeliveredViewController {
                if let refreshingBlock =  vc.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
            }else if let vc = self?.currentVC as? YXNewStockMarketViewController {
                if let refreshingBlock =  vc.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
            }
            self?.tabPageView.mainTableView.mj_header.endRefreshing()
        }
        
        tabPageView.mainTableView.mj_header = refreshHeader
        
        tabPageView.reloadData()
    }

}

//MARK: Initialize UI
extension YXNewStockCenterViewController {
    
    fileprivate func initNavigationBar() {

        let recordText = YXLanguageUtility.kLang(key: "newStock_purchase_list")
        let width = (recordText as NSString).boundingRect(with: CGSize(width: 200, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).width
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: width + CGFloat(2), height: 20))
        button.setTitle(recordText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        let recordItem = UIBarButtonItem.init(customView: button)
        navigationItem.rightBarButtonItems = [messageItem, recordItem]
        
        button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if YXUserManager.isLogin() {
                let type: YXExchangeType = self.currentExchangeType
                self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
            } else {
                let callback: (([String: Any])->Void)? = { [weak self] _ in
                    guard let `self` = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                        let type: YXExchangeType = self.currentExchangeType
                        self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
                    })
                }
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: self))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
            }.disposed(by: disposeBag)
    }
}

extension YXNewStockCenterViewController: YXTabPageViewDelegate {
    func headerViewInTabPage() -> UIView {
        if self.hasBanner {
            return self.headerView
        }else {
            return UIView()
        }
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        if self.hasBanner {
            return kTableHeaderViewHeight
        }else {
            return 0
        }
    }
    
    func tabViewInTabPage() -> YXTabView {
        return self.tabView
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        return 40
    }
    
    func pageViewInTabPage() -> YXPageView {
        return self.pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return self.view.bounds.size.height
    }
}

extension YXNewStockCenterViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        self.currentVC = self.pageView.viewControllers[Int(index)]
        let tab = self.tabviewTabs[Int(index)]
        
        if tab == .purchasing {
            if tab == tabViewSelectedTab {
                self.popover.show(self.purchasingMenuView, from: self.tabView.getArrowView(at: index))
            }
        }else if tab == .marketed {
            if tab == tabViewSelectedTab {
                self.popover.show(self.marketedMenuView, from: self.tabView.getArrowView(at: index))
            }
        }
        
        tabViewSelectedTab = tab
    }
    
    func tabView(_ tabView: YXTabView, imageForItemAt index: UInt) -> UIImage {
        if index == 1 || index == 3 {
            return UIImage.init(named: "down_arrow_grey") ?? UIImage()
        }else if index == 2, shouldShowGrayIcon {
            return grayIcon
        }else {
            return UIImage()
        }
    }
}

extension YXNewStockCenterViewController: YXCycleScrollViewDelegate {
    
    //广告页
    func queryBannerInfo() {

        viewModel.newsService.request(.userBanner(id: .newStock), response: { [weak self](response) in
            
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if let code = code, code == .success, let model = result.data, model.dataList?.count ?? 0 > 0 {

                    self.bannerModel = model
                    var arr = [String]()
                    for news in model.dataList ?? [] {
                        arr.append(news.pictureURL ?? "")
                    }
                    self.bannerImageView.imageURLStringsGroup = arr
                    self.hasBanner = true
                    
                    self.tabPageView.reloadData()
                    
                    
                } else {
                    self.hasBanner = false
                    self.bannerImageView.imageURLStringsGroup = []
                    self.tabPageView.reloadData()
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                self.hasBanner = false
                self.bannerImageView.imageURLStringsGroup = []
                self.tabPageView.reloadData()
            }
            
            } as YXResultResponse<YXUserBanner>).disposed(by: YXUserManager.shared().disposeBag)
        
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if bannerModel != nil, index < bannerModel.dataList?.count ?? 0 {
            if !(bannerModel.dataList?[index].jumpURL?.isEmpty ?? true) {//bannerModel.bannerList[index].jumpURL?.count ?? 0 > 0
                YXBannerManager.goto(withBanner: bannerModel.dataList![index], navigator: self.viewModel.navigator)
            }
            
        }
    }
}
