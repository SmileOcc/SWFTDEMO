//
//  YXBullBearContractViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXBullBearContractViewController: YXViewController {
    
    var bullBearViewModel: YXBullBearContractViewModel {
        let vm = viewModel as! YXBullBearContractViewModel
        return vm
    }
    
    var quoteRequest: YXQuoteRequest?
    var disposeBag = DisposeBag()
    var streetSectionHeader: YXBullBearSectionHeaderView?
    var timeFlag: YXTimerFlag?
    
    lazy var tableView: YXTableView = {
        let tableView = YXTableView.init(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.qmui_color(withHexString: "#F5F8FF")//QMUITheme().backgroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        if #available(iOS 11.0, *) {
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        return tableView
    }()
    
    lazy var assetView: YXBullBearAssetView = {
        let view = YXBullBearAssetView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.tapAssetAction = { [weak self] in
            if let market = self?.bullBearViewModel.assetMarket, let symbol = self?.bullBearViewModel.assetSymbol {
                self?.bullBearViewModel.gotoStockDetail(market: market, symbol: symbol)
            }
        }
        
        view.tapItemAction = { [weak self](market, symbol) in
            self?.bullBearViewModel.gotoStockDetail(market: market, symbol: symbol)
        }
        
        return view
    }()
    
    lazy var entranceView: YXWarrantsEntranceCell = {
        let entranceView = YXWarrantsEntranceCell()
        entranceView.backgroundColor = QMUITheme().foregroundColor()
        entranceView.tapAction = { [weak self](type) in
            guard let `self` = self else { return }
            switch type {
            case .warrantsCBBC:
                (YXNavigationMap.navigator as? NavigatorServices)?.push(YXModulePaths.warrantsAndStreet.url, context: [:])
            case .marketMakerScore:
                let vm = YXMarketMakerRankViewModel.init(services: self.viewModel.services, params: nil)
                self.viewModel.services.push(vm, animated: true)
            case .warrantsDayReport:
                YXWebViewModel.pushToWebVC(YXH5Urls.warrantsDayReportUrl())
            case .warrantsCollege:
                YXWebViewModel.pushToWebVC(YXH5Urls.warrantsCollegeUrl())
            
            }
        }
        return entranceView
    }()
    
    lazy var warrantsDealView: YXNewWarrantsDealCell = {
        let view = YXNewWarrantsDealCell.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 762))
        
        view.addSubview(assetView)
        view.addSubview(entranceView)
        view.addSubview(warrantsDealView)
        
        assetView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(415)
        }
        
        entranceView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(assetView.snp.bottom)
            make.height.equalTo(90)
        }
        
        warrantsDealView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(entranceView.snp.bottom).offset(10)
            make.height.equalTo(239)
        }
        
        let sepView = UIView()
        
        view.addSubview(sepView)
        sepView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.bottom.equalTo(warrantsDealView.snp.bottom)
        }
        
        
        return view
    }()
    
    lazy var footerView: UIView = {
        var height: CGFloat = 140.0
        if YXUserManager.isENMode() {
            height = 180.0
        }
        let frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: height)
        let view = UIView.init(frame: frame)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "bullbear_disclaimer")
        view.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        self.bullBearViewModel.bearAssetListViewModel.selectedItemSubject.subscribe(onNext: { [weak self](assetModel) in
            if let market = assetModel.market, let symbol = assetModel.symbol {
                self?.bullBearViewModel.assetMarket = market
                self?.bullBearViewModel.assetSymbol = symbol
                self?.bullBearViewModel.assetName = assetModel.name ?? ""
            }
        }).disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = Timer.scheduledTimer(withTimeInterval: 0, block: { [weak self](timer) in
            self?.requestData()
        }, repeats: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.quoteRequest?.cancel()
    }
    
    func setupUI() {
        tableView.register(YXBullBearStreeCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearStreeCell.self))
//        tableView.register(YXNewWarrantsFundFlowCell.self, forCellReuseIdentifier: NSStringFromClass(YXNewWarrantsFundFlowCell.self))
        tableView.register(YXBullBearLongShortSignalCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearLongShortSignalCell.self))
        tableView.register(YXBullBearStreetCurrentPriceCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearStreetCurrentPriceCell.self))
        
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }
            self.requestData()
            self.tableView.mj_header.endRefreshing()
        }
        
        tableView.mj_header = refreshHeader
        tableView.tableHeaderView = headerView
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func requestData() {
        let secu = Secu.init(market: bullBearViewModel.assetMarket, symbol: bullBearViewModel.assetSymbol)
        let level = YXUserManager.shared().getLevel(with: kYXMarketHK)
        self.quoteRequest?.cancel()
        self.quoteRequest = YXQuoteManager.sharedInstance.subRtFullQuote(secu: secu, level: level, handler: ({ [weak self](quoteArr, scheme) in
            guard let `self` = self else { return }
            let quote = quoteArr.first
            self.assetView.quoteModel = quote
        }))
        
        self.bullBearViewModel.getAsset().subscribe(onSuccess: { [weak self](assetModel) in
            self?.assetView.warrantCBBCModel = assetModel
        }).disposed(by: self.disposeBag)
        
        self.bullBearViewModel.getDeal().subscribe(onSuccess: { [weak self](dealModel) in
            self?.warrantsDealView.data = dealModel
        }).disposed(by: self.disposeBag)
        
        self.bullBearViewModel.getCBBCTop().subscribe(onSuccess: { [weak self](model) in
            self?.tableView.reloadData()
        }).disposed(by: self.disposeBag)
        
        self.bullBearViewModel.getPbSignal().subscribe(onSuccess: { [weak self](pbModel) in
            self?.tableView.reloadData()
        }).disposed(by: self.disposeBag)
        
        self.bullBearViewModel.getFundFlow().subscribe(onSuccess: { [weak self](model) in
            self?.tableView.reloadData()
        }).disposed(by: self.disposeBag)
    }
    
    func showAlert() {
        var msg: String
        if self.bullBearViewModel.derivativeType == .bullBear {
            msg = YXLanguageUtility.kLang(key: "bullbear_cbbcflow_tips")//"统计对应股票所有牛熊和熊证的资金流入流出数据"
        }else {
            msg = YXLanguageUtility.kLang(key: "bullbear_warrantflow_tips")//"统计对应股票所有认购证和认沽证的资金流入流出数据"
        }
        let alertView = YXAlertView.init(title: nil, message: msg, prompt: nil, style: .default, messageAlignment: .center)
        let vc = YXAlertController.init(alert: alertView)
        alertView.addAction(YXAlertAction.init(title: YXLanguageUtility.kLang(key:"common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        
        if let alertViewController = vc {
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    func commonHeaderView(title: String) -> YXMarketCommonHeaderCell {
        let view = YXMarketCommonHeaderCell()
        let line = UIView.line()
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        view.title = title
        view.hideRedDot = true
        view.icon = nil
        
        return view
    }
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.lineColor = QMUITheme().themeTextColor()
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.linePadding = 1
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.titles = [YXLanguageUtility.kLang(key: "market_warrants_warrants"), YXLanguageUtility.kLang(key: "market_warrants_cbbc")]
        tabView.delegate = self
        
        let line = UIView.line()
        tabView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        
        return tabView
    }()
    
    lazy var signalSectionHeader: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        let commonHeader = commonHeaderView(title: YXBullBearContractSectionType.longShortSignal.sectionTitle)
        let subTitle = YXBullBearSectionHeaderSubTitleView.init(frame: CGRect.zero, sectionType: .longShortSignal)
        bgView.addSubview(commonHeader)
        bgView.addSubview(tabView)
        bgView.addSubview(subTitle)
        
        // 点击查看更多
        commonHeader.action = { [weak self] in
             self?.bullBearViewModel.gotoMorePage(withSectionType: YXBullBearContractSectionType.longShortSignal)
         }
        
        commonHeader.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(55)
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(commonHeader.snp.bottom)
        }
        
        subTitle.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(tabView.snp.bottom)
        }
        
        return bgView
    }()

}


extension YXBullBearContractViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.bullBearViewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = self.bullBearViewModel.dataSource[section]
        switch type {
        case .street:
            return (self.bullBearViewModel.street?.bearList.count ?? 0) + (self.bullBearViewModel.street?.bullList.count ?? 0) + 1
        case .longShortSignal:
            return self.bullBearViewModel.pbSignal?.list.count ?? 0
        case .fundFlow:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionType = self.bullBearViewModel.dataSource[indexPath.section]
        
        switch sectionType {
        case .street:
            if indexPath.row < (self.bullBearViewModel.street?.bearList.count ?? 0) { // 熊
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBullBearStreeCell.self), for: indexPath) as! YXBullBearStreeCell
                cell.maxOutstanding = self.bullBearViewModel.maxOutStanding
                cell.item = self.bullBearViewModel.street?.bearList[indexPath.row]
                // 点击名称
                cell.tapNameAction = { [weak self](market, symbol) in
                    self?.bullBearViewModel.gotoStockDetail(market: market, symbol: symbol)
                }
                // 点击区间
                cell.tapRangeAction = { [weak self](prcLower, prcUpper) in
                    guard let `self` = self else { return }
                    let market = self.bullBearViewModel.assetMarket
                    let symbol = self.bullBearViewModel.assetSymbol
                    let name = self.bullBearViewModel.assetName
                    self.bullBearViewModel.gotoWarrants(market: market, symbol: symbol, name: name, prcLower: prcLower, prcUpper: prcUpper, bullBeartype: YXBullAndBellType.bear)
                }
                return cell
            }else if indexPath.row > (self.bullBearViewModel.street?.bearList.count ?? 0) { // 牛
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBullBearStreeCell.self), for: indexPath) as! YXBullBearStreeCell
                cell.maxOutstanding = self.bullBearViewModel.maxOutStanding
                let index = indexPath.row - (self.bullBearViewModel.street?.bearList.count ?? 0) - 1
                cell.item = self.bullBearViewModel.street?.bullList[index]
                cell.tapNameAction = { [weak self](market, symbol) in
                    self?.bullBearViewModel.gotoStockDetail(market: market, symbol: symbol)
                }
                cell.tapRangeAction = { [weak self](prcLower, prcUpper) in
                    guard let `self` = self else { return }
                    let market = self.bullBearViewModel.assetMarket
                    let symbol = self.bullBearViewModel.assetSymbol
                    let name = self.bullBearViewModel.assetName
                    self.bullBearViewModel.gotoWarrants(market: market, symbol: symbol, name: name, prcLower: prcLower, prcUpper: prcUpper, bullBeartype: YXBullAndBellType.bull)
                }
                return cell
            }else { // 当前标的价格
                let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBullBearStreetCurrentPriceCell.self), for: indexPath) as! YXBullBearStreetCurrentPriceCell
                if let asset = self.bullBearViewModel.street?.asset {
                    cell.nameLabel.text = "\(asset.name ?? "")\(YXLanguageUtility.kLang(key: "bullbear_new_price"))："
                    cell.priceLabel.text = String(format: "%.2lf", Double(asset.latestPrice) / pow(10.0, Double(asset.priceBase)))
                }
                
                return cell
            }
            
        case .longShortSignal:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBullBearLongShortSignalCell.self), for: indexPath) as! YXBullBearLongShortSignalCell
            cell.item = self.bullBearViewModel.pbSignal?.list[indexPath.row]
            cell.tapStockNameAction = { [weak self](market, symbol) in
                self?.bullBearViewModel.gotoStockDetail(market: market, symbol: symbol)
            }
            return cell
        default:
            return UITableViewCell()
//        case .fundFlow:
//            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXNewWarrantsFundFlowCell.self), for: indexPath) as! YXNewWarrantsFundFlowCell
//            cell.data = bullBearViewModel.fundFlowModel
//            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionType = self.bullBearViewModel.dataSource[section]
        let rect = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 55)
        
        switch sectionType {
        case .street:
            // 根据标的的不同，修改区域文案
            let view = YXBullBearSectionHeaderView.init(frame: rect, type: sectionType)
            view.commonHeader.title = (self.bullBearViewModel.street?.asset?.name ?? "") + YXLanguageUtility.kLang(key: "bullbear_CBBC_outstanding")
            if self.bullBearViewModel.street?.asset?.type1 == 6 { // 指数
                view.subTitleView.subTitleLabel3.text = YXLanguageUtility.kLang(key: "bullbear_ratio")
            }else { // 正股
                view.subTitleView.subTitleLabel3.text = YXLanguageUtility.kLang(key: "bullbear_equivalent_number_of_Stocks")
            }
            // 点击查看更多跳转到牛熊街货分布页
            view.commonHeader.action = { [weak self] in
                guard let `self` = self else { return }
                let market = self.bullBearViewModel.assetMarket
                let symbol = self.bullBearViewModel.assetSymbol
                let name = self.bullBearViewModel.assetName
                self.bullBearViewModel.gotoCBBC(market: market, symbol: symbol, name: name)
            }
            
            return view
            
        case .longShortSignal:
            return signalSectionHeader
            
        case .fundFlow:
            let view = commonHeaderView(title: sectionType.sectionTitle)
            // 点击查看更多
             view.action = { [weak self] in
                guard let `self` = self else { return }

                let vm = YXWarrantsFundFlowDetailViewModel.init(services: self.viewModel.services, params: nil)
                self.viewModel.services.push(vm, animated: true)
             }
            
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = self.bullBearViewModel.dataSource[indexPath.section]
        switch sectionType {
        case .street:
            if indexPath.row == (self.bullBearViewModel.street?.bearList.count ?? 0) { // 当前价格cell
                return 26
            }else {
                return 40
            }
        case .fundFlow:
            return 100
        case .longShortSignal:
            return 40
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = self.bullBearViewModel.dataSource[section]
        switch sectionType {
        case .street:
            return 90
        case .longShortSignal:
            return 120
        default:
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

extension YXBullBearContractViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        if index == 0 {
            self.bullBearViewModel.derivativeType = .warrant
        }else {
            self.bullBearViewModel.derivativeType = .bullBear
        }
        
        self.bullBearViewModel.getPbSignal().subscribe(onSuccess: { [weak self](pbModel) in
            self?.tableView.reloadData()
        }).disposed(by: self.disposeBag)
    }
}
