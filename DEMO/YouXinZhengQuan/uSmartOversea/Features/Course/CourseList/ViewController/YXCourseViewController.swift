//
//  YXCourseViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXCourseViewController: YXHKViewController {
    
    var viewModel: YXCourseViewModel!
    
    let emptyButtonAction = PublishSubject<()>.init()
    
    var bannerResult: [YXActivityBannerModel]?
    
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader()
    }()
    
    lazy var cycleScrollView: YXCycleScrollView = {
        let banner = YXCycleScrollView(frame: CGRect.zero, delegate: self, placeholderImage: UIImage.init(named: "course_banner_placeholder"))
        banner?.showPageControl = false
        banner?.layer.cornerRadius = 12
        banner?.layer.masksToBounds = true
        return banner ?? YXCycleScrollView()
    }()
    
    private lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.isHidden = true
        pageControl.spacingBetweenDots = 4
        pageControl.isUserInteractionEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        let dotSize = CGSize(width: 8, height: 2)
        var selectedColor = UIColor.qmui_color(withHexString: "#FF8B00")
        var normalColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        pageControl.currentDotImage = UIImage.qmui_image(with: selectedColor, size: CGSize(width: 12, height: 4), cornerRadius: 2)
        pageControl.dotImage = UIImage.qmui_image(with: normalColor, size: CGSize(width: 4, height: 4), cornerRadius: 2)
        return pageControl
    }()
    
    lazy var banner: UIView = {
        let view = UIView()
        view.frame = .zero
//        view.addSubview(cycleScrollView)
//        view.addSubview(pageControl)
//        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 186)
//        cycleScrollView.snp.makeConstraints { make in
//            make.top.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
//            make.bottom.equalToSuperview()
//        }
//        pageControl.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-8)
//        }
        return view
    }()
    
    
    fileprivate lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView(delegate: self)
        tabPageView.mainTableView.backgroundColor = .clear
        return tabPageView
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 8
        tabLayout.tabMargin = 0
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 4
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 22, weight: .semibold)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)

        tabView.pageView = pageView
        tabView.delegate = self
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    override func didInitialize() {
        super.didInitialize()        
        initInput()
    }
    
    func initInput() {
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        
        viewModel = YXCourseViewModel(input: (viewDidLoad: viewDidLoad,
                                              reload: emptyButtonAction.asDriver(onErrorJustReturn: ()),
                                              refresh: refreshHeader.rx.refreshing.asDriver()))
    }
    
    override var pageName: String {
            return "Course"
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView?.titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleView?.titleLabel.textColor = QMUITheme().textColorLevel1()
        titleView?.title = YXLanguageUtility.kLang(key: "nbb_course")
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        
        view.addSubview(tabPageView)
        
        tabPageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(YXConstant.navBarHeight())
//            make.top.equalTo(tabView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
           // make.left.right.top.bottom.equalToSuperview()
        }
        
        tabPageView.mainTableView.mj_header = refreshHeader
    }

    
    func bindViewModel() {
        
      //  viewModel.activity.drive(loadingHUD.rx.isShowNetWorkLoading).disposed(by: disposeBag)
        
        viewModel.allCourse.drive { [weak self]courseResModel in
            guard let `self` = self else { return }
            if let model = courseResModel, let list = model.list, list.count > 0 {
                var titles: [String] = []
                var viewControllers: [YXCourseListTabViewController] = []
                
                for item in list {
                    titles.append(item.categoryName ?? "--")
                    
                    let vc = YXCourseListTabViewController()
                    vc.viewModel.primaryCategory = item.categoryId
                    
                    if item.list?.count ?? 0 > 0 {
                        vc.viewModel.tabList = item.list
                    }else {
                        vc.viewModel.tabList = [YXCourseItem()]
                    }
                    
                    viewControllers.append(vc)
                    
                }
               
                self.refreshHeader.endRefreshing()
                self.tabView.titles = titles
                self.tabView.reloadData()
                self.pageView.viewControllers = viewControllers
                self.pageView.reloadData()
                self.tabPageView.reloadData()
    
            }else {
                self.refreshHeader.endRefreshing()
                

                if let model = courseResModel, let list = model.list, list.count == 0 {
                    self.showNoDataEmptyView()
                }else {
                    if self.pageView.viewControllers.count == 0 {
                        self.showErrorEmptyView()
                    }
                }
                
            }
            
        }.disposed(by: disposeBag)
        
//        viewModel.banner.drive { [weak self] res in
//            guard let `self` = self else { return }
//            if let models = res {
//                self.pageControl.numberOfPages = models.count
//                self.cycleScrollView.imageURLStringsGroup = models.compactMap{$0.img}
//                self.bannerResult = models
//                self.tabPageView.reloadData()
//            }
//        }.disposed(by: disposeBag)
        
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return false
    }
    
    override func emptyRefreshButtonAction() {
        self.hideEmptyView()
        emptyButtonAction.onNext(())
    }
    
    override func layoutEmptyView() -> Bool {
        super.layoutEmptyView()
        var rect = self.emptyView?.frame
        let originy = self.emptyView?.frame.origin.y
        rect?.origin.y = (originy ?? 0) + 34
        self.emptyView?.frame = rect ?? CGRect.zero
        if let emptyH =  self.emptyView?.frame.size.height, let contentH = self.emptyView?.sizeThatContentViewFits().height {
            self.emptyView?.verticalOffset = -((emptyH - contentH)/2 - 40)
        }
        return true
    }
    
}

extension YXCourseViewController: YXTabPageViewDelegate{
        
    func headerViewInTabPage() -> UIView {
        return banner
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        return bannerResult == nil ? 0 : 186
    }
    
    func tabViewInTabPage() -> YXTabView {
        return tabView
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        return 46
    }
    
    func pageViewInTabPage() -> YXPageView {
        return pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return self.view.bounds.size.height - 48 - YXConstant.navBarHeight()
    }
    
}

extension YXCourseViewController:YXTabViewDelegate{
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        
        if pageView.viewControllers.count >= 5 {
            if index == 0{
                self.trackViewClickEvent(name: "Stock Course_Tab")
            }else if index == 1{
                self.trackViewClickEvent(name: "Fund Course_Tab")
            }else if index == 2{
                self.trackViewClickEvent(name: "Stagging Course_Tab")
            }else if index == 3{
                self.trackViewClickEvent(name: "Derivatives Course_Tab")
            }else if index == 4{
                self.trackViewClickEvent(name: "Rookie Course_Tab")
            }
        }
    }
}

extension YXCourseViewController: YXCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didScrollTo index: Int) {
        pageControl.currentPage = index
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if let bannerModel = bannerResult?[index], let url = bannerModel.redirectPosition {
            if bannerModel.redirectMethod == 2 {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: url)
            }
        }

    }
    
}
