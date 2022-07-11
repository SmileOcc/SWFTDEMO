//
//  YXHoldFundListViewController.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import QMUIKit
import YXKit
import NSObject_Rx

class YXHoldFundListViewController: YXHKTableViewController, HUDViewModelBased, RefreshViweModelBased,ViewModelBased {
    var viewModel: YXHoldFundListViewModel!
    
    
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    var refreshFooter: YXRefreshAutoNormalFooter?
    
    typealias ViewModelType = YXHoldFundListViewModel
    let config = YXNewStockMarketConfig()
    
    
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    lazy var fundSecHeaderView: YXHoldFundSectionSortView = {
        let view = YXHoldFundSectionSortView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44), sortTypes: sortArrs, config: self.config)
        
        switch viewModel.securityType {
        case .stock:
            view.nameLabel.text = YXLanguageUtility.kLang(key: "market_codeName")
        case .fund:
            view.nameLabel.text = YXLanguageUtility.kLang(key: "hold_fund_name")
        default:
            print("none")
        }
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        return view
    }()
    
    lazy var sortArrs: [YXStockRankSortType] = {
        [YXStockRankSortType.amountMoney,//金额
            YXStockRankSortType.yesterdayGains,//昨日收益
            YXStockRankSortType.holdGains] //持有收益
    }()
    
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
        
        
        
        footerView.addSubview(tipsLabel)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(footerView).offset(18)
            make.right.equalTo(footerView).offset(-18)
            make.centerY.equalTo(footerView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.invalidTimer()
        
        if viewModel.exchangeType == .us || (viewModel.exchangeType == .hk && YXUserManager.hkLevel() != .hkBMP) {
            timerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
                if let refreshingBlock = self?.refreshHeader.refreshingBlock{
                    refreshingBlock()
                }
                }, timeInterval: TimeInterval(YXGlobalConfigManager.configFrequency(.holdingFreq)), repeatTimes: Int.max, atOnce: true)
        } else {
            if let refreshingBlock = refreshHeader.refreshingBlock{
                refreshingBlock()
            }
        }
    }
    
    //取消轮询
    fileprivate func invalidTimer() {
        if timerFlag != 0 {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: timerFlag)
            timerFlag = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.invalidTimer()
    }
    
    override func initTableView() {
        super.initTableView()
        
        view.backgroundColor = QMUITheme().foregroundColor()
        
        tableView.dataSource = nil
        setupRefreshHeader(tableView)
        
        //头部刷新
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
                }
                else if (strongSelf.viewModel.exchangeType == .hk && YXUserManager.hkLevel() == .hkDelay)
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
            let CellIdentifier = NSStringFromClass(YXHoldFundListCell.self)
            guard let strongSelf = self else {
                return YXHoldFundListCell(style: .default, reuseIdentifier: CellIdentifier, sortTypes: [], config: self?.config ?? YXNewStockMarketConfig())
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? YXHoldFundListCell {
                cell.stock.accept(item)
                return cell
            }
            
            let cell = YXHoldFundListCell(style: .default, reuseIdentifier: CellIdentifier, sortTypes: strongSelf.sortArrs, config: strongSelf.config)
            
            strongSelf.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                point != cell.scrollView.contentOffset
            }.bind(to:cell.scrollView.rx.contentOffset).disposed(by: strongSelf.disposeBag)
            cell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                point != self?.viewModel.contentOffsetRelay.value
            }.bind(to: strongSelf.viewModel.contentOffsetRelay).disposed(by: strongSelf.disposeBag)
            
            cell.stock.asDriver().drive(onNext: { [weak cell] (stock) in
                
                cell?.refreshUI(model: stock, exchangeType: strongSelf.viewModel.exchangeType)
                
            }).disposed(by: strongSelf.disposeBag)
            
            cell.stock.accept(item)
            
            return cell
            
        }.disposed(by: disposeBag)
        
        //MARK: itemSelected
        tableView.rx.itemSelected.asDriver().drive(onNext: { [weak self] (indexPath) in
            guard let strongSelf = self else { return }
            
            let model: YXHoldFundModel = strongSelf.viewModel.dataSource.value[indexPath.row]
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_TRADE_URL(with: model.fundID)]
            strongSelf.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            
        }).disposed(by: disposeBag)
    }
    
    override func emptyRefreshButtonAction() {
        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_TRADE_URL()]
        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.dataSource.value.count == 0 {
            return nil
        }
        return fundSecHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.dataSource.value.count == 0 {
            return 0
        }
        return 44
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "hold_fund_no_data"))
        self.emptyView?.setImage(UIImage(named:"empty_hold"))
        
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0)
        self.tipsLabel.isHidden = true
        self.tableView.tableFooterView = self.footerView
        
        self.emptyView?.setActionButtonTitle(YXLanguageUtility.kLang(key: "hold_fund_search_fund"))
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        self.emptyView?.actionButton.addTarget(self, action: #selector(emptyRefreshButtonAction), for: .touchUpInside)
    }
}
