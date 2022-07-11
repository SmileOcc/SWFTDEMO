//
//  YXHoldListViewController.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import QMUIKit
import YXKit
import NSObject_Rx

class YXHoldListViewController: YXHKTableViewController, HUDViewModelBased, RefreshViweModelBased {
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    var refreshFooter: YXRefreshAutoNormalFooter?
    
    typealias ViewModelType = YXHoldListViewModel
    
    var viewModel: YXHoldListViewModel!
    let config = YXNewStockMarketConfig(leftItemWidth: 120, itemWidth: 80, itemMargin: 16, fixMargin: 16)

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    lazy var sectionHeaderView: YXWarrantsMarketedSortView = {
        let view = YXWarrantsMarketedSortView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44), sortTypes: sortArrs, firstState: .normal, source: .holdList, config: self.config)
        view.securityType = self.viewModel.securityType
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        return view
    }()
    
    lazy var sortArrs: [YXStockRankSortType] = {
        [.marketValueAndNumber,
                .lastAndCostPrice,
                .holdingBalance,
                .dailyBalance
                ]
        }()
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sorttype = type
            strongSelf.viewModel.sortdirection = state
            strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
        }
    }
    
    var timerFlag: YXTimerFlag = 0
    
    lazy var footerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "hold_holds")
        
        bindHUD()
        viewModel.hudSubject.onNext(.loading(nil, false))
        
        viewModel.requestRemoteDataSubject.subscribe(onNext: { [weak self] (isOK) in
            guard let `self` = self else { return }
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }).disposed(by: disposeBag)
        
        handleBlock()
        
        footerView.addSubview(tipsLabel)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(footerView).offset(18)
            make.right.equalTo(footerView).offset(-18)
            make.centerY.equalTo(footerView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if timerFlag != 0 {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timerFlag)
            timerFlag = 0
        }
        
        if viewModel.exchangeType == .us || (viewModel.exchangeType == .hk && YXUserManager.hkLevel() != .hkBMP) {
            timerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
                if let refreshingBlock = self?.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
                }, timeInterval: TimeInterval(YXGlobalConfigManager.configFrequency(.holdingFreq)), repeatTimes: Int.max, atOnce: true)
        } else {
            if let refreshingBlock = refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if timerFlag != 0 {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timerFlag)
            timerFlag = 0
        }
    }
    
    override func initTableView() {
        super.initTableView()

        view.backgroundColor = QMUITheme().foregroundColor()
        
        tableView.dataSource = nil
        setupRefreshHeader(tableView) 
        
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [weak self] (endRefreshing) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject.onNext(.hide)
            if endRefreshing == .error || endRefreshing == .hasDataWithError {
                strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            } else {
                if (strongSelf.viewModel.exchangeType == .hk && YXUserManager.hkLevel() == .hkBMP) {
                    strongSelf.footerView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: 64)
                    strongSelf.tipsLabel.isHidden = false
                    strongSelf.tipsLabel.text = YXLanguageUtility.kLang(key: "common_bmptips")
                } else if (strongSelf.viewModel.exchangeType == .hk && YXUserManager.hkLevel() == .hkDelay)
                    || (strongSelf.viewModel.exchangeType == .us && YXUserManager.usLevel() == .usDelay) {
                    strongSelf.footerView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: 64)
                    strongSelf.tipsLabel.isHidden = false
                    strongSelf.tipsLabel.text = YXLanguageUtility.kLang(key: "common_delaytips")
                } else {
                    strongSelf.footerView.frame = CGRect(x: 0, y: 0, width: strongSelf.view.bounds.width, height: 0)
                    strongSelf.tipsLabel.isHidden = true
                }
                
                if strongSelf.viewModel.originList.count == 0 {
                    strongSelf.tipsLabel.isHidden = true
                }
                strongSelf.tableView.tableFooterView = strongSelf.footerView
            }
            
        }).disposed(by: disposeBag)
        
        //MARK: celloForRow
        
        
        viewModel.dataSource.bind(to: tableView.rx.items) { [weak self] (tableView, row, item) in
            let CellIdentifier = NSStringFromClass(YXHKHoldListCell.self)
            guard let strongSelf = self else {
                return YXHKHoldListCell(style: .default, reuseIdentifier: CellIdentifier, sortTypes: [], config: self?.config ?? YXNewStockMarketConfig())
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? YXHKHoldListCell {
                cell.stock.accept(item)
                return cell
            }
            
            let cell = YXHKHoldListCell(style: .default, reuseIdentifier: CellIdentifier, sortTypes: strongSelf.sortArrs, config: strongSelf.config)
            
//            cell.scrollView.rxContentOffsetBind(trackingRelay: strongSelf.viewModel.trackOffsetRelay, draggingRelay: strongSelf.viewModel.dragOffsetRelay, disposeBag: strongSelf.disposeBag)
            strongSelf.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                point != cell.scrollView.contentOffset
            }.bind(to:cell.scrollView.rx.contentOffset).disposed(by: strongSelf.disposeBag)
            cell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                point != self?.viewModel.contentOffsetRelay.value
            }.bind(to: strongSelf.viewModel.contentOffsetRelay).disposed(by: strongSelf.disposeBag)
            
            cell.stock.asDriver().drive(onNext: { [weak cell] (stock) in
                
                cell?.refreshUI(model: stock)
                
            }).disposed(by: strongSelf.disposeBag)
            
            cell.stock.accept(item)
            
            return cell
            
            }.disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected.asDriver().drive(onNext: { [weak self] (indexPath) in
            guard let strongSelf = self else { return }
            
            let stock:YXHoldStock = strongSelf.viewModel.dataSource.value[indexPath.row]
            
            if let market = stock.exchangeType?.market, let symbol = stock.stockCode {

                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = stock.stockName ?? ""
                strongSelf.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
            
        }).disposed(by: disposeBag)
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "hold_no_data"))
        self.emptyView?.setImage(UIImage(named:"empty_hold"))
        
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0)
        self.tipsLabel.isHidden = true
        self.tableView.tableFooterView = self.footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.dataSource.value.count == 0 {
            return nil
        }
        
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.dataSource.value.count == 0 {
            return 0
        }
        return 44
    }
    
    override func showErrorEmptyView() {
        self.showEmptyView()
        
        self.emptyView?.setImage(UIImage(named: "hold_empty_noData"))
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
    }
}

