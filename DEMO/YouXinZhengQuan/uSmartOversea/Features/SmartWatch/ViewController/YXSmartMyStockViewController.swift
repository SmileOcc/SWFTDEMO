//
//  YXSmartMyStockViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import MJRefresh
import YXKit
import RxSwift

class YXSmartMyStockViewController: YXHKTableViewController, ViewModelBased, HUDViewModelBased {
    
    override func didInitialize() {
        self.hidesBottomBarWhenPushed = true
    }
    
    var viewModel: YXSmartViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var timerBag: DisposeBag?
    
    var smartType: YXSmartType = .selfStock  //2-自选股 1-持仓
    var didAppear: Bool = false
    let reuseIdentifier = "YXSmartMyStockCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = QMUITheme().foregroundColor()
        tableView.register(YXSmartMyStockCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.tableHeaderView = tableHeaderView
        
        bindHUD()
        addRefreshFooter()
        bindViewModel()
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        if self.viewModel.smartType == .selfStock {
            addRereshHeader() //HK-1704 智能盯盘持仓不需要下拉更新
        }
        headerRereshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didAppear = true
        if (self.viewModel.needReloadData) {
            self.tableView.reloadData()
            self.viewModel.needReloadData = false
        }
        if self.viewModel.smartType == .selfStock {
            startTimer()
        }
        // 神策事件：开始记录
        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didAppear = false
        stopTimer()
      
    }
    
    //MARK:  获取用户盯盘请求 Method
    func requestStockData(seqNum: Int64, showLoading: Bool, unixTime: Int64 = 0) {
        
        if showLoading {
            self.viewModel.hudSubject.onNext(.loading(nil, false))
        }
        var params: yxSmartPostSmart
        params.uid = String(format: "%lld", YXUserManager.userUUID())
        params.count = self.viewModel.perPageCount
        var codeArray: [String] = []
        for item in YXSecuGroupManager.shareInstance().allSecuGroup.list {
            codeArray.append(item.market + item.symbol)
        }
        params.stockList = self.viewModel.smartType.rawValue == 1 ? nil : (codeArray.count > 0 ? codeArray : nil)
        params.smartType = self.viewModel.smartType.rawValue
        params.fontType = YXUserManager.curLanguage().rawValue
        params.seqNum = seqNum
        params.unixTime = unixTime
        self.viewModel.services.smartService.request(.postSmart(params), response: (self.viewModel.stockResultResponse)).disposed(by: self.disposeBag)
    }
    
    //实时行情roc获取方法
    func requestHzRealTimeData(ids: [Secu]) {
       
        YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: ids, level: .level2, handler: ({ [weak self] (quotes, scheme) in
            guard let `self` = self else { return }
            self.viewModel.hzDataSource = quotes
            DispatchQueue.global().async {
                for model in quotes {
                    if let roc = model.pctchng?.value, let market = model.market, let symbol = model.symbol {
                        let key = market + symbol
                        self.viewModel.needReloadData = true
                        self.viewModel.stockRocSource[key] = Int(roc)
                    }
                }
                DispatchQueue.main.async {
                    if self.didAppear {
                        self.reloadVisibleCells()
                    }
                }
            }
        }))
    }
    
    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 8)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    func showOrHideEmptyView(isError: Bool) {
        
        if self.viewModel.dataSource.count <= 0 {
            if isError {
                self.showErrorEmptyView()
            } else {
                self.showNoDataEmptyView()
                self.emptyView?.imageView.image = UIImage.init(named: "empty_noStock")
                if self.viewModel.smartType == .selfStock {
                    self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "smart_noSelfStock"))
                } else {
                    self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "smart_noPosition"))
                }
            }
        } else {
            self.hideEmptyView()
        }
    }
    
    override func emptyRefreshButtonAction() {
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        headerRereshing()
    }
}

extension YXSmartMyStockViewController {
    
    func bindViewModel() {
        
        self.viewModel.stockResultSubject.subscribe(onNext: {
            [weak self] (isSuccess, noMoreData, message) in
            guard let strongSelf = self else { return }
            
            if message != nil && (strongSelf.viewModel.isRefeshing || strongSelf.viewModel.isPulling) {
                strongSelf.networkingHUD.showError(message!, in: strongSelf.view, hideAfter: 2)
            }
            
            if strongSelf.viewModel.isRefeshing {
                strongSelf.viewModel.isRefeshing = false
                if strongSelf.tableView.mj_header != nil {
                    strongSelf.tableView.mj_header?.endRefreshing()
                }
            }
            
            if strongSelf.viewModel.isPulling {
                strongSelf.viewModel.isPulling = false
                if noMoreData && strongSelf.viewModel.dataSource.count > 0 {
                    strongSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    strongSelf.tableView.mj_footer?.endRefreshing()
                }
            }
            if isSuccess {
                if !strongSelf.viewModel.stockNameSource.isEmpty {
                    strongSelf.requestHzRealTimeData(ids: strongSelf.viewModel.stockNameSource)
                }
                if strongSelf.didAppear {
                    strongSelf.tableView.reloadData()
                } else if (!noMoreData) {
                    strongSelf.viewModel.needReloadData = true
                }
            }
            
            strongSelf.showOrHideEmptyView(isError: !isSuccess)
            
        }).disposed(by: self.disposeBag)
        
        if self.viewModel.smartType == .stockPosition {
            _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: kYXSocketSmartNotification))
                .takeUntil(self.rx.deallocated)
                .subscribe(onNext: {
                    [weak self] noti in
                    guard let strongSelf = self else { return }
                    strongSelf.headerRereshing()
                })
        }
        
    }

    //轮询数据
    private func startTimer() {
        
        self.stopTimer()
        self.timerBag = DisposeBag()
        if let timerBag = self.timerBag {
            let interval = RxTimeInterval.seconds((YXGlobalConfigManager.configFrequency(.selfStockFreq)))
            Observable<Int>.timer(interval, period: interval, scheduler: MainScheduler.instance)
                .subscribe({ [weak self] _ in
                    guard let strongSelf = self else { return }
                    if strongSelf.didAppear {
                        strongSelf.requestStockData(seqNum: 0, showLoading: false)
                    }
                }).disposed(by: timerBag)
        }
    }
    
    private func stopTimer() {
        self.timerBag = nil
    }
}

extension YXSmartMyStockViewController {
    //下拉更新
    func addRereshHeader() {
        self.tableView.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
    }
    
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
        requestStockData(seqNum: 0, showLoading: false)
    }
    //上拉更新
    func addRefreshFooter() {
        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(footerRereshing))
    }
    
    @objc func footerRereshing() {
        
        guard !self.viewModel.isPulling, self.viewModel.dataSource.count > 0 else { return }
        self.viewModel.isPulling = true
        if let seqNum: Int64 = self.viewModel.dataSource.last?.last?.seqNum, let unixTime = self.viewModel.dataSource.last?.last?.unixTime {
            requestStockData(seqNum: seqNum, showLoading: false, unixTime: unixTime)
        }
    }
}

extension YXSmartMyStockViewController {
    //MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: YXSmartMyStockCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! YXSmartMyStockCell
        
        refreshCellData(cell: cell, indexPath: indexPath)
        return cell
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        tableView.qmui_heightForCell(withIdentifier: reuseIdentifier, cacheBy: indexPath, configuration: { [unowned self](tableviewCell) in
            if let cell = tableviewCell as? YXSmartMyStockCell {
                self.refreshCellData(cell: cell, indexPath: indexPath)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        let headerLabel = UILabel()
        headerLabel.backgroundColor = QMUITheme().foregroundColor()
        headerLabel.frame = CGRect(x: 18, y: 0, width: headerView.bounds.width - 36, height: headerView.bounds.height)
        headerLabel.textAlignment = .left
        headerLabel.textColor = QMUITheme().textColorLevel1()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
        headerLabel.numberOfLines = 0
        var prefix = ""
        var suffix = ""
        if let model: YXSmartMyStockSmartStare = self.viewModel.dataSource[section].first {

            if YXUserManager.isENMode() {
                let formatter = "dd MM yyyy"
                let currentDate = YXDateHelper.dateSting(from: TimeInterval(model.unixTime), formatter: formatter)
                var monthArray = currentDate.components(separatedBy: " ")
                prefix = currentDate
                if monthArray.count > 1, let monthIndex = Int(monthArray[1]), monthIndex >= 1 {
                    monthArray[1] = YXToolUtility.enMonthName(monthIndex)
                    prefix = monthArray.joined(separator: " ")
                }
            } else {
                let formatter = "yyyy" + YXLanguageUtility.kLang(key: "common_year") + "MM" + YXLanguageUtility.kLang(key: "common_month") +  "dd" + YXLanguageUtility.kLang(key: "common_day")
                prefix = YXDateHelper.dateSting(from: TimeInterval(model.unixTime), formatter: formatter)
            }
            suffix = YXDateHelper.weekDay(from: TimeInterval(model.unixTime))
        }
        headerLabel.text = prefix + " " + suffix
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    //更新可见cell
    func reloadVisibleCells() {
        let visibleCells = self.tableView.visibleCells
        for cell in visibleCells {
            if let indexPath = self.tableView.indexPath(for: cell) {
                refreshCellData(cell: (cell as! YXSmartMyStockCell), indexPath: indexPath)
            }
        }
    }
    
    //cell数据填充方法
    func refreshCellData(cell: YXSmartMyStockCell, indexPath: IndexPath) {
        var position: YXSmartMyStockCell.CellPosition = .middle
        if indexPath.row == 0 {
            position = .top
            if indexPath.row == self.viewModel.dataSource[indexPath.section].count - 1 {
                position = .both
            }
        } else if indexPath.row == self.viewModel.dataSource[indexPath.section].count - 1 {
            position = .bottom
        }
        let model = self.viewModel.dataSource[indexPath.section][indexPath.row]
        var roc: Int? = nil
        if !self.viewModel.stockRocSource.isEmpty, let code = model.stockCode {
            roc = self.viewModel.stockRocSource[code]
        }
        cell.reloadData(position: position, model: model, roc: roc)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < self.viewModel.dataSource.count && indexPath.row < self.viewModel.dataSource[indexPath.section].count {
            let model = self.viewModel.dataSource[indexPath.section][indexPath.row]
            if let stockCode = model.stockCode {
                var market = YXMarketType.HK.rawValue
                var symbol = stockCode
                if stockCode.hasPrefix(YXMarketType.HK.rawValue) {
                    symbol = stockCode.replacingOccurrences(of: YXMarketType.HK.rawValue, with: "")
                    market = YXMarketType.HK.rawValue
                } else if stockCode.hasPrefix(YXMarketType.US.rawValue) {
                    symbol = stockCode.replacingOccurrences(of: YXMarketType.US.rawValue, with: "")
                    market = YXMarketType.US.rawValue
                } else if stockCode.hasPrefix(YXMarketType.ChinaSH.rawValue) {
                    symbol = stockCode.replacingOccurrences(of: YXMarketType.ChinaSH.rawValue, with: "")
                    market = YXMarketType.ChinaSH.rawValue
                } else if stockCode.hasPrefix(YXMarketType.ChinaSZ.rawValue) {
                    symbol = stockCode.replacingOccurrences(of: YXMarketType.ChinaSZ.rawValue, with: "")
                    market = YXMarketType.ChinaSZ.rawValue
                }

                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = model.stockName ?? ""
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
            
        }
    }
}

extension YXSmartMyStockViewController {
    
    //和大陆版资讯详情页面一致，滑动停止更新roc数据
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshVisibleRocData()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            refreshVisibleRocData()
        }
    }
    
    //更新roc数据
    func refreshVisibleRocData() {
        let visibleCells = self.tableView.visibleCells
        var stockNames: [Secu] = []
        var sortNames: [String] = []
        for cell in visibleCells {
            if let indexPath = self.tableView.indexPath(for: cell) {
                let model = self.viewModel.dataSource[indexPath.section][indexPath.row]
                if let code = model.stockCode, !sortNames.contains(code) {
                    sortNames.append(code)
                    var market = kYXMarketHK
                    if code.hasPrefix(kYXMarketUS) {
                        market = kYXMarketUS
                    } else if code.hasPrefix(kYXMarketChinaSH) {
                        market = kYXMarketChinaSH
                    } else if code.hasPrefix(kYXMarketChinaSZ) {
                        market = kYXMarketChinaSZ
                    } else if code.hasPrefix(kYXMarketChinaHS) {
                        market = kYXMarketChinaHS
                    }
                    stockNames.append(Secu(market: market, symbol: code.replacingOccurrences(of: market, with: "")))
                }
            }
        }
        if !stockNames.isEmpty {
            self.requestHzRealTimeData(ids: stockNames)
        }
    }
}
