//
//  YXSGWarrantsViewController.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import YXKit

@objc enum YXWarrantsCurSortType: Int { //类型
    case none                = 0 //无
    case type                = 1 //类型
    case date                = 2 //日期
    case issuer              = 3 //发行人
}

class YXSGWarrantsViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    override var pageName: String {
        "Warrants SG"
    }
    
    var curSortType: YXWarrantsCurSortType = .none
    var confirmCallBack: (([String: String])->Void)!
    var didSearchItem :((YXSearchItem)->())!
    var didSearchAll :((Bool)->())!
    let config = YXNewStockMarketConfig(itemWidth: 95)

    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXSGWarrantsViewModel! = YXSGWarrantsViewModel()
    let reuseIdentifier = "YXWarrantsTableViewCell"
    var refreshTimer: Timer?
    var quoteRequest: YXQuoteRequest?
    
    lazy var sortTopView: YXWarrantsSortTopView = {
        let view = YXWarrantsSortTopView.init(sgWarrantsWithFrame: .zero)
        view.typeArr = self.typeArr
        view.dateArr = self.dateArr
        return view
    }()
    
    
    lazy var tableFooterView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = QMUITheme().foregroundColor()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        do {
            let label = QMUILabel()
            if self.viewModel.userLevel == .delay {
                label.text = YXLanguageUtility.kLang(key: "stock_detail_delayTip")
            } else {
                label.text = YXLanguageUtility.kLang(key: "warrants_bmp_tip")
            }
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
    
    
    lazy var typeArr: [String] = {
        var typeArr = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "warrants_sell"), YXLanguageUtility.kLang(key: "warrants_buy")]
        return typeArr
    }()
    
    lazy var dateArr: [String] = {
        var dateArr = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "warrants_less_3_month"), YXLanguageUtility.kLang(key: "warrants_3_6_month"), YXLanguageUtility.kLang(key: "warrants_6_12_month"), YXLanguageUtility.kLang(key: "warrants_morethan_12_month")]
        return dateArr
    }()
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        refreshHeader.refreshingBlock?()
    }
    
    override func showNoDataEmptyView() {
//        super.showNoDataEmptyView()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.reloadEmptyDataSet()
    }
    
    lazy var sectionHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = sectionSortView.backgroundColor
        
        view.addSubview(sortTopView)
        view.addSubview(sectionSortView)
        
        sortTopView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(44)
        }
        
        sectionSortView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.bottom.right.equalTo(view)
        }
        
        if viewModel.warrantType == .inlineWarrants {
            sortTopView.isHidden = true
            sortTopView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
        
        return view
    }()
    
    lazy var sectionSortView: YXWarrantsMarketedSortView = {
        let view = YXWarrantsMarketedSortView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), sortTypes: sortArrs, firstState: .normal, config: self.config)
        view.warrantResetViewFrame()
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        
        if self.viewModel.isFromFundFlow {
            view.setDefaultSortTypeDescending(sortType: .yxScore)
        }else {
            view.setDefaultSortTypeDescending(sortType: .roc)
        }

        return view
    }()
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let tool = YXBottomSheetViewTool()
        return tool
    }()
    
    var sortArrs: [YXStockRankSortType] {
        return [.warrantsNow,
                .roc,
                .change,
                .volume,
                .amount,
                .bidSize,
                .askSize,
                .endDate,
                .strikePrice,
                .premium,
                .moneyness,
                .impliedVolatility,
                .actualLeverage,
                .gearingRatio,
                .exchangeRatio,
                .delta,
                .status]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "market_sg_warrants_title")
        initUI()
        handleBlock()
        bindHUD()
        bindTableView()
        loadNewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.needRefresh {
            viewModel.needRefresh = false
            refreshHeaderViewAndData()
        }
        startTimer()
        requestQuoteData()

        self.viewModel.updateLevel()
        self.refreshVisibleData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        quoteRequest?.cancel()
    }
    
    func clearAll() {
//        guard let `self` = self else { return }
        self.viewModel.symbol = ""
        self.viewModel.market = kYXMarketSG
        self.viewModel.name = ""
        self.clearSortConditions()
        self.loadNewData()
    }
    
    func initUI() {
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
                
        confirmCallBack = {[weak self] dic in
            guard let `self` = self else { return }
            
            self.viewModel.outstandingPctLow = dic["outstandingPctLow"] ?? ""
            self.viewModel.outstandingPctHeight = dic["outstandingPctHeight"] ?? ""
            self.viewModel.exchangeRatioLow = dic["exchangeRatioLow"] ?? ""
            self.viewModel.exchangeRatioHeight = dic["exchangeRatioHeight"] ?? ""
            self.viewModel.recoveryPriceLow = dic["recoveryPriceLow"] ?? ""
            self.viewModel.recoveryPriceHeight = dic["recoveryPriceHeight"] ?? ""
            self.viewModel.extendedVolatilityLow = dic["extendedVolatilityLow"] ?? ""
            self.viewModel.extendedVolatilityHeight = dic["extendedVolatilityHeight"] ?? ""
            
            self.viewModel.moneyness = YXBullAndBellMoneyness(rawValue: NSInteger(dic["moneyness"] ?? "")!) ?? YXBullAndBellMoneyness.all
            self.viewModel.leverageRatio = YXBullAndBellLeverageRatio(rawValue: NSInteger(dic["leverageRatio"] ?? "")!) ?? YXBullAndBellLeverageRatio.all
            self.viewModel.premium = YXBullAndBellPremium(rawValue: NSInteger(dic["premium"] ?? "")!) ?? YXBullAndBellPremium.all
            self.viewModel.outstandingRatio = YXBullAndBellOutstandingRatio(rawValue: NSInteger(dic["outstandingRatio"] ?? "")!) ?? YXBullAndBellOutstandingRatio.all
            self.loadNewData()
            self.setSortBtnState()
            self.bottomSheet.hide()
        }
        
        didSearchItem = { [weak self] (item) in
            guard let `self` = self else { return }
            self.viewModel.symbol = item.symbol
            self.viewModel.market = item.market
            self.viewModel.name = item.name
            self.viewModel.priceBase = 0
            self.viewModel.now = 0
            self.viewModel.change = 0
            self.viewModel.roc = 0
            self.clearSortConditions()
            self.loadNewData()
            //self.requestQuoteData()
        }
        
        didSearchAll = { [weak self] (bool) in
            guard let `self` = self else { return }
            self.viewModel.symbol = ""
            self.viewModel.market = kYXMarketSG
            self.viewModel.name = ""
            self.clearSortConditions()
            self.loadNewData()
        }
        

        
        self.tableView.rx.observeWeakly(CGSize.self, "contentSize").subscribe(onNext: { [weak self] (contentSize) in
            guard let strongSelf = self else { return }
            
            if let size = contentSize {
                let maxHeight = strongSelf.tableView.bounds.height
                if size.height < maxHeight {
                    strongSelf.tableView.contentSize = CGSize(width: size.width, height: maxHeight)
                }
            }
            }).disposed(by: disposeBag)
        
//        view.addSubview(backView)
//        backView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(view)
//            make.top.equalTo(self.view).offset(44);
//            make.bottom.equalTo(self.tableView)
//        }
//
//        backView.addSubview(hideBtn)
//        hideBtn.snp.makeConstraints { (make) in
//            make.left.top.right.bottom.equalTo(backView)
//        }
                
        sortTopView.type = viewModel.type.rawValue
        sortTopView.setSortBtnState()
        
        sortTopView.typeBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.sortTopView.typeBtn.isSelected = true
            self.sortTopView.setSelectedWith(self.sortTopView.typeBtn)
            self.setSortBtnState()
            self.scrollToSortTop()
            
            self.curSortType = .type
            var index = 0
            switch self.viewModel.type {
            case .sell:
                index = 1
                break
            case .buy:
                index = 2
                break
            default:
                index = 0
                break
            }
            
            let sortView: YXWarrantsSortView = YXWarrantsSortView(titleArr: self.typeArr, select: index)
            
            sortView.seletedBlock = {[weak self] index in
                guard let `self` = self else { return }
                
                self.bottomSheet.hide()
                
                switch index {
                case 1:
                    self.viewModel.type = YXBullAndBellType.sell
                    break
                case 2:
                    self.viewModel.type = YXBullAndBellType.buy
                    break
                default:
                    self.viewModel.type = YXBullAndBellType.all
                    break
                }
                
                self.loadNewData()
                self.setSortBtnState()
            }
            
            self.bottomSheet.rightButton.isHidden = true
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_type")
            self.bottomSheet.showView(view: sortView, contentHeight: 276)
            
            
        }).disposed(by: disposeBag)
        
       
        sortTopView.dateBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            self.sortTopView.setSelectedWith(self.sortTopView.dateBtn)
            self.setSortBtnState()
            self.scrollToSortTop()
            
            self.curSortType = .date
            let sortView: YXWarrantsSortView = YXWarrantsSortView(titleArr: self.dateArr, select: self.viewModel!.expireDate.rawValue)
            sortView.seletedBlock = {[weak self] index in
                guard let `self` = self else { return }
                
                self.bottomSheet.hide()
                
                self.viewModel.expireDate = YXBullAndBellExpireDate(rawValue: index) ?? YXBullAndBellExpireDate.all
                
                self.loadNewData()
                self.setSortBtnState()
            }
            
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_end_date")
            self.bottomSheet.showView(view: sortView, contentHeight: 380)
            
        }).disposed(by: disposeBag)
        
        sortTopView.moreBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            self.sortTopView.setSelectedWith(self.sortTopView.moreBtn)
            
            let vc = YXStockWarrantsSortViewController()
            vc.viewModel.navigator = self.viewModel.navigator
            vc.sortView.outstandingPctLow = self.viewModel.outstandingPctLow
            vc.sortView.outstandingPctHeight = self.viewModel.outstandingPctHeight
            vc.sortView.exchangeRatioLow = self.viewModel.exchangeRatioLow
            vc.sortView.exchangeRatioHeight = self.viewModel.exchangeRatioHeight
            vc.sortView.recoveryPriceLow = self.viewModel.recoveryPriceLow
            vc.sortView.recoveryPriceHeight = self.viewModel.recoveryPriceHeight
            vc.sortView.extendedVolatilityLow = self.viewModel.extendedVolatilityLow
            vc.sortView.extendedVolatilityHeight = self.viewModel.extendedVolatilityHeight
            vc.sortView.moneyness = self.viewModel!.moneyness.rawValue
            vc.sortView.leverageRatio = self.viewModel!.leverageRatio.rawValue
            vc.sortView.premium = self.viewModel!.premium.rawValue
            vc.sortView.outstandingRatio = self.viewModel!.outstandingRatio.rawValue
            vc.confirmCallBack = self.confirmCallBack
            vc.sortView.setAllBtnState()
            
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_more_sort")
            self.bottomSheet.rightButton.isHidden = false
            self.bottomSheet.rightButton.setImage(UIImage(named: "guess_refresh"), for: .normal)
            self.bottomSheet.rightButton.setTitle(YXLanguageUtility.kLang(key: "warrants_reset"), for: .normal)
            self.bottomSheet.rightButtonAction = { [weak vc] in
                vc?.resetAll()
            }
            self.bottomSheet.showViewController(vc: vc)
            
        }).disposed(by: disposeBag)
        

    }
    
    @objc func setPrcData(low: String, up: String, type: YXBullAndBellType) {
//        self.viewModel.type = type;
        self.viewModel.recoveryPriceLow = low;
        self.viewModel.recoveryPriceHeight = up;
//        [self.viewModel.requestOffsetDataCommand execute:@(0)];
        loadNewData()
//        [self updateHeaderView];
//        self.moreSortView.recoveryPriceLow = low;
//        self.moreSortView.recoveryPriceHeight = up;
//        [self.headerView setSortBtnState];
        setSortBtnState()
//        [self.moreSortView setAllBtnState];
    }
    
    func scrollToSortTop() {
        let point = CGPoint(x: 0, y: 0)
        tableView.setContentOffset(point, animated: true)
    }
    
    func handleBlock() {
        self.sectionSortView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            switch type {
            case .warrantsNow:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.price
                break
            case .roc:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.roc
                break
            case .yxScore:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.score
                break
            case .change:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.change
                break
            case .volume:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.volume
                break
            case .amount:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.amount
                break
            case .endDate:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.maturityDate
                break
            case .premium:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.premium
                break
            case .outstandingRatio:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.outstandingPct
                break
            case .leverageRatio:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.gearing
                break
            case .exchangeRatio:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.conversionRatio
                break
            case .strikePrice:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.strike
                break
            case .moneyness:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.moneyness
                break
            case .impliedVolatility:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.impliedVolatility
                break
            case .actualLeverage:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.actualLeverage
                break
            case .callPrice:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.callPrice
                break
            case .toCallPrice:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.toCallPrice
                break
            case .upperStrike:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.upperStrike
                break
            case .lowerStrike:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.lowerStrike
                break
            case .toUpperStrike:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.toUpperStrike
                break
            case .toLowerStrike:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.toLowerStrike
                break
            case .bidSize:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.bidSize
                break
            case .askSize:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.askSize
                break
            case .status:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.status
                break
            case .delta:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.delta
                break
            default:
                strongSelf.viewModel.sortType = YXBullAndBellSortType.volume
            }

            switch state {
            case .normal:
                strongSelf.viewModel.direction = .descending
                strongSelf.viewModel.sortType = YXBullAndBellSortType.volume
                break
            case .descending:
                strongSelf.viewModel.direction = .descending
                break
            case .ascending:
                strongSelf.viewModel.direction = .ascending
                break
            }
            strongSelf.loadNewData()
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
    
    func refreshHeaderViewAndData() {
        self.clearSortConditions()
        self.loadNewData()
        //self.requestQuoteData()
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        setupRefreshHeader(tableView)
        
        
        viewModel.hudSubject.onNext(.loading(nil, false))

        tableView.dataSource = nil
        var isDelay = false
        if viewModel.userLevel == .delay {
            isDelay = true
        }
        
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
            var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
            if cell == nil {
                cell = YXWarrantsTableViewCell(style: .default, reuseIdentifier: self.reuseIdentifier, sortTypes: self.sortArrs, config: self.config)
                if let marketCell = cell as? YXWarrantsTableViewCell {
                    marketCell.isDelay = isDelay
                    self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                        point != marketCell.scrollView.contentOffset
                    }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                    marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                        point != self?.viewModel.contentOffsetRelay.value
                    }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                }
            }
            let tableCell = (cell as! YXWarrantsTableViewCell)
            tableCell.isDelay = (self.viewModel.userLevel == .delay)
            tableCell.refreshUI(model: item, market:self.viewModel.market ,isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
            return cell!
            }
            .disposed(by: disposeBag)
        
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
            
            if (self.viewModel.userLevel == .bmp) && self.viewModel.dataSource.value.count > 0 {
                self.tableView.tableFooterView = self.tableFooterView
            } else {
                self.tableView.tableFooterView = nil
            }
            
        }).disposed(by: rx.disposeBag)
        
        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutTableView() {
        
        tableView.snp.remakeConstraints { (make) in
            make.right.left.bottom.equalTo(view)
            make.top.equalTo(YXConstant.navBarHeight())
        }
    }
    
    func clearSortConditions() {
        
        self.viewModel.type = .all
        self.viewModel.expireDate = .all
        self.viewModel.moneyness = .all
        self.viewModel.leverageRatio = .all
        self.viewModel.premium = .all
        self.viewModel.outstandingRatio = .all
        self.viewModel.outstandingPctLow = ""
        self.viewModel.outstandingPctHeight = ""
        self.viewModel.exchangeRatioLow = ""
        self.viewModel.exchangeRatioHeight = ""
        self.viewModel.recoveryPriceLow = ""
        self.viewModel.recoveryPriceHeight = ""
        self.viewModel.extendedVolatilityLow = ""
        self.viewModel.extendedVolatilityHeight = ""
        self.setSortBtnState()
    }
    
    func loadNewData() {
        //tableView.setContentOffset(.zero, animated: false)
        refreshHeader.refreshingBlock?()
    }

    func cleanStock() {
        
    }
    
    func setSortBtnState() {
        
        sortTopView.type = viewModel.type.rawValue
        sortTopView.expireDate = viewModel.expireDate.rawValue
        sortTopView.moneyness = viewModel.moneyness.rawValue
        sortTopView.leverageRatio = viewModel.leverageRatio.rawValue
        sortTopView.premium = viewModel.premium.rawValue
        sortTopView.outstandingRatio = viewModel.outstandingRatio.rawValue
        sortTopView.outstandingPctLow = viewModel.outstandingPctLow
        sortTopView.outstandingPctHeight = viewModel.outstandingPctHeight
        sortTopView.exchangeRatioLow = viewModel.exchangeRatioLow
        sortTopView.exchangeRatioHeight = viewModel.exchangeRatioHeight
        sortTopView.recoveryPriceLow = viewModel.recoveryPriceLow
        sortTopView.recoveryPriceHeight = viewModel.recoveryPriceHeight
        sortTopView.extendedVolatilityLow = viewModel.extendedVolatilityLow
        sortTopView.extendedVolatilityHeight = viewModel.extendedVolatilityHeight
        
        sortTopView.setSortBtnState()
        
    }
    
    
    func requestQuoteData() {
        
        quoteRequest?.cancel()
        quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [Secu(market: viewModel.market, symbol: viewModel.symbol)], level: viewModel.userLevel, handler: ({ [weak self](quotes, scheme) in
            guard let `self` = self else { return }
            if let quote = quotes.first {
                if quote.symbol ?? "" == self.viewModel.symbol {
                    self.viewModel.name = quote.name
                    self.viewModel.now = quote.latestPrice?.value ?? 0
                    self.viewModel.change = quote.netchng?.value ?? 0
                    self.viewModel.roc = quote.pctchng?.value ?? 0
                    self.viewModel.priceBase = quote.priceBase?.value ?? 0

                }
            }
        }))
    }
}



extension YXSGWarrantsViewController {
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
    
    //轮询数据
    @objc func refreshVisibleData() {
        
        let visibleCells = self.tableView.visibleCells
        if let cell = visibleCells.first, let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row < viewModel.dataSource.value.count {
                
                var perPage = viewModel.perPage
                if viewModel.userLevel == .bmp {
                    perPage = 20
                }
                viewModel.services.request(.warrants(viewModel.market, viewModel.symbol, indexPath.row, perPage, viewModel.sortType.rawValue, viewModel.direction.rawValue, viewModel.generateFilterDictionary(), 0), response: (viewModel.warrantsResultResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
}

extension YXSGWarrantsViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        68
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 40
        if viewModel.warrantType == .bullBear {
            height = 84
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var height: CGFloat = 40
        if viewModel.warrantType == .bullBear {
            height = 84
        }
        sectionHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: height)
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < viewModel.dataSource.value.count {
            //let item = viewModel.dataSource.value[indexPath.row]

            var inputs: [YXStockInputModel] = []
            for info in viewModel.dataSource.value {
                if let symbol = info.code {

                    let input = YXStockInputModel()
                    input.market = self.viewModel.market
                    input.symbol = symbol
                    input.name = info.name ?? ""
                    inputs.append(input)
                }
            }

            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row])
            }
        }
    }
}


extension YXSGWarrantsViewController {
    
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

extension YXSGWarrantsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = ""
        if viewModel.warrantType == .bullBear {
            str = YXLanguageUtility.kLang(key: "warrants_no_warrants")
        } else if viewModel.warrantType == .inlineWarrants {
            str = YXLanguageUtility.kLang(key: "warrants_not_inline_warrant")
        }
        return NSAttributedString(string: str, attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage(named: "empty_noData")
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        10
    }
    
}


