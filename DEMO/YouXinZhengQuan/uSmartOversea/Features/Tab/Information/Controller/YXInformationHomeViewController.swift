//
//  YXNewsHomeViewController.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


extension YXTabLayout {
    
    func configMainPageUI() {
        
        lineHidden = false
        leftAlign = true
        lineHeight = 28
        lineCornerRadius = 14
        
        linePadding = 6
        lineWidth = 0
        titleFont = .systemFont(ofSize: 14)
        titleSelectedFont = .systemFont(ofSize: 14, weight: .medium)
        
//        if YXUserManager.getSkinType() == .pureWhite {
//            lineColor = UIColor.white.withAlphaComponent(0.2)
//            titleColor = UIColor.white.withAlphaComponent(0.6)
//            titleSelectedColor = .white
//        } else {
            lineColor = QMUITheme().separatorLineColor()
            titleColor = QMUITheme().textColorLevel2()
            titleSelectedColor = QMUITheme().textColorLevel1()
//        }
    }
}

@objc public enum YXInfomationIndex: Int {
    case hot            = 0         //热门
    case news           = 1         //资讯
    case video          = 2         //影片
    case fastNews       = 3         //7x24快讯
    case subscribe      = 4         //已订阅
    case follow         = 6         //关注
    case calendar       = 7         //日历
}

class YXInformationHomeViewController: YXHKTableViewController, ViewModelBased {

    typealias ViewModelType = YXInformationHomeViewModel
    var viewModel: YXInformationHomeViewModel! = YXInformationHomeViewModel.init()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
        
    var lastTabIndex: UInt = 0
    
    var guideView: YXStockDetailGuideView?
    
    lazy var tabContainerView: UIView = {
        let view = UIView()
//        view.backgroundColor = YXUserManager.getSkinType() == .skyBlack ? QMUITheme().foregroundColor() : UIColor.qmui_color(withHexString: "#20619D")
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
        
    lazy var tabView: YXTabView = {
        
        let tabLayout = YXTabLayout.default()
        tabLayout.configMainPageUI()
        let scale = YXConstant.screenWidth / 375.0
        tabLayout.tabMargin = 12 * scale
        tabLayout.tabPadding = 12 * scale
        
        tabLayout.lineHidden = true
        tabLayout.lrMargin = 16
        tabLayout.lineCornerRadius = 12.5
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 0
        tabLayout.titleFont = .systemFont(ofSize: 14)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 14)
        tabLayout.tabCornerRadius = 4
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.tabColor = QMUITheme().foregroundColor()
        tabLayout.tabSelectedColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        tabLayout.titleSelectedColor = QMUITheme().mainThemeColor()
        
        let tabView = YXTabView(frame: CGRect(x: 8, y: 0, width: view.bounds.width - 138, height: 28), with: tabLayout)
        tabView.titles = [YXLanguageUtility.kLang(key: "news_watchlist"),
                          YXLanguageUtility.kLang(key: "news_recommend"),
                          YXLanguageUtility.kLang(key: "news_market_us"),
                          YXLanguageUtility.kLang(key: "news_market_sg"),
                          YXLanguageUtility.kLang(key: "news_market_hk"),
                          ]
        tabView.pageView = self.pageView
        tabView.delegate = self
        tabView.layer.borderWidth = 0
//        tabView.backgroundColor = YXUserManager.getSkinType() == .skyBlack ? QMUITheme().foregroundColor() :  UIColor.qmui_color(withHexString: "#20619D")
        tabView.backgroundColor = QMUITheme().foregroundColor()
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = true
        return pageView
    }()
    
    private lazy var popover:YXStockPopover = {
        let popover = YXStockPopover()
        return popover
    }()
    
    override func didInitialize() {
        super.didInitialize()        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.strongNoticeView.isHidden = true
        // Do any additional setup after loading the view.
        self.titleView?.title = YXLanguageUtility.kLang(key: "tab_find_title")
        // 初始化
        YXTabInfomationTool.initReadStatusDic()
        
        initUI()
        //刷新一下，否则通过ResetRootView跳过来，会闪退
        tabView.reloadData()
        
        //涨跌颜色更改 监听
//        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateColor))
//            .takeUntil(self.rx.deallocated)
//            .subscribe(onNext: {
//                [weak self] noti in
//                guard let `self` = self else { return }
//                if YXUserManager.curLanguage() != .EN {
//                    //日历
////                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_INFO_CALENDAR_URL()]
////                    let webViewModel = YXWebViewModel(dictionary: dic)
////                    let calendarVC = YXInfoCalendarVC.instantiate(withViewModel: webViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
////                    //重新建一个 【日历】控制器
////                    self.pageView.viewControllers.remove(at: 4)
////                    self.pageView.viewControllers.insert(calendarVC, at: 4)
////                    self.pageView.reloadData()  //让网页重新加载出来
////                }
//            })
        
        // 添加快捷导航手势
//        YXShortCutsManager.shareInstance.shortCutsVC.addScreenEdgePanGesture(inView: self.navigationController?.view ?? self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.addNavUserBtn()
        self.setTabbarVisibleIfNeed()
        
        // huhuaxiang added: 2021年07月21日（屏蔽引导页）
        // self.perform(#selector(self.showGuideView), with: nil, afterDelay: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.guideView?.hidePageGuide()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }    
    
    func initUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()

        self.view.addSubview(tabContainerView)
        self.view.addSubview(self.pageView)
        
        tabContainerView.addSubview(self.tabView)
        
        tabContainerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
//            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.top.equalToSuperview()
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalTo(tabContainerView.snp.centerY)
            make.height.equalTo(28)
            make.right.equalToSuperview().offset(-66)
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabContainerView.snp.bottom)
        }
                
//        let hotVC = YXNewHotMainViewController.init(viewModel: YXNewHotMainViewModel.init(services: viewModel.navigator, params: nil))
        //市场
        let recommendViewModel = YXRecommendViewModel.init()
        let recommendVC = YXRecommendVC.instantiate(withViewModel: recommendViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        
        //自选（我的组合）
        let myGroupViewModel = YXMyGroupInfoViewModel.init()
        let myGroupVC = YXMyGroupInfoVC.instantiate(withViewModel: myGroupViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
                
//        let liveVC = YXLiveListViewController.init(viewModel: YXLiveListViewModel.init(services: viewModel.navigator, params: nil))
        
//        let attentionVC = YXUGCAttentionViewController.init(viewModel: YXUGCAttentionViewModel.init(services: viewModel.navigator, params: nil))
        
        let marketNewsViewModel_us = YXMarketNewsViewModel.init()
        marketNewsViewModel_us.market_str = "us"
        let marketNewsVC_us = YXMarketNewsVC.instantiate(withViewModel: marketNewsViewModel_us, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        
        let marketNewsViewModel_sg = YXMarketNewsViewModel.init()
        marketNewsViewModel_sg.market_str = "sg"
        let marketNewsVC_sg = YXMarketNewsVC.instantiate(withViewModel: marketNewsViewModel_sg, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        
        let marketNewsViewModel_hk = YXMarketNewsViewModel.init()
        marketNewsViewModel_hk.market_str = "hk"
        let marketNewsVC_hk = YXMarketNewsVC.instantiate(withViewModel: marketNewsViewModel_hk, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        
        // 牛人牛股
//        let geniusDic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.DYNAMIC_SUNDRYING_URL()]
//        let geniusWebViewModel = YXWebViewModel(dictionary: geniusDic)
//        let geniusVC = YXGeniusViewController.instantiate(withViewModel: geniusWebViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        
        /*
         tabView.titles = [YXLanguageUtility.kLang(key: "common_news"),
                           YXLanguageUtility.kLang(key: "news_watchlist"),
                           YXLanguageUtility.kLang(key: "news_calendar"),
                           ]
         */
        
        if YXUserManager.isENMode() {
            pageView.viewControllers = [myGroupVC, recommendVC, marketNewsVC_us, marketNewsVC_sg, marketNewsVC_hk]
        } else {
            pageView.viewControllers = [myGroupVC, recommendVC, marketNewsVC_us, marketNewsVC_sg, marketNewsVC_hk]
        }

        let changeBtn = QMUIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 22))
        changeBtn.imagePosition = .left
        changeBtn.setImage(UIImage(named:"news_changeLan"), for: .normal)
        
        changeBtn.spacingBetweenImageAndTitle = 2
        changeBtn.layer.cornerRadius = 2
        changeBtn.layer.borderWidth = 1
        changeBtn.layer.borderColor = QMUITheme().textColorLevel2().cgColor
        changeBtn.clipsToBounds = true
        changeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        changeBtn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        if YXUserManager.isENMode() { //语言 1-简体  2-繁体  3-英文
            changeBtn.setTitle(YXLanguageUtility.kLang(key: "news_change_tab_EN"), for: .normal)
            news_selected_language = 3
        } else {
            changeBtn.setTitle(YXLanguageUtility.kLang(key: "news_change_tab_CN"), for: .normal)
            news_selected_language = 1
        }
        changeBtn.addTarget(self, action: #selector(changeClick(_:)), for: .touchUpInside)
        self.tabContainerView.addSubview(changeBtn)
        changeBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalTo(42)
            make.height.equalTo(18)
        }
    }
    
    func refresh() {
        let index = NSInteger(self.tabView.selectedIndex)
        guard index < self.pageView.viewControllers.count else { return }
        for vc in self.pageView.viewControllers {
            if let vc = vc as? YXHKTableViewController {
                vc.tableView.mj_header?.beginRefreshing()
            }
        }
    }
}

extension YXInformationHomeViewController {
    
    @objc func seachClick(_ sender: UIButton) {
        self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
    }
    
    @objc func changeClick(_ sender: UIButton) {
//        sender.isUserInteractionEnabled = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            sender.isUserInteractionEnabled = true
//        }
        let popList: [Int] = [YXArticleInfoAPILangType.ALL.rawValue, YXArticleInfoAPILangType.CN.rawValue,YXArticleInfoAPILangType.EN.rawValue]
        let view:YXLanguageDetailPopView = YXLanguageDetailPopView.init(list: popList, isWhiteStyle: true) {
            [weak self] type in
            guard let `self` = self else { return }
            
            news_selected_language = type
            let langType = YXArticleInfoAPILangType.init(rawValue: type)
            sender.setTitle(langType?.articleInfoAPILangTypeName, for: .normal)
            
            self.refresh()
            self.popover.dismiss()
        }
        self.popover.show(view, from: sender)

    }
    
    @objc func showGuideView() {
        
        let isShow = MMKV.default().bool(forKey: "YXInfoHomeViewNewFeature", defaultValue: false)
        if !isShow {
            let window = UIApplication.shared.keyWindow!
             
            if let highLightView = self.tabView.collectionView.cellForItem(at: IndexPath.init(row: 1, section: 0)) {
                                  
                let guideView = YXStockDetailGuideView(parentView: window)
                self.guideView = guideView
                guideView.titles = [YXLanguageUtility.kLang(key: "new_guide_live")]
                guideView.highLightViews = [highLightView]
                guideView.showPageGuide(step: 0) {
                    MMKV.default().set(true, forKey: "YXInfoHomeViewNewFeature")
                }
            }
        }
    }
}

extension YXInformationHomeViewController: YXTabViewDelegate {
    
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        ///self.lastTabIndex != index
        /// 为解决：小幅度滑动就会收到调用的问题；
        
        var title = ""
        if index < self.tabView.titles.count {
            title = self.tabView.titles[Int(index)]
        }
        if title == YXLanguageUtility.kLang(key: "news_calendar"), self.lastTabIndex != index, let calendarVC = self.pageView.viewControllers[Int(index)] as? YXInfoCalendarVC {
            
            //tab之间切换时，切到日历控制器，要调用 onPageStatusChange
            calendarVC.onPageStatusChange()
        }
        self.lastTabIndex = index
                
        if title == YXLanguageUtility.kLang(key: "live_video"), let liveVC = self.pageView.viewControllers[Int(index)] as? YXLiveListViewController {
            // 刷新直播
            liveVC.refreshData()
        }

        
        
        var propViewId = ""
        var propViewName = ""
        
        if title == YXLanguageUtility.kLang(key: "news_hot") {
            propViewId = "recommend"
            propViewName = "热门-Tab"
        } else if title == YXLanguageUtility.kLang(key: "common_news") {
            propViewId = "news"
            propViewName = "资讯-Tab"
        } else if title == YXLanguageUtility.kLang(key: "live_video") {
            propViewId = "live"
            propViewName = "影片-Tab"
        } else if title == YXLanguageUtility.kLang(key: "hadSubscribe") {
            propViewId = "subscribed"
            propViewName = "已订阅-Tab"
        } else if title == YXLanguageUtility.kLang(key: "live_follow") {
            propViewId = "followed"
            propViewName = "关注-Tab"
        } else if title == YXLanguageUtility.kLang(key: "news_calendar") {
            propViewId = "calendar"
            propViewName = "日历-Tab"
        } else if title == YXLanguageUtility.kLang(key: "news_watchlist") {
            propViewId = "optional"
            propViewName = "自选-Tab"
        } else if title == YXLanguageUtility.kLang(key: "news_7x24") {
            propViewId = "7*24"
            propViewName = "7*24-Tab"

        } else if title == YXLanguageUtility.kLang(key: "news_course") {
           propViewId = "course"
           propViewName = "课程"

       }
        

        if propViewId.count > 0 {

        }
    }
}


class YXLanguageDetailPopView: UIView {
    
    @objc var popBlock:((_ type:Int) -> Void)?
    
    var popList: [Int] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc convenience init( list:[Int], isWhiteStyle:Bool, clickCallBack:((_ type:Int) -> Void)?) {
        
        self.init(frame: CGRect(x: 0, y: 0, width: 75, height: 40 * list.count))
        self.popBlock = clickCallBack
        self.popList = list
//        self.layer.masksToBounds = true
//        backgroundColor = isWhiteStyle ? .white : QMUITheme().popupLayerColor()
        for (index, type) in list.enumerated() {
            
            let button = QMUIButton()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let titleColor:UIColor = isWhiteStyle ? QMUITheme().textColorLevel1() : QMUITheme().textColorLevel1()
            button.setTitleColor(titleColor, for: .normal)
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            button.tag = index
            button.spacingBetweenImageAndTitle = 8
            button.frame = CGRect(x: 0, y: index * 40, width: Int(frame.size.width), height: 40)
            if type == YXArticleInfoAPILangType.ALL.rawValue {
                button.setTitle(YXArticleInfoAPILangType.ALL.articleInfoAPILangTypeName, for: .normal)
            }else if type == YXArticleInfoAPILangType.CN.rawValue {
                button.setTitle(YXArticleInfoAPILangType.CN.articleInfoAPILangTypeName, for: .normal)
            }else if type == YXArticleInfoAPILangType.EN.rawValue {
                button.setTitle(YXArticleInfoAPILangType.EN.articleInfoAPILangTypeName, for: .normal)
            }
            
            addSubview(button)
            if index < list.count - 1 {
                let lineView = UIView.init(frame: CGRect(x: 6, y: CGFloat((index + 1) * 40), width: (CGFloat(frame.size.width - 12) ), height: CGFloat(0.5)))
                lineView.backgroundColor = QMUITheme().popSeparatorLineColor()
                addSubview(lineView)
            }
            
        }
    }
    
    @objc func buttonClick(_ sender: QMUIButton) {
        let index:Int = sender.tag
        if index < self.popList.count {
            let type: Int = self.popList[index]
            self.popBlock?(type)
        }
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
