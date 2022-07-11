//
//  YXUSMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUSMarketViewController: YXHKViewController, ViewModelBased {
    
    override var pageName: String {
        "US"
    }
    
    var viewModel: YXUSMarketViewModel!
    
    var timerFlag: YXTimerFlag?
    var timer: Timer?
    var stareTimer = "YXStareTimer"
    var isShowAdditionalType = false
    var additionalType: YXStockRankSortType = .roc
    var isShowDailyReplayRedDot = false

    var networkingHUD: YXProgressHUD = YXProgressHUD()
    var showNoticeView = false

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().foregroundColor()//UIColor.qmui_color(withHexString: "#F5F8FF")
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        let allCellClass: [AnyClass] = [YXMarketIndexCell.self,
                                        YXQuickEntryCell.self,
                                        YXTopIndustryScrollCell.self,
                                        YXStockCollectionViewCell.self,
                                        YXHKAllCollectionViewCell.self,
                                        YXGuessUpOrDownCell.self,
                                        YXETFCollectionViewCell.self,
                                        YXMarketETFCell.self]
        allCellClass.forEach { (cellClass) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        }
        
        let allHeaderViewClass: [AnyClass] = [YXMarketCommonHeaderCell.self,
                                              YXMarketFilterCell.self,
                                              YXGuessHeaderView.self,
                                              YXMarketTabSectionHeader.self]
        allHeaderViewClass.forEach { (headerClass) in
            collectionView.register(headerClass, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(headerClass))
        }
        
        let refreshHeader = YXRefreshHeader()
        refreshHeader.refreshingBlock = { [weak self] in
            self?.requestData {
                refreshHeader.endRefreshing()
            }
        }
        collectionView.mj_header = refreshHeader
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showNoticeView = YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketUS)
        view.addSubview(self.noticeView)
        view.addSubview(collectionView)

        self.noticeView.isHidden = !self.showNoticeView

        self.noticeView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.showNoticeView ? 26 : 0)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.noticeView.snp.bottom)
        }
        
        self.viewModel.hotETFLeadStockSubject.subscribe(onNext: { [weak self](e) in
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)

        addQuoteKickNotification()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = Timer.scheduledTimer(0, action: { [weak self](timer) in
            self?.requestData()
        }, userInfo: nil, repeats: false)

        startPolling()
        
        YXRedDotHelper.shareInstance.getRedDotData(with: .dailyReplayUS) { [weak self] in
            self?.isShowDailyReplayRedDot = true
            self?.collectionView.reloadData()
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.indexRequest?.cancel()
        viewModel.etfRequest?.cancel()
//        viewModel.timeLineRequest?.cancel()
        viewModel.indexTimeLineRequest?.cancel()

        stopPolling()
    }

    
    func requestData(complete: @escaping () -> Void = {}) {
        viewModel.requestIndexData()
       
        if YXUserManager.shared().getUsaThreeLevel() != .level1 {
            viewModel.requestETFData()
        }
     
        self.viewModel.marketDataSourceSingle.subscribe { [weak self]arr in
            complete()
            self?.collectionView.reloadData()
        } onError: { err in
            complete()
        }.disposed(by: disposeBag)

    }
    
    func startPolling() {
        
        stopPolling()
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.rankFreq))
        
        timer = Timer.scheduledTimer(timeInterval, action: { [weak self](timer) in
            guard let `self` = self else { return }
            
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](_) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
            
        }, userInfo: nil, repeats: true)

//        let stareTimeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.selfStockFreq))
//        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.stareTimer, timeInterval: stareTimeInterval, queue: .main, repeats: true) {
//            [weak self] in
//            guard let `self` = self else { return }
//            self.viewModel.stareDataSingle.asObservable().subscribe(onNext: { [weak self] model in
//                guard let strongSelf = self else { return }
//
//                strongSelf.collectionView.reloadData()
//            }).disposed(by: self.rx.disposeBag)
//        }
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
        YXTimer.shared.cancleTimer(WithTimerName: self.stareTimer)
    }
    
    func goToNewStockCenter() {
        let context: [String : Any] = ["market" : viewModel.market]
        self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
    }
    
    func goToStockList(title: String, code: String, sortType: YXStockRankSortType = .roc, sortDirection: Int = 1) {
        var dic: [String : Any] = [:]
        dic["title"] = title
        dic["market"] = viewModel.market
        dic["code"] = code
        dic["sortType"] = sortType
        dic["sortDirection"] = sortDirection
        self.viewModel.navigator.push(YXModulePaths.stockIndustry.url, context: dic)
        
        if code == YXMarketSectionType.upsaAndDowns.rankCode {
            trackViewClickEvent(name: "All Stocks_Tab")
        } else if code == YXMarketSectionType.chinaConceptStock.rankCode {
            trackViewClickEvent(name: "China Concept Stock_Tab")
        }else if code == YXMarketSectionType.star.rankCode {
            trackViewClickEvent(name: "Hot Stocks_Tab")
        }
    }

    func goToStareHome() {
        if !YXUserManager.isLogin() {
            // 未登錄
            guard let topVC = UIViewController.topMost else { return }
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: topVC))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        } else {
            let params: [AnyHashable : Any] = [ "market" : viewModel.market]
            let detailViewModel = YXStareHomeViewModel.init(services: viewModel.navigator, params: params)
            viewModel.navigator.push(detailViewModel, animated: true)
        }
    }

    lazy var noticeView: YXQuoteKickNoticeView = {
        let view = YXQuoteKickTool.createNoticeView()

        view.quoteLevelChangeBlock = {
            [weak self] in
            guard let `self` = self else { return }

            self.networkingHUD.showLoading("")
            YXQuoteKickTool.shared.getUserQuoteLevelRequest(activateToken: true, resultBock: {
                [weak self] _ in
                guard let `self` = self else { return }
                self.networkingHUD.hide(animated: true)
                //请求后有通知， 逻辑在YXUserManager.notiQuoteKick通知中处理

            })
        }

        return view
    }()
    
    deinit {
        stopPolling()
    }

}

extension YXUSMarketViewController {

    func addQuoteKickNotification() {
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                var isFromAlert = false
                var isRefresh = false
                if let object = noti.object as? NSNumber {
                    isFromAlert = object.boolValue
                }

                if self.showNoticeView {

                    if self.noticeView.isHidden == false && (YXQuoteKickTool.shared.currentQuoteLevleIsReal(kYXMarketUS) || !YXUserManager.isLogin()) {
                        self.showNoticeView = false

                        self.noticeView.isHidden = true
                        self.noticeView.snp.updateConstraints { (make) in
                            make.height.equalTo(0)
                        }
                        isRefresh = true
                    }

                } else {
                    if self.noticeView.isHidden, YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketUS) {
                        self.showNoticeView = true

                        self.noticeView.isHidden = false
                        self.noticeView.snp.updateConstraints { (make) in
                            make.height.equalTo(26)
                        }
                        isRefresh = true
                    }
                }

                if isRefresh, !isFromAlert, self.qmui_isViewLoadedAndVisible() {
                    self.beginAppearanceTransition(false, animated: false)
                    self.endAppearanceTransition()

                    self.beginAppearanceTransition(true, animated: false)
                    self.endAppearanceTransition()
                }

            }).disposed(by: rx.disposeBag)
    }


}

//MARK:数据源
extension YXUSMarketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .industry:
            return 1
        case .chinaConceptStock:
            return self.viewModel.conceptRank?.list?.count ?? 0
        case .star:
            return self.viewModel.starRank?.list?.count ?? 0
        default:
            if let items = viewModel.dataSource[section]["list"] {
                return (items as! Array<Any>).count
            }
            
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            return footerView
        }else if kind == UICollectionView.elementKindSectionHeader {
            
            let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
            
            if (sectionType == .upsaAndDowns) {
                return filterHeaderView(collectionView: collectionView, indexPath: indexPath, sectionType: sectionType)
            }else if sectionType == .monthlyPayment {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMonthlyStockHeaderView.self), for: indexPath) as! YXMonthlyStockHeaderView
                headerView.commonHeader.action = { [weak self] in
                    guard let `self` = self else { return }
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MONTHLY_ALL_URL()]
                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    
                }
                return headerView
            }else if sectionType == .guess {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXGuessHeaderView.self), for: indexPath) as! YXGuessHeaderView
                headerView.comonHeaderView.title = YXMarketSectionType.guess.sectionName
                headerView.refreshGuessButton.rx.tap.subscribe(onNext: { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.guessUpAndDownSingle(isRefresh: true).subscribe(onSuccess: { (e) in
                        self.collectionView.reloadData()
                    }, onError: nil).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
                
                return headerView
            }
            else {
                return commonHeaderView(collectionView: collectionView, indexPath: indexPath, sectionType: sectionType)
            }
        }
        
        return UICollectionReusableView()
    }
    
    func commonHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXMarketSectionType) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self), for: indexPath) as! YXMarketCommonHeaderCell
        
        headerView.title = sectionType.sectionName
        headerView.hideRedDot = true
        headerView.icon = nil
        headerView.arrowView.isHidden = false
        
        switch sectionType {
            
        case .entrance:
            headerView.arrowView.isHidden = true
            headerView.action = nil
            
        case .stare:
            
            headerView.action = { [weak self] in
                self?.goToStareHome()
            }
            
        case .dailyReplay:
            headerView.hideRedDot = !isShowDailyReplayRedDot
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                
                self.isShowDailyReplayRedDot = false
                headerView.hideRedDot = true
                YXRedDotHelper.shareInstance.updateCacheTime(with: .dailyReplayUS)
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.DAILY_REPLAY_URL(market: self.viewModel.market)
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }
            
        case .industry:
            
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let context: [String : Any] = ["market" : self.viewModel.market, "rankCode": sectionType.rankCode,"showSearch": false ]
                self.viewModel.navigator.push(YXModulePaths.hotIndustryList.url, context: context)
                self.trackViewClickEvent(name: "Top Industries_Tab")
            }
            
        case .star, .chinaConceptStock:
            
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                self.goToStockList(title: sectionType.sectionName, code: sectionType.rankCode)
                
                let name =  sectionType == .chinaConceptStock ? "China Concept Stock_Tab" : "Hot Stocks_Tab"
                self.trackViewClickEvent(name: name)
            }
        
        case .hotETF:
            
            headerView.action = { [weak self] in
                guard let `self` = self else { return }

                let vm = YXHotETFViewModel.init(services: self.viewModel.navigator, params: ["market": self.viewModel.market])
                self.viewModel.navigator.push(vm, animated: true)
            }
            
        case .dailyFunding:
            
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let dic: [String: Any] = ["market": YXMarketType.US, "rankType": YXRankType.dailyFunding]
                self.viewModel.navigator.push(YXModulePaths.financingList.url, context: dic)
            }
            
        default:
            headerView.title = ""
        }
        
        return headerView
    }
    
    func filterHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXMarketSectionType) -> UICollectionReusableView {
        let usAllHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketFilterCell.self), for: indexPath) as! YXMarketFilterCell
        
        let title = sectionType.sectionName
        usAllHeaderView.commonHeaderView.title = title

        usAllHeaderView.commonHeaderView.action = { [weak self] in
            guard let `self` = self else { return }
            self.goToStockList(title: title, code: self.viewModel.usRankCode, sortType: self.viewModel.usRankSortType, sortDirection: self.viewModel.usRankSortDirection)
            self.trackViewClickEvent(name: "All Stocks_Tab")
        }
        usAllHeaderView.tapFilterItemAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            self.additionalType = sortType
            self.viewModel.usRankSortDirection = direction
            self.viewModel.usRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
        }
        usAllHeaderView.tapSortButtonAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            self.viewModel.usRankSortDirection = direction
            self.viewModel.usRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
        }
        return usAllHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        
        switch sectionType {
        case .index:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketIndexCell.self), for: indexPath)
        case .usETF:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketETFCell.self), for: indexPath)
        case .guess:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXGuessUpOrDownCell.self), for: indexPath)
            
        case .entrance:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXQuickEntryCell.self), for: indexPath)
            
        case .newStockCenter:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXNewStockCenterCell.self), for: indexPath)

        case .stare:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketStareCell.self), for: indexPath)
        
        case .dailyReplay:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXEveryDayReplayCell.self), for: indexPath)
            
        case .hotETF:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXETFCollectionViewCell.self), for: indexPath)
            
        case .industry:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXTopIndustryScrollCell.self), for: indexPath)
            
        case .upsaAndDowns:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHKAllCollectionViewCell.self), for: indexPath)
            
        case .star, .chinaConceptStock, .dailyFunding:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXStockCollectionViewCell.self), for: indexPath)
        case .monthlyPayment:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMonthlyStockCell.self), for: indexPath)
            
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]
        switch sectionType {
        case .index:
            let indexCell = cell as! YXMarketIndexCell
            indexCell.disposeBag = DisposeBag()
            indexCell.startTimeLabel.text = "09:30"
            indexCell.endTimeLabel.text = "16:00"
            indexCell.midTimeLabel.text = "12:45"
            indexCell.onClickIndexPath = { [weak self](indexPath) in
                guard let `self` = self else {
                    return
                }
                let quote = self.viewModel.indexDataSource[indexPath.item]
                if let market = quote.market, let symbol = quote.symbol {
                    var pageBtnStr = ""
                    if symbol == YXMarketIndex.DJI.rawValue {
                        pageBtnStr = "DOW_Tab"
                    } else if symbol == YXMarketIndex.IXIC.rawValue {
                        pageBtnStr = "NASDAQ_Tab"
                    } else if symbol == YXMarketIndex.SPX.rawValue {
                        pageBtnStr = "S&P 500_Tab"
                    }
                    self.trackViewClickEvent(name: pageBtnStr)
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }
            
            indexCell.onClickOpenAccount = { [weak self] in
                guard let `self` = self else {return}
                if YXUserManager.isLogin() {
                    YXOpenAccountWebViewModel.pushToWebVC(YXH5Urls.YX_OPEN_ACCOUNT_URL())
                } else {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: {_ in
                    }, vc: nil))
                    self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            }
            
            if indexCell.disposeBag != nil {
                
                viewModel.indexSubject.subscribe(onNext: { [weak self](dataSource) in
                    guard let `self` = self else {return}
                    indexCell.dataSource = self.viewModel.indexDataSource
                }).disposed(by: indexCell.disposeBag!)
                
                
            }
        case .usETF:
            let indexCell = cell as! YXMarketETFCell
            indexCell.disposeBag = DisposeBag()
            indexCell.onClickIndexPath = { [weak self](indexPath) in
                guard let `self` = self else {
                    return
                }
                let quote = self.viewModel.etfDataSource[indexPath]
                if let market = quote.market, let symbol = quote.symbol {
                    
                    var pageBtnStr = ""
                    if symbol == YXMarketIndex.DIA.rawValue {
                        pageBtnStr = "DIA_Tab"
                    } else if symbol == YXMarketIndex.QQQ.rawValue {
                        pageBtnStr = "QQQ_Tab"
                    } else if symbol == YXMarketIndex.SPY.rawValue {
                        pageBtnStr = "S&P SPY_Tab"
                    }
                    self.trackViewClickEvent(name: pageBtnStr)
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }
            
            if indexCell.disposeBag != nil {
                
                viewModel.etfSubject.subscribe(onNext: { [weak self](dataSource) in
                    guard let `self` = self else {return}
                    indexCell.dataSource = self.viewModel.etfDataSource
                }).disposed(by: indexCell.disposeBag!)
                
                viewModel.indexTimeLineSubject.subscribe(onNext: { (timeLineData) in
                    indexCell.timeLineData = timeLineData
                }).disposed(by: indexCell.disposeBag!)
            }
            
        case .guess:
            let guessCell = cell as! YXGuessUpOrDownCell
        
            guessCell.tapStockInfoAction = { [weak self]index in
                guard let `self` = self else { return }
                let array = self.viewModel.guessUpAndDownModel?.stockInfos.map({ (stock) -> YXStockInputModel in
                    let input = YXStockInputModel()
                    input.market = self.viewModel.market
                    input.symbol = stock.stockCode ?? ""
                    return input
                })
                if let inputs = array {
                    self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : index])
                }
            }
            guessCell.tapUpAction = { [weak self](market, symbol, isSelected) in
                let url = YXH5Urls.guessUpOrDownUrl(market: market, symbol: symbol, type: "warrant", upOrDown: "1")
                self?.tapGuessAction(symbol: symbol, isSelected: isSelected, guessValue: "1", url: url)
            }
            guessCell.tapDownAction = { [weak self](market, symbol, isSelected) in
                let url = YXH5Urls.guessUpOrDownUrl(market: market, symbol: symbol, type: "warrant", upOrDown: "-1")
                self?.tapGuessAction(symbol: symbol, isSelected: isSelected, guessValue: "0", url: url)
            }
            
            if let datas = self.viewModel.guessUpAndDownModel?.stockInfos {
                guessCell.datas = datas
            }
            
        case .entrance:
            let entranceCell = cell as! YXQuickEntryCell
            let items = list as! Array<[String: String]>
            let item = items[indexPath.item]
            entranceCell.imageView.image = UIImage(named: item["iconName"] ?? "")
            entranceCell.titleLabel.text = item["title"]
            
        case .newStockCenter:
            let newStockCell = cell as! YXNewStockCenterCell
            newStockCell.cellStyle = .normal
            let titles = list as! Array<[String: Any]>
            newStockCell.title = (titles[indexPath.item]["title"] as! String)
            newStockCell.num = titles[indexPath.item]["count"] as? Int ?? 0

        case .stare:
            let stockCell = cell as! YXMarketStareCell
            stockCell.model = self.viewModel.stareModel
            
        case .dailyReplay:
            let dailyReplayCell = cell as! YXEveryDayReplayCell
            let items = list as! Array<String>
            dailyReplayCell.contentLabel.text = items[indexPath.item]

        case .industry:
            let industryCell = cell as! YXTopIndustryScrollCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            industryCell.datas = items
            industryCell.didTapAction = {[weak self](market, symbol, name) in
                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                self?.trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : symbol, "stock_name": name])

            }
            
        case .hotETF:
            let etfCell = cell as! YXETFCollectionViewCell
            let item = self.viewModel.hotETF?.list?[indexPath.item]
            etfCell.hotPlateView.info = item
            
            if let key = item?.secuCode {
                let leadStockInfo = self.viewModel.etfLeadStock[key]
                etfCell.hotPlateView.leadStockInfo = leadStockInfo
            }
            
            if indexPath.item == 2 {
                etfCell.line.isHidden = true
            }else {
                etfCell.line.isHidden = false
            }
            
        case .upsaAndDowns:
            let stockCell = cell as! YXHKAllCollectionViewCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            let item = items[indexPath.item]
            stockCell.isShowAdditionalType = self.isShowAdditionalType
            stockCell.additionalType = self.additionalType
            stockCell.model = item
            stockCell.level = viewModel.usRank?.level
            
        case .chinaConceptStock, .dailyFunding:
            let stockCell = cell as! YXStockCollectionViewCell
            if let list = self.viewModel.conceptRank?.list {
                stockCell.info = list[indexPath.item]
            }
            stockCell.level = viewModel.conceptRank?.level
            
        case .star:
            let stockCell = cell as! YXStockCollectionViewCell
            if let list = self.viewModel.starRank?.list {
                stockCell.info = list[indexPath.item]
            }
            stockCell.level = viewModel.conceptRank?.level
            
        case .monthlyPayment:
            let stockCell = cell as! YXMonthlyStockCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            let item = items[indexPath.item]
            stockCell.info = item
            stockCell.level = viewModel.monthlyStockRank?.level
            
        default:
            break
        }
    }
    
    func tapGuessAction(symbol: String, isSelected: Bool, guessValue: String, url: String) {
        
        if YXUserManager.isLogin() {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            if !isSelected {
                self.viewModel.guessUserSelectedSingle(code: symbol, value: guessValue).subscribe(onSuccess: nil, onError: nil).disposed(by: disposeBag)
            }
        }else {
            guard let topVC = UIViewController.topMost else { return }
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: topVC))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]
        
        switch sectionType {
        case .entrance:
            if indexPath.item == 0 {
                
                if YXToolUtility.needFinishQuoteNotify() {
                    
                    let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "optionQuoteStatement"))

                    alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
                    }))

                    alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "optionQuoteStatementGo"), style: .default, handler: { (action) in

                        let context = YXNavigatable(viewModel: YXUSAuthStateWebViewModel(dictionary: [:]))
                        YXNavigationMap.navigator.push(YXModulePaths.USAuthState.url, context: context)
                        
                    }))

                    alertView.showInWindow()
                    
                } else {
                    YXToolUtility.handleBusinessWithOptionLevel(excute: {
                        [weak self] in
                        if let item = YXSearchHistoryManager.shared.optionChainSearchItem {
                            self?.goShareOptions(market: item.market, symbol: item.symbol)
                        } else {
                            let didSelectedItem: (YXSearchItem)->() = { [weak self] (item) in
                                guard let `self` = self else { return }
                                self.goShareOptions(market: item.market, symbol: item.symbol)
                            }
                            let dic = ["didSelectedItem": didSelectedItem, "warrantType": YXStockWarrantsType.optionChain, "needPushOptionChain" : true] as [String : Any]
                            self?.viewModel.navigator.push(YXModulePaths.stockWarrantsSearch.url, context: dic)
                            
                        }
                    })
                    
                }
                
                trackViewClickEvent(name: "options_Tab")
                
                
            }else if indexPath.item == 1 {
                
                YXToolUtility.handleBusinessWithLogin {
                    let dic = ["market": YXMarketType.US]
                    if YXUserManager.shared().getLevel(with: kYXMarketUS) == .delay {
                        YXNewStockPurchaseUtility.commonAlert(title: nil, msg: YXLanguageUtility.kLang(key: "pre_after_notice"), cancelTitle: YXLanguageUtility.kLang(key: "common_cancel"), otherActionTitle: YXLanguageUtility.kLang(key: "user_mymarket"), actionBlock: {
                            YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL(tab: 1))
                        })
                        
                    }else {
                        self.viewModel.navigator.push(YXModulePaths.preAfterRank.url, context: dic)
                    }
                }
                trackViewClickEvent(name: "Pre/Post Mkt_Tab")
                
            }else if indexPath.item == 2 {
                let vm = YXHotETFViewModel.init(services: self.viewModel.navigator, params: ["market": self.viewModel.market])
                self.viewModel.navigator.push(vm, animated: true)
                self.trackViewClickEvent(name: "HOT ETF_Tab")
            }else if indexPath.item == 3 {
                let yearsRequestModel = YXDividendsYearsRequestModel.init()
                let requestModel = YXRequest.init(request: yearsRequestModel)
                requestModel.startWithBlock { responseModel in
                    
                    if responseModel.code == .success{
                        if let res = responseModel as? YXDividendsYearsResponse,res.date.count > 0 {
                            let dateModel = YXDateToolUtility.dateTime(withTime: res.date)
                            let selectYear = (dateModel.month.int64Value >= 4 && dateModel.day.int64Value >= 1) ? dateModel.year.int64Value : dateModel.year.int64Value - 1
                            let selectYearIndex = res.list.map{ $0.year.int64Value }.firstIndex(of: selectYear)
                            var dic: [String: Any] = [:]
                            dic["selectYearIndex"] = selectYearIndex
                            dic["model"] = res.list
                            dic["market"] = self.viewModel.market
                            self.viewModel.navigator.push(YXModulePaths.dividends.url, context: dic)
                        }
                    } else {
                        YXProgressHUD.showError("没有数据")
                    }
                    
                } failure: { _ in
                    YXProgressHUD.showError("没有数据")
                }
            }
            
        case .newStockCenter:
            if indexPath.item == 0 {
                let context: [String : Any] = ["market" : viewModel.market]
                self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)

            }else if indexPath.item == 1 {
                let context: [String : Any] = ["market" : viewModel.market, "toPreMarket": true]
                self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
            }else if indexPath.item == 2 {
                self.viewModel.navigator.push(YXModulePaths.newStockMarket.url, context: ["market" : viewModel.market])
            }
        
        case .industry:
            break

        case .upsaAndDowns, .dailyFunding, .monthlyPayment:
            let items = list as! Array<YXMarketRankCodeListInfo>
            //let item = items[indexPath.item]

            var inputs: [YXStockInputModel] = []
            for info in items {
                if let market = info.trdMarket, let symbol = info.secuCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.item])
                if sectionType == .upsaAndDowns {
                    let info = inputs[indexPath.item]
                    trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : info.symbol, "stock_name": info.name!])
                }
                
            }
            
        case .chinaConceptStock:
            let items = self.viewModel.conceptRank?.list ?? []
            var inputs: [YXStockInputModel] = []
            for info in items {
                if let market = info.trdMarket, let symbol = info.secuCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.item])
                let info = inputs[indexPath.item]
                trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : info.symbol, "stock_name": info.name!])
            }
        case .star:
            let items = self.viewModel.starRank?.list ?? []
            var inputs: [YXStockInputModel] = []
            for info in items {
                if let market = info.trdMarket, let symbol = info.secuCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.item])
                let info = inputs[indexPath.item]
                trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : info.symbol, "stock_name": info.name!])
            }
        case .stare:
            if let stockCode = self.viewModel.stareModel?.stockCode, stockCode.count > 2 {
                let market = stockCode.subString(toCharacterIndex: 2)
                let symbol = stockCode.suffix(stockCode.count - 2)

                let input = YXStockInputModel()
                input.market = market
                input.symbol = String(symbol)
                input.name = self.viewModel.stareModel?.stockName ?? ""
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
            
        case .hotETF:
            let sectionInfo = ["chsNameAbbr": YXLanguageUtility.kLang(key: "index_title"), "secuCode": "EBK001"]
            
            let vm = YXHotETFListViewModel.init(services: viewModel.navigator,
                                                params: ["market": self.viewModel.market,
                                                         "sectionInfo": sectionInfo,
                                                         "sectionList": self.viewModel.hotETFList,
                                                         "selectedTab": indexPath.item+1
                                                ])
            viewModel.navigator.push(vm, animated: true)
            
        default:
            break
        }
    }
    
    func goShareOptions(market: String, symbol: String) {
        let vm = YXShareOptionsViewModel.init(services: viewModel.navigator, params: ["market": market, "code": symbol])
        vm.style = .inMarket
        viewModel.navigator.push(vm, animated: true)
    }
}


//MARK:布局
extension YXUSMarketViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        var size: CGSize = .zero
        let collectionViewWidth = collectionView.frame.size.width
        
        switch sectionType {
        case .index:
            size = CGSize.init(width: YXConstant.screenWidth-32.0, height: 106)
        case .usETF:
            size = CGSize.init(width: YXConstant.screenWidth-32.0, height: 117)
        case .guess:
            size = CGSize.init(width: collectionViewWidth, height: 135)
            if let model = viewModel.guessUpAndDownModel, model.stockInfos.count > 0 {
                let count = Float(model.stockInfos.count)
                let spaceH: Float = 16.0
                var itemH = ceilf(count/2.0) * 154.0
                if count > 2 {
                    itemH += spaceH
                }
            
                size = CGSize.init(width: YXConstant.screenWidth-32.0, height: CGFloat(itemH))
            }
        case .entrance:
            size = CGSize.init(width: collectionViewWidth * 164.0/375.0, height: 40)
        case .newStockCenter:
            size = CGSize.init(width: (collectionViewWidth-2)/3.0, height: 55)
        case .hotETF:
            size = CGSize.init(width: (collectionViewWidth-32.0)/3.0, height: 98)
        case .industry:
            size = CGSize.init(width: collectionViewWidth, height: 160)
        case .chinaConceptStock, .upsaAndDowns, .star, .dailyFunding, .monthlyPayment:
            size = CGSize.init(width: collectionViewWidth, height: 68)
        case .stare:
            size = CGSize.init(width: collectionViewWidth, height: 44)
        case .dailyReplay:
            size = CGSize.init(width: collectionViewWidth, height: 55)
        default:
            size = CGSize.zero
        }
        
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index:
            var  bootom:CGFloat = 30
            let sectionType = viewModel.dataSource[1]["sectionType"] as! YXMarketSectionType
            if sectionType == .usETF {
                bootom = 12
            }
            return UIEdgeInsets(top: 12, left: 16, bottom: bootom, right: 16)
        case .guess, .entrance, .hotETF:
            return UIEdgeInsets(top: 8, left: 16, bottom: 40, right: 16)
        case .industry:
            return UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
        case .upsaAndDowns,.chinaConceptStock:
            return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        case .newStockCenter,.dailyReplay, .stare, .star, .dailyFunding, .monthlyPayment:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        case .usETF:
           return UIEdgeInsets(top: 0, left: 16, bottom: 40, right: 16)
        default:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .entrance:
            return 12
        default:
            return 0
        }
    }
    
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .entrance:
            return 12
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index,
             .usETF:
            return CGSize.zero
        case .upsaAndDowns:
            return CGSize.init(width: collectionView.frame.size.width, height: 110)
        case .monthlyPayment:
            if let list = viewModel.dataSource[section]["list"] as? Array<Any>, list.count > 0 {
                return CGSize.init(width: collectionView.frame.size.width, height: 75)
            }else {
                return CGSize.init(width: collectionView.frame.size.width, height: 55)
            }
        default:
            return CGSize.init(width: collectionView.frame.size.width, height: 40)
        }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
//        switch sectionType {
//        case .index:
//            return CGSize.zero
//        default:
//            return CGSize.init(width: collectionView.frame.size.width, height: 10)
//        }
//    }
}

