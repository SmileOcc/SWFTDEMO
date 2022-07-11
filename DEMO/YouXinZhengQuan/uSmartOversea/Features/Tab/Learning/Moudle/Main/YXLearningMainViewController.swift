//
//  YXLearningMainViewController.swift
//  uSmartOversea
//
//  Created by wangfengnan on 2022/3/17.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit


class YXLearningMainViewController: YXHKViewController, ViewModelBased {
    
    var viewModel: YXLearningMainViewModel!
    
    override var pageName: String {
        return "大咖页"
    }
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 0
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 4
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 22, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.delegate = self
        tabView.pageView = pageView;
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var learningVC: YXLearningViewController = {
        let vc = YXLearningViewController.instantiate(withViewModel: YXLearningViewModel(), andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var videoVC: YXShortVideoIndexViewController = {
        return YXShortVideoIndexViewController()
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name("FirstInNoScribe")).subscribe { [weak self]noti in
            self?.tabView.selectTab(at: 1)
        }.disposed(by: disposeBag)

        
        view.backgroundColor = QMUITheme().foregroundColor()
        
        tabView.titles = [YXLanguageUtility.kLang(key: "tab_expert"), "BeeRich"]
        pageView.viewControllers = [learningVC,videoVC]
        
        navigationItem.titleView = tabView

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

        let searchBtn = QMUIButton()
        searchBtn.setImage(UIImage(named: "market_search"), for: .normal)
        searchBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
            self.trackViewClickEvent(name: "Search_Tab")
        }
        searchBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let searchBarButtonItem = UIBarButtonItem(customView: searchBtn)

        navigationItem.rightBarButtonItems = [buildSpaceItem(12), UIBarButtonItem(customView: messageBtn), buildSpaceItem(16), searchBarButtonItem]
        
        view.addSubview(pageView)
        view.bringSubviewToFront(tabView)
        
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }


    private func buildSpaceItem(_ width: CGFloat) -> UIBarButtonItem {
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = width
        return spaceItem
    }

}

extension YXLearningMainViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        self.trackViewClickEvent(name: tabView.titles[Int(index)]+"tab")
    }
}
