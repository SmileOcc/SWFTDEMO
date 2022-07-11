//
//  YXStockDetailIntroduceVC.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import SwiftyJSON
import JXPagingView

enum YXStockDetailIntroduceType: Int {
    case profit = 0  //简介
    case industry    //所属行业
    case conception  //所属概念
    case compose     //组成
    case shareholder //十大股东
    case divien      //分红
    case buyback     //回购
    case splitshare  //拆股
    
    func getTitle(_ market: String = kYXMarketHK) -> String {
        switch self {
        case .compose:
            return YXLanguageUtility.kLang(key: "stock_detail_income")
        case .industry:
            return YXLanguageUtility.kLang(key: "belong_industry")
        case .conception:
            return YXLanguageUtility.kLang(key: "belong_conception")
        case .shareholder:
            if market == kYXMarketHK {
                return YXLanguageUtility.kLang(key: "stock_detail_major_shareholder")
            } else if market == kYXMarketUS || market == kYXMarketSG {
                return YXLanguageUtility.kLang(key: "stock_holder")
            } else {
                return YXLanguageUtility.kLang(key: "stock_holders")
            }
        case .divien:
            return YXLanguageUtility.kLang(key: "stock_detail_dividend")
        case .buyback:
            return YXLanguageUtility.kLang(key: "stock_detail_dividend_buyback")
        case .splitshare:
            return YXLanguageUtility.kLang(key: "stock_detail_stock_snc")
        default:
            return "--"
        }
    }
}

class YXStockDetailIntroduceVC: YXHKTableViewController, HUDViewModelBased {
    
    typealias ViewModelType = YXStockDetailIntroduceViewModel
    var viewModel: YXStockDetailIntroduceViewModel! = YXStockDetailIntroduceViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var titleArr = [YXStockDetailIntroduceType]()
    
    lazy var companyView: YXIntroduceCompanyView = {
        let companyView = YXIntroduceCompanyView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 260), market: self.viewModel.market)
        return companyView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "stock_detail_briefing")
        tableView.backgroundColor = QMUITheme().foregroundColor()
        bindModel()
        loadCompanyInfo()
        initUI()
        self.networkingHUD.showLoading("", in: self.view)
    }
    
    override init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.companyView.isHkMarket = (self.viewModel.market == "hk")
        self.tableView.separatorStyle = .none
        self.tableView.register(YXCompanyMainBusCell.self, forCellReuseIdentifier: "YXCompanyMainBusCell")
        self.tableView.register(YXBugBackSingleCell.self, forCellReuseIdentifier: "YXBugBackSingleCell")
        self.tableView.register(YXTenShareholderCell.self, forCellReuseIdentifier: "YXTenShareholderCell")

        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 30))
        footerView.backgroundColor = QMUITheme().foregroundColor()
        tableView.tableFooterView = footerView
    }
    
    override func jx_refreshData() {
        self.loadCompanyInfo()
    }
    
    func loadCompanyInfo() {
        self.viewModel.services.request(.companyInfo(self.viewModel.market + self.viewModel.symbol), response: self.viewModel.companyInfoResponse).disposed(by: self.disposeBag)
    }
    
    func loadCompanyProfit() {
        self.viewModel.services.request(.companyProfit(self.viewModel.market + self.viewModel.symbol), response: self.viewModel.companyProfitResponse).disposed(by: self.disposeBag)
    }

    // 新股
    func loadNewStockData() {
        let exchange = self.viewModel.exchangeType.rawValue
        self.viewModel.quotesDataService.request(.newStockDetail(self.viewModel.symbol, exchange), response: self.viewModel.newStockDataResponse).disposed(by: self.disposeBag)
    }
    
    func bindModel() {
        //主营业务 的更多、收起的回调
        self.companyView.moreCallBack = { [weak self] offsetHeight in
            guard let `self` = self else { return }
            self.companyView.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 260 + offsetHeight)
            self.tableView.tableHeaderView = self.companyView
        }

        self.companyView.pushToDetailBlock = { [weak self]  in
            guard let `self` = self else { return }
            let url = YXH5Urls.companyDetailUrl(self.viewModel.market + self.viewModel.symbol)
            YXWebViewModel.pushToWebVC(url)
        }
        //滚动到主营业务的开始位置
        self.companyView.scrollToTopClosure = { [weak self] should in
            if should {
                self?.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            }
        }
        
        self.companyView.industryClickBlock = {
            [weak self] (name, market, symbol) in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = market
            input.symbol = symbol
            input.name = name
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }

        self.companyView.ipoInfoClickBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.gotoNewStockDetail()
        }
        
        self.viewModel.companyInfoSubject.subscribe(onNext: { [weak self] (x) in
            guard let `self` = self else { return }
            self.endRefreshCallBack?()
            self.networkingHUD.hide(animated: true)
            if let isSuccess = x as? Bool {
                if isSuccess {
                    self.hideEmptyView()
                    self.titleArr.removeAll()
                    if let industryCodeYx = self.viewModel.introduceModel.profile?.industryCodeYx, !industryCodeYx.isEmpty {
                        self.titleArr.append(.industry)
                    }
                   // self.titleArr.append(.compose)
                    self.titleArr.append(.shareholder)
                    if let companyBriefText = self.viewModel.introduceModel.profile?.companyBriefText {//
                        let att = YXToolUtility.attributedString(withText: companyBriefText, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), lineSpacing: 5)
                        let layout = YYTextLayout.init(containerSize: CGSize.init(width: Int(YXConstant.screenWidth) - 32, height: Int.max), text: att!)
                        let height = layout?.textBoundingSize.height ?? 20
                        if height > 63 {
                            self.companyView.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 260)
                        }else {
                            self.companyView.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 175 + height)
                        }
                    }else {
                        self.companyView.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 175)
                    }
                    if self.companyView.isShow {
                        self.companyView.layoutConceptionView()
                    }
                    self.tableView.tableHeaderView = self.companyView
                    self.companyView.model = self.viewModel.introduceModel.profile
                    if self.viewModel.introduceModel.profile?.isSubnew == 1 {
                        self.companyView.hasIPOInfo = true
                    }
                    self.tableView.reloadData()
                    self.loadCompanyProfit()
                    //self.loadNewStockData()
                } else {
                    self.showErrorEmptyView()
                    self.titleArr.removeAll()
                    self.tableView.reloadData()
                    self.tableView.tableHeaderView = UIView.init()
                }
            }

        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        self.viewModel.companyProfitSubject.subscribe(onNext: { [weak self] (x) in
            guard let `self` = self else { return }
            
                if let count = self.viewModel.introduceModel.dividend?.count, count > 0, !self.titleArr.contains(.divien) {
                    self.titleArr.append(.divien)
                }
            
            if let count = self.viewModel.introduceModel.buyback?.count, count > 0, !self.titleArr.contains(.buyback) {
                self.titleArr.append(.buyback)
            }
            
                if let count = self.viewModel.introduceModel.splitshare?.count, count > 0, !self.titleArr.contains(.splitshare) {
                    self.titleArr.append(.splitshare)
                }

            if self.titleArr.count > 0 {
                self.hideEmptyView()
            }
            
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

//        // 新股详情
//        self.viewModel.newStockDataSubject.subscribe(onNext: { [weak self] _ in
//            guard let `self` = self else { return }
//
//            if self.viewModel.newStockData != nil, self.viewModel.introduceModel.profile?.isSubnew == 1 {
//                self.companyView.hasIPOInfo = true
//            }
//        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    override func emptyRefreshButtonAction() {
        self.loadCompanyInfo()
    }

    func gotoNewStockDetail() {
        // 認購詳情

//        if let data = self.viewModel.newStockData {
//            // 認購詳情
//            let json = JSON.init(data)
//            let ipoId = json["ipoId"].stringValue
//            let context: [String : Any] = [
//                "exchangeType" : self.viewModel.exchangeType.rawValue,
//                "ipoId" : Int64(ipoId) ?? 0,
//                "stockCode" : self.viewModel.symbol
//            ]
//            self.viewModel.navigator.push(YXModulePaths.newStockDetail.url, context: context)
//        }

        let context: [String : Any] = [
            "exchangeType" : self.viewModel.exchangeType.rawValue,
            "ipoId" : 0,
            "stockCode" : self.viewModel.symbol
        ]
        self.viewModel.navigator.push(YXModulePaths.newStockDetail.url, context: context)


    }

}


extension YXStockDetailIntroduceVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.titleArr.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = self.titleArr[section]
        if type == .compose || type == .shareholder || type == .industry  {
            return 1
        } else if type == .divien {
            let count = self.viewModel.introduceModel.dividend?.count ?? 0
            if count > 5 && !self.viewModel.configModel.isDividendExpand {
                return 5
            } else {
                return count
            }
        } else if type == .buyback  {
            let count = self.viewModel.introduceModel.buyback?.count ?? 0
            if count > 5 && !self.viewModel.configModel.isBuyBackExpand {
                return 5
            } else {
                return count
            }
        } else if type == .splitshare {
            let count = self.viewModel.introduceModel.splitshare?.count ?? 0
            if count > 5 && !self.viewModel.configModel.isSplitshareExpand  {
                return 5
            } else {
                return count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = self.titleArr[section]
        let headerView = YXIntroduceSectionView.init()
        headerView.market = self.viewModel.market
        headerView.type = type
        headerView.titleLabel.text = type.getTitle(self.viewModel.market)
        if type == .compose {
            var model: YXIntroduceMaincomp?
            if self.viewModel.configModel.isSelectCompbus {
                model = self.viewModel.introduceModel.maincompbus?.first
            } else {
                model = self.viewModel.introduceModel.maincomparea?.first
            }
            let str = model?.tradingCurrName ?? YXLanguageUtility.kLang(key: "common_rmb2")
            headerView.titleLabel.text = type.getTitle() + "(" + "\(str)" + ")"
            
            if let month = model?.month, let year = model?.year {
                var appendStr = ""
                if YXUserManager.isENMode() { // 英文环境下, 加空格
                    appendStr = " "
                }
                if month > 6 {
                    headerView.rightLabel.text = "\(year)" + appendStr + YXLanguageUtility.kLang(key: "financial_report_quarter_4")
                } else {
                    headerView.rightLabel.text = "\(year)" + YXLanguageUtility.kLang(key: "common_year") + appendStr + YXLanguageUtility.kLang(key: "financial_report_quarter_2")
                }
            }

        } else if type == .buyback {
            if let model = self.viewModel.introduceModel.buyback?.last {
                let str = model.currencyTypeDesc ?? YXLanguageUtility.kLang(key: "common_hk_dollar")
                if str.isEmpty {
                    headerView.titleLabel.text = type.getTitle()
                } else {
                    headerView.titleLabel.text = type.getTitle() + "(" + "\(str)" + ")"
                }
            }

        } else if type == .shareholder, self.viewModel.market == kYXMarketHK {
//            if let model = self.viewModel.introduceModel.toptenshareholders?.first, let infoSource = model.infoSource {
//                headerView.rightLabel.text = infoSource
//            }
        }

        headerView.pushToDetailBlock = {
            [weak self] type in
            guard let `self` = self else { return }
            var url: String = ""
            var propViewName = ""
            if type == .divien {
                url = YXH5Urls.companyDividendsDetailUrl(self.viewModel.market + self.viewModel.symbol)
                propViewName = "分红转送"
            } else if type == .shareholder {
                url = YXH5Urls.companyShareholderDetailUrl(self.viewModel.market + self.viewModel.symbol)
                propViewName = "主要股东"
            } else if type == .buyback {
                url = YXH5Urls.companyRepurchaseDetailUrl(self.viewModel.market + self.viewModel.symbol)
                propViewName = "公司回购"
            } else if type == .splitshare {
                url = YXH5Urls.companySplittingDetailUrl(self.viewModel.market + self.viewModel.symbol)
                propViewName = "拆股合股"
            }


            if !url.isEmpty {
                YXWebViewModel.pushToWebVC(url)
            }

        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let type = self.titleArr[section]
        if type == .divien || type == .buyback || type == .splitshare {
            return 64 + 36
        }
        return 64
    }
    
    // 底部的view
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let type = self.titleArr[section]
        if self.viewModel.market == kYXMarketHK {
            return 0.1
        } else {
            return self.getFootViewHeight(with: type)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = self.titleArr[section]
       
        if self.viewModel.market == kYXMarketHK {
            return UIView()
        } else {
            return self.getFootView(with: type)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = self.titleArr[indexPath.section]
        if type == .compose {
            var count = 0
            let itemHeight: Int = 40
            if self.viewModel.configModel.isSelectCompbus {
                count = self.viewModel.introduceModel.maincompbus?.count ?? 0
                if count > 5 && !self.viewModel.configModel.isMainBusinessIsExpand {
                    return CGFloat(340 + 5 * itemHeight + 40)
                }
            } else {
                count = self.viewModel.introduceModel.maincomparea?.count ?? 0
                if count > 5 &&
                    !self.viewModel.configModel.isMainAeraIsExpand {
                    return CGFloat(340 + 5 * itemHeight + 40)
                }
            }
            if count > 5 {
                return CGFloat(340 + count * itemHeight + 40)
            } else {
                return CGFloat(340 + count * itemHeight)
            }
            
        } else if type == .shareholder {
            let count = self.viewModel.introduceModel.toptenshareholders?.count ?? 0
            
            if count == 0 {
                return 150
            } else {

                if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketSG {
                    if self.viewModel.configModel.isTenStockIsExpand {
                        return CGFloat(36 + count * 64)
                    } else {
                        if count > 5 {
                            return CGFloat(36 + 5 * 64)
                        } else {
                            return CGFloat(36 + count * 64)
                        }
                    }
                } else {
                    if count > 5 {
                        return CGFloat(36 + 5 * 64)
                    } else {
                        return CGFloat(36 + count * 64)
                    }
                }

            }
        } else if type == .buyback{
            return 40
        } else if type == .divien {
            let model = self.viewModel.introduceModel.dividend?[indexPath.row]
            let str = model?.statements ?? "--"
            return self.getStrHeight(with: str)
        } else if type == .splitshare {
            let model = self.viewModel.introduceModel.splitshare?[indexPath.row]
            let str = model?.statements ?? "--"
            return self.getStrHeight(with: str)
        } else if type == .industry {
            return 40
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = self.titleArr[indexPath.section]
        if type == .compose {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YXCompanyMainBusCell", for: indexPath) as! YXCompanyMainBusCell
            cell.selecIndexCallBack = { [weak self] in
                self?.reloadData(with: .compose, isExpand: true)
            }
            cell.configModel = self.viewModel.configModel
            cell.model = self.viewModel.introduceModel
            return cell
        } else if type == .shareholder{
            let cell = tableView.dequeueReusableCell(withIdentifier: "YXTenShareholderCell", for: indexPath) as! YXTenShareholderCell
            cell.market = self.viewModel.market
            cell.list = self.viewModel.introduceModel.toptenshareholders
            return cell
            
        } else if type == .industry {
            var cell = tableView.dequeueReusableCell(withIdentifier: "YXStockDetailCompanyIndustryCell") as?  YXStockDetailCompanyIndustryCell
            if (cell == nil) {
                cell = YXStockDetailCompanyIndustryCell.init(style: .default, reuseIdentifier: "YXStockDetailCompanyIndustryCell", type: .industry)
            }

            if let cell = cell {
                //cell?.config = self.viewModel.configModel
                cell.market = self.viewModel.market
                cell.model = self.viewModel.introduceModel

//                cell.expandBlock = {
//                    [weak self] in
//                    guard let `self` = self else { return }
//
//                    self.tableView.reloadData()
//                }

                cell.industryClickBlock = {
                    [weak self] (name, market, symbol) in
                    guard let `self` = self else { return }

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = name
                    self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }

            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YXBugBackSingleCell", for: indexPath) as! YXBugBackSingleCell
            cell.isHiddenFirst = false
            if type == .divien {
                let model = self.viewModel.introduceModel.dividend?[indexPath.row]
                if let model = model {
                    if let str = model.exdate, str.count > 0 {
                        cell.firstLabel.text = YXDateHelper.commonDateString(str)
                    } else {
                        cell.firstLabel.text = "--"
                    }
                    if let str = model.divPayableDate, str.count > 0 {
                        cell.secondLabel.text = YXDateHelper.commonDateString(str)
                    } else {
                        cell.secondLabel.text = "--"
                    }
                    if let str = model.statements, str.count > 0 {
                        cell.thirdLabel.text = str
                    } else {
                        cell.thirdLabel.text = "--"
                    }
                }
            } else if type == .buyback {
                let model = self.viewModel.introduceModel.buyback?[indexPath.row]
                if let model = model {
                    if let str = model.backDate, str.count > 0 {
                        cell.firstLabel.text = YXDateHelper.commonDateString(str)
                    } else {
                        cell.firstLabel.text = "--"
                    }
                    if let number = model.buyBackSum, number > 0 {
                        cell.secondLabel.text = YXToolUtility.stockData(number, deciPoint: 2, stockUnit: "", priceBase: 0)
                    } else {
                        cell.secondLabel.text = "--"
                    }
                    if let number = model.buyBackMoney, number > 0 {
                        cell.thirdLabel.text = YXToolUtility.stockData(number, deciPoint: 2, stockUnit: "", priceBase: 0)
                    } else {
                        cell.thirdLabel.text = "--"
                    }
                }
            } else if type == .splitshare {
                let model = self.viewModel.introduceModel.splitshare?[indexPath.row]

                if self.viewModel.market == YXMarketType.US.rawValue {
                    cell.isHiddenFirst = true
                }
                if let model = model {
                    
                    if let str = model.dirDeciPublDate, str.count > 0, self.viewModel.market != YXMarketType.US.rawValue {
                        cell.firstLabel.text = YXDateHelper.commonDateString(str)
                    } else {
                        cell.firstLabel.text = "--"
                    }
                    if let str = model.effectDate, str.count > 0 {                        
                        cell.secondLabel.text = YXDateHelper.commonDateString(str)
                    } else {
                        cell.secondLabel.text = "--"
                    }
                    if let str = model.statements, str.count > 0 {
                        cell.thirdLabel.text = str
                    } else {
                        cell.thirdLabel.text = "--"
                    }
                }
            }
            
            return cell
        }

    }
}


extension YXStockDetailIntroduceVC {
    // MARK: - 获取cell的高度
    func getStrHeight(with str: String) -> CGFloat {
        
        let height = YXToolUtility.getStringSize(with: str, andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(uniHorLength(145) - 38), andLineSpace: 2).height
        if height > 70 {
            return 80
        } else if height > 40 {
            return height + 10
        } else {
            return 40 + 24
        }
    }
    
    // MARK: - 根据类型获取底部的view
    func getFootView(with type: YXStockDetailIntroduceType) -> UIView {
        if type == .divien {
            if (self.viewModel.introduceModel.dividend?.count ?? 0) > 5 {
                let btn = self.getFootBtn(with: type)
                if self.viewModel.configModel.isDividendExpand {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
                return btn
            } else {
                return UIView.init()
            }
        } else if type == .buyback {
            if (self.viewModel.introduceModel.buyback?.count ?? 0) > 5 {
                let btn = self.getFootBtn(with: type)
                if self.viewModel.configModel.isBuyBackExpand {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
                return btn
            } else {
                return UIView.init()
            }
        } else if type == .splitshare {
            if (self.viewModel.introduceModel.splitshare?.count ?? 0) > 5 {
                let btn = self.getFootBtn(with: type)
                if self.viewModel.configModel.isSplitshareExpand {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
                return btn
            } else {
                return UIView.init()
            }
        } else if type == .shareholder {
            if (self.viewModel.introduceModel.toptenshareholders?.count ?? 0) > 5 {
                let btn = self.getFootBtn(with: type)
                if self.viewModel.configModel.isTenStockIsExpand {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
                return btn
            } else {
                return UIView.init()
            }
        }
        return UIView.init()
    }
    
    // MARK: - 获取底部的按钮
    func getFootBtn(with type: YXStockDetailIntroduceType) -> UIButton {
        let btn = UIButton.init(frame: view.bounds)
        //显示更多、收起
        btn.setTitle(YXLanguageUtility.kLang(key: "show_more"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "stock_detail_pack_up"), for: .selected)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.tag = type.rawValue
        btn.addTarget(self, action: #selector(self.showMoreBtnDidClick(_:)), for: .touchUpInside)
        return btn
    }
    
    // MARK: - 获取底部的高度
    func getFootViewHeight(with type: YXStockDetailIntroduceType) -> CGFloat {
        if (type == .divien && (self.viewModel.introduceModel.dividend?.count ?? 0) > 5) ||
            (type == .buyback && (self.viewModel.introduceModel.buyback?.count ?? 0) > 5) ||
            (type == .splitshare && (self.viewModel.introduceModel.splitshare?.count ?? 0) > 5) ||
            (type == .shareholder && (self.viewModel.introduceModel.toptenshareholders?.count ?? 0) > 5) {
            return 60
        } else {
            return 0.1
        }
    }
    
    @objc func showMoreBtnDidClick(_ sender: UIButton) {
        
        let type = YXStockDetailIntroduceType.init(rawValue: sender.tag) ?? .compose
        var isExpand = true
        if type == .divien {
            self.viewModel.configModel.isDividendExpand = !self.viewModel.configModel.isDividendExpand
            isExpand = self.viewModel.configModel.isDividendExpand
        } else if type == .buyback {
            self.viewModel.configModel.isBuyBackExpand = !self.viewModel.configModel.isBuyBackExpand
            isExpand = self.viewModel.configModel.isBuyBackExpand
        } else if type == .splitshare {
            self.viewModel.configModel.isSplitshareExpand = !self.viewModel.configModel.isSplitshareExpand
            isExpand = self.viewModel.configModel.isSplitshareExpand
        } else if type == .shareholder {
            self.viewModel.configModel.isTenStockIsExpand = !self.viewModel.configModel.isTenStockIsExpand
            isExpand = self.viewModel.configModel.isTenStockIsExpand
        }
        self.reloadData(with: type, isExpand: isExpand)
    }
    
    
    // 根据type刷新某一组
    func reloadData(with type: YXStockDetailIntroduceType, isExpand: Bool) {
        for (index, subType) in self.titleArr.enumerated() {
            if subType == type {
                UIView.performWithoutAnimation {
                    self.tableView.reloadSections(IndexSet.init(integer: index), with: .none)
                    if !isExpand {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
                    }
                }
                break
            }
        }
    }
}



extension YXStockDetailIntroduceVC: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.tableView }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}
