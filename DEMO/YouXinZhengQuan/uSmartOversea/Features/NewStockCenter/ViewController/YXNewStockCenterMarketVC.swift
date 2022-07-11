//
//  YXNewStockCenterMarketVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXNewStockCenterMarketVC: YXHKTableViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockCenterViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var bannerModel: YXUserBanner!

    var headerRefreshingBlock: ((_ msg: String?) -> Void)?
    var scrollViewDidScrollBlock: ((_ scrollView: UIScrollView) -> Void)?
    var showLoadingblock: ((_ show: Bool) -> Void)?
    var needReload: Bool = true
    // 是否滑动到待上市
    var isToPreMarket = false
    var ipoProTip: String = ""

    lazy var goProButton: QMUIButton = {
        let button = QMUIButton(type: UIButton.ButtonType.custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        button.setTitleColor(QMUITheme().holdMark(), for: .normal)
        button.setImage(UIImage(named: "pro_next"), for: .normal)
        button.addTarget(self, action: #selector(goProButtonAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    enum CellSectionType: Int {
        case deliver = 0
        case purchase = 1
        case preMarket = 2
    }
    
    let deliverIdentifier = "YXNewStockDeliveredCell"
    let purchasingIdentifier = "YXNewStockPurchasingCell"
    let purchaseDoneIdentifier = "YXNewStockPurchaseDoneCell"
    

    required init(viewModel: YXNewStockCenterViewModel) {
        
        super.init(style: .grouped)
        self.viewModel = viewModel
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        bindHUD()
        initUI()
        headerRereshing()
        self.showLoadingblock?(true)
        //addRereshHeader()
        //viewModel.hudSubject.onNext(.loading(nil, false))
        
        YXUserManager.getIPOProWithComplete(["PRO-IPO2"], complete: {
            [weak self] ipoTip in
            guard let `self` = self else { return }
            self.ipoProTip = ipoTip ?? ""
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //headerRereshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    var currentBackgroudColor: UIColor = QMUITheme().backgroundColor()
    
    
    lazy var tableFooterView: UIView = {
        let view = UIView()
        view.backgroundColor = currentBackgroudColor
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40 + YXConstant.tabBarPadding())
        view.addSubview(self.footerLabel)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_next")
        view.addSubview(imageView)
        
        self.footerLabel.text = YXLanguageUtility.kLang(key: "newStock_center_view_listStock")
        
        self.footerLabel.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview().offset(-6)
            make.left.greaterThanOrEqualToSuperview().offset(18)
        })
        
        imageView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.footerLabel.snp.right).offset(6)
            make.centerY.equalTo(self.footerLabel.snp.centerY)
        })
        
        return view
    }()
    
    lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        
        let tapGes = UITapGestureRecognizer()
        label.addGestureRecognizer(tapGes)
        tapGes.rx.event.subscribe(onNext: {
            [weak self] recognizer in
            guard let `self` = self else { return }
            
            self.viewModel.navigator.push(YXModulePaths.newStockMarket.url, context: ["market" : self.viewModel.exchangeType.market])
        }).disposed(by: rx.disposeBag)
        return label
    }()
    
    @objc func goProButtonAction() {
        
        if !YXUserManager.isLogin() {
            
            //未登录
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            
        } else if (YXUserManager.canTrade()) {
            
            //高级账户介绍落地页
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_USERCENTER_PRO_INTRO("Notice_PRO-IPO2_HK")]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding, "moduleTag": 2])
        }
    }
    
}

extension YXNewStockCenterMarketVC {
    
    func bindViewModel() {
        
        viewModel.quoteObservable.subscribe(onNext: { [unowned self] (result) in
            //self.viewModel.hudSubject.onNext(.hide)
            
            var msgArray: [String] = []
            var msg: String? = nil
            if self.viewModel.isRefeshing {
                self.viewModel.isRefeshing = false
                //self.tableView.mj_header.endRefreshing()
            }
            
            result.forEach({ (isSuccess, msg) in
                if let message = msg, message.count > 0 {
                    msgArray.append(message)
                }
            })
            
            if msgArray.count >= 2  {
                msg = msgArray.first!
                //self.networkingHUD.showMessage(msgArray.first!, in: self.view, hideAfter: 1.5)
            }
            
            var dataList: [YXNewStockCenterPreMarketStockModel] = []
            
            if let model = self.viewModel.purchaseNormalModel, let list = model.list, list.count > 0 {
                dataList += list
            }
            if dataList.count > 0 {
                self.viewModel.purchaseList.removeAll()
                self.viewModel.purchaseList = dataList
            }
            
            self.headerRefreshingBlock?(msg)
            self.updateViewStatus()
            self.tableView.reloadData()
            
            if self.isToPreMarket, self.viewModel.premarketList.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 2), at: UITableView.ScrollPosition.top, animated: false)
                self.isToPreMarket = false
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func requestStockCenterInfo() {
                
        viewModel.services.request(.ipoList(orderBy: "latest_endtime", orderDirection: 1, pageNum: 1, pageSize: 30, pageSizeZero: true, status: 0, exchangeType: self.viewModel.exchangeType.rawValue), response: (self.viewModel.purchaseNormalResponse)).disposed(by: rx.disposeBag)
        
        viewModel.services.request(.ipoList(orderBy: "listing_time", orderDirection: 1, pageNum: 1, pageSize: 30, pageSizeZero: true, status: 1, exchangeType: self.viewModel.exchangeType.rawValue), response: (self.viewModel.premarketResponse)).disposed(by: rx.disposeBag)
        if self.viewModel.exchangeType == .hk {
            viewModel.services.request(.deliveredList(orderBy: "apply_date", orderDirection: 1, pageNum: 1, pageSize: 30, pageSizeZero: true), response: (self.viewModel.deliverResponse)).disposed(by: rx.disposeBag)
        }
        
    }
}


//MARK: Initialize UI
extension YXNewStockCenterMarketVC {
    
    fileprivate func initUI() {
        self.title = YXLanguageUtility.kLang(key: "newStock_center")
        self.view.backgroundColor = currentBackgroudColor
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = currentBackgroudColor
        tableView.tableFooterView = tableFooterView
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.bounces = false
        tableView.register(YXNewStockPurchasingCell.self, forCellReuseIdentifier: purchasingIdentifier)
    }
    
    func updateViewStatus() {
        
        var count = 0
        if viewModel.purchaseList.count > 0 || viewModel.premarketList.count > 0 {
            count = 1
        }
        
        if (self.footerLabel.superview != nil) {
            if count > 0 {
                self.footerLabel.snp.remakeConstraints({ (make) in
                    make.center.equalToSuperview()
                    make.left.greaterThanOrEqualToSuperview().offset(18)
                })
            } else {
                self.footerLabel.snp.remakeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().offset(18)
                })
            }
        }
    }
    
}

extension YXNewStockCenterMarketVC {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewDidScrollBlock?(scrollView)
    }
}

//MARK: TableView Delegate & DataSource
extension YXNewStockCenterMarketVC {
    //MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CellSectionType.deliver.rawValue {
            if self.viewModel.exchangeType == .us {
                return 0
            } else if let list = self.viewModel.deliverModel?.list, list.count > 0 {
                return 1
            }
            return 0
        } else  if section == CellSectionType.purchase.rawValue {
            return viewModel.purchaseList.count
        } else {
            return viewModel.premarketList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.section == CellSectionType.deliver.rawValue {
//            var cell = tableView.dequeueReusableCell(withIdentifier: deliverIdentifier)
//            if cell == nil {
//                cell = YXNewStockDeliveredCell(style: .default, reuseIdentifier: deliverIdentifier)
//            }
//
//            if let tableCell = (cell as? YXNewStockDeliveredCell), let list = self.viewModel.deliverModel?.list, list.count > 0 {
//                tableCell.countLabel.text = String(format: YXLanguageUtility.kLang(key: "delivered_company_count"), list.count)
//                if viewModel.exchangeType == .hk, YXUserManager.isHighWorth() {
//                    tableCell.ecmRedDotView.isHidden = false
//                } else {
//                    tableCell.ecmRedDotView.isHidden = true
//                }
//            }
//
//            return cell!
//        } else if indexPath.section == CellSectionType.purchase.rawValue {
//            var cell = tableView.dequeueReusableCell(withIdentifier: purchasingIdentifier)
//            if cell == nil {
//                cell = YXNewStockPurchasingCell(style: .default, reuseIdentifier: purchasingIdentifier)
//            }
//
//            if let tableCell = (cell as? YXNewStockPurchasingCell), indexPath.row < viewModel.purchaseList.count {
//                tableCell.refreshUI(model: viewModel.purchaseList[indexPath.row])
//            }
//            return cell!
//        } else {
//            var cell = tableView.dequeueReusableCell(withIdentifier: purchaseDoneIdentifier)
//            if cell == nil {
//                cell = YXNewStockPreMarketCell(style: .default, reuseIdentifier: purchaseDoneIdentifier)
//            }
//
//            if let tableCell = (cell as? YXNewStockPreMarketCell), indexPath.row < viewModel.premarketList.count {
//                tableCell.refreshUI(model: viewModel.premarketList[indexPath.row])
//            }
//            return cell!
//        }
        return UITableViewCell()
    
    }
    
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == CellSectionType.deliver.rawValue {
            if self.viewModel.exchangeType == .hk {
               return 58
            }
            return 0.1
        } else  if indexPath.section == CellSectionType.purchase.rawValue {
            return tableView.qmui_heightForCell(withIdentifier: purchasingIdentifier, cacheBy: indexPath, configuration: { [unowned self] (tableViewCell) in
                if let cell = tableViewCell as? YXNewStockPurchasingCell, indexPath.row < self.viewModel.purchaseList.count {
                    cell.refreshUI(model: self.viewModel.purchaseList[indexPath.row])
                }
            })
        } else {
            return 145
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == CellSectionType.deliver.rawValue {
         
            return 0.1
        } else if section == CellSectionType.purchase.rawValue {
            if viewModel.financingAccountDiff && self.ipoProTip.count > 0 && viewModel.purchaseList.count > 0 && viewModel.exchangeType == .hk{
                
                return kSectionHeaderHeight + 15
                
            } else {
                
                return kSectionHeaderHeight
            }
        }
        return kSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == CellSectionType.deliver.rawValue {
            return nil
        }
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: kSectionHeaderHeight)
        headerView.backgroundColor = currentBackgroudColor
        let headerTitleLabel = UILabel()
        headerView.addSubview(headerTitleLabel)
        headerTitleLabel.textAlignment = .left
        headerTitleLabel.textColor = QMUITheme().textColorLevel1()
        headerTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        headerTitleLabel.numberOfLines = 1
        
        let headerEmptyLabel = UILabel()
        headerView.addSubview(headerEmptyLabel)
        headerEmptyLabel.textAlignment = .left
        headerEmptyLabel.textColor = QMUITheme().textColorLevel3()
        headerEmptyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        headerEmptyLabel.numberOfLines = 1
                
        headerTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-18)
        }
        
        headerEmptyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerTitleLabel.snp.right).offset(20)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-18)
        }
        
        headerView.addSubview(goProButton)
        goProButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(headerEmptyLabel.snp.bottom).offset(2)
            make.height.equalTo(16)
            make.right.lessThanOrEqualToSuperview().offset(-18)
        }
        
        headerTitleLabel.text = sectionTitleArray[section]
        headerEmptyLabel.text = sectionEmptyDesArray[section]
        
        if section == CellSectionType.purchase.rawValue {
            if viewModel.purchaseList.count > 0 {
                headerEmptyLabel.isHidden = true
                if viewModel.financingAccountDiff && self.ipoProTip.count > 0 && viewModel.exchangeType == .hk && (YXUserManager.shared().curLoginUser?.userRoleType == YXUserRoleType.common || !YXUserManager.isLogin()){
                    goProButton.isHidden = false
                    headerTitleLabel.snp.updateConstraints { (make) in
                        make.left.equalToSuperview().offset(18)
                        make.centerY.equalToSuperview().offset(-10)
                        make.right.lessThanOrEqualToSuperview().offset(-18)
                    }
                    goProButton.setTitle(self.ipoProTip, for: .normal)
                    goProButton.imagePosition = .right
                } else {
                    goProButton.isHidden = true
                }
            } else {
                headerEmptyLabel.isHidden = false
                goProButton.isHidden = true
            }
        } else {
            
            goProButton.isHidden = true
            if viewModel.premarketList.count > 0  {
                headerEmptyLabel.isHidden = true
            } else {
                headerEmptyLabel.isHidden = false
            }
        }
        
        return headerView
    }
    
    var kSectionHeaderHeight: CGFloat {
        48
    }
    
    var sectionTitleArray: [String] {
        [" ", YXLanguageUtility.kLang(key: "newStock_center_purchasing"), YXLanguageUtility.kLang(key: "newStock_center_prelist")]
    }
    
    var sectionEmptyDesArray: [String] {
        [" ", YXLanguageUtility.kLang(key: "newStock_center_noSubStock"), YXLanguageUtility.kLang(key: "newStock_center_noWaitingListStock")]
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == CellSectionType.deliver.rawValue {
            if let cell = tableView.cellForRow(at: indexPath) as? YXNewStockDeliveredCell {
                cell.ecmRedDotView.isHidden = true
            }
            YXLittleRedDotManager.shared.hiddenEcmSub()
            self.viewModel.navigator.push(YXModulePaths.newStockDelivered.url)
        } else if indexPath.section == CellSectionType.purchase.rawValue {
            if indexPath.row < viewModel.purchaseList.count {
                let model = viewModel.purchaseList[indexPath.row]
                let context: [String : Any] = [
                    "exchangeType" : model.exchangeType ?? 0,
                    "ipoId" : Int64(model.ipoId ?? "0") ?? 0,
                    "stockCode" : model.stockCode ?? ""
                ]
                self.viewModel.navigator.push(YXModulePaths.newStockDetail.url, context: context)
            }
            
        } else {
            if indexPath.row < viewModel.premarketList.count {
                let model = viewModel.premarketList[indexPath.row]

                if model.openApplyInfo == 1 {

                    let context: [String : Any] = [
                        "exchangeType" : model.exchangeType ?? 0,
                        "ipoId" : Int64(model.ipoId ?? "0") ?? 0,
                        "stockCode" : model.stockCode ?? ""
                    ]
                    self.viewModel.navigator.push(YXModulePaths.newStockDetail.url, context: context)
                } else {
                    if let symbol = model.stockCode {

                        let input = YXStockInputModel()
                        input.market = (model.exchangeType == 5) ? YXMarketType.US.rawValue : YXMarketType.HK.rawValue
                        input.symbol = symbol
                        input.name = model.stockName ?? ""
                        self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                    }
                }

            }
        }
    }
   
}

extension YXNewStockCenterMarketVC {
    //下拉更新
    func addRereshHeader() {
        self.tableView.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
    }
    
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
        requestStockCenterInfo()
    }
}

