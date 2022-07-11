//
//  YXChinaMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXChinaMarketViewController: YXHKViewController, ViewModelBased {
    
    var viewModel: YXChinaMarketViewModel!
    
    var timerFlag: YXTimerFlag?
    var timer: Timer?
    var stareTimer = "YXStareTimer"
    var isShowAdditionalType = false
    var additionalType: YXStockRankSortType = .accer3
    
    var isIndexCellSubscribed = false // 控制指数cell只订阅一次数据源
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.qmui_color(withHexString: "#F5F8FF")
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        collectionView.register(YXMarketIndexCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketIndexCell.self))
        collectionView.register(YXMarketHSFundFlowCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketHSFundFlowCell.self))
        collectionView.register(YXHotPlateCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXHotPlateCell.self))
        collectionView.register(YXMarketStareCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketStareCell.self))
        collectionView.register(YXStockCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXStockCollectionViewCell.self))
        collectionView.register(YXMarketHSFundCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketHSFundCell.self))
        collectionView.register(YXChinaMarketOverViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXChinaMarketOverViewCell.self))
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
        collectionView.register(YXMarketCommonHeaderCell.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self))
        collectionView.register(YXMarketFilterCell.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketFilterCell.self))
        collectionView.register(YXHKAllCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXHKAllCollectionViewCell.self))
        collectionView.register(YXMarketEntranceViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketEntranceViewCell.self))
        
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
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
//        viewModel.timeLineSubject.subscribe(onNext: { [weak self](list) in
//            self?.collectionView.reloadData()
//        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = Timer.scheduledTimer(0, action: { [weak self](timer) in
            self?.requestData()
        }, userInfo: nil, repeats: false)
        
        startPolling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.indexRequest?.cancel()
        viewModel.timeLineRequest?.cancel()
        viewModel.indexTimeLineRequest?.cancel()
        
        stopPolling()
    }
    
    func requestData(complete: @escaping () -> Void = {}) {
        viewModel.requestIndexData()
        
        Observable.zip(self.viewModel.marketDataSourceSingle.asObservable(), self.viewModel.fundDataSingle.asObservable()).subscribe(onNext: { (arg0) in
            complete()
            self.collectionView.reloadData()
        }, onError: { error in
            complete()
        }).disposed(by: self.disposeBag)
    }
    
    func startPolling() {
        
        stopPolling()
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.rankFreq))
        
        timer = Timer.scheduledTimer(timeInterval, action: { [weak self](timer) in
            guard let `self` = self else { return }
            
            Observable.zip(self.viewModel.marketDataSourceSingle.asObservable(), self.viewModel.fundDataSingle.asObservable()).subscribe(onNext: { (arg0) in
                self.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
            
        }, userInfo: nil, repeats: true)

        let stareTimeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.selfStockFreq))
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.stareTimer, timeInterval: stareTimeInterval, queue: .main, repeats: true) {
            [weak self] in
            guard let `self` = self else { return }
            self.viewModel.stareDataSingle.asObservable().subscribe(onNext: { [weak self] model in
                guard let strongSelf = self else { return }

                strongSelf.collectionView.reloadData()
            }).disposed(by: self.rx.disposeBag)
        }

    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
        YXTimer.shared.cancleTimer(WithTimerName: self.stareTimer)
    }
    
    func goToNewStockCenter() {
        let context: [String : Any] = ["market" : YXMarketType.HK.rawValue]
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
    
    deinit {
        stopPolling()
    }
}

//MARK:数据源
extension YXChinaMarketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = viewModel.dataSource[section]["list"] {
            return (items as! Array<Any>).count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            return footerView
        }else if kind == UICollectionView.elementKindSectionHeader {
            let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
            
            if sectionType == .allHSStock {
                return filterHeaderView(collectionView: collectionView, indexPath: indexPath, sectionType: sectionType)
            }else {
                return commonHeaderView(collectionView: collectionView, indexPath: indexPath, sectionType: sectionType)
            }
            
        }
        
        return UICollectionReusableView()
    }
    
    func filterHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXMarketSectionType) -> UICollectionReusableView {
        let hsAllHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketFilterCell.self), for: indexPath) as! YXMarketFilterCell
        
        let title = sectionType.sectionName
        hsAllHeaderView.commonHeaderView.title = title

        hsAllHeaderView.commonHeaderView.action = { [weak self] in
            guard let `self` = self else { return }
            self.goToStockList(title: title, code: self.viewModel.allHSRankCode, sortType: self.viewModel.hsRankSortType, sortDirection: self.viewModel.hsRankSortDirection)
        }
        hsAllHeaderView.tapFilterItemAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            if sortType != .roc {
                self.isShowAdditionalType = true
                self.additionalType = sortType
            }else {
                self.isShowAdditionalType = false
            }
            self.viewModel.hsRankSortDirection = direction
            self.viewModel.hsRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
        }
        hsAllHeaderView.tapSortButtonAction = { [weak self](direction, sortType) in
            guard let `self` = self else { return }
            self.viewModel.hsRankSortDirection = direction
            self.viewModel.hsRankSortType = sortType
            self.viewModel.marketDataSourceSingle.subscribe(onSuccess: { [weak self](result) in
                self?.collectionView.reloadData()
            }).disposed(by: self.disposeBag)
        }
        return hsAllHeaderView
    }
    
    func commonHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXMarketSectionType) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self), for: indexPath) as! YXMarketCommonHeaderCell
        
        switch sectionType {

        case .AStockFund:
            let title = YXMarketSectionType.AStockFund.sectionName
            headerView.title = title
            headerView.subTitle = String(format: "(%@)", YXLanguageUtility.kLang(key: "markets_news_explain"))
            headerView.action = {[weak self] in
                guard let `self` = self else { return }
                self.goToStockList(title: title, code: self.viewModel.AstockRankCode)

            }
        
        case .concept:
            let title = YXMarketSectionType.concept.sectionName
            headerView.title = title
            headerView.subTitle = ""
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let context: [String : Any] = ["market": self.viewModel.market, "rankCode": self.viewModel.conceptRankCode, "title": title]
                self.viewModel.navigator.push(YXModulePaths.hotIndustryList.url, context: context)
            }
        
        case .industry:
            headerView.title = YXMarketSectionType.industry.sectionName
            headerView.subTitle = ""
            headerView.action = { [weak self] in
                guard let `self` = self else { return }
                let context: [String : Any] = ["market" : self.viewModel.market, "rankCode": self.viewModel.industryRankCode]
                self.viewModel.navigator.push(YXModulePaths.hotIndustryList.url, context: context)
            }
        case .stare:
            headerView.title = YXMarketSectionType.stare.sectionName
            headerView.subTitle = ""
            headerView.action = { [weak self] in
                self?.goToStareHome()
            }
            
        default:
            headerView.title = ""
            headerView.subTitle = ""
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        
        switch sectionType {
        case .index:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketIndexCell.self), for: indexPath)
            
        case .entrance:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketEntranceViewCell.self), for: indexPath)
            
        case .marketOverview:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXChinaMarketOverViewCell.self), for: indexPath)
        
        case .AStockFund:
            if indexPath.item < 2 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketHSFundCell.self), for: indexPath)
            }else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketHSFundFlowCell.self), for: indexPath)
            }
            
        case .AStock:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXStockCollectionViewCell.self), for: indexPath)

        case .industry, .concept:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHotPlateCell.self), for: indexPath)

        case .stare:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketStareCell.self), for: indexPath)
        
        case .allHSStock:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHKAllCollectionViewCell.self), for: indexPath)

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
            indexCell.endTimeLabel.text = "15:00"
            indexCell.midTimeLabel.text = "11:30/13:00"
            indexCell.onClickIndexPath = { [weak self](indexPath) in
                self?.viewModel.requestIndexTimeLineData(index: indexPath.item)
            }
            indexCell.onClickTimeLineView = { [weak self](selectedIndex) in
                guard let `self` = self else { return }
                if self.viewModel.indexDataSource.count > 0 {
                    let quoteItem = self.viewModel.indexDataSource[selectedIndex]
                    if let _ = quoteItem.market, let _ = quoteItem.symbol {

                        var inputs: [YXStockInputModel] = []
                        for info in self.viewModel.indexDataSource {
                            if let market = info.market, let symbol = info.symbol {

                                let input = YXStockInputModel()
                                input.market = market
                                input.symbol = symbol
                                input.name = info.name ?? ""
                                inputs.append(input)
                            }
                        }

                        if inputs.count > 0 {
                            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : selectedIndex])
                        }

                    }
                }
            }
            
            if indexCell.disposeBag != nil {
                
                viewModel.indexSubject.subscribe(onNext: { [weak self](dataSource) in
                    guard let `self` = self else {return}
                    indexCell.dataSource = self.viewModel.indexDataSource
                }).disposed(by: indexCell.disposeBag!)
                
                viewModel.indexTimeLineSubject.subscribe(onNext: { (timeLineData) in
                    indexCell.timeLineData = timeLineData
                }).disposed(by: indexCell.disposeBag!)
                
            }
         
        case .entrance:
            let entranceCell = cell as! YXMarketEntranceViewCell
            let items = list as! Array<[String: String]>
            entranceCell.titleLabel.text = items[indexPath.item]["title"]
            entranceCell.icon.image = UIImage.init(named: items[indexPath.item]["iconName"] ?? "")
            
        case .marketOverview:
            let overviewCell = cell as! YXChinaMarketOverViewCell
            overviewCell.overViewData = viewModel.allHSRank;
        case .AStockFund:
            let items = list as! Array<Any>
            if indexPath.item < 2 {
                let fundCell = cell as! YXMarketHSFundCell
                let item = items[indexPath.item] as! YXMarketHSSCMItem
                fundCell.info = item
            }else {
                let fundFlowCell = cell as! YXMarketHSFundFlowCell
                let item = items[indexPath.item] as! YXMarketHSSCMResponseModel
                fundFlowCell.info = item
            }

        case .stare:
            let stockCell = cell as! YXMarketStareCell
            stockCell.model = self.viewModel.stareModel
            
        case .AStock:
            let stockCell = cell as! YXStockCollectionViewCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            let item = items[indexPath.item]
            if let market = item.trdMarket, let secuCode = item.secuCode {
                let key = market + secuCode
                stockCell.info = item
                stockCell.timeLineData = viewModel.timeLinePool[key]
            }

            stockCell.level = viewModel.AstockRank?.level
        
        case .industry, .concept:
            let industryCell = cell as! YXHotPlateCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            industryCell.info = items[indexPath.item]
            
        case .allHSStock:
            let stockCell = cell as! YXHKAllCollectionViewCell
            let items = list as! Array<YXMarketRankCodeListInfo>
            let item = items[indexPath.item]
            stockCell.isShowAdditionalType = self.isShowAdditionalType
            stockCell.additionalType = self.additionalType
            stockCell.model = item
            stockCell.level = viewModel.allHSRank?.level
        
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]
        
        switch sectionType {
        
        case .entrance:
            if indexPath.item == 0 {
                let viewModel = YXIntervalHomeViewModel.init(services: self.viewModel.navigator, params: ["market" : "hs"])
                self.viewModel.navigator.push(viewModel, animated: true)
                
                
            }else if (indexPath.item == 1) {
                let vm = YXStockFilterTabViewModel.init(services: self.viewModel.navigator, params: ["market": YXMarketType.ChinaHS.rawValue])
                self.viewModel.navigator.push(vm, animated: true)
                
            }
        
        case .AStock, .allHSStock:
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
            }
        
        case .industry, .concept:
            let items = list as! Array<YXMarketRankCodeListInfo>
            //let info = items[indexPath.item]

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
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.item])
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

        default:
            break
        }
    }
}

//MARK:布局
extension YXChinaMarketViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXMarketSectionType
        var size: CGSize = .zero
        let collectionViewWidth = collectionView.frame.size.width
        
        switch sectionType {
        case .index:
            size = CGSize.init(width: YXConstant.screenWidth, height: 276)
        case .entrance:
            size = CGSize.init(width: collectionViewWidth/2.0, height: 84)
        case .marketOverview:
            size = CGSize.init(width: collectionViewWidth, height: 370)
        case .AStockFund:
            size = CGSize.init(width: (collectionViewWidth-2)/3.0, height: 140)
        case .AStock, .allHSStock:
            size = CGSize.init(width: collectionViewWidth, height: 63)
        case .industry, .concept:
            size = CGSize.init(width: (collectionViewWidth-2)/3.0, height: 124)
        case .stare:
            size = CGSize.init(width: collectionViewWidth, height: 44)
        default:
            size = CGSize.zero
        }
        
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .marketOverview, .AStock, .AStockFund, .concept, .industry, .allHSStock:
            return UIEdgeInsets.init(top: 1, left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .entrance:
            return 0
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index, .AStock, .marketOverview, .entrance:
            return CGSize.zero
        case .allHSStock:
            return CGSize.init(width: collectionView.frame.size.width, height: 155)
        default:
            return CGSize.init(width: collectionView.frame.size.width, height: 55)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXMarketSectionType
        switch sectionType {
        case .index, .AStockFund:
            return CGSize.zero
        default:
            return CGSize.init(width: collectionView.frame.size.width, height: 10)
        }
        
    }
}
