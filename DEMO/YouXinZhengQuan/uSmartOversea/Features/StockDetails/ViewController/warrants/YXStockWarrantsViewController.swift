//
//  YXStockWarrantsViewController.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import YXKit

@objc enum YXBullAndBellCurSortType: Int { //类型
    case none                = 0 //无
    case type                = 1 //类型
    case date                = 2 //日期
    case issuer              = 3
}

class YXStockWarrantsViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    weak var mainViewController: YXWarrantsMainViewController?
    var curSortType: YXBullAndBellCurSortType = .none
    var confirmCallBack: (([String: String])->Void)!
    var didSearchItem :((YXSearchItem)->())!
    var didSearchAll :((Bool)->())!
    let config = YXNewStockMarketConfig(leftItemWidth: 170, itemWidth: 95)

    var isHideLZBButton = false {
        didSet {
            headerView.hideLZBButton(isHideLZBButton)
        }
    } // 是否隐藏界内证 涡轮牛熊切换按钮
    
//    lazy var backView: UIView = {
//        let v = UIView()
//        v.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.2)
//        v.isHidden = true
//        return v
//    }()
//
//    lazy var hideBtn: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.addTarget(self, action: #selector(backViewTapAction), for: .touchUpInside)
//        return btn
//    }()
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockWarrantsViewModel! = YXStockWarrantsViewModel()
    let reuseIdentifier = "YXWarrantsTableViewCell"
    var refreshTimer: Timer?
    var quoteRequest: YXQuoteRequest?
    
    lazy var sortTopView: YXWarrantsSortTopView = {
        let view = YXWarrantsSortTopView()
        view.typeArr = self.typeArr
        view.dateArr = self.dateArr
        return view
    }()
    
    func searchAction() {
        if self.viewModel.warrantType == .inlineWarrants {
            let dic = ["didSelectedItem": self.didSearchItem, "didSearchAll": self.didSearchAll, "warrantType": self.viewModel.warrantType] as [String : Any]
            self.viewModel.navigator.present(YXModulePaths.stockWarrantsSearch.url, context: dic)
        } else {
            self.mainViewController?.searchAction(type: self.viewModel.warrantType)
        }
    }
    
    lazy var headerView: YXWarrantsHeaderView = {
        var headerView = YXWarrantsHeaderView()

        headerView.searchBgView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let `self` = self else { return }
            if ges.state == .ended {
                self.searchAction()
            }
        }).disposed(by: rx.disposeBag)
        
        headerView.searchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.searchAction()
            
        }).disposed(by: rx.disposeBag)
        
        headerView.bullBearView.tapItemAction = { [weak self] (market, symbol) in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = market
            input.symbol = symbol
            input.name = self.viewModel.name ?? ""
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }
        
        headerView.signalView.tapItemAction = { [weak self] (market, symbol) in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = market
            input.symbol = symbol
            input.name = self.viewModel.name ?? ""
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }

        headerView.signalView.tapSignalMoreAction = { [weak self] in
            guard let `self` = self else { return }
            
            let vm = YXBullBearMoreViewModel(services:self.viewModel.navigator, type: .warrantcbbc, sectionType: .longShortSignal, params: ["id": kYXMarketHK + self.viewModel.symbol])
            self.viewModel.navigator.push(vm, animated: true)
        }

        headerView.bullBearView.tapBullBearMoreAction = { [weak self] (type) in
            guard let `self` = self else { return }
            self.clearSortConditions()
            self.viewModel.type = type
            self.scrollToSortTop()
            self.loadNewData()
            self.setSortBtnState()
        }
        return headerView
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
        var typeArr = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "warrants_bull"), YXLanguageUtility.kLang(key: "warrants_bear"), YXLanguageUtility.kLang(key: "warrants_sell"), YXLanguageUtility.kLang(key: "warrants_buy")]
        return typeArr
    }()
    
    lazy var dateArr: [String] = {
        var dateArr = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "warrants_less_3_month"), YXLanguageUtility.kLang(key: "warrants_3_6_month"), YXLanguageUtility.kLang(key: "warrants_6_12_month"), YXLanguageUtility.kLang(key: "warrants_morethan_12_month")]
        return dateArr
    }()
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock{
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
//        super.showNoDataEmptyView()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.reloadEmptyDataSet()
//        self.emptyView?.setImage(UIImage(named: "no_stock"))
//        var str = ""
//        if viewModel.warrantType == .bullBear {
//            str = YXLanguageUtility.kLang(key: "warrants_no_warrants")
//        } else if viewModel.warrantType == .inlineWarrants {
//            str = YXLanguageUtility.kLang(key: "warrants_not_inline_warrant")
//        }
//        self.emptyView?.setTextLabelText(str)
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
        tool.leftButtonAction = { [weak self] in
            self?.hideSortView()
        }
        return tool
    }()
    
    var sortArrs: [YXStockRankSortType] {
        if viewModel.warrantType == .bullBear {
            return [YXStockRankSortType.warrantsNow,
            YXStockRankSortType.roc,
            YXStockRankSortType.yxScore,
            YXStockRankSortType.change,
            YXStockRankSortType.strikePrice,
            YXStockRankSortType.volume,
            YXStockRankSortType.amount,
            YXStockRankSortType.endDate,
            YXStockRankSortType.premium,
            YXStockRankSortType.outstandingRatio,
            YXStockRankSortType.moneyness,
            YXStockRankSortType.impliedVolatility,
            YXStockRankSortType.actualLeverage,
            YXStockRankSortType.callPrice,
            YXStockRankSortType.toCallPrice,
            YXStockRankSortType.leverageRatio,
            YXStockRankSortType.exchangeRatio]
            
        } else  {
            return [YXStockRankSortType.warrantsNow,
                    YXStockRankSortType.roc,
                    YXStockRankSortType.change,
                    YXStockRankSortType.lowerStrike,
                    YXStockRankSortType.upperStrike,
                    YXStockRankSortType.volume,
                    YXStockRankSortType.amount,
                    YXStockRankSortType.toLowerStrike,
                    YXStockRankSortType.toUpperStrike,
                    YXStockRankSortType.endDate,
            ]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel.warrantType == .bullBear {
            self.title = YXLanguageUtility.kLang(key: "warrants_bull_bear")
        } else if viewModel.warrantType == .inlineWarrants {
            self.title = YXLanguageUtility.kLang(key: "warrants_inline_warrants")
        }
        
        initUI()
        handleBlock()
        bindHUD()
        bindTableView()
        loadNewData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !MMKV.default().bool(forKey: YXStockWarrantsViewController.className()) {
            self.sectionSortView.scrollView.scrollToRight(animated: false)
            MMKV.default().set(true, forKey: YXStockWarrantsViewController.className())
            self.sectionSortView.scrollToSortType(sortType: .roc, animated: true)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.needRefresh {
            viewModel.needRefresh = false
            refreshHeaderViewAndData()
        }
        startTimer()
        requestQuoteData()
        
        loadSignal()
        loadBullBear()

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
        self.viewModel.market = kYXMarketHK
        self.viewModel.name = ""
        self.clearSortConditions()
        self.updateHeaderViewConstraint()
        self.updateHeaderViewStock()
        self.loadNewData()
    }
    
    func initUI() {
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
//        //搜索
//        let searchItem = UIBarButtonItem.qmui_item(with: UIImage(named: "warrant_search"), target: self, action: nil)
//        //搜索 的响应
//        searchItem.rx.tap.bind { [weak self] in
//            guard let `self` = self else { return }
//            let dic = ["didSelectedItem": self.didSearchItem, "didSearchAll": self.didSearchAll, "warrantType": self.viewModel.warrantType] as [String : Any]
//            self.viewModel.navigator.present(YXModulePaths.stockWarrantsSearch.url, context: dic)
//
//            }.disposed(by: disposeBag)
//
//        navigationItem.rightBarButtonItems = [searchItem]
        
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
            self.updateHeaderViewConstraint()
            self.updateHeaderViewStock()
            self.loadNewData()
            //self.requestQuoteData()
        }
        
        didSearchAll = { [weak self] (bool) in
            guard let `self` = self else { return }
            self.viewModel.symbol = ""
            self.viewModel.market = kYXMarketHK
            self.viewModel.name = ""
            self.clearSortConditions()
            self.updateHeaderViewConstraint()
            self.updateHeaderViewStock()
            self.loadNewData()
        }
        
        
//        view.addSubview(headerView)
        tableView.tableHeaderView = headerView
        headerView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.tableView)
            make.width.equalTo(YXConstant.screenWidth)
        }
        
        self.tableView.rx.observeWeakly(CGSize.self, "contentSize").subscribe(onNext: { [weak self] (contentSize) in
            guard let strongSelf = self else { return }
            
            if let size = contentSize {
                let headerSize = strongSelf.headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                let maxHeight = headerSize.height + strongSelf.tableView.bounds.height
                if size.height < maxHeight {
                    strongSelf.tableView.contentSize = CGSize(width: size.width, height: maxHeight)
                }
            }
            }).disposed(by: disposeBag)
        
//        view.addSubview(backView)
//        backView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(view)
//            make.top.equalTo(self.headerView.snp.bottom).offset(44);
//            make.bottom.equalTo(self.tableView)
//        }
//
//        backView.addSubview(hideBtn)
//        hideBtn.snp.makeConstraints { (make) in
//            make.left.top.right.bottom.equalTo(backView)
//        }
        
        sortTopView.issuerBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            self.sortTopView.setSelectedWith(self.sortTopView.issuerBtn)
            self.setSortBtnState()
            self.scrollToSortTop()
            self.sortTopView.issuerArr = self.viewModel.issuerTitleArray
            self.sortTopView.issuerIndex = self.viewModel.issuerIndex
//            if self.curSortType == .issuer {
//                self.bottomSheet.hide()
//            } else {
//            }
            self.curSortType = .issuer
            
            let sortView: YXWarrantsSortView = YXWarrantsSortView(titleArr: self.viewModel.issuerTitleArray, select: self.viewModel.issuerIndex)
            
            sortView.seletedBlock = {[weak self] index in
                guard let `self` = self else { return }
                
                self.bottomSheet.hide()
                
                self.viewModel.issuerIndex = index
                self.viewModel.issuer = self.viewModel.issuerIDArray[index]
                self.hideSortView()
                self.loadNewData()
                self.setSortBtnState()
            }
            
            self.bottomSheet.rightButton.isHidden = true
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "stock_issuer")
            self.bottomSheet.showView(view: sortView)
            
        }).disposed(by: disposeBag)
        
        sortTopView.type = viewModel.type.rawValue
        sortTopView.setSortBtnState()
        
        sortTopView.typeBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            self.sortTopView.setSelectedWith(self.sortTopView.typeBtn)
            self.setSortBtnState()
            self.scrollToSortTop()
            
//            if self.curSortType == .type {
//                self.bottomSheet.hide()
//            } else {
//            }
            self.curSortType = .type
            var index = 0
            switch self.viewModel.type {
            case .bull:
                index = 1
                break
            case .bear:
                index = 2
                break
            case .sell:
                index = 3
                break
            case .buy:
                index = 4
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
                    self.viewModel.type = YXBullAndBellType.bull
                    break
                case 2:
                    self.viewModel.type = YXBullAndBellType.bear
                    break
                case 3:
                    self.viewModel.type = YXBullAndBellType.sell
                    break
                case 4:
                    self.viewModel.type = YXBullAndBellType.buy
                    break
                default:
                    self.viewModel.type = YXBullAndBellType.all
                    break
                }
                
                self.hideSortView()
                self.loadNewData()
                self.setSortBtnState()
            }
            
            self.bottomSheet.rightButton.isHidden = true
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_type")
            self.bottomSheet.showView(view: sortView, contentHeight: 380)
            
            
        }).disposed(by: disposeBag)
        
        
        sortTopView.dateBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            
            self.sortTopView.setSelectedWith(self.sortTopView.dateBtn)
            self.setSortBtnState()
            self.scrollToSortTop()
            
//            if self.curSortType == .date {
//                self.bottomSheet.hide()
//            } else {
//            }
            self.curSortType = .date
            let sortView: YXWarrantsSortView = YXWarrantsSortView(titleArr: self.dateArr, select: self.viewModel!.expireDate.rawValue)
            sortView.seletedBlock = {[weak self] index in
                guard let `self` = self else { return }
                
                self.bottomSheet.hide()
                
                self.viewModel.expireDate = YXBullAndBellExpireDate(rawValue: index) ?? YXBullAndBellExpireDate.all
                
                self.hideSortView()
                self.loadNewData()
                self.setSortBtnState()
            }
            
            self.bottomSheet.rightButton.isHidden = true
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
        
        headerView.stockBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = self.viewModel.market
            input.symbol = self.viewModel.symbol
            input.name = self.viewModel.name ?? ""
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }).disposed(by: disposeBag)
    }
    
    @objc func setPrcData(low: String, up: String, type: YXBullAndBellType) {
        self.viewModel.type = type;
        self.viewModel.recoveryPriceLow = low;
        self.viewModel.recoveryPriceHeight = up;
//        [self.viewModel.requestOffsetDataCommand execute:@(0)];
        loadNewData()
        updateHeaderViewConstraint()
//        [self updateHeaderView];
//        self.moreSortView.recoveryPriceLow = low;
//        self.moreSortView.recoveryPriceHeight = up;
//        [self.headerView setSortBtnState];
        setSortBtnState()
//        [self.moreSortView setAllBtnState];
    }
    
    func scrollToSortTop() {
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let point = CGPoint(x: 0, y: headerSize.height)
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
        
        self.headerView.lzButtonBlock = {
            [weak self] in
            guard let `self` = self else { return }
            
            if self.viewModel.warrantType == .bullBear {
                var dic: [String : Any] = [:]
                dic["name"] = self.viewModel.name ?? ""
                dic["symbol"] = self.viewModel.symbol
                dic["market"] = self.viewModel.market
                dic["change"] = self.viewModel.change
                dic["roc"] = self.viewModel.roc
                dic["now"] = self.viewModel.now
                dic["priceBase"] = self.viewModel.priceBase
                dic["warrantType"] = YXStockWarrantsType.inlineWarrants
                dic["pushVC"] = self
                self.viewModel.navigator.push(YXModulePaths.stockWarrants.url, context: dic)
            } else {
                if let pushVC = self.viewModel.pushVC {
                    pushVC.viewModel.name = self.viewModel.name ?? ""
                    pushVC.viewModel.symbol = self.viewModel.symbol
                    pushVC.viewModel.market = self.viewModel.market
                    pushVC.viewModel.change = self.viewModel.change
                    pushVC.viewModel.roc = self.viewModel.roc
                    pushVC.viewModel.now = self.viewModel.now
                    pushVC.viewModel.priceBase = self.viewModel.priceBase
                    pushVC.viewModel.needRefresh = true
                }
                self.navigationController?.popViewController(animated: true)
            }
        }


        self.headerView.updateHeightBlock = {
            [weak self] height in
            guard let `self` = self else { return }

            //self.tableView.beginUpdates()
            self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
            self.tableView.tableHeaderView = self.headerView
            self.tableView.reloadData()
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
        self.updateHeaderViewStock()
        self.loadNewData()
        //self.requestQuoteData()
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        setupRefreshHeader(tableView)
        
        viewModel.endHeaderRefreshStatus?.asObservable().subscribe(onNext: { [weak self] (status) in
            if status == .endHeaderRefresh {
                self?.loadSignal()
                self?.loadBullBear()
            }
        }).disposed(by: disposeBag)
        
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
            tableCell.refreshUI(model: item, market:self.viewModel.market, isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
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
        
//        viewModel.refreshStockSubject.subscribe(onNext: { [weak self] (bool) in
//            guard let strongSelf = self else { return }
//            //strongSelf.requestQuoteData()
//        }).disposed(by: rx.disposeBag)
    }
    
//    func getHeaderViewHeight() -> CGFloat {
//        var height: CGFloat = 1
//        if viewModel.symbol.count > 0 {
//            if viewModel.warrantType == .inlineWarrants {
//                height = 140
//            } else {
//                height = 170
//            }
//
//        } else {
//            if viewModel.warrantType == .inlineWarrants {
//                height = 51
//            } else {
//                height = 90
//            }
//        }
//        return height
//    }
    
    override func layoutTableView() {
        
//        headerView.snp.remakeConstraints { [weak self] (make) in
//            guard let `self` = self else { return }
//            make.right.left.equalTo(view)
//            make.top.equalTo(view).offset(YXConstant.navBarHeight())
//            make.height.equalTo(self.getHeaderViewHeight())
//        }
//        headerView.height = self.getHeaderViewHeight()
        
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
        self.viewModel.issuerIndex = 0
        self.viewModel.issuer = 0
        self.setSortBtnState()
    }
    
    func loadNewData() {
        //tableView.setContentOffset(.zero, animated: false)
        if let refreshingBlock = refreshHeader.refreshingBlock{
            refreshingBlock()
        }
    }
    
    func loadSignal() {
        if viewModel.warrantType == .inlineWarrants {
            return
        }
        if viewModel.symbol.count > 0 {
            let requestModel = YXBullBearPbSignalReqModel()
            requestModel.type = "warrantcbbc"
            requestModel.size = 3
            requestModel.idString = kYXMarketHK + viewModel.symbol
            requestModel.nextPageSeqNum = 0
            
            let request = YXRequest(request: requestModel)
            request.startWithBlock(success: { [weak self] (responseModel) in
                guard let strongSelf = self else { return }
                
                if responseModel.code == .success, let data = responseModel.data, let model = YXBullBearPbSignalResModel.yy_model(withJSON: data), model.list.count > 0  {
                    strongSelf.headerView.signalView.signalList = model.list;
                    strongSelf.headerView.showSignal()
                } else {
                    if strongSelf.headerView.signalCode != strongSelf.viewModel.symbol {
                        strongSelf.headerView.hideSignal()
                    }
                }
                strongSelf.headerViewBeginUpdate()
                strongSelf.headerView.signalCode = strongSelf.viewModel.symbol
            }, failure: { [weak self] (request) in
                guard let strongSelf = self else { return }
                
                if strongSelf.headerView.signalCode != strongSelf.viewModel.symbol {
                    strongSelf.headerView.hideSignal()
                    strongSelf.headerViewBeginUpdate()
                    strongSelf.headerView.signalCode = strongSelf.viewModel.symbol
                }
            })
        } else {
            self.headerView.signalCode = self.viewModel.symbol
            self.headerView.hideSignal()
            headerViewBeginUpdate()
        }
    }
    
    func loadBullBear() {
        if viewModel.warrantType == .inlineWarrants {
            return
        }
        if viewModel.symbol.count > 0 {
            let requestModel = YXBullBearWarrantcbbctopReqModel()
            requestModel.market = kYXMarketHK
            requestModel.symbol = self.viewModel.symbol
            let request = YXRequest(request: requestModel)
            
            request.startWithBlock(success: { [weak self] (responseModel) in
                guard let strongSelf = self else { return }
                
                if responseModel.code == .success, let data = responseModel.data, let model = YXWarrantBullBearModel.yy_model(withJSON: data), model.rise != nil, model.fall != nil {
                    strongSelf.headerView.bullBearView.bullBearModel = model
                    strongSelf.headerView.showBullBear()
                } else {
                    if strongSelf.headerView.bullBearCode != strongSelf.viewModel.symbol {
                        strongSelf.headerView.hideBullBear()
                    }
                }
                strongSelf.headerViewBeginUpdate()
                strongSelf.headerView.bullBearCode = strongSelf.viewModel.symbol
            }, failure: { [weak self] (request) in
                guard let strongSelf = self else { return }
                if strongSelf.headerView.bullBearCode != strongSelf.viewModel.symbol {
                    strongSelf.headerView.hideBullBear()
                    strongSelf.headerViewBeginUpdate()
                    strongSelf.headerView.bullBearCode = strongSelf.viewModel.symbol
                }
            })
        } else {
            self.headerView.bullBearCode = self.viewModel.symbol
            self.headerView.hideBullBear()
            headerViewBeginUpdate()
        }
    }

    func headerViewBeginUpdate() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            guard let strongSelf = self else { return }
//
//            strongSelf.tableView.beginUpdates()
//            strongSelf.tableView.tableHeaderView = strongSelf.headerView
//            strongSelf.tableView.endUpdates()
//
//        }
    }

    
    func cleanStock() {
        
    }
    
    
    func updateHeaderViewConstraint() {
        
        headerView.cleanStock()
        
        if viewModel.symbol.count > 0 {
            headerView.stockView.isHidden = false
            headerView.searchView.isHidden = true
//            headerView.nameLab.text = viewModel.name ?? ""
//            headerView.marketLab.text = String(format: "%@.HK", viewModel.symbol)
            
        } else {
            headerView.stockView.isHidden = true
            headerView.searchView.isHidden = false
        }
    }
    
    func updateHeaderViewStock() {
        
        headerView.nameLab.text = viewModel.name ?? ""
        headerView.marketLab.text = String(format: "%@.HK", viewModel.symbol)
        
        if viewModel.now != 0 {
            headerView.nowLab.text = YXToolUtility.stockPriceData(Double(viewModel.now), deciPoint: Int(viewModel.priceBase) , priceBase: Int(viewModel.priceBase))
        } else {
            headerView.nowLab.text = "--"
        }
        
        if viewModel.warrantType == .bullBear {
            headerView.warrantType = .inlineWarrants
        } else if viewModel.warrantType == .inlineWarrants {
            headerView.warrantType = .bullBear
        }
        
        let change = YXToolUtility.stockPriceData(Double(viewModel.change), deciPoint: Int(viewModel.priceBase) , priceBase: Int(viewModel.priceBase))
        let roc = String(format: "%.2lf", Double(viewModel.roc)/Double(100))
        
        if viewModel.change > 0 {
            
            headerView.changeLab.text = String(format: "+%@", change ?? "")
            headerView.rocLab.text = String(format: "+%@%%", roc)
            headerView.nowLab.textColor = QMUITheme().stockRedColor()
            headerView.changeLab.textColor = QMUITheme().stockRedColor()
            headerView.rocLab.textColor = QMUITheme().stockRedColor()
            
        } else if viewModel.change == 0 {
            
            headerView.changeLab.text = String(format: "%@", change ?? "")
            headerView.rocLab.text = String(format: "%@%%", roc)
            headerView.nowLab.textColor = QMUITheme().stockGrayColor()
            headerView.changeLab.textColor = QMUITheme().stockGrayColor()
            headerView.rocLab.textColor = QMUITheme().stockGrayColor()
        } else {
            
            headerView.changeLab.text = String(format: "%@", change ?? "")
            headerView.rocLab.text = String(format: "%@%%", roc)
            headerView.nowLab.textColor = QMUITheme().stockGreenColor()
            headerView.changeLab.textColor = QMUITheme().stockGreenColor()
            headerView.rocLab.textColor = QMUITheme().stockGreenColor()
        }
    }
    
    func hideSortView() {
//        for v in backView.subviews {
//            if v != self.hideBtn {
//                v.removeFromSuperview()
//            }
//        }
//
//        backView.isHidden = true
        curSortType = .none
        
    }
    
    func setSortBtnState() {
        
        sortTopView.type = viewModel.type.rawValue
        sortTopView.expireDate = viewModel.expireDate.rawValue
        sortTopView.moneyness = viewModel.moneyness.rawValue
        sortTopView.issuerIndex = viewModel.issuerIndex
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
    
//    @objc func backViewTapAction() {
//        hideSortView()
//
//        self.setSortBtnState()
//    }
    
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
                    self.headerView.stockInfoView.model = quote
                    print("lyu:\(quote.level?.value)")
                    self.updateHeaderViewStock()
                }
            }
        }))
    }
}



extension YXStockWarrantsViewController {
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

extension YXStockWarrantsViewController {
    
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


extension YXStockWarrantsViewController {
    
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

extension YXStockWarrantsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        var height: CGFloat = 40
        if viewModel.warrantType == .bullBear {
            height = 84
        }
        return (self.tableView.tableHeaderView?.mj_h ?? 0) + 40 + height
    }
}


