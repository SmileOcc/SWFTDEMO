//
//  YXStockDetailIndustryLandVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXStockDetailIndustryLandVC: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockDetailIndustryLandViewModel! = YXStockDetailIndustryLandViewModel()
    let reuseIdentifier = "YXNewStockMarketedCell"
    var refreshTimer: Timer?
    var isUserInfoUpdate: Bool = false
    var viewAppear: Bool = true

    let config = YXNewStockMarketConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.title ?? ""
        bindHUD()
        handleBlock()
        bindTableView()
        
        if viewModel.rankType == .marginAble {
            viewModel.sorttype = .marginRatio
            sectionHeaderView.setStatus(sortState: .descending, mobileBrief1Type: .marginRatio)
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.forceToLandscapeRight = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        if self.isUserInfoUpdate {
            self.isUserInfoUpdate = false
            self.tableView.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        self.view.addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(45)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
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
                    self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                        point != marketCell.scrollView.contentOffset
                    }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                    marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                        point != self?.viewModel.contentOffsetRelay.value
                    }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
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
            
//            if self.viewModel.userLevel == .bmp, self.viewModel.dataSource.value.count >= 20, self.viewModel.market == YXMarketType.HK.rawValue, self.viewModel.isShowBMP {
//                self.tableView.tableFooterView = self.tableFooterView
//                self.footerLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bmpTip")
//            }
            
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
        view.frame = CGRect(x:0, y: 0, width: self.view.frame.width, height: self.kSectionHeaderHeight)
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        view.setStatus(sortState: .descending, mobileBrief1Type: .roc)
        
        return view
    }()
    
    lazy var rotateButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "rotate-landscape"), for: .normal)
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
    
    var sortArrs: [YXStockRankSortType] {
        if self.viewModel.rankType == .marginAble {
            return YXRankType.marginAble.sortArrs
        } else if self.viewModel.rankType == .sgETF {
            return YXRankType.sgETF.sortArrs
        } else if self.viewModel.rankType == .DLCs {
            return YXRankType.DLCs.sortArrs
        } else if self.viewModel.rankType == .REITs {
            return YXRankType.REITs.sortArrs
        } else {
            return YXRankType.normal.sortArrs
        }
        
    }
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sorttype = type
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
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "newStock_no_market_stock"))
    }
}

extension YXStockDetailIndustryLandVC {
    
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
            var inputs: [YXStockInputModel] = []

            for item in viewModel.dataSource.value {

                if let market = item.trdMarket, let symbol = item.secuCode {
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = item.chsNameAbbr ?? ""
                    inputs.append(input)
                }
            }
            if inputs.count > 0 {
                self.viewModel.navigator.push(YXModulePaths.landStockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row, "fromLand" : true])
            }
        }
    }
}

extension YXStockDetailIndustryLandVC {
    
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
