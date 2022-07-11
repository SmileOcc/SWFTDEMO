//
//  YXDividendsViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXDividendsViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    override var pageName: String {
        "Dividends"
      }
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXDividendsViewModel!
    let reuseIdentifier = "YXHKADRListCell"
    var refreshTimer: Timer?

    
    lazy var sortArrs: [YXStockRankSortType] = {
        return [.dividendsPriceChg, .dividendsRate, .dividendsYield]
    }()
    
    let config = YXNewStockMarketConfig.init(leftItemWidth: 120.0, itemWidth: (YXConstant.screenWidth - 120 - 10 - 18) / 3.0)

    var quoteLevelChange = false
        
    private lazy var popover:YXStockPopover = {
        let popover = YXStockPopover()
        return popover
    }()
    
    lazy var filterBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(viewModel.rankModels[viewModel.selectYearIndex].year, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.spacingBetweenImageAndTitle = 3
        btn.imagePosition = .right
        let arrowImageNormal =  UIImage(named: "warrant_filter_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel3())
        let arrowImageSelected = UIImage(named: "warrant_filter_arrow")?.qmui_image(withTintColor: QMUITheme().themeTintColor())
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
        btn.setImage(arrowImageNormal, for: .normal)
        btn.setImage(arrowImageSelected, for: .selected)
        btn.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.popover.show(self.getMenuView(), from: sender)

        }
        return btn
    }()
    
    func getMenuView() -> UIView {

        var maxWidth: CGFloat = 0
        for title in viewModel.years {
            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }
        let menuView = YXStockLineMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth + 48, height: CGFloat(48 * viewModel.years.count)), andTitles: viewModel.years)
        menuView.clickCallBack = {
            [weak self] sender in
            guard let `self` = self else { return }
            
            self.popover.dismiss()
            if sender.isSelected {
                return
            }
            let selectTitle = self.viewModel.years.indices.contains(sender.tag) ? self.viewModel.years[sender.tag] : ""
            self.filterBtn.setTitle(selectTitle, for: .selected)
            self.filterBtn.isSelected = true
            
            self.viewModel.selectYearIndex = self.viewModel.rankModels.map{ $0.year.int64Value }.firstIndex(of: selectTitle.int64Value) ?? 0
            self.refreshHeader.refreshingBlock?()

        }

        return menuView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "market_entrance_dividens")
        
        view.addSubview(filterBtn)
        filterBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            if #available(iOS 11.0, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            } else {
                $0.top.equalTo(self.topLayoutGuide.snp.top).offset(12)
            }
        }

        
        bindHUD()
        bindTableView()

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if self.qmui_isViewLoadedAndVisible() {
                    self.viewModel.updateLevel()
                    if let refreshingBlock = self.refreshHeader.refreshingBlock {
                        refreshingBlock()
                    }
                } else {
                    self.quoteLevelChange = true
                }

            }).disposed(by: rx.disposeBag)

        self.qmui_visibleStateDidChangeBlock = {
            [weak self] (vc, state) in
            guard let `self` = self else { return }

            if state == .didAppear, self.quoteLevelChange {
                self.quoteLevelChange = false
                self.viewModel.updateLevel()
                if let refreshingBlock = self.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func layoutTableView() {
            tableView.snp.remakeConstraints { (make) in
                make.right.left.bottom.equalTo(view)
                make.top.equalTo(filterBtn.snp.bottom).offset(12)
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    fileprivate func initNavigationBar() {
        let searchItem = UIBarButtonItem.qmui_item(with: UIImage(named: "market_search") ?? UIImage(), target: self, action: nil)
        searchItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            self.viewModel.navigator.present(YXModulePaths.search.url, animated: false)
        }.disposed(by: self.disposeBag)
        
        navigationItem.rightBarButtonItems = [searchItem]
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        setupRefreshHeader(tableView)
        
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
        tableView.dataSource = nil
        
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
            var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
            if cell == nil {
                cell = YXDividendsCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                if let adrCell = cell as? YXDividendsCell {
                    adrCell.scrollView.contentSize = CGSize(width: adrCell.scrollView.contentSize.width + 10, height: adrCell.scrollView.contentSize.height)
                    self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                        point != adrCell.scrollView.contentOffset
                    }.bind(to:adrCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                    adrCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                        point != self?.viewModel.contentOffsetRelay.value
                    }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                }
            }
            let tableCell = (cell as! YXDividendsCell)
            tableCell.isDelay = (self.viewModel.userLevel == .delay)
//            tableCell.rankType = self.viewModel.rankType
            // 点击港股代码
//            if self.viewModel.rankType == .adr, let _ = item.trdMarket, let _ = item.secuCode  {
//                tableCell.tapHKCodeAction = { [weak self] in
//                    guard let `self` = self else { return }
//                    var inputs: [YXStockInputModel] = []
//                    for info in self.viewModel.dataSource.value {
//                       if let market = info.trdMarket, let symbol = info.secuCode {
//
//                           let input = YXStockInputModel()
//                           input.market = market
//                           input.symbol = symbol
//                        input.name =  info.chsNameAbbr ?? ""
//                           inputs.append(input)
//                       }
//                   }
//
//                   if inputs.count > 0 {
//                       self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : row])
//                   }
//
//                }
//            }
            // 点击cell
            tableCell.clickCellAction = { [weak self] in
                guard let `self` = self else { return }
                
                if let _ = item.trdMarket, let _ = item.secuCode {

                    var inputs: [YXStockInputModel] = []
                    for info in self.viewModel.dataSource.value {
                        if let market = info.trdMarket, let symbol = info.secuCode {

                            let input = YXStockInputModel()
                            input.market = market
                            input.symbol = symbol
                            input.name = info.chsNameAbbr
                            inputs.append(input)
                        }
                    }

                    if inputs.count > 0 {
                        self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : row])
                        let info = inputs[row]
                        trackViewClickEvent(name: "stocklist_item", other: ["stock_code" : info.symbol, " stock_name": info.name ?? ""])
                    }
                }

            }
            tableCell.refreshUI(model: item, isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
            return cell!
        }
        .disposed(by: disposeBag)
        
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
            
            if self.viewModel.userLevel == .bmp && self.viewModel.dataSource.value.count >= 20 && self.viewModel.market == YXMarketType.HK.rawValue {
                self.tableView.tableFooterView = self.tableFooterView
                self.footerLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bmpTip")
            }
            
            if self.viewModel.userLevel == .bmp && self.tableView.mj_footer != nil {
                self.tableView.mj_footer?.removeFromSuperview()
                self.tableView.mj_footer = nil
            }
            
        }).disposed(by: rx.disposeBag)
        
        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    lazy var sectionHeaderView: YXNewStockMarketedSortView = {
        
        let view = YXNewStockMarketedSortView.init(sortTypes: sortArrs, config: self.config)
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.kSectionHeaderHeight)
        view.nameLabel.text = YXLanguageUtility.kLang(key: "market_codeName_wrap")
        if YXUserManager.isENMode() {
            view.nameLabel.numberOfLines = 2
            view.nameLabel.adjustsFontSizeToFitWidth = true
            view.nameLabel.minimumScaleFactor = 0.3
        }
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        
        for subview in view.scrollView.subviews {
            if subview.isKind(of: YXNewStockMarketedSortButton.self), let button = subview as? YXNewStockMarketedSortButton {
                switch button.mobileBrief1Type {
                case .dividendsPriceChg:
                    button.setImage(nil, for: .normal)
                    button.hiddenImage = true
                default:
                    break
                }
                button.titleLabel?.numberOfLines = 2
            }
        }
        
        view.setStatus(sortState: .descending, mobileBrief1Type: .ahSpread)
        
        view.onClickSort = {
            [weak self] (state, type) in
            guard let `self` = self else { return }
            if type == .dividendsRate {
                self.viewModel.sortType = .dividendsRate
            } else if type == .dividendsYield {
                self.viewModel.sortType = .dividendsYield
            }
            switch state {
            case .normal:
                self.viewModel.direction = 0
            case .descending:
                self.viewModel.direction = 1
            case .ascending:
                self.viewModel.direction = 0
            default:
                break
            }
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }
        return view
    }()
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_no_data"))

    }
    
    
    lazy var tableFooterView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = QMUITheme().foregroundColor()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        do {
            footerView.addSubview(footerLabel)
            footerLabel.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.top.equalToSuperview().offset(10)
            })
        }
        
        return footerView
    }()
    
    lazy var footerLabel: UILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 0
        return label
    }()
}


extension YXDividendsViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        68
    }
    
    var kSectionHeaderHeight: CGFloat {
        34
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        kSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        if indexPath.row < viewModel.dataSource.value.count {
//            let item = viewModel.dataSource.value[indexPath.row]
//            }
//        }
    }
    
}

extension YXDividendsViewController {
    //轮询数据
    private func startTimer() {
        
        self.stopTimer()
        if viewModel.userLevel != .bmp {
            let rankInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.rankFreq))
            refreshTimer = Timer.scheduledTimer(timeInterval: rankInterval, target: self, selector: #selector(refreshVisibleData), userInfo: nil, repeats: true)
        }
    }
    
    private func stopTimer() {
        if refreshTimer != nil {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    //和大陆版资讯详情页面一致，滑动停止更新roc数据
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            refreshVisibleData()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView.contentOffset.y > 0 {
            refreshVisibleData()
        }
    }
    
    //更新roc数据
    @objc func refreshVisibleData() {
        if viewModel.userLevel == .bmp {
            return
        }
        let visibleCells = self.tableView.visibleCells
        if let cell = visibleCells.first, let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row < viewModel.dataSource.value.count {
                viewModel.services.request(.quotesRank(sortType: viewModel.sortType.rawValue, sortDirection: viewModel.direction, pageDirection: 0, from: indexPath.row, count: viewModel.perPage, code: self.viewModel.code, market: self.viewModel.market, level: viewModel.userLevel.rawValue), response: (viewModel.resultResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
}
