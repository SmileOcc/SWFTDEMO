//
//  YXOrderListViewController.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/**
 模块：交易订单
 */
import UIKit
import RxDataSources
import YXKit


class YXOrderListViewController: YXHKTableViewController, HUDViewModelBased, RefreshViweModelBased {

    var isFromAAStock: Bool = false {
        didSet {
            if isFromAAStock {
                //是否禁止使用修正,默认为NO
                UINavigationConfig.shared().sx_defaultRightFixSpace = 0
                UINavigationConfig.shared().sx_disableFixSpace = false

                let navbarHeight = 44.0
                //按钮的阴影
                let layer = CALayer()
                layer.frame = CGRect(x: 2, y: (navbarHeight - 37) / 2.0, width: 93, height: 37)
                layer.backgroundColor = UIColor.white.cgColor
                layer.shadowColor = UIColor.black.qmui_color(withAlpha: 0.1, backgroundColor: .clear).cgColor
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.shadowRadius = 5
                layer.shadowOpacity = 1
                layer.cornerRadius = 18.5   //圆角

                //按钮
                let button = QMUIButton(frame: layer.frame)
                button.backgroundColor = QMUITheme().foregroundColor()
                button.setTitle(YXLanguageUtility.kLang(key: "common_go_back"), for: .normal)
                button.setImage(UIImage(named: "order_list_AAStock"), for: .normal)
                button.imagePosition = .right
                button.spacingBetweenImageAndTitle = 8
                button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

                button.layer.cornerRadius = layer.cornerRadius  //圆角
                button.layer.masksToBounds = true

                button.rx.tap.bind {[weak self] in
                    //是否禁止使用修正,默认为NO
                    UINavigationConfig.shared().sx_disableFixSpace = true
                    self?.isFromAAStock = false

                    if let url = URL(string: YXH5Urls.YX_OPEN_AASTOCKS_URL(with: YXConstant.AAStockPageName ?? "") ), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }

                }.disposed(by: self.disposeBag)


                let baseView = UIView(frame: CGRect(x: 0, y: 0, width: 95, height: navbarHeight))
                baseView.layer.insertSublayer(layer, at: 0)//阴影位置
                baseView.addSubview(button)

                let rightBackItem = UIBarButtonItem(customView: baseView)
                navigationItem.rightBarButtonItem = rightBackItem
            }

        }
    }

    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()

    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()

    lazy var selectBgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2)

        let tapGes = UITapGestureRecognizer()
        tapGes.rx.event.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak view] (ges) in
            UIView.animate(withDuration: 0.5, animations: {
                view?.alpha = 0
            })
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tapGes)

        return view
    }()

    lazy var marketFilterView: YXOrderMarketFilterContainerView = {
        let view = YXOrderMarketFilterContainerView.init(frame: CGRect.zero, defaultMarketFilterType: self.viewModel.market)

        view.didShowBlock = { [weak self] in
            self?.filterView.hideAllFilterView()
            self?.filterView.unSelectedAllFilterButton()
        }

        view.selectOrderMarketBlock = { [weak self] market in
            self?.filterView.resetStockFilter()
            self?.viewModel.stockCode = ""
            self?.viewModel.market = market
            if let refreshingBlock = self?.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }

        return view
    }()

    lazy var filterView: YXOrderFilterView = {
        let view = YXOrderFilterView.init(frame: CGRect.zero, type: .allOrder)
        view.stockFilterView.parentViewController = self

        view.filterConditionAction = { [weak self] (securityType, orderStatus, orderType) in
            guard let `self` = self else { return }
            self.viewModel.securityType = securityType
            self.viewModel.enEntrustStatus = orderStatus
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        };

        view.allSotckButtonAction = { [weak self](btn) in
            self?.viewModel.stockCode = ""
            self?.view.endEditing(true)
            if let refreshingBlock = self?.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }

        view.stockFilterAction = { [weak self](item) in
            guard let `self` = self else { return }
            let text = String(format: "%@", item.symbol)
            self.filterView.stockFilter.setTitle(text, for: .normal)
            self.filterView.stockFilterView.allStockButton.isSelected = false
            self.viewModel.stockCode = item.symbol
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }

        view.dateFilterAction = { [weak self](dateFlag, beginDate, endDate) in
            guard let `self` = self else { return }
            self.viewModel.filterDateFlag = dateFlag
            self.viewModel.entrustBeginDate = beginDate
            self.viewModel.entrustEndDate = endDate
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }

        return view
    }()

    lazy var headerView: OrderSectionHeaderView = {
        let headerView = OrderSectionHeaderView.init()
        return headerView
    }()

    lazy var selectView: UIView = { [unowned self] in
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 184))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 20

        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "history_time_limit")
        label.textColor = QMUITheme().textColorLevel1()
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.top.left.equalTo(14)
        })

        let flags: [YXDateFlag] = [.week, .month, .threeMonth, .year, .thisYear]

        var buttons = [QMUIButton]()
        flags.enumerated().forEach({ (offset, flag) in
            let button = QMUIButton()
            button.setTitle(flag.text, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
            button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().textColorLevel1().withAlphaComponent(0.2), size: CGSize(width: 35, height: 35), lineWidth: 1, cornerRadius: 4)?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)), for: .normal)
            button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().themeTextColor(), size: CGSize(width: 35, height: 35), lineWidth: 1, cornerRadius: 4)?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)), for: .selected)
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)

            if let dateFlag = viewModel.dateFlag.value , flag == dateFlag {
                button.isSelected = true
            } else if viewModel.dateFlag.value == nil, flag == .month {
                button.isSelected = true
            }

            button.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self, weak button] (_) in
                guard let strongSelf = self else { return }

                buttons.forEach({ (btn) in
                    btn.isSelected = false
                })
                button?.isSelected = true
                strongSelf.viewModel.dateFlag.accept(flag)

                UIView.animate(withDuration: 0.3, animations: {
                    strongSelf.selectBgView.alpha = 0
                })
            }).disposed(by: disposeBag)

            view.addSubview(button)
            buttons.append(button)
        })

        Array(buttons.prefix(4)).snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 14, tailSpacing: 14)
        Array(buttons.prefix(4)).snp.makeConstraints({ (make) in
            make.top.equalTo(label.snp.bottom).offset(14)
            make.height.equalTo(35)
        })

        if let firstButton = buttons.first, let lastButton = buttons.last {
            lastButton.snp.makeConstraints({ (make) in
                make.bottom.equalTo(view.snp.bottom).offset(-54)
                make.left.width.height.equalTo(firstButton)
            })
        }

        return view
        }()

    typealias ViewModelType = YXOrderListViewModel

    var viewModel: YXOrderListViewModel!

    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    override func layoutTableView() {
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindHUD()
        self.title = YXLanguageUtility.kLang(key: "hold_orders")

        initTitleView()

        self.emptyView?.verticalOffset = 0
        view.addSubview(headerView)
        view.addSubview(filterView)
        view.addSubview(marketFilterView)
        
        tableView.tableFooterView = UIView()

        marketFilterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }

        filterView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(marketFilterView.snp.bottom)
            make.height.equalTo(57)
        }
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(filterView.snp.bottom)
        }

        viewModel.requestRemoteDataSubject.subscribe(onNext: { [weak self] (isOK) in
            guard let `self` = self else { return }

            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }).disposed(by: disposeBag)

        setupRefreshHeader(tableView)
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [weak self] (endRefreshing) in
            self?.viewModel.hudSubject.onNext(.hide)
            if endRefreshing == .error || endRefreshing == .hasDataWithError {
                self?.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
        }).disposed(by: disposeBag)

        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [weak self] (endRefreshing) in
            if endRefreshing == .error || endRefreshing == .hasDataWithError {
                self?.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
        }).disposed(by: disposeBag)


        //导航栏左侧 - 返回
        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            if self.isFromAAStock {
                self.isFromAAStock = false
                //是否禁止使用修正,默认为NO
                UINavigationConfig.shared().sx_disableFixSpace = true
            }
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItems = [backItem]

        if let symbol = self.viewModel.externParams["symbol"] as? String {
            var name = ""
            if let tempName = self.viewModel.externParams["name"] as? String {
                name = tempName
            }
            let text = String(format: "%@ %@", symbol, name)
            self.filterView.stockFilter.setTitle(text, for: .normal)
            self.filterView.stockFilterView.allStockButton.isSelected = false
        }

        if let beginDate = self.viewModel.externParams["beginDate"] as? String, let endDate = self.viewModel.externParams["endDate"] as? String {
            self.filterView.dateFilter.setTitle(String(format: "%@-\n%@", beginDate, endDate), for: .normal)
        }


        viewModel.dateFlag.asDriver().drive(onNext: { [weak self] (dateFlag) in
            guard let strongSelf = self else { return }
            guard let flag = dateFlag else { return }

//            if let vc = strongSelf.parent, let mixOrderListVC = vc as? YXMixOrderListViewController {
//                mixOrderListVC.titleView?.subtitle = flag.text
//            }else {
                strongSelf.titleView?.subtitle = flag.text
//            }

            strongSelf.viewModel.hudSubject.onNext(.loading(nil, false))
            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func setupRefreshHeader(_ scrollView: UIScrollView) {
        scrollView.mj_header = refreshHeader;
        viewModel.endHeaderRefreshStatus = viewModel.bindHeaderRefresh(dependency: (headerRefresh: refreshHeader.rx.refreshing.asDriver(), disposeBag: rx.disposeBag))
        viewModel.endHeaderRefreshStatus?.drive(refreshHeader.rx.endRefreshStatus).disposed(by: rx.disposeBag)
        viewModel.endHeaderRefreshStatus?.drive(onNext: { [weak self] (status) in
            guard let strongSelf = self else { return }

            switch status {
            case .error:
                strongSelf.showErrorEmptyView()
            case .noData:
                strongSelf.showNoDataEmptyView()
            case .noMoreData,
                 .hasDataWithError:
                strongSelf.hideEmptyView()
                if scrollView.mj_footer == nil {
                    strongSelf.setupRefreshFooter(scrollView)
                  //  strongSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            default:
                strongSelf.hideEmptyView()

                if scrollView.mj_footer == nil {
                    strongSelf.setupRefreshFooter(scrollView)
                }
            }
            strongSelf.tableView.scrollToTop(animated: false)
        }).disposed(by: rx.disposeBag)
    }

    override func didInitialize() {
        super.didInitialize()
    }

    func initTitleView() {
//        if let vc = self.parent, let mixOrderListVC = vc as? YXMixOrderListViewController {
//            mixOrderListVC.titleView?.style = .subTitleVertical
//            mixOrderListVC.titleView?.accessoryType = .disclosureIndicator
//            mixOrderListVC.titleView?.subAccessoryView = UIImageView(image: UIImage(named: "icon_pull_down"))
//            mixOrderListVC.titleView?.subAccessoryViewOffset = CGPoint(x: -2, y: 0)
//            mixOrderListVC.titleView?.verticalSubtitleFont = .systemFont(ofSize: 12)
//            mixOrderListVC.titleView?.needsAccessoryPlaceholderSpace = true
//            mixOrderListVC.titleView?.subtitleLabel.textColor = QMUITheme().textColorLevel1()
//            mixOrderListVC.titleView?.needsSubAccessoryPlaceholderSpace = false
//
//            mixOrderListVC.titleView?.isUserInteractionEnabled = true
//            mixOrderListVC.titleView?.rx.controlEvent(.touchUpInside).asControlEvent().takeUntil(rx.deallocated).filter({ [weak mixOrderListVC](_) -> Bool in
//                mixOrderListVC?.tabView.selectedIndex == 0
//            }).subscribe(onNext: { [weak self] (_) in
//                guard let strongSelf = self else { return }
//
//                UIView.animate(withDuration: 0.3, animations: {
//                    strongSelf.selectBgView.alpha = 1
//                })
//
//            }).disposed(by: disposeBag)
//        }else {
            titleView?.style = .subTitleVertical
            titleView?.accessoryType = .disclosureIndicator
            titleView?.subAccessoryView = UIImageView(image: UIImage(named: "icon_pull_down"))
            titleView?.subAccessoryViewOffset = CGPoint(x: -2, y: 0)
            titleView?.verticalSubtitleFont = .systemFont(ofSize: 12)
            titleView?.needsAccessoryPlaceholderSpace = true
            titleView?.subtitleLabel.textColor = QMUITheme().textColorLevel1()
            titleView?.needsSubAccessoryPlaceholderSpace = false

            titleView?.isUserInteractionEnabled = true
            titleView?.rx.controlEvent(.touchUpInside).asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
                guard let strongSelf = self else { return }

                UIView.animate(withDuration: 0.3, animations: {
                    strongSelf.selectBgView.alpha = 1
                })

            }).disposed(by: disposeBag)
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewModel.dateFlag.value == nil {
            viewModel.dateFlag.accept(.month)
        }
    }

    override func initTableView() {
        super.initTableView()

        view.backgroundColor = QMUITheme().foregroundColor()
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.dataSource = nil
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude

        let CellIdentifier = NSStringFromClass(YXHKOrderListCell.self)

        let dataSource = RxTableViewSectionedReloadDataSource<YXTimeSection<YXOrderListViewModel.IdentifiableModel>>(
            configureCell: { [weak self] ds, tv, ip, item in
                guard let strongSelf = self else { return YXHKOrderListCell(style: .default, reuseIdentifier: CellIdentifier) }
                if let cell = tv.dequeueReusableCell(withIdentifier: CellIdentifier) as? YXHKOrderListCell {
                    cell.order.accept(item)
                    return cell
                }

                let cell = YXHKOrderListCell(style: .default, reuseIdentifier: CellIdentifier)
                cell.order.asDriver().drive(onNext: { [weak cell] (order) in
//                    cell?.nameLabel.setStockName(order?.stockName ?? "--")
                    if let stockCode = order?.symbol,let market = order?.market {
                        cell?.stockInfoView.symbol = stockCode + "." + market
                    }
                    cell?.stockInfoView.name = order?.symbolName
                    cell?.stockInfoView.market = order?.market?.lowercased()

                    if let symbolType = order?.symbolType {
                        cell?.fractionFlagLabel.isHidden = symbolType != "2"
                    } else {
                        cell?.fractionFlagLabel.isHidden = true
                    }

                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal;
                    formatter.groupingSize = 3;
                    formatter.groupingSeparator = ","
                    formatter.maximumFractionDigits = 4

                    let priceFormatter = NumberFormatter()
                    priceFormatter.numberStyle = .decimal;
                    priceFormatter.groupingSize = 3;
                    priceFormatter.groupingSeparator = ","
                    priceFormatter.maximumFractionDigits = 4

                    if let entrustPrice = order?.entrustPrice {
                        cell?.costLabel.text = priceFormatter.string(from: NSNumber.init(value: entrustPrice))  //String(format:"%.3f", entrustPrice)
                    }  else {
                        cell?.costLabel.text = "--"
                    }
                    if let entrustBusinessPrice = order?.businessAvgPrice {
                        cell?.tradeCostLabel.text =  priceFormatter.string(from: NSNumber.init(value: entrustBusinessPrice)) //String(format:"%.3f", entrustBusinessPrice)
                    }  else {
                        cell?.tradeCostLabel.text = "--"
                    }
//                    if let entrustProp = item.entrustProp, entrustProp == "d" {
//                        cell?.costLabel.text = "--"
//                    }
                    if let entrustProp = item.entrustProp, entrustProp == "AM" {
                        cell?.costLabel.text = "--"
                    }
                    if let entrustProp = item.entrustProp, entrustProp == "MKT" {
                        cell?.costLabel.text = YXLanguageUtility.kLang(key: "trade_market_price")
                    }

                    if let entrustAmount = order?.entrustQty {
                        cell?.numLabel.text = formatter.string(from: NSNumber(value: Float(entrustAmount))) ?? "0"
                    } else {
                        cell?.numLabel.text = "--"
                    }

                    if let businessAmount = order?.businessQty {
                        cell?.tradeNumLabel.text = formatter.string(from: NSNumber(value: Float(businessAmount))) ?? "0"
                    } else {
                        cell?.tradeNumLabel.text = "--"
                    }

                    cell?.statusNameLabel.text = order?.statusName
                    // 买卖方向,委托类型
                    cell?.entrustDirectionLabel.text = order?.entrustSide?.text

                    let exchangeType =  YXExchangeType.exchangeType(order?.market?.lowercased() ?? "hk")
                    if (exchangeType == .us && (order?.sessionType == 1 || order?.sessionType == 2)){

                        let panName : String = (order?.sessionType == 1 ) ? "common_pre_opening" : "common_after_opening"
                        cell?.openPreLabel.isHidden = false
                        cell?.openPreLabel.text = YXLanguageUtility.kLang(key: panName)
                    }else{
                        cell?.openPreLabel.isHidden = true
                        if order?.sessionType == 3 {
                            //是暗盘
                            if order?.entrustSide == .buy {
                                cell?.entrustDirectionLabel.text = YXLanguageUtility.kLang(key: "grey_mkt_buy")
                            } else if order?.entrustSide == .sell {
                                cell?.entrustDirectionLabel.text = YXLanguageUtility.kLang(key: "grey_mkt_sell")
                            }
                        }
                        cell?.entrustDirectionLabel.textColor = order?.entrustSide?.textColor
                    }

                    cell?.setColor(isfinal: (order?.finalStateFlag ?? .normal).rawValue == "1", direction: (order?.entrustSide ?? .buy).rawValue)

                }).disposed(by: strongSelf.disposeBag)

                cell.order.accept(item)

                return cell
        })

        dataSource.titleForHeaderInSection = { ds, index in
            ds.sectionModels[index].timeString
        }

        viewModel.sectionDataSouce
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)


        tableView.rx.itemSelected.asDriver().drive(onNext: { [weak self] (indexPath) in
            guard let strongSelf = self else { return }
            var sections = strongSelf.viewModel.sectionDataSouce.value
            let order = sections[indexPath.section].items[indexPath.row]
            guard order.symbol != nil else { return }

            guard strongSelf.viewModel.showExpand else {
                var id: String?
//                if self?.viewModel.allOrderType == .dayMargin {
//                    id = order.id
//                }else {
//                    id = order.entrustId
//                }
                id = order.id
                if let orderId = id {
                    (UIViewController.current() as? QMUICommonViewController)?.trackViewClickEvent(name: "Order list_tab",
                                                                                                   other: ["stock_code": order.symbol ?? "",
                                                                                                           "stock_name": order.symbolName ?? ""])
                    let viewModel = YXOrderDetailViewModel(market: order.market?.lowercased() ?? "", symbol: order.symbol ?? "", entrustId: orderId, name: order.symbolName ?? "", allOrderType: self?.viewModel.allOrderType ?? .normal)
                    strongSelf.viewModel.navigator.push(YXModulePaths.orderDetail.url, context:viewModel)
                }
                return
            }

            if let selectedIndexPath = strongSelf.viewModel.selectedIndexPath {
                var array = sections[selectedIndexPath.section].items
                array.remove(at: selectedIndexPath.row + 1)
                sections[selectedIndexPath.section].items = array
                if selectedIndexPath == indexPath {
                    strongSelf.viewModel.selectedIndexPath = nil
                    strongSelf.viewModel.selectedItem = nil
                    strongSelf.viewModel.sectionDataSouce.accept(sections)
                } else {
                    var sourceIndexPath = indexPath
                    if sourceIndexPath.section == selectedIndexPath.section, sourceIndexPath.row > selectedIndexPath.row {
                        sourceIndexPath = IndexPath(row: sourceIndexPath.row - 1, section: sourceIndexPath.section)
                    }

                    var array = sections[sourceIndexPath.section].items
                    strongSelf.viewModel.selectedIndexPath = sourceIndexPath
                    strongSelf.viewModel.selectedItem = array[sourceIndexPath.row]
                    array.insert(YXOrderItem(), at: sourceIndexPath.row + 1)
                    sections[sourceIndexPath.section].items = array
                    strongSelf.viewModel.sectionDataSouce.accept(sections)
                    strongSelf.tableView.scrollToRow(at: IndexPath(row: sourceIndexPath.row + 1, section: sourceIndexPath.section), at: .none, animated: false)
                }
            } else {
                strongSelf.viewModel.selectedIndexPath = indexPath
                strongSelf.viewModel.selectedItem = order

                var array = sections[indexPath.section].items
                array.insert(YXOrderItem(), at: indexPath.row + 1)
                sections[indexPath.section].items = array
                strongSelf.viewModel.sectionDataSouce.accept(sections)
                strongSelf.tableView.scrollToRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section), at: .none, animated: false)
            }
        }).disposed(by: disposeBag)
    }

    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }

    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        if self.tableView.mj_footer != nil {
            self.tableView.mj_footer.resetNoMoreData()
        }
        self.emptyView?.imageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.emptyView?.textLabelFont = UIFont.systemFont(ofSize: 14)
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noOrder")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "hold_no_order"))
    }
}

extension YXOrderListViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        24
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 300, height: 24))
        label.text = self.viewModel.sectionDataSouce.value[section].timeString
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        view.addSubview(label)
        return view
    }
}

class OrderSectionHeaderView: UIView {


    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text =  YXLanguageUtility.kLang(key: "orderfilter_trade_time")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3

        return label
    }()

    fileprivate lazy var avgLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "entrust_and_avg")
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.3

        return label
    }()

    fileprivate lazy var turnoverLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "entrust_and_success")
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.3

        return label
    }()

    fileprivate lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "order_direction")
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = QMUITheme().foregroundColor()

        addSubview(nameLabel)
        addSubview(avgLabel)
        addSubview(turnoverLabel)
        addSubview(stateLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalTo(self)
        }

        stateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.width.equalTo(60)
            make.centerY.equalTo(self)
        }

        turnoverLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-100)
            make.width.equalTo(55)
            make.centerY.equalTo(self)
        }

        avgLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-160)
            make.width.equalTo(60)
            make.centerY.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

}

