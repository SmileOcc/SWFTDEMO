//
//  YXETFBriefViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

import RxSwift
import RxCocoa

class YXETFBriefViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    typealias ViewModelType = YXETFBriefViewModel

    var viewModel: ViewModelType! = YXETFBriefViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()

        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }

            self.requestBreifInfo()
        }
        self.scrollview.mj_header = refreshHeader

        networkingHUD.showLoading("", in: self.view)
        requestBreifInfo()
    }

    func requestBreifInfo() {
        self.viewModel.requestBriefInfo().subscribe(onSuccess: {
            [weak self] model in
            guard let `self` = self else { return }

            self.networkingHUD.hide(animated: true)
            if (self.scrollview.mj_header.isRefreshing) {
                self.scrollview.mj_header.endRefreshing()
            }

            self.infoView.model = model
            
            if self.viewModel.market == kYXMarketHK {

                self.investView.model = model
                if let invest = model?.basicInfo?.investTarget, !invest.isEmpty {
                    self.investView.isHidden = false
                    self.investView.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview()
                        make.top.equalTo(self.infoView.snp.bottom)
                        make.right.equalTo(self.view)
                    }
                } else {
                    self.investView.isHidden = true
                    self.investView.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview()
                        make.top.equalTo(self.infoView.snp.bottom)
                        make.right.equalTo(self.view)
                        make.height.equalTo(0)
                    }
                }

                self.returnInfoView.model = model
                if let count = model?.returnsInfo?.count, count > 0 {
                    self.returnInfoView.isHidden = false
                    self.returnInfoView.snp.updateConstraints { (make) in
                        make.height.equalTo(404)
                    }
                } else {
                    self.returnInfoView.isHidden = true
                    self.returnInfoView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                }
            } else {
                self.elementView.model = model
                self.elementChangeView.model = model

                if let count = model?.elementChangeInfo?.count, count > 0 {
                    self.elementChangeView.isHidden = false
                    let height: CGFloat = CGFloat(122 + 44 * (count > 3 ? 3: count))
                    self.elementChangeView.snp.updateConstraints { (make) in
                        make.height.equalTo(height)
                    }
                } else {
                    self.elementChangeView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    self.elementChangeView.isHidden = true
                }


                if let count = model?.elementInfo?.count, count > 0 {
                    self.elementView.isHidden = false
                    let height: CGFloat = CGFloat(126 + 50 * (count > 10 ? 10: count))
                    self.elementView.snp.updateConstraints { (make) in
                        make.height.equalTo(height)
                    }
                } else {
                    self.elementView.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    self.elementView.isHidden = true
                }
            }

        }).disposed(by: rx.disposeBag)
    }

    func initUI() {
        view.addSubview(scrollview)
        scrollview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        scrollview.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.right.equalTo(self.view)
        }

        if self.viewModel.market == kYXMarketHK {
            scrollview.addSubview(investView)
            investView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(infoView.snp.bottom)
                make.right.equalTo(self.view)
            }

            scrollview.addSubview(returnInfoView)
            returnInfoView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(investView.snp.bottom)
                make.right.equalTo(self.view)
                make.height.equalTo(404)
                make.bottom.equalToSuperview().offset(-YXStockDetailTool.pageBottomInsets())
            }

        } else {
            scrollview.addSubview(elementView)
            scrollview.addSubview(elementChangeView)

            elementChangeView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(infoView.snp.bottom)
                make.right.equalTo(self.view)
                make.height.equalTo(254)
            }

            elementView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(elementChangeView.snp.bottom)
                make.right.equalTo(self.view)
                make.height.equalTo(626)
                make.bottom.equalToSuperview().offset(-YXStockDetailTool.pageBottomInsets())
            }
        }
    }

    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        return scrollview
    }()

    lazy var infoView: YXETFBriefBasicInfoView = {
        let view = YXETFBriefBasicInfoView(frame: .zero, market: self.viewModel.market, type3: self.viewModel.type3)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var investView: YXETFBriefInvestView = {
        let view = YXETFBriefInvestView(frame: .zero, market: self.viewModel.market)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var returnInfoView: YXETFBriefReturnInfoView = {
        let view = YXETFBriefReturnInfoView(frame: .zero, market: self.viewModel.market, symbol: self.viewModel.symbol, name: self.viewModel.name)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var elementView: YXETFBriefElementView = {
        let view = YXETFBriefElementView(frame: .zero, market: self.viewModel.market)
        view.backgroundColor = QMUITheme().foregroundColor()
        view.pushToDetailBlock = {
            [weak self] in
            guard let `self` = self else { return }
            let viewModel = YXUSElementViewModel(services: self.viewModel.navigator, params: nil)
            viewModel.uniqueSecuCode = self.viewModel.market + self.viewModel.symbol
            self.viewModel.navigator.push(viewModel, animated: true)
        }

        view.pushToStockDetail = {
            [weak self] input in
            guard let `self` = self else { return }
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }
        return view
    }()

    lazy var elementChangeView: YXETFBriefElementChangeView = {
        let view = YXETFBriefElementChangeView(frame: .zero, market: self.viewModel.market)
        view.backgroundColor = QMUITheme().foregroundColor()
        view.pushToDetailBlock = {
            [weak self] in
            guard let `self` = self else { return }
            let viewModel = YXUSElementChangeViewModel(services: self.viewModel.navigator, params: nil)
            viewModel.uniqueSecuCode = self.viewModel.market + self.viewModel.symbol
            self.viewModel.navigator.push(viewModel, animated: true)
        }
        return view
    }()

}

