//
//  SearchResultListViewController.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Masonry
import JXSegmentedView

class SearchResultListViewController: YXTableViewController {

    var searchWord: String = "" {
        didSet {
            if searchResultListViewModel.searchWord != searchWord {
                searchResultListViewModel.searchWord = searchWord

                if isViewLoaded {
                    loadFirstPage()
                }
            }
        }
    }

    // 首次加载会闪现空页面然后才是 loading，增加辅助标记优化下体验
    private var isFirstLoad = true

    private var searchResultListViewModel: SearchResultListViewModel {
        return self.viewModel as! SearchResultListViewModel
    }

    private lazy var tabViewContainer: UIView = {
        let container = UIView()
        container.backgroundColor = QMUITheme().foregroundColor()
        container.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        container.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)

        container.addSubview(tabView)
        tabView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }

        return container
    }()

    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = true
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 16
        tabLayout.tabPadding = 10
        tabLayout.lineHeight = 24
        tabLayout.leftAlign = true
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

        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 28), with: tabLayout)
        tabView.delegate = self
        tabView.backgroundColor = QMUITheme().foregroundColor()

        return tabView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = QMUITheme().foregroundColor()

        view.addSubview(tabViewContainer)
        tabViewContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(44)
        }

        tableView.mas_remakeConstraints { _ in

        } // 父类用的 Masonary, 这里先 remove 掉，然后用 SnapKit

        tableView.snp.remakeConstraints { make in
            make.top.equalTo(tabViewContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: YXConstant.safeAreaInsetsBottomHeight(), right: 0)

        tableView.register(SearchQuoteCell.self, forCellReuseIdentifier: NSStringFromClass(SearchQuoteCell.self))
        tableView.register(SearchStrategyCell.self, forCellReuseIdentifier: NSStringFromClass(SearchStrategyCell.self))
        tableView.register(SearchPostCell.self, forCellReuseIdentifier: NSStringFromClass(SearchPostCell.self))
        tableView.register(SearchBeeRichCourseCell.self, forCellReuseIdentifier: NSStringFromClass(SearchBeeRichCourseCell.self))
        tableView.register(SearchNewsCell.self, forCellReuseIdentifier: NSStringFromClass(SearchNewsCell.self))
        tableView.register(SearchBeeRichMasterCell.self, forCellReuseIdentifier: NSStringFromClass(SearchBeeRichMasterCell.self))
        tableView.register(SearchHelpCell.self, forCellReuseIdentifier: NSStringFromClass(SearchHelpCell.self))
        tableView.register(SearchResultHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(SearchResultHeaderView.self))

        let titles = searchResultListViewModel.searchType.subTypes.map{ $0.title }
        tabView.titles = titles
        tabView.reloadData()

        tabViewContainer.isHidden = tabView.titles.isEmpty
        tabViewContainer.snp.updateConstraints { make in
            let amount = titles.isEmpty ? 0 : 44
            make.height.equalTo(amount)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()

        searchResultListViewModel.rx.observe(Bool.self, "shouldInfiniteScrolling")
            .subscribe(onNext: { [weak self] shouldInfiniteScrolling in
                if let shouldInfiniteScrolling = shouldInfiniteScrolling, shouldInfiniteScrolling {
                    //
                } else {
                    self?.tableView.mj_footer = nil
                }
            }).disposed(by: rx.disposeBag)

        // 处理 loading 状态
        searchResultListViewModel.requestRemoteDataCommand.executing
            .take(until: self.rac_willDeallocSignal())
            .subscribeNext { [weak self] executing in
                guard let `self` = self else { return }

                self.isFirstLoad = false

                if let executing = executing?.boolValue,
                   executing {
                    if let mj_header = self.tableView.mj_header, mj_header.isRefreshing {
                        //
                    } else if let mj_footer = self.tableView.mj_footer, mj_footer.isRefreshing {
                        //
                    } else { // 有请求，并且也没有上/下拉刷新状态
                        self.hideEmptyView()
                        self.showEmptyViewWithLoading()
                    }
                } else {
                    self.hideEmptyView()
                }
            }
    }

    override func loadFirstPage() {
        searchResultListViewModel.cancelRequest()
        super.loadFirstPage()
    }

    override func preferredNavigationBarHidden() -> Bool {
        true
    }

    /// 针对社区子分类的情况
    func resetSearchType(searchType: SearchType) {
        switch searchType {
        case .community(let subType):
            tabView.selectTab(at: UInt(subType.rawValue))
            searchResultListViewModel.searchType = searchType
            loadFirstPage()
        default:
            break
        }
    }

}

extension SearchResultListViewController {

    override func tableViewTop() -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchType = searchResultListViewModel.sectionSearchTypes[indexPath.section]
        let model = searchResultListViewModel.dataSource[indexPath.section][indexPath.row]

        switch searchType {
        case .all:
            break
        case .quote:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchQuoteCell.self)) as! SearchQuoteCell
            cell.searchWord = searchWord
            cell.model = model
            return cell
        case .strategy:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchStrategyCell.self)) as! SearchStrategyCell
            cell.searchWord = searchWord
            cell.model = model
            return cell
        case .news:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchNewsCell.self)) as! SearchNewsCell
            cell.searchWord = searchWord
            cell.model = model
            return cell
        case .community(let subType):
            switch subType {
            case .expert:
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchBeeRichMasterCell.self)) as! SearchBeeRichMasterCell
                cell.searchWord = searchWord
                cell.model = model
                return cell
            case .post:
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchPostCell.self)) as! SearchPostCell
                // UI 要求综合页面不显示分割线
                switch searchResultListViewModel.searchType {
                case .community(let subType):
                    cell.seperator.isHidden = subType != .post
                default:
                    cell.seperator.isHidden = true
                }
                cell.searchWord = searchWord
                cell.model = model
                return cell
            case .course:
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchBeeRichCourseCell.self)) as! SearchBeeRichCourseCell
                cell.searchWord = searchWord
                cell.model = model
                return cell
            default:
                break
            }
        case .help:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SearchHelpCell.self)) as! SearchHelpCell
            cell.searchWord = searchWord
            cell.model = model
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = searchResultListViewModel.dataSource[indexPath.section][indexPath.row] as? SearchCellViewModel {
            return model.cellHeight
        }

        if case .quote = searchResultListViewModel.sectionSearchTypes[indexPath.section] {
            return 60
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch searchResultListViewModel.searchType {
        case .all:
            return 40
        case .community(let subType):
            return subType == .all ? 40 : 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(SearchResultHeaderView.self)) as? SearchResultHeaderView {
            headerView.searchType = searchResultListViewModel.sectionSearchTypes[section]
            headerView.didTap = { [weak self, weak headerView] in
                guard let `self` = self, let strongHeaderView = headerView else {
                    return
                }

                if case .all = self.searchResultListViewModel.searchType {
                    NotificationCenter.default.post(name: NSNotification.Name("SearchTypeDidChangedNotification"), object: strongHeaderView.searchType)
                } else {
                    switch strongHeaderView.searchType {
                    case .community(let subType):
                        self.tabView.selectTab(at: UInt(subType.rawValue))
                    default:
                        break
                    }
                }
            }
            return headerView
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch searchResultListViewModel.searchType {
        case .all:
            return 40
        case .community(let subType):
            return subType == .all ? 40 : 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 用户点击搜索结果也要保持搜索关键字
        SearchHistoryManager.sharedManager.append(searchWord)
        
        let cellViewModel = searchResultListViewModel.dataSource[indexPath.section][indexPath.row]

        if let cellViewModel = cellViewModel as? SearchQuoteCellViewModel { // 股票
            let model = cellViewModel.model

            let input = YXStockInputModel()
            input.market = model.market
            input.symbol = model.symbol
            input.name = model.name
            YXStockDetailViewModel.pushSafty(paramDic: [
                "dataSource": [input],
                "selectIndex": 0
            ])
        } else if let cellViewModel = cellViewModel as? SearchStrategyCellViewModel { // 策略
            let model = cellViewModel.model
            let jumpUrl: String

            switch model.type {
            case .manual:
                jumpUrl = YXH5Urls.manualUrl(strategyId: model.strategyId)
            case .fund:
                jumpUrl = YXH5Urls.fundUrl(strategyId: model.strategyId)
            }
            YXWebViewModel.pushToWebVC(jumpUrl)
        } else if let cellViewModel = cellViewModel as? SearchNewsCellViewModel { // 资讯
            let model = cellViewModel.model
            let vm = YXImportantNewsDetailViewModel(services: self.viewModel.services, params: ["cid": model.newsId])
            self.viewModel.services.push(vm, animated: true)
        } else if let cellViewModel = cellViewModel as? SearchPostCellViewModel { // 帖子
            let model = cellViewModel.model

            switch model.postType {
            case .article:
//                let vm = YXArticleDetailViewModel(services: self.viewModel.services, params: ["cid": model.postId])
//                self.viewModel.services.push(vm, animated: true)
                break
            case .stockDiscussion:
                let vm = YXStockCommentDetailViewModel(services: self.viewModel.services, params: ["cid": model.postId])
                self.viewModel.services.push(vm, animated: true)
            }
        } else if let cellViewModel = cellViewModel as? SearchBeeRichCourseCellViewModel { // 课程
            let model = cellViewModel.model
            YXNavigationMap.navigator.push(
                YXModulePaths.courseDetail.url,
                context: ["courseId": model.courseId],
                from: nil,
                animated: true
            )
        } else if let cellViewModel = cellViewModel as? SearchBeeRichMasterCellViewModel { // 大咖
            let model = cellViewModel.model
            NavigatorServices.shareInstance.pushPath(YXModulePaths.kolHome, context: ["kolId": model.kolUid], animated: true)
        } else if let cellViewModel = cellViewModel as? SearchHelpCellViewModel { // 帮助
            let model = cellViewModel.model
            let jumpUrl = YXH5Urls.helpDetailURL(with: model.id)
            YXWebViewModel.pushToWebVC(jumpUrl)
        }
        
        trackClickCell(atIndexPath: indexPath)
    }

}

extension SearchResultListViewController {

    override func customImageForEmptyDataSet() -> UIImage! {
        return UIImage(named: "icon_search_noData")
    }

    override func customTitleForEmptyDataSet() -> NSAttributedString! {
        return NSAttributedString(
            string: YXLanguageUtility.kLang(key: "no_search_result"),
            attributes: [.font: UIFont.normalFont16(), .foregroundColor: QMUITheme().textColorLevel3()]
        )
    }

    override func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20
    }


    override func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        let shouldDisplay = super.emptyDataSetShouldDisplay(scrollView)
        return shouldDisplay && !isFirstLoad
    }

}

extension SearchResultListViewController: YXTabViewDelegate {

    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        switch searchResultListViewModel.searchType {
        case .community:
            searchResultListViewModel.searchType = .community(SearchCommunityType(rawValue: Int(index)) ?? .all)
            loadFirstPage()
        default:
            break
        }
    }

}


extension SearchResultListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension SearchResultListViewController {
    
    private func trackClickCell(atIndexPath indexPath: IndexPath) {
        let cellViewModel = searchResultListViewModel.dataSource[indexPath.section][indexPath.row]
        var other: [String : String]?
        var pageBtn: String = ""

        switch searchResultListViewModel.searchType {
        case .all:
            pageBtn = "All"
        case .quote:
            pageBtn = "Quotes"
        case .strategy:
            pageBtn = "Strategies"
        case .news:
            pageBtn = "News"
        case .community:
            pageBtn = "Community"
        case .help:
            pageBtn = "Help"
        }

        if let cellViewModel = cellViewModel as? SearchQuoteCellViewModel { // 股票
            let model = cellViewModel.model
            other = ["stock_id" : model.symbol]
        } else if let cellViewModel = cellViewModel as? SearchStrategyCellViewModel { // 策略
            let model = cellViewModel.model
            other = ["strategy_id" : String(model.strategyId)]
        } else if let cellViewModel = cellViewModel as? SearchNewsCellViewModel { // 资讯
            let model = cellViewModel.model
            other = ["news_id" : model.newsId]
        } else if let cellViewModel = cellViewModel as? SearchPostCellViewModel { // 帖子
            let model = cellViewModel.model
            other = ["post_id" : model.postId]
        } else if let cellViewModel = cellViewModel as? SearchBeeRichCourseCellViewModel { // 课程
            let model = cellViewModel.model
            other = ["course_id" : model.courseId]
        } else if let cellViewModel = cellViewModel as? SearchBeeRichMasterCellViewModel { // KOL
            let model = cellViewModel.model
            other = ["kol_id" : model.kolUid]
        } else if let cellViewModel = cellViewModel as? SearchHelpCellViewModel { // 帮助
            let model = cellViewModel.model
            other = ["helpcenter_id" : model.id]
        }

        self.view?.trackViewClickEvent(customPageName: "Search_result_page", name: pageBtn, other: other)
    }
    
}
