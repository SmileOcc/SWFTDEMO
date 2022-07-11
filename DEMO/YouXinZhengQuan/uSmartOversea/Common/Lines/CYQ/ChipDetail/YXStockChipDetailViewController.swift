//
//  YXStockChipDetailViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class YXStockChipDetailViewController: YXHKViewController, HUDViewModelBased, UIGestureRecognizerDelegate {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    typealias ViewModelType = YXStockChipDetailViewModel

    var viewModel: ViewModelType!

    var quoteRequest: YXQuoteRequest?

    var isFirstRecord = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = YXLanguageUtility.kLang(key: "chips")
        self.view.backgroundColor = QMUITheme().foregroundColor()

        initUI()
        loadData()
        let stockId = self.viewModel.market + self.viewModel.symbol
        if let model = YXCYQRequestTool.shared.singleChipParam?[stockId] {
            chipDetailView.priceBase = model.priceBase
            chipDetailView.model = model.list?.first
            sliderView.singleModel = model
        }

        self.sliderView.chipInfoBlock = {
            [weak self] (info, priceBase) in
            guard let `self` = self else { return }

            self.chipDetailView.priceBase = priceBase
            self.chipDetailView.model = info

            if self.isFirstRecord {
                self.isFirstRecord = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadQuoteData()
        if self.viewModel.isFromLand {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quoteRequest?.cancel()
        quoteRequest = nil
        if self.viewModel.isFromLand {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }

    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewModel.isFromLand, gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }

    func loadData() {
        let stockId = self.viewModel.market + self.viewModel.symbol
        if let model = YXCYQRequestTool.shared.batchChipParam?[stockId] {
            sliderView.model = model
            if self.chipDetailView.model == nil {
                self.chipDetailView.priceBase = model.priceBase
                self.chipDetailView.model = model.list?.last
            }
        } else {
            YXCYQRequestTool.shared.requestBatchCYQData(stockId, count: 88) { [weak self] (model) in
                guard let `self` = self else { return }
                self.sliderView.model = model
                if self.chipDetailView.model == nil, let tempModel = model {
                    self.chipDetailView.priceBase = tempModel.priceBase
                    self.chipDetailView.model = tempModel.list?.last
                }

            }
        }

    }

    func loadQuoteData() {
        quoteRequest?.cancel()
        let secu = Secu.init(market: self.viewModel.market, symbol: self.viewModel.symbol)
        let level = YXUserManager.shared().getLevel(with: self.viewModel.market)

        quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [secu], level: level, handler: {
            [weak self] (quotes, scheme) in
            guard let `self` = self else { return }
            if let quoteModel = quotes.first {
                self.topView.model = quoteModel
            }
        })
    }

    func initUI() {

        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(69)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            }
        }

        let sliderHeight: CGFloat = 85

        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalToSuperview().offset(-sliderHeight - YXConstant.tabBarPadding())
        }

        scrollView.addSubview(chipDetailView)
        chipDetailView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(self.view)
        }


        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(sliderHeight)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
        }

        self.bottomView.addSubview(self.sliderView)
        self.sliderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(sliderHeight)
        }
    }


    lazy var topView: YXStockTopView = {
        let view = YXStockTopView()
        view.seperatorView.isHidden = false
        return view
    }()

    lazy var bottomView: UIView = {
        let view = UIView()

        return view
    }()

    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()

        return scrollview
    }()

    lazy var chipDetailView: YXStockChipDetailView = {
        let view = YXStockChipDetailView()
        
        return view
    }()

    lazy var sliderView: YXStockChipDetailSliderView = {
        let view = YXStockChipDetailSliderView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 85))

        return view
    }()


}



