//
//  YXStockDetailIndustryVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import JXPagingView

enum YXRankType: Int {
    case adr = 0
    case ah = 1
    // 个股详情的成分股
    case stockDetail
    // 可融资股票
    case marginAble
    case normal
    // 日内融
    case dailyFunding
    // 盘前
    case pre
    // 盘后
    case after
    
    case sgETF
    
    case REITs
    
    case DLCs
      
    
    var rankCode: String {
        switch self {
        case .adr:
            return "ADR_ALL"
        case .ah:
            return "AH_ALL"
        case .stockDetail:
            return ""
        case .marginAble:
            return "MARGIN_ALL"
        case .normal:
            return ""
        case .dailyFunding:
            return "DAILYFUNDING_ALL"
        case .pre:
            return "USPRE_ALL"
        case .after:
            return "USAFT_ALL"
        case .sgETF:
            return "MKTETF_ALL"
        case .REITs:
            return "REITs_ALL"
        case .DLCs:
            return "DLCs_ALL"
        }
    }
    
    var title: String {
        switch self {
        case .adr:
            return YXLanguageUtility.kLang(key: "markets_news_adr")//"港股ADR"
        case .ah:
            return YXLanguageUtility.kLang(key: "market_ah_shares")//"AH股"
        case .marginAble:
            return YXLanguageUtility.kLang(key: "market_financing")//可融资股票
        case .dailyFunding:
            return YXLanguageUtility.kLang(key: "market_dailyFunding")//"日内融股票"//
        case .pre:
            return YXLanguageUtility.kLang(key: "common_pre_opening")
        case .after:
            return YXLanguageUtility.kLang(key: "common_after_opening")
        case .sgETF:
            return YXLanguageUtility.kLang(key: "market_sg_etf")
        case .REITs:
            return YXLanguageUtility.kLang(key: "markets_news_reits")
        case .DLCs:
            return YXLanguageUtility.kLang(key: "market_sg_dlcs")
        default:
            return ""
        }
    }
    
    var sortArrs: [YXStockRankSortType] {
        switch self {
        case .stockDetail:
            return [.now, .roc]
        case .marginAble:
            return [.now,
                    .roc,
                    .marginRatio,
                    .change,
                    .volume,
                    .amount,
                    .turnoverRate,
                    .marketValue,
                    .amp,
                    .pe,
                    .volumeRatio
            ]
        case .dailyFunding:
            return [.gearingRatio, .now, .roc, .bail, .change]
        case .pre:
            return [.preAndClosePrice, .preRoc]
        case .after:
            return [.afterAndClosePrice, .afterRoc]
        case .REITs:
            return [.now,
                    .roc,
                    .change,
                    .volume,
                    .amount,
                    .turnoverRate,
                    .pe,
                    .amp,
                    .marketValue,
                    .volumeRatio,
                    .cittthan]
        case .sgETF:
            return [.now,
                    .roc,
                    .change,
                    .volume,
                    .amount,
                    .turnoverRate,
                    .pe,
                    .amp,
                    .marketValue,
                    .volumeRatio,
                    .cittthan]
        case .DLCs:
            return [.now,
                    .roc,
                    .change,
                    .volume,
                    .amount,
                    .bid,
                    .ask,
                    .bidSize,
                    .askSize,
                    .currency,
                    .expiryDate]
        default:
            return [.now,
                    .roc,
                    .change,
                    .accer5,
                    .volume,
                    .amount,
                    .mainInflow,
                    .netInflow,
                    .turnoverRate,
                    .marketValue,
                    .amp,
                    .pe,
                    .pb,
                    .dividendYield,
                    .volumeRatio
            ]
        }
    }
}

class YXStockDetailIndustryVC: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    var trackName = ""
    
    override var pageName: String {
        trackName
     }
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockDetailIndustryViewModel! = YXStockDetailIndustryViewModel()
    let reuseIdentifier = "YXNewStockMarketedCell"
    var refreshTimer: Timer?
    var isFirst: Bool = true
    var config = YXNewStockMarketConfig.init(leftItemWidth: 140)
    let kCellHeight: CGFloat = 68
    var isUserInfoUpdate: Bool = false
    var viewAppear: Bool = true
    var isForDayMarginSearch: Bool = false

    var contentHeightBlock: ((_ height: CGFloat) -> Void)?
    var contentHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.title ?? ""
        if self.viewModel.isDetailIndustry, YXConstant.screenWidth < 414  {
            config = YXNewStockMarketConfig(leftItemWidth: uniSize(118), itemWidth: (YXConstant.screenWidth - uniSize(118) - 18 - 50) / 2.0)
        }
        if self.viewModel.rankType == .pre || self.viewModel.rankType == .after {
            self.rotateBgView.isHidden = true
            self.rotateButton.isHidden = true
            config = YXNewStockMarketConfig(leftItemWidth: uniSize(118), itemWidth: (YXConstant.screenWidth - uniSize(118) - 18) / 2.0)
        }
        bindHUD()
        handleBlock()
        bindTableView()
        
       
        if !self.viewModel.isDetailIndustry {
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
        }
        
        if viewModel.market == kYXMarketUS {
            
            if viewModel.code == YXMarketSectionType.upsaAndDowns.rankCode {
                trackName = "All Stocks US"
            } else if viewModel.code == YXMarketSectionType.star.rankCode {
                trackName = "Hot Stocks US"
            }else if viewModel.code == YXMarketSectionType.chinaConceptStock.rankCode {
                trackName = "China Concept Stock US "
            }
            
        } else if viewModel.market == kYXMarketHK {
            
            if viewModel.code == YXMarketSectionType.mainboard.rankCode {
                trackName = "Main Board HK"
            }else if viewModel.code == YXMarketSectionType.gem.rankCode {
                trackName = "GEM HK"
            }else if viewModel.code == YXMarketSectionType.allHKStock.rankCode {
                trackName = "All Stocks HK"
            }
            
            
        } else if viewModel.market == kYXMarketSG {
            
            if viewModel.code == YXRankType.REITs.rankCode {
                trackName = "REITs SG"
            } else if viewModel.code == YXRankType.sgETF.rankCode {
                trackName = "ETF SG"
            }else if viewModel.code == YXRankType.DLCs.rankCode {
                trackName = "DLCs SG"
            }
            
            if viewModel.code == YXMarketSectionType.allSGStock.rankCode {
                trackName = "All Stocks SG"
            } else if viewModel.code == YXMarketSectionType.mainboard.rankCode {
                trackName = "Main Board SG "
            }else if viewModel.code == YXMarketSectionType.cata.rankCode {
                trackName = "Catalist SG  "
            }
            
        }
        
        
    }
    
    override func layoutTableView() {
        if !self.viewModel.isDetailIndustry {
            tableView.snp.remakeConstraints { (make) in
                make.right.left.bottom.equalTo(view)
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                } else {
                    make.top.equalTo(self.topLayoutGuide.snp.top)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        viewAppear = true
        if self.isUserInfoUpdate {
            self.isUserInfoUpdate = false
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !MMKV.default().bool(forKey: YXStockDetailIndustryVC.className()) {
            self.sectionHeaderView.scrollView.scrollToRight(animated: false)
            MMKV.default().set(true, forKey: YXStockDetailIndustryVC.className())
        }
        
        sectionHeaderView.scrollToSortType(sortType: self.viewModel.sorttype, animated: true)
        
        if viewModel.rankType == .dailyFunding {
            // 找到最低保证金额的位置，在该位置左侧价格问号按钮
            for view in self.sectionHeaderView.scrollView.subviews {
                if let item = view as? YXNewStockMarketedSortButton, item.mobileBrief1Type == .bail, infoButton.superview == nil {
                    let rect = view.frame
                    if YXUserManager.isENMode() {
                        infoButton.frame = CGRect.init(x: rect.origin.x - 6, y: rect.origin.y, width: 25, height: rect.size.height)
                    }else {
                        infoButton.frame = CGRect.init(x: rect.origin.x - 20, y: rect.origin.y, width: 25, height: rect.size.height)
                    }
                    
                    self.sectionHeaderView.scrollView.addSubview(infoButton)
                    break
                }
            }
        }

        self.viewModel.updateLevel()
        self.refreshVisibleData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        viewAppear = false
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
                    cell = YXNewStockMarketedCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                    if let marketCell = cell as? YXNewStockMarketedCell {
                        if !self.viewModel.isDetailIndustry {
                            marketCell.scrollView.contentSize = CGSize(width: marketCell.scrollView.contentSize.width + 50, height: marketCell.scrollView.contentSize.height)
                            self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                                point != marketCell.scrollView.contentOffset
                            }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                            marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                                point != self?.viewModel.contentOffsetRelay.value
                            }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                        }
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
            
//            if self.viewModel.userLevel == .bmp && self.viewModel.dataSource.value.count >= 20 && self.viewModel.market == YXMarketType.HK.rawValue && self.viewModel.isShowBMP {
//                self.tableView.tableFooterView = self.tableFooterView
//                self.footerLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bmpTip")
//            }

            if status == .noMoreData{
                if self.tableView.mj_footer == nil {
                    self.setupRefreshFooter(self.tableView)
                }
            }
            if self.isFirst {
                self.isFirst = false
                self.contentHeight = CGFloat(self.viewModel.dataSource.value.count) * self.kCellHeight
                self.contentHeightBlock?(self.contentHeight + self.kSectionHeaderHeight)
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
        
        if !self.viewModel.isDetailIndustry {
            viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
                point != view.scrollView.contentOffset
            }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
            
            view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
                point != self?.viewModel.contentOffsetRelay.value
            }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)

            view.scrollView.contentSize = CGSize(width: view.scrollView.contentSize.width + 50, height: view.scrollView.contentSize.height)
        }

        let sortSate = self.viewModel.sortdirection == 0 ? YXSortState.ascending : YXSortState.descending
        if self.viewModel.rankType == .pre {
            view.setStatus(sortState: sortSate, mobileBrief1Type: .preRoc)
        }else if self.viewModel.rankType == .after {
            view.setStatus(sortState: sortSate, mobileBrief1Type: .afterRoc)
        }else if self.viewModel.rankType == .marginAble {
            view.setStatus(sortState: sortSate, mobileBrief1Type: .marginRatio)
        }
        else {
            view.setStatus(sortState: sortSate, mobileBrief1Type: self.viewModel.sorttype)
        }
        
        
        if self.viewModel.rankType != .dailyFunding {
            
            view.addSubview(rotateBgView)
            rotateBgView.snp.makeConstraints { (make) in
                make.height.equalTo(self.kSectionHeaderHeight)
                make.width.equalTo(50)
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            view.addSubview(rotateButton)
            rotateButton.snp.makeConstraints { (make) in
                make.width.height.equalTo(30)
                make.right.equalToSuperview().offset(-13)
                make.centerY.equalToSuperview()
            }
        }
        
        return view
    }()
    
    lazy var rotateBgView: UIView = {
        let rotateBgView = UIView()
        rotateBgView.backgroundColor = QMUITheme().foregroundColor()
        return rotateBgView
    }()
    
    lazy var infoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "question")?.qmui_image(withTintColor: QMUITheme().textColorLevel2())
        button.setImage(image, for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: {
            YXNewStockPurchaseUtility.noticeOneButtonAlert(title: nil, msg: YXLanguageUtility.kLang(key: "market_bail_notice"))
        })
        return button
    }()
    
    lazy var rotateButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "rotate_portrait"), for: .normal)
        button.addTarget(self, action: #selector(rotateButtonAction), for: .touchUpInside)
        return button
    }()
    
    @objc func rotateButtonAction() {
        
        
        self.viewModel.navigator.push(YXModulePaths.stockIndustryLand.url, context: ["title": self.viewModel.title ?? "", "market": self.viewModel.market ?? "", "code": self.viewModel.code, "isFromBK" : self.viewModel.isDetailIndustry, "isShowBMP" : self.viewModel.isShowBMP, "rankType": self.viewModel.rankType], animated: false)
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
    
    var sortArrs: [YXStockRankSortType]  {
        
        if self.viewModel.isDetailIndustry {
            // 为了兼容旧代码
            self.viewModel.rankType = .stockDetail
        }
        
        return self.viewModel.rankType.sortArrs
    }
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
           [weak self] (state, type) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sorttype = type
            if type == .preRoc || type == .afterRoc {
                strongSelf.viewModel.sorttype = .roc
            }
            if type == .preAndClosePrice || type == .afterAndClosePrice {
                return
            }
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
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                self.isUserInfoUpdate = true
                self.viewModel.updateLevel()
                if self.viewAppear {
                    self.isUserInfoUpdate = false
                    self.tableView.reloadData()
                }
            }).disposed(by: rx.disposeBag)

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
    
    override func layoutEmptyView() -> Bool {
        super.layoutEmptyView()
        var rect = self.emptyView?.frame
        let originy = self.emptyView?.frame.origin.y
        rect?.origin.y = (originy ?? 0) + 34
        self.emptyView?.frame = rect ?? CGRect.zero
        if let emptyH =  self.emptyView?.frame.size.height, let contentH = self.emptyView?.sizeThatContentViewFits().height {
            self.emptyView?.verticalOffset = -((emptyH - contentH)/2 - 40)
        }
        return true
    }
}

extension YXStockDetailIndustryVC {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        kCellHeight
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
        if isForDayMarginSearch {
            if let parent = self.parent as? YXFinancingViewController {
                let item = viewModel.dataSource.value[indexPath.row]
                
                if let market = item.trdMarket, let symbol = item.secuCode {
                    let searchItem = YXSearchItem.init(name: item.chsNameAbbr, market: market, symbol: symbol)
                    parent.navigationController?.popViewController(animated: true)
                    parent.didSelectedSearchResultItem?(searchItem)
                }
            }
            return
        }
        if indexPath.row < viewModel.dataSource.value.count {
            //let item = viewModel.dataSource.value[indexPath.row]

            var inputs: [YXStockInputModel] = []
            for info in viewModel.dataSource.value {
                if let market = info.trdMarket, let symbol = info.secuCode {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = info.chsNameAbbr
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row])
                let info = inputs[indexPath.row]
                trackViewClickEvent(name: "stocklist_item", other: [" stock_code": info.symbol, "stock_name": info.name ?? ""])
            }

        }
    }
}

extension YXStockDetailIndustryVC {
    
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
                viewModel.services.request(.quotesRank(sortType: viewModel.sorttype.rawValue, sortDirection: viewModel.sortdirection, pageDirection: 0, from: indexPath.row, count: viewModel.perPage, code: self.viewModel.code, market: self.viewModel.market, level: viewModel.userLevel.rawValue), response: (viewModel.resultResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
}


extension YXStockDetailIndustryVC: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.tableView }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}
