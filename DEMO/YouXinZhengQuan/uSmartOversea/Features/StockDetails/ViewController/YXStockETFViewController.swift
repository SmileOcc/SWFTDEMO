//
//  YXStockETFViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import YXKit

class YXStockETFViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockETFViewModel! = YXStockETFViewModel()
    let reuseIdentifier = "YXNewStockMarketedCell"
    var refreshTimer: Timer?
    var quoteRequest: YXQuoteRequest?
    let config = YXNewStockMarketConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "stock_detail_ETF_title")
        bindHUD()
        handleBlock()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        requestQuoteData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewModel.updateLevel()
        self.refreshVisibleData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        quoteRequest?.cancel()
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.tableHeaderView = tableHeaderView
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
                cell = YXNewStockMarketedCell(style: .default, reuseIdentifier: self.reuseIdentifier, sortTypes: self.sortArrs, config: self.config)
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
            if isDelay && self.viewModel.dataSource.value.count > 0 {
                self.tableView.tableFooterView = self.tableFooterView
            }
            //self.requestQuoteData()
        }).disposed(by: rx.disposeBag)
        
        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)

    }
    
    func refreshHeaderData(quote: YXV2Quote) {
        var priceBasic = 1
        if let priceBase = quote.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }
        
        var textColor = YXStockColor.currentColor(.flat)
        if let name = quote.name {
            nameLabel.text = name
        }
        //roc
        if let roc = quote.pctchng?.value {
            let number = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            if roc > 0 {
                rocLabel.text = (number ?? "")
            } else if roc == 0 {
                rocLabel.text = "0.00%"
            } else {
                rocLabel.text = (number ?? "")
            }
            textColor = YXStockColor.currentColor(Double(roc))
            rocLabel.textColor = textColor
        }
        
        //change
        if let change = quote.netchng?.value {
            let number = YXToolUtility.stockPriceData(Double(change), deciPoint: 3, priceBase: priceBasic)
            if change > 0 {
                changeLabel.text = "+" + (number ?? "")
            } else if change == 0 {
                changeLabel.text = "0.00"
            } else {
                changeLabel.text = number
            }
            
            changeLabel.textColor = textColor
        }
        
        //now
        if let now = quote.latestPrice?.value {
            let nowString = YXToolUtility.stockPriceData(Double(now), deciPoint: 3, priceBase: priceBasic)
            priceLabel.text = nowString
            priceLabel.textColor = textColor
        }
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "newStock_no_market_stock"))
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
    
    var sortArrs = [YXStockRankSortType.now,
                    YXStockRankSortType.roc,
                    YXStockRankSortType.change,
                    YXStockRankSortType.volume,
                    YXStockRankSortType.amount]
    
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
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                if self.qmui_isViewLoadedAndVisible() {
                    self.viewModel.updateLevel()
                    self.refreshVisibleData()
                }

            }).disposed(by: rx.disposeBag)
    }
    
    lazy var tableFooterView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = QMUITheme().foregroundColor()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        do {
            let label = QMUILabel()
            label.text = YXLanguageUtility.kLang(key: "stock_detail_delayTip")
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .left
            label.textColor = QMUITheme().textColorLevel3()
            label.numberOfLines = 0
            footerView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.top.equalToSuperview().offset(10)
            })
        }
        
        return footerView
    }()
    
    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 64)
        
        view.addSubview(self.nameLabel)
        view.addSubview(self.priceLabel)
        view.addSubview(self.rocLabel)
        view.addSubview(self.changeLabel)
        
        self.nameLabel.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth - 210)
        })
        
        self.priceLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.nameLabel.snp.right).offset(10)
            make.centerY.equalTo(self.nameLabel.snp.centerY)
        })
        
        self.changeLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.priceLabel.snp.right).offset(10)
            make.centerY.equalTo(self.priceLabel.snp.centerY)
        })
        
        self.rocLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.changeLabel.snp.right).offset(6)
            make.centerY.equalTo(self.changeLabel.snp.centerY)
        })
        
        let bottomView = UIView()
        bottomView.backgroundColor = QMUITheme().backgroundColor()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(10)
        })
        
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 16.0
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        label.text = self.viewModel.name ?? "--"
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        return label
    }()
}

extension YXStockETFViewController {
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
    
    func requestQuoteData() {
        
        quoteRequest?.cancel()
        quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [Secu(market: viewModel.market, symbol: viewModel.symbol)], level: viewModel.userLevel, handler: ({ [weak self] (quotes, scheme) in
            guard let `self` = self else { return }
            if let quote = quotes.first {
                self.refreshHeaderData(quote: quote)
            }
        }))
    }
   
}

extension YXStockETFViewController {
    
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
            //let item = viewModel.dataSource.value[indexPath.row]
            var inputs: [YXStockInputModel] = []
            for info in viewModel.dataSource.value {
                if let market = info.trdMarket, let symbol = info.secuCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row])
            }
        }
    }
}



extension YXStockETFViewController {
    
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
        let visibleCells = self.tableView.visibleCells
        if let cell = visibleCells.first, let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row < viewModel.dataSource.value.count {
                viewModel.services.request(.quotesRank(sortType: viewModel.sorttype.rawValue, sortDirection: viewModel.sortdirection, pageDirection: 0, from: indexPath.row, count: viewModel.perPage, code: kYXIndexIXICETF, market: YXMarketType.US.rawValue, level: viewModel.userLevel.rawValue), response: (viewModel.etfResultResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
}
