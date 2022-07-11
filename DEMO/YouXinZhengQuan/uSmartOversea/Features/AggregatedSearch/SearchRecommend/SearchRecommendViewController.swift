//
//  SearchRecommendViewController.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchRecommendViewController: YXViewController {

    private var recommendViewModel: SearchRecommendViewModel {
        return self.viewModel as! SearchRecommendViewModel
    }

    private lazy var stockView: QMUIFloatLayoutView = {
        let view = QMUIFloatLayoutView.init()
        view.padding = .zero
        view.itemMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        view.minimumItemSize = CGSize(width: 32, height: 32)
        view.maximumItemSize = CGSize(width: 253, height: 32)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadRecommend()
    }

    override func initSubviews() {
        super.initSubviews()

        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "hot_stocks")
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = .mediumFont16()
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(24)
        }

        view.addSubview(stockView)
        stockView.snp.makeConstraints { make in
            make.top.equalTo(62)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }

    private func loadRecommend() {
        recommendViewModel.loadRecommendCommand?.execute(nil).deliverOnMainThread().subscribeCompleted { [weak self] in
            self?.reloadData()
        }
    }

    override func preferredNavigationBarHidden() -> Bool {
        true
    }

    private func reloadData() {
        stockView.removeAllSubviews()

        for stock in recommendViewModel.stockList {
            let stockItemView = SearchRecommendStockItemView()
            stockItemView.bind(to: stock)
            stockItemView.didSelectStock = { [weak self] stock in
                guard let `self` = self, let stock = stock, !stock.symbol.isEmpty else {
                    return
                }

                let input = YXStockInputModel()
                input.market = stock.market
                input.symbol = stock.symbol
                input.name = stock.name
                YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [input], "selectIndex": 0])

                self.view?.trackViewClickEvent(customPageName: "Search_page", name: "Hot_stocks", other: ["stock_id" : stock.symbol])
            }
            stockView.addSubview(stockItemView)
        }

        var height: CGFloat = 0
        if recommendViewModel.stockList.count > 0 {
            height += 62
            height += stockView.sizeThatFits(CGSize(width: YXConstant.screenWidth - 32, height: CGFloat.greatestFiniteMagnitude)).height
        }

        self.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }

        self.view.isHidden = recommendViewModel.stockList.isEmpty
    }

}
