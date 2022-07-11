//
//  YXHotIndustryViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXHotIndustryViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    var trackName = "Top Industries"
    
    override var pageName: String {
        trackName
    }
    
    var refreshTimer: Timer?

    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXHotIndustryViewModel! = YXHotIndustryViewModel()
    let reuseIdentifier = "YXHotIndustryCell"
    
    var sortArrs = [YXStockRankSortType.roc,
                    YXStockRankSortType.leadStock]
    
    let config = YXNewStockMarketConfig.init(leftItemWidth: YXConstant.screenWidth - 2 * 100 - 10 - 18)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.title ?? YXLanguageUtility.kLang(key: "markets_news_hk_industry")
        bindHUD()
        if let showSearch = viewModel.showSearch {
            //1.美股热门行业页面 2.港股热门行业页面、港股adr页面
            if showSearch {
                initNavigationBar()
            }
        } else {
            initNavigationBar()
        }
        handleBlock()
        bindTableView()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        if viewModel.market == kYXMarketUS {
            trackName = "Top Industries US"
        } else if viewModel.market == kYXMarketHK {
            trackName = "Top Industries HK"
        } else if viewModel.market == kYXMarketSG {
            trackName = "Top Industries SG"
        }
    }
    
    override func layoutTableView() {
        
        tableView.snp.remakeConstraints { (make) in
            make.right.left.bottom.equalTo(view)
            make.top.equalTo(YXConstant.navBarHeight())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.userLevel != .bmp {
            startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        if let refreshingBlock = refreshHeader.refreshingBlock{
            refreshingBlock()
        }
        tableView.dataSource = nil
        
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
            var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
            if cell == nil {
                cell = YXHotIndustryCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
            }
            let tableCell = (cell as! YXHotIndustryCell)
            tableCell.onClickLeadStock = { [weak self] in
                guard let `self` = self else { return }

                if let _ = item.leadStock?.trdMarket, let _ = item.leadStock?.secuCode {

                    var inputs: [YXStockInputModel] = []
                    for info in self.viewModel.dataSource.value {
                        if let market = info.trdMarket, let symbol = info.leadStock?.secuCode {

                            let input = YXStockInputModel()
                            input.market = market
                            input.symbol = symbol
                            input.name = info.leadStock?.chsNameAbbr ?? ""
                            inputs.append(input)
                        }
                    }

                    if inputs.count > 0 {
                        self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : row])
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
        view.nameLabel.text = YXLanguageUtility.kLang(key: "markets_news_name")
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        view.setStatus(sortState: .descending, mobileBrief1Type: .roc)
        
        for subview in view.scrollView.subviews {
            if subview.isKind(of: YXNewStockMarketedSortButton.self), let button = subview as? YXNewStockMarketedSortButton {
                if button.mobileBrief1Type == .leadStock {
                    button.setImage(nil, for: .normal)
                    button.hiddenImage = true
                }
                button.titleLabel?.numberOfLines = 2
            }
        }
        return view
    }()
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            if type == .roc {
                switch state {
                case .normal:
                    strongSelf.viewModel.orderDirection = 1
                case .descending:
                    strongSelf.viewModel.orderDirection = 1
                case .ascending:
                    strongSelf.viewModel.orderDirection = 0
                }
            }
            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock{
                refreshingBlock()
            }
        }
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
//        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "deliver_no_apply_company"))
    }
}

extension YXHotIndustryViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        48
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
            let items = viewModel.dataSource.value

            var inputs: [YXStockInputModel] = []
            for info in items {
                if let market = info.trdMarket, let symbol = info.yxCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row])
                let info = inputs[indexPath.row]
                trackViewClickEvent(name: "stocklist_item" ,other:["stock_code" : info.symbol ,"stock_name" : info.name!])
            }
        }
    }

}


extension YXHotIndustryViewController {
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
    
    //更新roc数据
    @objc func refreshVisibleData() {
        let visibleCells = self.tableView.visibleCells
        if let cell = visibleCells.first, let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row < viewModel.dataSource.value.count {
                viewModel.services.request(.quotesRank(sortType: 1, sortDirection: viewModel.orderDirection, pageDirection: 0, from: indexPath.row, count: viewModel.perPage, code: self.viewModel.rankCode, market: self.viewModel.market, level: viewModel.userLevel.rawValue), response: (viewModel.resultResponse)).disposed(by: rx.disposeBag)
            }
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
    
}
