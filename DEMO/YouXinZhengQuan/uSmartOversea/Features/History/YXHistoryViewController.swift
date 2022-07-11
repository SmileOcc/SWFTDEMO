//
//  YXHistoryViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YXKit

class YXHistoryViewController: YXHKTableViewController, HUDViewModelBased, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXHistoryViewModel!

    var datas: [YXHistoryList] = []
    
    var total: Int = 0
    
    var page: UInt = 1

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    var bizType: YXHistoryBizType = .All {
        didSet {
            self.bizTypeFilter.setTitle(bizType.title, for: .normal)

            // 设置是否选中状态，除.All以外都使用选中效果
            if bizType == .All {
                self.bizTypeFilter.isSelected = false
            } else {
                self.bizTypeFilter.isSelected = true
            }
        }
    }
    
    var dateType: YXHistoryDateType = .All {
        didSet {
            switch dateType {
            case .All:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_all"), for: .normal)
            case .LastMonth:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_last_month"), for: .normal)
            case .LastThreeMonth:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_last_three_month"), for: .normal)
            case .LastYear:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_last_year"), for: .normal)
            case .WithinThisYear:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_within_this_year"), for: .normal)
            case .Custom:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_custom"), for: .normal)
            case .Today:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "hold_today"), for: .normal)
            case .Week:
                self.dateFilter.setTitle(YXLanguageUtility.kLang(key: "history_date_type_last_week"), for: .normal)
            }
            
            // 设置是否选中状态，除.All以外都使用选中效果
            if dateType == .All {
                self.dateFilter.isSelected = false
            } else {
                self.dateFilter.isSelected = true
            }
        }
    }

    var status: YXHistoryFilterStatus = .all {
        didSet {
            self.statusFilter.setTitle(status.title, for: .normal)

            if status == .all {
                self.statusFilter.isSelected = false
            } else {
                self.statusFilter.isSelected = true
            }
        }
    }
    
    var beginDate: Date?, endDate: Date?
    
    // 过滤器的普通颜色
    let filterNormalColor = QMUITheme().textColorLevel2()
    
    // 过滤器的选中颜色
    let filterSelectedColor = QMUITheme().themeTextColor()
    
    // 过滤器箭头的Size
    let filterArrowSize = CGSize.init(width: 7, height: 5)
    
    var isEmpty: Bool = false
    
    // 用于记录服务器返回的系统时间,如果没有收到服务器的返回时间，则取手机时间
    var systemDate: String = ""
    
    lazy var filterContainerView: YXHistoryFilterContainerView = {
        let containerView = YXHistoryFilterContainerView()
        return containerView
    }()
    
    lazy var bizTypeFilter: YXHistoryFilterButton = {
        let filter = YXHistoryFilterButton(type: .custom)
        filter.setTitleColor(filterNormalColor, for: .normal)
        filter.setTitleColor(filterSelectedColor, for: .selected)
        filter.setTitleColor(filterSelectedColor, for: .highlighted)
        filter.setImage(UIImage(named: "icon_all_order_down"), for: .normal)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .selected)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .highlighted)
        return filter
    }()
    
    lazy var dateFilter: YXHistoryFilterButton = {
        let filter = YXHistoryFilterButton()
        filter.setTitleColor(filterNormalColor, for: .normal)
        filter.setTitleColor(filterSelectedColor, for: .selected)
        filter.setTitleColor(filterSelectedColor, for: .highlighted)
        filter.setImage(UIImage(named: "icon_all_order_down"), for: .normal)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .selected)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .highlighted)
        return filter
    }()

    lazy var statusFilter: YXHistoryFilterButton = {
        let filter = YXHistoryFilterButton()
        filter.setTitleColor(filterNormalColor, for: .normal)
        filter.setTitleColor(filterSelectedColor, for: .selected)
        filter.setTitleColor(filterSelectedColor, for: .highlighted)
        filter.setImage(UIImage(named: "icon_all_order_down"), for: .normal)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .selected)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .highlighted)
        return filter
    }()
    
    lazy var bizTypeFilterView: YXHistoryBizTypeFilterView = {
        let filterView = YXHistoryBizTypeFilterView.init(frame: .zero)
        return filterView
    }()
    
    lazy var dateFilterView: YXDateFilterView = {
        let dateFilter = YXDateFilterView.init(style: YXDateFilterView.YXDateFilterStyle.history)
        return dateFilter
    }()

    lazy var statusFilterView: YXHistoryStatusFilterView = {
        let dateFilter = YXHistoryStatusFilterView.init(frame: .zero)
        return dateFilter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        bindViewModel()
    }
    
    override func layoutTableView() {
        self.tableView.frame = CGRect(x: 0, y: YXConstant.navBarHeight() + 40, width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - 40)
    }
    
    private func initUI() -> Void {
        self.title = YXLanguageUtility.kLang(key: "history_title")
        
        let serviceItem = UIBarButtonItem.qmui_item(with: UIImage(named: "service") ?? UIImage(), target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [serviceItem]
        
        serviceItem.rx.tap.bind { [weak self] in
            self?.serviceAction()
            }.disposed(by: disposeBag)

        weak var weakSelf = self
        
        self.view.backgroundColor = QMUITheme().foregroundColor()

        self.tableView.isHidden = true

        self.tableView.backgroundColor = QMUITheme().foregroundColor()

        self.tableView.separatorStyle = .none
        
        self.tableView.emptyDataSetSource = self
        
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.register(YXHistoryTableViewCell1.self, forCellReuseIdentifier: "cell1_identifier")

        // 过滤器容器
        self.view.addSubview(self.filterContainerView)
        self.filterContainerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.snp.top).offset(YXConstant.navBarHeight())
            make.height.equalTo(56)
        }

        self.bizType = self.viewModel.bizType
        
        self.dateType = .All

        self.status = .all
        
        self.bizTypeFilter.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if self.bizTypeFilterView.isHidden {
                if self.dateFilterView.isHidden == false {
                    self.dateFilterView.hideFilterCondition(completion: nil)
                }

                if self.statusFilterView.isHidden == false {
                    self.statusFilterView.hidden()
                }

                self.bizTypeFilterView.show(selectedType: self.bizType)
            } else {
                // 隐藏过滤条件
                self.bizTypeFilterView.hidden()
            }

        }.disposed(by: disposeBag)
        
        self.dateFilter.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if self.dateFilterView.isHidden {
                if self.bizTypeFilterView.isHidden == false {
                    self.bizTypeFilterView.hidden()
                }

                if self.statusFilterView.isHidden == false {
                    self.statusFilterView.hidden()
                }

                self.dateFilterView.showFilterCondition()
            } else {
                // 隐藏过滤条件
                self.dateFilterView.hideFilterCondition()
            }

        }.disposed(by: disposeBag)

        self.statusFilter.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            if self.statusFilterView.isHidden {
                if self.bizTypeFilterView.isHidden == false {
                    self.bizTypeFilterView.hidden()
                }

                if self.dateFilterView.isHidden == false {
                    self.dateFilterView.hideFilterCondition(completion: nil)
                }

                self.statusFilterView.show(selectedStatus: self.status)
            } else {
                // 隐藏过滤条件
                self.statusFilterView.hidden()
            }

        }.disposed(by: disposeBag)

        self.filterContainerView.addFilter(self.bizTypeFilter)
        self.filterContainerView.addFilter(self.dateFilter)
        self.filterContainerView.addFilter(self.statusFilter)

        // 业务类型选择视图
        self.view.insertSubview(self.bizTypeFilterView, belowSubview: self.filterContainerView)
        self.bizTypeFilterView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.filterContainerView.snp.bottom)
        }

        // 执行过滤动作
        self.bizTypeFilterView.filter = { [weak self] type in
            guard let strongSelf = self else { return }
            strongSelf.bizType = type
            // 请求第一页数据
            strongSelf.loadFirstPage()
        }

        self.bizTypeFilterView.isHidden = true

        self.view.insertSubview(self.dateFilterView, belowSubview: self.filterContainerView)
        self.dateFilterView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.filterContainerView.snp.bottom)
        }

        self.dateFilterView.filter = {[weak self] tag, beginDate, endDate in
            guard let strongSelf = self else { return }

            if tag == YXHistoryDateType.All.index {
                strongSelf.dateType = .All
            } else if tag == YXHistoryDateType.LastMonth.index {
                strongSelf.dateType = .LastMonth
            } else if tag == YXHistoryDateType.LastThreeMonth.index {
                strongSelf.dateType = .LastThreeMonth
            } else if tag == YXHistoryDateType.LastYear.index {
                strongSelf.dateType = .LastYear
            } else if tag == YXHistoryDateType.WithinThisYear.index {
                strongSelf.dateType = .WithinThisYear
            } else if tag == YXHistoryDateType.Custom.index {
                strongSelf.dateType = .Custom
                strongSelf.beginDate = beginDate
                strongSelf.endDate = endDate
            }

            // 请求第一页数据
            strongSelf.loadFirstPage()
        }

        self.dateFilterView.isHidden = true

        self.view.insertSubview(self.statusFilterView, belowSubview: self.filterContainerView)
        self.statusFilterView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.filterContainerView.snp.bottom)
        }

        self.statusFilterView.filter = {[weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.status = status
            strongSelf.loadFirstPage()
        }

        self.statusFilterView.isHidden = true

        let header = YXRefreshHeader {
            weakSelf?.page = 1
            weakSelf?.requestHistory(page: weakSelf?.page ?? 1)
        }
        
        header?.backgroundColor = QMUITheme().foregroundColor()
        header?.tiplab.textColor = QMUITheme().textColorLevel1()
        self.tableView.mj_header = header

        let footer = YXRefreshAutoNormalFooter {
            weakSelf?.page += 1
            weakSelf?.loadMoreData()
        }
        
        footer?.backgroundColor = QMUITheme().foregroundColor()
        footer?.setStateTextColor(QMUITheme().textColorLevel1() )
        self.tableView.mj_footer = footer
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func bindViewModel() {
        self.bindHUD()
        
        self.loadFirstPage()
    }
    
    func requestHistory(page: UInt) {
        // 业务类型：全部、出金、入金、货币兑换
        let bizType = self.bizType.index - 1
        
        // 时间类型：全部日期、近1月、近3月、近1年
        var dateType = self.dateType.index - 1
        if self.dateType == .Custom {
            dateType = 9
        }
        
        let startTime = (self.beginDate != nil ? self.formatter.string(from: self.beginDate?.beginningOfDay() ?? Date()) : "")
        let endTime = (self.endDate != nil ? self.formatter.string(from: self.endDate?.endOfDay() ?? Date()) : "")

        self.viewModel.services.tradeService.request(
            .historyList(
                dateType,
                type: bizType,
                pageNum: page,
                pageSize: 10,
                startTime: startTime,
                endTime: endTime,
                status: status.requestParam
            ), response: { [weak self] (response) in
            guard let `self` = self else { return }
            
            self.viewModel.hudSubject.onNext(.hide)
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    if result.data?.pageNum == 1 {
                        if result.data?.total == 0 {
                            self.isEmpty = true
                        } else {
                            self.isEmpty = false
                        }
                        self.tableView.qmui_scrollToTop()
                    }
                    
                    if let model = result.data {
                        self.updateDatas(model: model)
                    } else {
                        if self.isEmpty {
                            self.tableView.reloadData()
                        }
                    }
                    
                    if self.page == 1 {
                        self.tableView.isHidden = false
                        self.tableView.mj_header?.endRefreshing()
                        
                        if self.datas.count == self.total {
                            if self.datas.count == 0 {
                                self.tableView.mj_footer = nil
                            } else {
                                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                            }
                        } else {
                            self.tableView.mj_footer?.resetNoMoreData()
                        }
                        
                        // 设置日期选择器的时间
                        self.dateFilterView.systemDate = self.systemDate
                    } else {
                        if self.datas.count < self.total {
                            self.tableView.mj_footer?.endRefreshing()
                        } else {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        }
                    }
                default:
                    self.viewModel.hudSubject.onNext(.error(result.msg, false))
                }
            case .failed(_):
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                
                if self.page == 1 {
                    self.tableView.isHidden = false
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_footer = nil
                    
                    // 设置日期选择器的时间
                    self.dateFilterView.systemDate = self.systemDate
                } else {
                    self.tableView.mj_footer?.endRefreshing()
                }
            }
        } as YXResultResponse<YXHistoryResponseModel>).disposed(by: self.disposeBag)
    }
    
    func loadFirstPage() -> Void {
        self.page = 1
        
        if self.tableView.mj_footer == nil {
            
            let footer = YXRefreshAutoNormalFooter { [weak self] in
                guard let `self` = self else { return }
                
                self.page += 1
                self.loadMoreData()
            }
            footer?.setStateTextColor(QMUITheme().textColorLevel1())
            self.tableView.mj_footer = footer
        }

        self.viewModel.hudSubject.onNext(.loading("", false))
        self.requestHistory(page: self.page)
    }
    
    
    private func loadMoreData() -> Void {
        self.requestHistory(page: self.page)
    }
    
    private func updateDatas(model: YXHistoryResponseModel) -> Void {

        self.total = model.total

        // 获取数据成功
        if model.pageNum == 1 {
            // 当前页码是1时,则重置datas
            self.datas = model.list
        } else {
            // 如果是其他页码，则往后追加数据
            self.datas.append(contentsOf: model.list)
        }

        // 设置日期选择器的最大时间、最小时间
        self.systemDate = model.systemDate
        
        self.tableView.reloadData()
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
//        if self.isEmpty && self.bizType != .All {
//            return -149
//        } else {
//            return 0
//        }
        
        return 40
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        scrollView.contentOffset = CGPoint.zero
    }


    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {

        if self.isEmpty {
            if self.bizType == .All {
                let container = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
                let imageView = UIImageView.init(image: UIImage.init(named: "empty_noOrder"))
                container.addSubview(imageView)
                imageView.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(-25.5)
                    make.width.equalTo(130)
                    make.height.equalTo(120)
                }

                let label = UILabel()
                label.text = YXLanguageUtility.kLang(key: "history_no_history")

                label.textColor = UIColor.qmui_color(withHexString: "#C2C9D4")
                label.font = UIFont.systemFont(ofSize: 14)
                label.textAlignment = .center

                container.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(imageView.snp.bottom).offset(10)
                    make.leading.equalToSuperview()
                    
                    make.trailing.equalToSuperview()
                    make.height.equalTo(20)
                }
                return container
            } else {
                let container = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.bounds.width, height: 210))
                let imageView = UIImageView.init(image: UIImage.init(named: "empty_noOrder"))
                container.addSubview(imageView)
                imageView.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview()
                    make.width.equalTo(130)
                    make.height.equalTo(120)
                }

                let label = UILabel()
                switch self.bizType {
                case .Deposit:
                    label.text = YXLanguageUtility.kLang(key: "history_no_deposit_history")
                case .Withdraw:
                    label.text = YXLanguageUtility.kLang(key: "history_no_withdraw_history")
                case .Exchange:
                    label.text = YXLanguageUtility.kLang(key: "history_no_exchange_history")
                default:
                    log(.warning, tag: kModuleViewController, content: "其他业务类型不在此判断")
                }

                label.textColor = UIColor.qmui_color(withHexString: "#C2C9D4")
                label.font = UIFont.systemFont(ofSize: 14)
                label.textAlignment = .center

                container.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(imageView.snp.bottom).offset(10)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(20)
                }

                let actionbButton = QMUIButton()
                switch self.bizType {
                case .Deposit:
                    actionbButton.setTitle(YXLanguageUtility.kLang(key: "history_i_want_deposit"), for: .normal)
                case .Withdraw:
                    actionbButton.setTitle(YXLanguageUtility.kLang(key: "history_i_want_withdraw"), for: .normal)
                case .Exchange:
                    actionbButton.setTitle(YXLanguageUtility.kLang(key: "history_i_want_exchange"), for: .normal)
                default:
                    log(.warning, tag: kModuleViewController, content: "其他业务类型不需要Button")
                }
                actionbButton.setTitleColor(UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1), for: .normal)
                actionbButton.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
                actionbButton.layer.cornerRadius = 6
                actionbButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                
                actionbButton.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    
                    switch self.bizType {
                    case .Deposit:
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL(market: "hk"),
                            YXWebViewModel.kWebViewModelTitleBarVisible : true
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    case .Withdraw:
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_WITHDRAWAL_URL(market: "hk"),
                            YXWebViewModel.kWebViewModelTitleBarVisible : true
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    case .Exchange:
                        // 换汇
                        let context = YXNavigatable(viewModel: YXCurrencyExchangeViewModel(market: YXMarketType.HK.rawValue))
                        self.viewModel.navigator.push(YXModulePaths.exchange.url, context: context)
                        log(.warning, tag: kModuleViewController, content: "换汇页面跳转")
                    default:
                        log(.warning, tag: kModuleViewController, content: "其他业务类型不需要Button")
                    }
                }.disposed(by: self.disposeBag)

                container.addSubview(actionbButton)
                actionbButton.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.height.equalTo(48)
                    make.top.equalTo(label.snp.bottom).offset(47)
                }
                
                let guideButton = QMUIButton()
                switch self.bizType {
                case .Deposit:
                    guideButton.setTitle(YXLanguageUtility.kLang(key: "history_deposit_guide"), for: .normal)
                case .Withdraw:
                    guideButton.setTitle(YXLanguageUtility.kLang(key: "history_withdraw_guide"), for: .normal)
                case .Exchange:
                    guideButton.setTitle(YXLanguageUtility.kLang(key: "history_exchange_guide"), for: .normal)
                default:
                    log(.warning, tag: kModuleViewController, content: "其他业务类型不需要引导")
                }
                guideButton.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
                guideButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                
                guideButton.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    
                    switch self.bizType {
                    case .Deposit:
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.DEPOSIT_GUIDELINE_SG_URL(),
                            YXWebViewModel.kWebViewModelTitleBarVisible : true
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    case .Withdraw:
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.WITHDRAWAL_GUIDELINE_SG_URL(),
                            YXWebViewModel.kWebViewModelTitleBarVisible : true
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    case .Exchange:
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.EXCHANGE_GUIDELINE_URL(),
                            YXWebViewModel.kWebViewModelTitleBarVisible : true
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    default:
                        log(.warning, tag: kModuleViewController, content: "其他业务类型不需要引导")
                    }
                }.disposed(by: self.disposeBag)

                container.addSubview(guideButton)
                guideButton.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(actionbButton.snp.bottom).offset(14)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(20)
                }
                return container
            }
        } else {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
            let emptyImageView = UIImageView.init(image: UIImage.init(named: "empty2"))
            container.addSubview(emptyImageView)
            emptyImageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-40)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }

            let label = UILabel()
            label.text = YXLanguageUtility.kLang(key: "history_fetch_data_error")
            label.textColor = UIColor.qmui_color(withHexString: "#B4CEEC")
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center

            container.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(emptyImageView.snp.bottom).offset(15)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(20)
            }

            return container
        }


    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.datas[indexPath.row].type == YXHistoryList.BizType.withdraw.rawValue {
            return 140
        }

        return 175
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1_identifier", for: indexPath) as! YXHistoryTableViewCell1
        cell.selectionStyle = .none
        cell.model = model
        cell.refreshUI()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.datas[indexPath.row]
        if model.type == YXHistoryList.BizType.deposit.rawValue {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_HISTORY_DETAIL_URL(model.businessID)]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
}

extension Date {
    /// 获取某一天的时分秒为23:59:59的Date
    ///
    /// - Returns: 返回指定的某一天时分秒为23:59:59的Date
    func endOfDay() -> Date? {
        let cal = Calendar.current
        var components = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return cal.date(from: components)
    }
    
    
    /// 获取某一天的时分秒为0的Date
    ///
    /// - Returns: 返回指定的某一天时分秒为0的Date
    func beginningOfDay() -> Date? {
        let cal = Calendar.current
        var components = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return cal.date(from: components)
    }
}

