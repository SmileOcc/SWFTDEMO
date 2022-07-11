//
//  YXSGMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXSGMarketViewController: YXHKViewController, ViewModelBased {
    
    override var pageName: String {
         "SG"
     }
    
    var refreshFooter: YXRefreshAutoNormalFooter?
    
    var viewModel: YXSGMarketViewModel!
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXWhiteRefreshHeader()
    }()
    
    var timerFlag: YXTimerFlag?
    var timer: Timer?
    var stareTimer = "YXStareTimer"
    var isShowAdditionalType = false
    var additionalType: YXStockRankSortType = .roc
    var isShowDailyReplayRedDot = false

    var networkingHUD: YXProgressHUD = YXProgressHUD()
    var showNoticeView = false
        
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        let allCellClass: [AnyClass] = [YXMarketIndexCell.self,
                                        YXQuickEntryCell.self,
                                        YXTopIndustryScrollCell.self,
                                        YXStockCollectionViewCell.self,
                                        YXHKAllCollectionViewCell.self,
                                        YXGuessUpOrDownCell.self]
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

        self.showNoticeView = YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketSG)
        view.addSubview(self.noticeView)
        view.addSubview(collectionView)

        self.noticeView.isHidden = !self.showNoticeView

        self.noticeView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
//            make.top.equalTo(self.strongNoticeView.snp.bottom);
            make.height.equalTo(self.showNoticeView ? 26 : 0)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.noticeView.snp.bottom)
        }

        addQuoteKickNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = Timer.scheduledTimer(0, action: { [weak self](timer) in
            self?.requestData()
        }, userInfo: nil, repeats: false)

        startPolling()
        
        YXRedDotHelper.shareInstance.getRedDotData(with: .dailyReplayHK) { [weak self] in
            self?.isShowDailyReplayRedDot = true
            self?.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.indexRequest?.cancel()
//        viewModel.timeLineRequest?.cancel()
//        viewModel.indexTimeLineRequest?.cancel()

        stopPolling()
    }
    
    func requestData(complete: @escaping () -> Void = {}) {
        
        
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
            
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { e in
                self.collectionView.reloadData()
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

    func goToStareHome() {
        if !YXUserManager.isLogin() {
            // 未登錄
            guard let topVC = UIViewController.topMost else { return }
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: topVC))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        } else {
            let params: [AnyHashable : Any] = [ "market" : viewModel.market]
            let detailViewModel = YXStareHomeViewModel.init(services: self.viewModel.navigator, params: params)
            self.viewModel.navigator.push(detailViewModel, animated: true)

        }
    }
    
    func goToStockList(title: String, code: String, sortType: YXStockRankSortType = .roc, sortDirection: Int = 1) {
        var dic: [String : Any] = [:]
        dic["title"] = title
        dic["market"] = YXMarketType.SG.rawValue
        dic["code"] = code
        dic["sortType"] = sortType
        dic["sortDirection"] = sortDirection
        self.viewModel.navigator.push(YXModulePaths.stockIndustry.url, context: dic)
        
        if code == YXMarketSectionType.allSGStock.rankCode {
            trackViewClickEvent(name: "All Stocks_Tab")
        } else if code == YXMarketSectionType.mainboard.rankCode {
            trackViewClickEvent(name: "Main Board_Tab")
        }else if code == YXMarketSectionType.cata.rankCode {
            trackViewClickEvent(name: "Catalist_Tab")
        }
        
    }

    func goToStockList(title: String, rankType: YXRankType, sortType: YXStockRankSortType = .roc, sortDirection: Int = 1) {
        var dic: [String : Any] = [:]
        dic["title"] = title
        dic["market"] = YXMarketType.SG.rawValue
        dic["code"] = rankType.rankCode
        dic["sortType"] = sortType
        dic["sortDirection"] = sortDirection
        dic["rankType"] = rankType
        self.viewModel.navigator.push(YXModulePaths.stockIndustry.url, context: dic)
    }
    
    lazy var noticeView: YXQuoteKickNoticeView = {
        let view = YXQuoteKickTool.createNoticeView()
        view.isHidden = true
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

extension YXSGMarketViewController {

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

                    if self.noticeView.isHidden == false && (YXQuoteKickTool.shared.currentQuoteLevleIsReal(kYXMarketSG) || !YXUserManager.isLogin()) {
                        self.showNoticeView = false

                        self.noticeView.isHidden = true
                        self.noticeView.snp.updateConstraints { (make) in
                            make.height.equalTo(0)
                        }
                        isRefresh = true
                    }

                } else {
                    if self.noticeView.isHidden, YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketSG) {
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
extension YXSGMarketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .industry:
            return 1
        case .stare:
            if (YXUserManager.shared().getLevel(with: kYXMarketSG) == .bmp) {
               return 1
            }
            
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                return (items as Array<Any>).count
            }
            
            return 0
        case .mainboard:
            return self.viewModel.mainRank?.list?.count ?? 0
        case .cata:
            return self.viewModel.cataRank?.list?.count ?? 0
        default:
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                return (items as Array<Any>).count
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
            
            if sectionType == .allSGStock {
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
        
        case .newStockCenter:
            headerView.action = { [weak self] in
                self?.goToNewStockCenter()
            }
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
                YXRedDotHelper.shareInstance.updateCacheTime(with: .dailyReplayHK)
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.DAILY_REPLAY_URL(market: self.viewModel.market)
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }
            
        case .industry:
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let context: [String : Any] = ["market": self.viewModel.market, "rankCode": self.viewModel.industryRankCode]
                self.viewModel.navigator.push(YXModulePaths.hotIndustryList.url, context: context)
                self.trackViewClickEvent(name: "Top Industries_Tab")
            }
        
        case .mainboard:
            let title = YXMarketSectionType.mainboard.sectionName
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                self.goToStockList(title: title, code: self.viewModel.mainRankCode)
            }
        
        case .cata:
            let title = YXMarketSectionType.cata.sectionName
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                self.goToStockList(title: title, code: self.viewModel.cataRankCode)
            }
        case .dailyFunding:
            
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let dic: [String: Any] = ["market": YXMarketType.SG, "rankType": YXRankType.dailyFunding]
                self.viewModel.navigator.push(YXModulePaths.financingList.url, context: dic)
            }
        default:
            headerView.title = ""
        }
        
        return headerView
    }
    
    func filterHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXMarketSectionType) -> UICollectionReusableView {
        
        let title = sectionType.sectionName
        
        let sgAllHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketFilterCell.self), for: indexPath) as! YXMarketFilterCell
        
        sgAllHeaderView.commonHeaderView.title = title
        
        sgAllHeaderView.commonHeaderView.action = { [weak self] in
            guard let `self` = self else { return }
            self.goToStockList(title: title, code: self.viewModel.sgRankCode, sortType: self.viewModel.sgRankSortType, sortDirection: self.viewModel.sgRankSortDirection)
        }
        sgAllHeaderView.tapFilterItemAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            self.additionalType = sortType
            self.viewModel.sgRankSortDirection = direction
            self.viewModel.sgRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
            
        }
        sgAllHeaderView.tapSortButtonAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            self.viewModel.sgRankSortDirection = direction
            self.viewModel.sgRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
        }
        
        return sgAllHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        
        switch sectionType {
        case .index:
            let indexCell : YXMarketIndexCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketIndexCell.self), for: indexPath) as! YXMarketIndexCell
//            indexCell.showArrowMore = true
            
            return indexCell
            
        case .guess:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXGuessUpOrDownCell.self), for: indexPath)
        
        case .entrance:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXQuickEntryCell.self), for: indexPath)
        
        case .newStockCenter:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXNewStockCenterCell.self), for: indexPath)
            
        case .stare:
            if (YXUserManager.shared().getLevel(with: kYXMarketSG) == .bmp) {
                
                return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXStareBMPDefaultCollectionViewCell.self), for: indexPath)
            }else{
                return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketStareCell.self), for: indexPath)
            }
            
        case .dailyReplay:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXEveryDayReplayCell.self), for: indexPath)
        case .industry:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXTopIndustryScrollCell.self), for: indexPath)
        case .allSGStock:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHKAllCollectionViewCell.self), for: indexPath)
        case .mainboard, .cata, .dailyFunding:
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
            
            let titles = list as! Array<[String: Any]>
            newStockCell.title = (titles[indexPath.item]["title"] as! String)
            newStockCell.num = titles[indexPath.item]["count"] as? Int ?? 0
            newStockCell.moreButton.isHidden = true
            if indexPath.item == 0 {
                newStockCell.moreButton.isHidden = newStockCell.num <= (viewModel.ipoAdList?.count ?? 0)
                newStockCell.cellStyle = .showAD
                newStockCell.adList = viewModel.ipoAdList
                newStockCell.gestureBlock = { [weak self](index) in
                    let item = self?.viewModel?.ipoAdList?[index]

                    let context: [String : Any] = [
                        "exchangeType" : item?.exchangeId ?? 0,
                        "ipoId" : 0,
                        "stockCode" : item?.secuCode ?? ""
                    ]
                    self?.viewModel.navigator.push(YXModulePaths.newStockDetail.url, context: context)
                }
                newStockCell.moreBlock = { [weak self] in
                    self?.goToNewStockCenter()
                    
                }
            }else {
                newStockCell.cellStyle = .normal
                newStockCell.adList = nil
            }
        case .stare:
            if ( YXUserManager.shared().getLevel(with: kYXMarketSG ) != .bmp) {
                let stockCell = cell as! YXMarketStareCell
                stockCell.model = self.viewModel.stareModel
            }
          
        case .dailyReplay:
            let dailyReplayCell = cell as! YXEveryDayReplayCell
            let items = list as! Array<String>
            dailyReplayCell.contentLabel.text = items[indexPath.item]

        case .industry:
            let industryCell = cell as! YXTopIndustryScrollCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            industryCell.datas = items
            industryCell.didTapAction = {[weak self](market, symbol,name) in
                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                self?.trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : symbol, "stock_name": name])
            }
            
        case .allSGStock:
            let stockCell = cell as! YXHKAllCollectionViewCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            let item = items[indexPath.item]
            stockCell.isShowAdditionalType = self.isShowAdditionalType
            stockCell.additionalType = self.additionalType
            stockCell.model = item
            stockCell.level = viewModel.sgRank?.level
            
        case .mainboard,.dailyFunding:
            let stockCell = cell as! YXStockCollectionViewCell
            if let list = self.viewModel.mainRank?.list {
                stockCell.info = list[indexPath.item]
            }
            stockCell.level = viewModel.mainRank?.level
            
        case .cata:
            let stockCell = cell as! YXStockCollectionViewCell
            if let list = self.viewModel.cataRank?.list {
                stockCell.info = list[indexPath.item]
            }
            stockCell.level = viewModel.mainRank?.level
            
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
            var dic: [String: Any] = [:]
            if indexPath.item == 0 {

                goToStockList(title: YXRankType.REITs.title, rankType: YXRankType.REITs)
                
                trackViewClickEvent(name: "REITs_Tab")
            }else if indexPath.item == 1 {
                
                goToStockList(title: YXRankType.sgETF.title, rankType: YXRankType.sgETF)
                trackViewClickEvent(name: "ETF_Tab")
                
            }else if indexPath.item == 2 {
                
                let vc = YXSGWarrantsViewController()
                
                vc.viewModel.navigator = self.viewModel.navigator
                vc.viewModel.warrantType = YXStockWarrantsType.bullBear
                vc.viewModel.market = self.viewModel.market
                vc.clearAll()
                viewModel.navigator.push(vc)
                
                trackViewClickEvent(name: "Warrants_Tab")
            }else if indexPath.item == 3 {
                
                goToStockList(title: YXRankType.DLCs.title, rankType: YXRankType.DLCs)
                trackViewClickEvent(name: "DLCs_Tab")
            }else if indexPath.item == 4 {
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
                self.goToNewStockCenter()
            }else if indexPath.item == 1 {
                let context: [String : Any] = ["defaultTab" : YXNewStockCenterTab.preMarket]
                self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
                
            }else if indexPath.item == 2 {
                let context: [String : Any] = ["defaultTab" : YXNewStockCenterTab.preMarket]
                self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
                
            }else if indexPath.item == 3 {
                let context: [String : Any] = ["defaultTab" : YXNewStockCenterTab.marketed]
                self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
                
            }
            
        case .stare:
            if (YXUserManager.shared().getLevel(with: kYXMarketSG) == .bmp) {
                return
            }
            
            if let stockCode = self.viewModel.stareModel?.stockCode, stockCode.count > 2 {
                let market = stockCode.subString(toCharacterIndex: 2)
                let symbol = stockCode.suffix(stockCode.count - 2)

                let input = YXStockInputModel()
                input.market = market
                input.symbol = String(symbol)
                input.name = self.viewModel.stareModel?.stockName ?? ""
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
            
        case .industry:
            break
        
        case .allSGStock, .dailyFunding, .monthlyPayment:
            let items = list as! Array<YXMarketRankCodeListInfo>
            
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
                
                if sectionType == .allSGStock {
                    let info = inputs[indexPath.item]
                    trackViewClickEvent(name: "stocklist_item",other: ["stock_code " : info.symbol, "stock_name": info.name!])
                }
                
            }
            
        case .mainboard:
            var items = self.viewModel.mainRank?.list ?? []
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
        case .cata:
            var items = self.viewModel.cataRank?.list ?? []
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
        default:
            break
        }
    }
}

//MARK:布局
extension YXSGMarketViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        var size: CGSize = .zero
        let collectionViewWidth = collectionView.frame.size.width
        
        switch sectionType {
        case .index:
            size = CGSize.init(width: YXConstant.screenWidth-32.0, height: 106)
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
            // 解决当UICollectionViewCell的size不为整数时，UICollectionViewFlowLayout在布局计算时，可能会调整Cell的frame.origin，使Cell按照最小物理像素（渲染像素）对齐，导致出现缝隙
            // https://blog.csdn.net/ayuapp/article/details/80360745
//            let width = collectionViewWidth/5.0
//            if indexPath.item == 0 {
//                width = collectionViewWidth - floor(width)*3
//            }else {
//                width = floor(width)
//            }
            size = CGSize.init(width: collectionViewWidth * 164.0/375.0, height: 40)
        case .newStockCenter:
            size = CGSize.init(width: (collectionViewWidth-1)/2.0, height: 110.0/3.0)
            if indexPath.item == 0 {
                size = CGSize.init(width: (collectionViewWidth-1)/2.0, height: 110.0)
            }
        case .stare:
            if (YXUserManager.shared().getLevel(with: kYXMarketSG) == .bmp) {
                size = CGSize.init(width: collectionViewWidth, height: 54)
            } else {
                size = CGSize.init(width: collectionViewWidth, height: 44)
            }
            
        case .dailyReplay:
            size = CGSize.init(width: collectionViewWidth, height: 55)
            
        case .industry:
            size = CGSize.init(width: collectionViewWidth, height: 160)
        case .allSGStock, .mainboard, .cata, .dailyFunding, .monthlyPayment:
            size = CGSize.init(width: collectionViewWidth, height: 68)
        default:
            size = CGSize.zero
        }
        
        return size
    }
    
    func fixedCollectionCellSize(size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize.init(width: round(scale * size.width) / scale, height: round(scale * size.height) / scale)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index:
            return UIEdgeInsets(top: 12, left: 16, bottom: 38, right: 16)
        case .guess, .entrance:
            return UIEdgeInsets(top: 8, left: 16, bottom: 40, right: 16)
        case .industry:
            return UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
        case .allSGStock,.cata, .mainboard:
            return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        case .newStockCenter, .dailyFunding, .dailyReplay, .stare, .monthlyPayment:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
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
    
    // header高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index:
            return CGSize.zero
        case .allSGStock:
            return CGSize.init(width: collectionView.frame.size.width, height: 110)
        case .monthlyPayment:
            if let list = viewModel.dataSource[section]["list"] as? Array<Any>, list.count > 0 {
                return CGSize.init(width: collectionView.frame.size.width, height: 75)
            }else {
                return CGSize.init(width: collectionView.frame.size.width, height: 40)
            }
            
        default:
            return CGSize.init(width: collectionView.frame.size.width, height: 40)
        }
    }
    
    // footer高度
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

class YXSGMarketFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = super.layoutAttributesForElements(in: rect)
        if let arr = array, arr.count < 1 { return nil }

        let firstAttribute = self.layoutAttributesForItem(at: IndexPath.init(row: 0, section: 2))
        if let arr = array, let first = firstAttribute {

            for item in arr {
                if item.indexPath.section == 2 {
                    if item.representedElementCategory == .cell {
                        if (item.indexPath.item == 1) {
                            var rect = item.frame
                            rect.origin = CGPoint.init(x: rect.origin.x, y: first.frame.origin.y)
                            item.frame = rect
                        }
                        if (item.indexPath.item == 2) {
                            var rect = item.frame
                            rect.origin = CGPoint.init(x: first.frame.maxX + 1, y: first.frame.maxY - (110.0/3.0)*2)
                            item.frame = rect
                        }
                        if (item.indexPath.item == 3) {
                            var rect = item.frame
                            rect.origin = CGPoint.init(x: first.frame.maxX + 1, y: first.frame.maxY - (110.0/3.0))
                            item.frame = rect
                        }
                    }else if item.representedElementKind == UICollectionView.elementKindSectionFooter {
                        var rect = item.frame
                        rect.origin = CGPoint.init(x: rect.origin.x, y: first.frame.maxY)
                        item.frame = rect
                    }
                }

                if item.indexPath.section > 2 {
                    var rect = item.frame
                    rect.origin = CGPoint.init(x: rect.origin.x, y: rect.origin.y - (110.0/3.0))
                    item.frame = rect
                }
            }
        }
        
        return array
    }
    
    override var collectionViewContentSize: CGSize {
        var size = super.collectionViewContentSize
        size.height -= (110.0/3.0)
        return size
    }
}

