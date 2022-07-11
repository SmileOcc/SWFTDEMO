//
//  YXNewStockMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXNewStockMarketViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    @objc var tabPageViewScrollCallBack: YXTabPageScrollBlock?
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXNewStockMarketViewModel! = YXNewStockMarketViewModel()
    let reuseIdentifier = "YXNewStockMarketedCell"
    var refreshTimer: Timer?
    
    let config = YXNewStockMarketConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "newStock_new_market_stock")
        bindHUD()
        initNavigationBar()
        handleBlock()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.updateLevel()
        refreshVisibleData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

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
            guard let strongSelf = self else { return }
            strongSelf.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url)
            }.disposed(by: disposeBag)
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
        var isDelay = false
        if viewModel.userLevel == .delay {
            isDelay = true
        }
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
                var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
                if cell == nil {
                    cell = YXNewStockMarketedCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                    if let marketCell = cell as? YXNewStockMarketedCell {
                        marketCell.isDelay = isDelay
                        self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                            point != marketCell.scrollView.contentOffset
                        }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                        marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                            point != self?.viewModel.contentOffsetRelay.value
                        }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                    }
                }
                let tableCell = (cell as! YXNewStockMarketedCell)
                tableCell.isDelay = (self.viewModel.userLevel == .delay)
                tableCell.refreshUI(model: item, isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
                return cell!
            }
            .disposed(by: disposeBag)
        
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
            
            if self.viewModel.market == YXMarketType.HK.rawValue {
                if isDelay && self.viewModel.dataSource.value.count > 0 {
                    self.tableView.tableFooterView = self.tableFooterView
                    self.footerLabel.text = YXLanguageUtility.kLang(key: "common_delaytips")
                } else if self.viewModel.userLevel == .bmp && self.viewModel.dataSource.value.count >= 20 {
                    self.tableView.tableFooterView = self.tableFooterView
                    self.footerLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bmpTip")
                }
                
                if self.viewModel.userLevel == .bmp && self.tableView.mj_footer != nil {
                    self.tableView.mj_footer?.removeFromSuperview()
                    self.tableView.mj_footer = nil
                }
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
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        return view
    }()
    
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
    
//    var sortArrs = [YXStockRankSortType.listDate,
//                    YXStockRankSortType.issuePrice,
//                    YXStockRankSortType.now,
//                    YXStockRankSortType.totalRoc,
//                    YXStockRankSortType.listedDays,
//                    YXStockRankSortType.firstDayClosePrice,
//                    YXStockRankSortType.firstDayRoc,
//                    YXStockRankSortType.winningRate,
//                    YXStockRankSortType.greyChgPct]
    
    var sortArrs:[YXStockRankSortType] {
        get {
            if viewModel.market == YXMarketType.HK.rawValue {
                return [.listDate, .issuePrice, .now, .totalRoc, .listedDays, .firstDayClosePrice, .firstDayRoc, .winningRate, .greyChgPct]
            }else {
                return [.listDate, .issuePrice, .now, .totalRoc, .listedDays, .firstDayClosePrice, .firstDayRoc]
            }
        }
    }
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
           [weak self] (state, type) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sorttype = type
            switch state {
            case .normal:
                strongSelf.viewModel.sortdirection = 1
            case .descending:
                strongSelf.viewModel.sortdirection = 1
            case .ascending:
                strongSelf.viewModel.sortdirection = 0
            }
            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }


        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if self.qmui_isViewLoadedAndVisible() {
                    self.viewModel.updateLevel()
                    self.refreshVisibleData()
                }
            }).disposed(by: rx.disposeBag)

    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock{
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "newStock_no_market_stock"))
    }
}

extension YXNewStockMarketViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        60
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
        if indexPath.row < viewModel.dataSource.value.count {
            let item = viewModel.dataSource.value[indexPath.row]
            if let symbol = item.secuCode {

                let input = YXStockInputModel()
                input.market = item.trdMarket ?? ""
                input.symbol = symbol
                input.name = item.chsNameAbbr ?? ""
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }

        }
    }
}

extension YXNewStockMarketViewController {
    
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
                viewModel.services.request(.quotesRank(sortType: viewModel.sorttype.rawValue, sortDirection: viewModel.sortdirection, pageDirection: 0, from: indexPath.row, count: viewModel.perPage, code: "NEW_ALL", market: self.viewModel.market, level: viewModel.userLevel.rawValue), response: (viewModel.resultResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tabPageViewScrollCallBack?(scrollView)
    }
}

extension YXNewStockMarketViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        self.tabPageViewScrollCallBack = callback
    }
}
