//
//  YXCommunityViewController.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/10.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
import IGListKit

class YXCommunityViewController: YXHKViewController, HUDViewModelBased, UICollectionViewDelegate {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXCommunityViewModel!
    
    var page = 1
    var page_size = 20
    var query_token = ""
    var local = true //发现-社区模块默认请求值要改成-新加坡
    var scrollCallBack: YXTabPageScrollBlock?

    var dataSource:[ListDiffable] = []
    
    lazy var headerView: YXCommunityHeaderView = {
        let view = YXCommunityHeaderView.init(selectIndex: YXDiscussionSelectedType.singaporeTab.rawValue)
        view.selectCallBack = { [weak self] (index) in
            guard let self = `self` else { return }
            
            if index == 0 {
                self.local = false
                self.trackViewClickEvent(name: "Global_Tab")

            } else if index == 1 {
                self.local = true
                self.trackViewClickEvent(name: "Singapore_Tab")
            }
            self.loadHotCommentData(ismore: false)

        }
        return view
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
//        layout.headerReferenceSize = CGSizeMake(YXConstant.screenWidth, 45)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = QMUITheme().foregroundColor()
//        let refreshHeader = YXRefreshHeader()
//        refreshHeader.refreshingBlock = { [weak self] in
//            guard let self = `self` else { return }
//            self.loadHotCommentData(ismore: false)
//        }
//        collectionView.mj_header = refreshHeader
        
        collectionView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            guard let self = `self` else { return }
            self.loadHotCommentData(ismore: true)
        });

        return collectionView
    }()
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self;
        adapter.performanceDelegate = self;
        return adapter
    }()
    
    
//    lazy var reportButton:YXExpandAreaButton = {
//        let btn = YXExpandAreaButton.init()
//        btn.expandX = 10
//        btn.expandY = 10
//        btn.setImage(UIImage.init(named: "comment_report_write"), for: .normal)
//        btn.rx.tap.asObservable().throttle(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).bind { [weak self] in
//            guard let `self` = self else { return }
//
//            if !YXUserManager.isLogin() {
//                YXToolUtility.handleBusinessWithLogin {
//
//                }
//            } else {
//                let viewmodel = YXReportViewModel.init(services: self.viewModel.navigator, params: nil)
//                viewmodel.successBlock = {
//                    self.loadHotCommentData(ismore: false)
//                }
//                self.viewModel.navigator.push(viewmodel, animated: true)
//            }
//
//        }.disposed(by: self.rx.disposeBag)
//        return btn
//    }()
    
    lazy var noDataView:YXCommentDetailNoDataView = {
        let view = YXCommentDetailNoDataView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight))
        view.isWhiteStyle = true
        view.emptyImageView.image = UIImage(named: "empty_noData")
        view.titleLabel.text = YXLanguageUtility.kLang(key: "comment_post_noData")
        view.subTitleButton .setTitle(YXLanguageUtility.kLang(key: "comment_publish_now"), for: .normal)
        view.isHidden = true
        view.clickActionBlock = { [weak self] in
            guard let `self` = self else { return }
            if !YXUserManager.isLogin() {
                YXToolUtility.handleBusinessWithLogin {
                    
                }
            } else {
                let viewmodel = YXReportViewModel.init(services: self.viewModel.navigator, params: nil)
                viewmodel.successBlock = {
                    self.loadHotCommentData(ismore: false)
                }
                self.viewModel.navigator.push(viewmodel, animated: true)
            }
            
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        loadHotCommentData(ismore: false)
//        guessUpView.loadData()
    }
    
    override var pageName: String {
          return "Opportunity"
    }
    
    func initUI() {
        
//        view.addSubview(guessUpView)
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(noDataView)
//        view.addSubview(reportButton)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
        
        collectionView.alwaysBounceVertical = false;
        collectionView.bounces = false;
        collectionView.showsVerticalScrollIndicator = false
        
//        guessUpView.snp.makeConstraints{
//            $0.left.right.top.equalToSuperview()
//            $0.height.equalTo(220)
//        }
//
        headerView.snp.makeConstraints{
//            $0.top.equalTo(guessUpView.snp.bottom).offset(10)
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(45)
        }
//
        collectionView.snp.makeConstraints{
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
        }
        
        noDataView.snp.makeConstraints{
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
        }
        
//        reportButton.snp.makeConstraints{
//            $0.right.equalToSuperview().inset(14)
//            $0.bottom.equalToSuperview().inset(40)
//            $0.width.height.equalTo(66)
//
//        }
        
    }
    
    
    func bindViewModel() {
        
    }
    
    func reportComment() {
        let viewmodel = YXReportViewModel.init(services: self.viewModel.navigator, params: nil)
        viewmodel.successBlock = {
            self.loadHotCommentData(ismore: false)
        }
        self.viewModel.navigator.push(viewmodel, animated: true)
    }
}


extension YXCommunityViewController : ListAdapterDataSource {
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        nil
    }
    
    // MARK: ListAdapterDataSource
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return dataSource as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is Int {
            let hotCommentVC = YXCommentSectionController.init()
            hotCommentVC.refreshDataBlock = {  (model,type) in
                if type == .deleteData {
                    if let index = self.dataSource.firstIndex(where: { $0.isEqual(toDiffableObject: object as? ListDiffable ) }) {
                        self.dataSource.remove(at: index)
                    }
                    
                } else if type == .refreshDataReplace {
                    
                    if let index = self.dataSource.firstIndex(where: { $0.isEqual(toDiffableObject: object as? ListDiffable ) }), let model = model {
                        self.dataSource[index] = model as! ListDiffable
                    }
                }
                self.adapter.performUpdates(animated: false, completion: nil)
            }
            return hotCommentVC
        } else if object is YXSquareStockPostListModel {
            let hotCommentVC = YXCommentSectionController.init()            
            hotCommentVC.refreshDataBlock = {  (model,type) in
                if type == .deleteData {
                    if let index = self.dataSource.firstIndex(where: { $0.isEqual(toDiffableObject: object as? ListDiffable ) }) {
                        self.dataSource.remove(at: index)
                    }
                    
                } else if type == .refreshDataReplace {
                    
                    if let index = self.dataSource.firstIndex(where: { $0.isEqual(toDiffableObject: object as? ListDiffable ) }), let model = model {
                        self.dataSource[index] = model as! ListDiffable
                    }
                }
                self.adapter.performUpdates(animated: false, completion: nil)
            }
            return hotCommentVC
        }
        
        return ListSectionController.init()
        
    }
    
}

extension YXCommunityViewController {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
//
//    // header高度
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize.init(width: collectionView.frame.size.width, height: 45)
//
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "YXCommunityHeaderView1", for: indexPath) as? UICollectionReusableView {
//            return self.headerView1
//        }
//        return UICollectionReusableView()
//    }
    
    func loadHotCommentData(ismore: Bool) {
        
        if !ismore {
            page = 1
            page_size = 20
            query_token = ""
            if dataSource.count == 0 {
                YXProgressHUD.showLoading(YXLanguageUtility.kLang(key:"common_loading_with_dot"), in: self.view)
            }
        } else {
            page = page + 1
        }
        
        YXSquareCommentManager.queryFeaturedHotList(page: page, pageSize: page_size, query_token: query_token, local:local) { (model) in
            
            if let token = model?.query_token {
                self.query_token = token
            }
            if !ismore {
                if self.dataSource.count == 0  {
                    YXProgressHUD.hide(for: self.view, animated: true)
                }
                self.dataSource.removeAll()
//                self.collectionView.mj_header.endRefreshing()
                
                if let list = model?.post_list, list.count == 0 {
                    self.noDataView.isHidden = false
                    self.adapter.performUpdates(animated: true, completion: nil)
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    self.collectionView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                    return
                } else {
                    self.noDataView.isHidden = true
                    self.collectionView.mj_footer.endRefreshing()
                    self.collectionView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                }
            } else {
                self.collectionView.mj_footer.endRefreshing()
                if let list = model?.post_list, list.count == 0 {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
            if let list = model?.post_list {
                list.forEach{
                    self.dataSource.append($0)
                }
            }
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
}

extension YXCommunityViewController: YXTabPageScrollViewProtocol,ListAdapterPerformanceDelegate {
    func listAdapterWillCallDequeueCell(_ listAdapter: ListAdapter) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didCallDequeue cell: UICollectionViewCell, on sectionController: ListSectionController, at index: Int) {
        
    }
    
    func listAdapterWillCallDisplayCell(_ listAdapter: ListAdapter) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didCallDisplay cell: UICollectionViewCell, on sectionController: ListSectionController, at index: Int) {
        
    }
    
    func listAdapterWillCallEndDisplayCell(_ listAdapter: ListAdapter) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didCallEndDisplay cell: UICollectionViewCell, on sectionController: ListSectionController, at index: Int) {
        
    }
    
    func listAdapterWillCallSize(_ listAdapter: ListAdapter) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didCallSizeOn sectionController: ListSectionController, at index: Int) {
        
    }
    
    func listAdapterWillCallScroll(_ listAdapter: ListAdapter) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didCallScroll scrollView: UIScrollView) {
        self.scrollCallBack?(scrollView);
    }
    
    func pageScrollView() -> UIScrollView {
        return self.collectionView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }
}


//YXCommunityViewController的容器
class YXCommunityContainViewController: YXHKViewController, ViewModelBased {
    
    typealias ViewModelType = YXCommunityContainViewModel
    var viewModel: YXCommunityContainViewModel! = YXCommunityContainViewModel.init()
    
    private lazy var headerView: YXCommunityGuessUpView = {
        let view = YXCommunityGuessUpView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 220))

        view.heightDidChange = { [weak self]  in
            guard let `self` = self else { return }
            view.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height:self.headerView.height)
            self.tabPageView.reloadData()
            
        }
        return view
    }()
    
    lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView.init(delegate: self)
        tabPageView.mainTableView.backgroundColor = UIColor.clear
        
        return tabPageView
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 3
        tabLayout.lineWidth = 12
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 0
        tabLayout.linePadding = 1
        tabLayout.lineColor = UIColor.qmui_color(withHexString: "#0091FF")!
//        tabLayout.titleColor = QMUICMI().textColorLevel2()
        tabLayout.titleSelectedColor = UIColor.qmui_color(withHexString: "#0091FF")!
        tabLayout.titleFont = UIFont.normalFont14()
        tabLayout.titleFont = UIFont(_PingF_Semibold: 14)
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
//        tabView.backgroundColor = QMUICMI().foregroundColor()
//        tabView.titles = [YXSquarePageTabType.hot.title,
//                          YXSquarePageTabType.square.title,
//                          YXSquarePageTabType.recommend.title,
//                          YXSquarePageTabType.fastNews.title,
//                          YXSquarePageTabType.live.title,
//                          YXSquarePageTabType.attention.title]
//        tabView.delegate = self
        tabView.defaultSelectedIndex = 0
        return tabView
    }()
    
    lazy var reportButton:YXExpandAreaButton = {
        let btn = YXExpandAreaButton.init()
        btn.expandX = 10
        btn.expandY = 10
        btn.setImage(UIImage.init(named: "comment_report_write"), for: .normal)
        btn.rx.tap.asObservable().throttle(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).bind { [weak self] in
            guard let `self` = self else { return }

            if !YXUserManager.isLogin() {
                YXToolUtility.handleBusinessWithLogin {
                    
                }
            } else {
                guard let vc = self.pageView.viewControllers[Int(self.tabView.selectedIndex)] as? YXCommunityViewController else {
                    return
                }
                vc.reportComment()
            }

        }.disposed(by: self.rx.disposeBag)
        return btn
    }()
    
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        //community
        let communityViewModel = YXCommunityViewModel.init()
        let communitVC = YXCommunityViewController.instantiate(withViewModel: communityViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        pageView.contentView.isScrollEnabled = false
        pageView.viewControllers = [communitVC]
        return pageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        headerView.loadData()
    }

    func setupUI() {
        view.addSubview(tabPageView)
        tabPageView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(strongNoticeView.snp.bottom)
        }
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }
            self.headerView.loadData()
            guard let vc = self.pageView.viewControllers[Int(self.tabView.selectedIndex)] as? YXCommunityViewController else {
                return
            }
            vc.loadHotCommentData(ismore: false)
            
            self.tabPageView.mainTableView.mj_header.endRefreshing()
        }
        tabPageView.mainTableView.mj_header = refreshHeader

//        view.addSubview(self.stickButton)
//        stickButton.snp.makeConstraints {
//            $0.right.equalTo(self.view).offset(-8);
//            $0.size.equalTo(CGSize(width: 68, height: 68));
//            $0.bottom.equalToSuperview().offset(-(20 + YXConstant.tabBarHeight()));
//        }
//
        view.addSubview(self.reportButton)
//        reportButton.snp.makeConstraints {
//            $0.right.equalTo(self.view).offset(-8);
//            $0.size.equalTo(CGSize(width: 68, height: 68));
//            $0.bottom.equalToSuperview().offset(-(88 + YXConstant.tabBarHeight()));
//        }
        
        reportButton.snp.makeConstraints{
            $0.right.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(40)
            $0.width.height.equalTo(66)
        }
    }
    
}


extension YXCommunityContainViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
//        if self.tabView.selectedIndex == YXSquarePageTabType.square.tabIndex {
//            self.reportButton.isHidden = false
//        } else {
//            self.reportButton.isHidden = true
//        }
    }
}


extension YXCommunityContainViewController: YXTabPageViewDelegate {
    func headerViewInTabPage() -> UIView {
        self.headerView
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        self.headerView.height
    }
    
    func tabViewInTabPage() -> YXTabView {
        return self.tabView
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        return 0
    }
    
    func pageViewInTabPage() -> YXPageView {
        self.pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return self.view.bounds.size.height
    }
}
