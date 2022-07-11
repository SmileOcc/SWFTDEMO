//
//  YXStockDetailWarrantIntroduceVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailWarrantIntroduceVC: YXHKViewController {

    typealias ViewModelType = YXStockDetailWarrantIntroduceViewModel
    var viewModel: YXStockDetailWarrantIntroduceViewModel = YXStockDetailWarrantIntroduceViewModel.init()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var isLoaded = false
    var scrollCallBack: YXTabPageScrollBlock?

    var underlineQuoteRequest: YXQuoteRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindModel()
        isLoaded = true
        self.networkingHUD.showLoading("", in: self.view)
        refreshControllerData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUnderlisngQuoteData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        underlineQuoteRequest?.cancel()
        underlineQuoteRequest = nil;
    }

    @objc func refreshControllerData() {
        if isLoaded {
            loadHkwarrantData()
        }
    }

    func initUI() {

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(briefView)
        briefView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalToSuperview().offset(-30)
        }

        briefView.titles = self.viewModel.briefParameters
        briefView.relateStockName = self.viewModel.relatedName
        briefView.currentStockName = self.viewModel.name

        // 下拉更新
        scrollView.mj_header = YXRefreshHeader { [weak self] in
            guard let `self` = self else { return }

            self.loadHkwarrantData()
            self.loadUnderlisngQuoteData()
        }
    }

    // 簡況
    func loadHkwarrantData() {

        self.viewModel.services.request(.hkwarrant(self.viewModel.market + self.viewModel.symbol), response: self.viewModel.hkwarrantResponse).disposed(by: self.disposeBag)
    }


    //行情
    func loadUnderlisngQuoteData() {
        let market = self.viewModel.relatedMarket
        let symbol = self.viewModel.relatedSymbol
        if !market.isEmpty, !symbol.isEmpty {
            underlineQuoteRequest?.cancel()
            underlineQuoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [Secu(market: market, symbol: symbol)], level: YXUserManager.shared().getLevel(with: market), handler: ({ [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                if let quote = quotes.first {
                    if let basic = quote.priceBase?.value {
                        self.briefView.relatePriceBase = Int(basic)
                    }

                    if let roc = quote.pctchng?.value {
                        self.briefView.roc = Int64(roc)
                    }
                }
            }))
        }

    }


    func bindModel() {

        // 簡況
        self.viewModel.stockHkwarrantDataSubject.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            self.networkingHUD.hide(animated: true)
            if self.scrollView.mj_header.isRefreshing {
                self.scrollView.mj_header.endRefreshing()
            }
            if let model = model {
                self.briefView.kwarrantModel = model
            }

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.briefView.clickStockDetalCallBack = { [weak self] in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = self.viewModel.market
            input.symbol = self.viewModel.hkwarrantModel?.positiveSecuCode ?? ""
            input.name = self.viewModel.hkwarrantModel?.positiveSecuAbbr ?? ""
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }

    }

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .always
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        return scrollView
    }()

    lazy var briefView: YXStockDetailWarrantsBriefView = {
        let view = YXStockDetailWarrantsBriefView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
}

extension YXStockDetailWarrantIntroduceVC: YXTabPageScrollViewProtocol, UIScrollViewDelegate {

    func pageScrollView() -> UIScrollView {
        self.scrollView
    }

    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        self.scrollCallBack = callback
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollCallBack?(scrollView)
    }
}
