//
//  YXOptionalListLandVC.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/1/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXOptionalListLandVC: YXHKTableViewController, RefreshViweModelBased, ViewModelBased {
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    var refreshFooter: YXRefreshAutoNormalFooter?
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXOptionalListLandViewModel!
    let reuseIdentifier = "YXNewStockMarketedCell"
    
    let config = YXNewStockMarketConfig()

    var quoteLevelChange = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleBlock()
        bindTableView()
        
        viewModel.quoteSubject.subscribe(onNext: { [weak self] (list,scheme) in
            guard let strongSelf = self else { return }
            guard list.count > 0 else { return }
            
            var dataSource = strongSelf.viewModel.dataSource.value
            if list.count > 1 {
                let array = dataSource.map({ (quote) -> YXV2Quote in
                    for item in list {
                        if quote.symbol == item.symbol && quote.market == item.market {
                            return item
                        }
                    }
                    return quote
                })
                strongSelf.viewModel.updateOriginList(list: array)
                strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
            } else {
                var row: Int?
                guard let quote = list.first else { return }
                for index in 0 ..< dataSource.count {
                    let item = dataSource[index]
                    if item.market == quote.market, item.symbol == quote.symbol {
                        row = index
                        break
                    }
                }
                if let row = row {
                    if let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? YXOptionalListCell {
                        cell.quote.accept(quote)
                    }
                    strongSelf.viewModel.updateOriginList(list: [quote])
                    if scheme == .http {
                        strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
                    }
                }
            }
            }).disposed(by: disposeBag)
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.forceToLandscapeRight = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        setupRefreshHeader(tableView)
        self.view.addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
        tableView.dataSource = nil
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
            var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
            if cell == nil {
                cell = YXNewStockMarketedCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                if let marketCell = cell as? YXNewStockMarketedCell {
                    self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                        point != marketCell.scrollView.contentOffset
                    }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                    marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                        point != self?.viewModel.contentOffsetRelay.value
                    }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                }
            }
            if let marketCell = cell as? YXNewStockMarketedCell {
                marketCell.isDelay = false
                if let level = item.level?.value, QuoteLevel(rawValue: Int(level)) == .delay {
                    marketCell.isDelay = true
                } 
            }
            
            let tableCell = (cell as! YXNewStockMarketedCell)
            let info = YXMarketRankCodeListInfo(secuCode: item.symbol, trdMarket: item.market, yxCode: nil, chsNameAbbr: item.name,  priceBase: Int(item.priceBase?.value ?? 0), quoteTime: Int64(item.latestTime?.value ?? 0), turnover: item.amount?.value, quoteType: nil, prevClose: nil, openPrice: nil, latestPrice: Int(item.latestPrice?.value ?? 0), accer3: nil, accer5:nil, dividendYield: nil, highPrice: nil, lowPrice: nil, closePrice: nil, avgPrice: Int(item.avg?.value ?? 0), netChng:  Int(item.netchng?.value ?? 0), pctChng:  Int(item.pctchng?.value ?? 0), volume: Int(item.volume?.value ?? 0), outstandingShares: nil, outstandingCap: nil, totalStockIssue: nil, totalMarketValue: Int(item.mktCap?.value ?? 0), inner: nil, outer: nil, peStatic: Int(item.pe?.value ?? 0), peTtm: Int(item.peTTM?.value ?? 0), pb: Int(item.pb?.value ?? 0), amplitude: Int(item.amp?.value ?? 0), volRatio: Int(item.volumeRatio?.value ?? 0), turnoverRate: Double(item.turnoverRate?.value ?? 0), ipoFlag: nil, listDate: nil, netInflow: nil, mainInflow: nil, listDays: nil, issuePrice: nil, ipoDayPctchng: nil, ipoDayClose: nil, accuPctchng: nil, leadStock: nil, adrCode: nil, adrMarket: nil, adrDisplay: nil, adrExchangePrice: nil, adrPctchng: nil, adrPriceSpread: nil, adrPriceSpreadRate: nil, ahCode: nil, ahMarket: nil, hNameAbbr: nil, ahLastestPrice: nil, ahPreclose: nil, ahPctchng: nil, ahExchangePrice: nil, ahPriceSpread: nil, ahPriceSpreadRate: nil, bail: nil, marginRatio: nil, greyChgPct: nil, winningRate: nil, gearingRatio: nil, high_52week: nil, low_52week: nil,cittthan: nil, bid: nil, bidSize: nil, ask: nil, askSize: nil, currency: nil, expiryDate: nil, divAmountYear:nil, divYieldYear:nil)
            
            tableCell.refreshUI(model: info, isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
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
        view.frame = CGRect(x:0, y: 0, width: self.view.frame.width, height: 34)
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        view.pageSource = .optionalList
        
        view.setStatus(sortState: viewModel.sortState.value, mobileBrief1Type: viewModel.quoteType.value)
        
        return view
    }()
    
    lazy var rotateButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "rotate_portrait"), for: .normal)
        button.addTarget(self, action: #selector(rotateButtonAction), for: .touchUpInside)
        return button
    }()
    
    @objc func rotateButtonAction() {
        YXToolUtility.forceToPortraitOrientation()
        self.navigationController?.popViewController(animated: false)
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
    
    var sortArrs = [YXStockRankSortType.now,
                    YXStockRankSortType.roc,
                    YXStockRankSortType.change,
                    YXStockRankSortType.turnoverRate,
                    YXStockRankSortType.volume,
                    YXStockRankSortType.amount,
                    YXStockRankSortType.amp,
                    YXStockRankSortType.volumeRatio,
                    YXStockRankSortType.marketValue,
                    YXStockRankSortType.pe,
                    YXStockRankSortType.pb]
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            //            strongSelf.viewModel.sorttype = type

            strongSelf.viewModel.sortState.accept(state)
            strongSelf.viewModel.quoteType.accept(type)
            strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
        }

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                if self.qmui_isViewLoadedAndVisible() {
                    if let refreshingBlock = self.refreshHeader.refreshingBlock {
                        refreshingBlock()
                    }
                } else {
                    self.quoteLevelChange = true
                }

            }).disposed(by: rx.disposeBag)

        self.qmui_visibleStateDidChangeBlock = {
            [weak self] (vc, state) in
            guard let `self` = self else { return }

            if state == .didAppear, self.quoteLevelChange {
                self.quoteLevelChange = false
                if let refreshingBlock = self.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
            }
        }

    }
    
    override func emptyRefreshButtonAction() {
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "opt_stock_empty"))
    }
}

extension YXOptionalListLandVC {
    
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
        if YXConstant.deviceScaleEqualToXStyle() {
            let view = UIView(frame: CGRect(x:0, y: 0, width: self.view.frame.width, height: self.kSectionHeaderHeight))
            view.addSubview(sectionHeaderView)
            sectionHeaderView.frame = CGRect(x:YXConstant.statusBarHeight(), y: 0, width: self.view.frame.width - YXConstant.statusBarHeight() - YXConstant.tabBarPadding(), height: self.kSectionHeaderHeight)
            return view

        }
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < viewModel.dataSource.value.count {
            //let item = viewModel.dataSource.value[indexPath.row]

        }
    }
}
