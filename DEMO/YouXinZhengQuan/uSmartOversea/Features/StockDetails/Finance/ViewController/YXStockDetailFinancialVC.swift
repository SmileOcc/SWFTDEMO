//
//  YXStockDetailDinancialVC.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import SnapKit
import JXPagingView

let financialChartViewH: CGFloat = 390

class YXStockDetailFinancialVC: YXHKViewController, HUDViewModelBased {

    typealias ViewModelType = YXFinancialViewModel
    var viewModel: YXFinancialViewModel! = YXFinancialViewModel.init()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    

    enum QuarterType: Int { //(1:一季报,2:中报,3:三季报,4:年报)
        case q1 = 1
        case q2
        case q3
        case q4

        var text: String {

            var str = "4"
            switch self {

                case .q1:
                    str = "1"
                    break
                case .q2:
                    str = "2"
                    break
                case .q3:
                    str = "3"
                    break
                case .q4:
                    str = "4"
                    break
            }
            return str
        }
    }
    
    let profitView: YXStockDetailFinancialSectionView = YXStockDetailFinancialSectionView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: financialChartViewH), type: .profit)
    let assetView: YXStockDetailFinancialSectionView = YXStockDetailFinancialSectionView.init(frame: CGRect.init(x: 0, y: financialChartViewH, width: YXConstant.screenWidth, height: financialChartViewH), type: .asset)
    let cashFlowView: YXStockDetailFinancialSectionView = YXStockDetailFinancialSectionView.init(frame: CGRect.init(x: 0, y: financialChartViewH * 2, width: YXConstant.screenWidth, height: financialChartViewH), type: .cashFlow)
    
    var listProfitViewH: CGFloat {
        
        if self.isHs() {
            return 520 - 44 * 2
        } else {
            return 520
        }
    }
    
    var listAssetViewH: CGFloat {

        388
    }
    
    var listCashFlowViewH: CGFloat {
        return 282 + ((YXUserManager.isENMode()) ? 30 : 0)
    }
    
    lazy var chartScrollView: UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.backgroundColor = QMUITheme().foregroundColor()
        return scrollView
    }()

    var isLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = YXLanguageUtility.kLang(key: "stock_finance_title")
        initUI()
        bindModel()
        loadData()
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        isLoaded = true

        handleRequestBlock()
    }

    func refreshControllerData() {
        if isLoaded {
            loadData()
        }
    }

    let marketHeight: CGFloat = 405

    var chartBottomConstraint: Constraint?
    var listBottomConstraint: Constraint?
    func initUI() {

        self.view.addSubview(self.chartScrollView)
        self.chartScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.chartScrollView.addSubview(self.marketChartView)
        self.marketChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.height.equalTo(self.marketHeight)
            make.top.equalToSuperview()
        }

        self.chartScrollView.addSubview(self.topView)
        self.topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.height.equalTo(118)
            make.top.equalTo(self.marketChartView.snp.bottom)
        }

        chartScrollView.addSubview(self.chartContainerView)
        chartScrollView.addSubview(self.listContainerView)

        self.chartContainerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            chartBottomConstraint = make.bottom.equalToSuperview().constraint
            make.top.equalTo(self.topView.snp.bottom)
        }

        self.listContainerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            listBottomConstraint = make.bottom.equalToSuperview().constraint
            make.top.equalTo(self.topView.snp.bottom)
        }

        chartBottomConstraint?.activate()
        listBottomConstraint?.deactivate()
        
        chartContainerView.addSubview(self.profitView)
        chartContainerView.addSubview(self.assetView)
        chartContainerView.addSubview(self.cashFlowView)
        
        self.profitView.isYear = true
        self.assetView.isYear = true
        self.cashFlowView.isYear = true

        self.profitView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(financialChartViewH)
        }

        self.assetView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.profitView.snp.bottom)
            make.height.equalTo(financialChartViewH)
        }

        self.cashFlowView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.assetView.snp.bottom)
            make.height.equalTo(financialChartViewH)
            make.bottom.equalToSuperview().offset(-30)
        }

        listContainerView.addSubview(self.listProfitView)
        listContainerView.addSubview(self.listAssetView)
        listContainerView.addSubview(self.listCashFlowView)

        self.listProfitView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(listProfitViewH)
        }

        self.listAssetView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.listProfitView.snp.bottom)
            make.height.equalTo(listAssetViewH)
        }

        self.listCashFlowView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.listAssetView.snp.bottom)
            make.height.equalTo(listCashFlowViewH)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    
    override func jx_refreshData() {
        self.refreshControllerData()
    }


    func handleRequestBlock() {
        profitView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadProfitData()
        }

        assetView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadAssetData()
        }

        cashFlowView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadCashFlowData()
        }

        listProfitView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadListProfitData()
        }

        listAssetView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadListAssetData()
        }

        listCashFlowView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadListCashFlowData()
        }
    }
    
    func loadData() {

        loadProfitData()
        loadListProfitData()

        loadAssetData()
        loadListAssetData()

        loadCashFlowData()
        loadListCashFlowData()

        loadMarketFinancialData(self.marketChartView.selectIndex)

    }

    func loadProfitData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (profitView.selectIndex < array.count) ? array[profitView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.financialIncomes(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.HSFinancialIncomesDataResponse).disposed(by: self.disposeBag)
        } else {

            self.viewModel.services.request(.financialIncomes(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.financialIncomesDataResponse).disposed(by: self.disposeBag)
        }
    }

    func loadListProfitData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (listProfitView.selectIndex < array.count) ? array[listProfitView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.hsListProfit(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text), response: self.viewModel.hsListProfitResponse).disposed(by: self.disposeBag)
        } else {
            var periodtype = "1"
            if type == QuarterType.q1 || type == QuarterType.q3 {
                periodtype = "2"
            } else if type == QuarterType.q2 {
                periodtype = "10"
            }
            self.viewModel.services.request(.listIncomestatement(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text, periodtype: periodtype), response: self.viewModel.listProfitDataResponse).disposed(by: self.disposeBag)
        }
    }

    func loadAssetData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (assetView.selectIndex < array.count) ? array[assetView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.financialBalance(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.HSFinancialBalanceDataResponse).disposed(by: self.disposeBag)
        } else {

            self.viewModel.services.request(.financialBalance(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.financialBalanceDataResponse).disposed(by: self.disposeBag)
        }
    }

    func loadListAssetData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (listAssetView.selectIndex < array.count) ? array[listAssetView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.hsListAsset(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text), response: self.viewModel.hsListAssetResponse).disposed(by: self.disposeBag)
        } else {
            var periodtype = "1"
            if type == QuarterType.q1 || type == QuarterType.q3 {
                periodtype = "2"
            } else if type == QuarterType.q2 {
                periodtype = "10"
            }
            self.viewModel.services.request(.listBalancesheet(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text, periodtype: periodtype), response: self.viewModel.listAssetDataResponse).disposed(by: self.disposeBag)
        }
    }

    func loadCashFlowData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (cashFlowView.selectIndex < array.count) ? array[cashFlowView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.financialCashflow(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.HSFinancialCashflowDataResponse).disposed(by: self.disposeBag)
        } else {

            self.viewModel.services.request(.financialCashflow(self.viewModel.market + self.viewModel.symbol, quartertype: type?.text ?? QuarterType.q4.text, isHS: self.isHs()), response: self.viewModel.financialCashflowDataResponse).disposed(by: self.disposeBag)
        }
    }
    
    func isHs() -> Bool {
        return self.viewModel.market != kYXMarketHK && self.viewModel.market != kYXMarketUS && self.viewModel.market != kYXMarketSG
    }

    func loadListCashFlowData() {
        
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (listCashFlowView.selectIndex < array.count) ? array[listCashFlowView.selectIndex] : array.first
        if self.isHs() {
            self.viewModel.services.request(.hsListCashFlow(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text), response: self.viewModel.hsListCashflowResponse).disposed(by: self.disposeBag)
        } else {
            var periodtype = "1"
            if type == QuarterType.q1 || type == QuarterType.q3 {
                periodtype = "2"
            } else if type == QuarterType.q2 {
                periodtype = "10"
            }
            self.viewModel.services.request(.listCashFlow(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text, periodtype: periodtype), response: self.viewModel.listCashflowDataResponse).disposed(by: self.disposeBag)
        }
    }


    func loadMarketFinancialData(_ quarter: Int = 0) {
        let array = [QuarterType.q4, QuarterType.q2, QuarterType.q1, QuarterType.q3]
        let type = (quarter < array.count) ? array[quarter] : array.first
        self.viewModel.services.request(.marketFinancial(self.viewModel.market + self.viewModel.symbol, quarter: type?.text ?? QuarterType.q4.text), response: self.viewModel.marketFinancialResponse).disposed(by: self.disposeBag)
    }
    
    func endRefresh() {
        self.endRefreshCallBack?()
    }
    
    func bindModel() {

        self.bindHUD()
        if self.isHs() {
            
            self.viewModel.financialIncomesSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.profitView.HSIncomeData = nil
                } else {
                    self?.profitView.HSIncomeData = self?.viewModel.HSFinancialIncomesData
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.financialBalanceSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.assetView.HSIncomeData = nil
                } else {
                    self?.assetView.HSIncomeData = self?.viewModel.HSFinancialBalanceData
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.financialCashFlowSubject.subscribe(onNext: { [weak self] result in

                self?.endRefresh()
                if result == nil {
                    self?.cashFlowView.HSIncomeData = nil
                } else {
                    self?.cashFlowView.HSIncomeData = self?.viewModel.HSFinancialCashFlowData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
            self.viewModel.hsListProfitSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.listProfitView.aListData = nil
                } else {
                    self?.listProfitView.aListData = self?.viewModel.hsListProfitData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.hsListAssetSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.listAssetView.aListData = nil
                } else {
                    self?.listAssetView.aListData = self?.viewModel.hsListAssetData
                }

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.hsListCashFlowSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.listCashFlowView.aListData = nil
                } else {
                    self?.listCashFlowView.aListData = self?.viewModel.hsListCashFlowData
                }

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
        } else {
            
            self.viewModel.financialIncomesSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.profitView.incomeData = nil
                } else {
                    self?.profitView.incomeData = self?.viewModel.financialIncomesData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.financialBalanceSubject.subscribe(onNext: { [weak self]  result in

                self?.endRefresh()
                if result == nil {
                    self?.assetView.incomeData = nil
                } else {
                    self?.assetView.incomeData = self?.viewModel.financialBalanceData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.viewModel.financialCashFlowSubject.subscribe(onNext: { [weak self] result in

                self?.endRefresh()
                if result == nil {
                    self?.cashFlowView.incomeData = nil
                } else {
                    self?.cashFlowView.incomeData = self?.viewModel.financialCashFlowData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
            self.viewModel.listProfitSubject.subscribe(onNext: { [weak self] result in

                self?.endRefresh()
                if result == nil {
                    self?.listProfitView.listProfitData = nil
                } else {
                    self?.listProfitView.listProfitData = self?.viewModel.listProfitData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
            self.viewModel.listAssetSubject.subscribe(onNext: { [weak self] result in

                self?.endRefresh()
                if result == nil {
                    self?.listAssetView.listAssetData = nil
                } else {
                    self?.listAssetView.listAssetData = self?.viewModel.listAssetData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
            self.viewModel.listCashFlowSubject.subscribe(onNext: { [weak self] result in

                self?.endRefresh()
                if result == nil {
                    self?.listCashFlowView.listCashFlowData = nil
                } else {
                    self?.listCashFlowView.listCashFlowData = self?.viewModel.listCashFlowData
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        }

        self.viewModel.marketFinancialSubject.subscribe(onNext: {
            [weak self] list in
            guard let `self` = self else { return }
            self.marketChartView.list = list
        }).disposed(by: disposeBag)

        profitView.detailClosure = {
            [weak self] in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "income")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }

        assetView.detailClosure = {
            [weak self] in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "balance")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }

        cashFlowView.detailClosure = {
            [weak self] in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "cashflow")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.textAlignment = .left
        titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_finance_chart")
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }
        
        view.addSubview(chartStyleTapButtonView)
        chartStyleTapButtonView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        return view
    }()
    
    lazy var chartStyleTapButtonView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXLanguageUtility.kLang(key: "chart_mode"), YXLanguageUtility.kLang(key: "report_mode")])
        view.tapAction = { [weak self]index in
            guard let `self` = self else { return }
            if index == 0 {
                self.listContainerView.isHidden = true
                self.chartContainerView.isHidden = false
                self.chartBottomConstraint?.activate()
                self.listBottomConstraint?.deactivate()
            }else {
                self.listContainerView.isHidden = false
                self.chartContainerView.isHidden = true
                self.chartBottomConstraint?.deactivate()
                self.listBottomConstraint?.activate()
            }
        }
        return view
    }()

    lazy var chartContainerView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var listContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    lazy var listProfitView: YXStockDetailFinanceListSectionView =  {
        let view = YXStockDetailFinanceListSectionView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: listProfitViewH), type: .profit, market: self.viewModel.market)
        view.arrowButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "income")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }).disposed(by: rx.disposeBag)
        return view
    }()

    lazy var listAssetView: YXStockDetailFinanceListSectionView =  {
        let view = YXStockDetailFinanceListSectionView.init(frame: CGRect.init(x: 0, y: listProfitViewH, width: YXConstant.screenWidth, height: listAssetViewH), type: .asset, market: self.viewModel.market)
        view.arrowButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "balance")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }).disposed(by: rx.disposeBag)
        return view
    }()

    lazy var listCashFlowView: YXStockDetailFinanceListSectionView =  {
        let view = YXStockDetailFinanceListSectionView.init(frame: CGRect.init(x: 0, y: listProfitViewH + listAssetViewH , width: YXConstant.screenWidth, height: listCashFlowViewH), type: .cashFlow, market: self.viewModel.market)
        view.arrowButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_FINANCE_URL(symbol: self.viewModel.market + self.viewModel.symbol, type: "cashflow")
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }).disposed(by: rx.disposeBag)
        return view
    }()

    lazy var marketChartView: YXStockDetailMarketFinanicalChartView = {
        let view = YXStockDetailMarketFinanicalChartView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: self.marketHeight), andMarket: self.viewModel.market)
        view.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.loadMarketFinancialData(selectIndex)
        }

        view.clickTypeBtnCallBack = {
            [weak self] type in
            guard let `self` = self else { return }
         
        }
        return view
    }()
}


extension YXStockDetailFinancialVC: JXPagingViewListViewDelegate, UIScrollViewDelegate {
    
    func listScrollView() -> UIScrollView { self.chartScrollView }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}
