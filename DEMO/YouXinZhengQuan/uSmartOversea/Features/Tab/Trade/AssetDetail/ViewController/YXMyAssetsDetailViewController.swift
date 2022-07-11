//
//  YXMyAssetsDetailViewController.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXMyAssetsDetailViewController: YXHKViewController, ViewModelBased {

    var viewModel: YXMyAssetsDetailViewModel!

    private lazy var menuView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXMyAssetsDetailMode.category.title, YXMyAssetsDetailMode.market.title])
        view.tapAction = { [weak self] index in
            guard let `self` = self else { return }
            if index == 0 {
                self.viewModel.mode = .category
            } else {
                self.viewModel.mode = .market
            }
            self.reloadData()
        }
        return view
    }()

    private lazy var tableView: QMUITableView = {
        let view = QMUITableView(frame: .zero, style: .plain)
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#101014")
        view.dataSource = self
        view.delegate = self
        view.separatorStyle = .none
        view.register(YXMyAssetsDetailViaCategoryCell.self, forCellReuseIdentifier: NSStringFromClass(YXMyAssetsDetailViaCategoryCell.self))
        view.register(YXMyAssetsDetailViaMarketCell.self, forCellReuseIdentifier: NSStringFromClass(YXMyAssetsDetailViaMarketCell.self))
        return view
    }()

    private lazy var headerView: YXMyAssetsDetailStatisticsView = {
        let view = YXMyAssetsDetailStatisticsView()

        view.didChoose = { [weak self] moneyType in
            self?.viewModel.moneyType = moneyType
            self?.fetchData()
        }

        view.contentHeightDidChangeBlock = { [weak self] height in
            guard let `self` = self else { return }
            self.headerView.bounds = CGRectMakeWithSize(CGSize(width: self.tableView.width, height: height))
            self.tableView.tableHeaderView = self.headerView
        }

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = YXLanguageUtility.kLang(key: "my_assets")

        self.showEmptyViewWithLoading()
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.bounds = CGRectMakeWithSize(CGSize(width: tableView.width, height: headerView.contentHeight))
        tableView.tableHeaderView = headerView
    }

    override func initSubviews() {
        super.initSubviews()

        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(30)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.bottom).offset(0)
            make.left.right.bottom.equalToSuperview()
        }

        let refreshHeader = YXRefreshHeader()
        refreshHeader.refreshingBlock = { [weak self] in
            self?.fetchData()
        }
        tableView.mj_header = refreshHeader
    }

    override func setupNavigationItems() {
        super.setupNavigationItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "icon_tips"),
            style: .plain,
            target: self,
            action: #selector(clickInfoButton)
        )
    }
    
    private func fetchData() {
        Single.zip(
            viewModel.fetchMyAssetsDetail(for: .category),
            viewModel.fetchMyAssetsDetail(for: .market)
        ).subscribe(onSuccess: { [weak self] (_, _) in
            self?.tableView.mj_header.endRefreshing()
            self?.hideEmptyView()
            self?.reloadData()
        }, onError: { [weak self] error in
            self?.tableView.mj_header.endRefreshing()
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                self?.showNoNetworkEmptyView()
            } else {
                self?.showErrorEmptyView()
            }
        }).disposed(by: rx.disposeBag)

        viewModel.getExchangeRateList().subscribe(onSuccess: { [weak self] exchangeRateList in
            self?.headerView.exchangeRateList = exchangeRateList?.map({ model in
                let cellVM = YXMoneyTypeSelectionCellViewModel(model: model)
                return cellVM
            })
        }).disposed(by: rx.disposeBag)
    }

    private func reloadData() {
        self.headerView.bind(to: self.viewModel.assetsDetailModel)
        self.tableView.reloadData()
    }

    @objc private func clickInfoButton() {
        YXWebViewModel.pushToWebVC(YXH5Urls.netAssetsDescURL())
    }

    override func emptyRefreshButtonAction() {
        self.showEmptyViewWithLoading()
        fetchData()
    }
}

extension YXMyAssetsDetailViewController: QMUITableViewDataSource, QMUITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.assetDetailList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.viewModel.assetDetailList[indexPath.row]

        if let model = model as? YXMyAssetsDetailViaCategroyListItem {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(YXMyAssetsDetailViaCategoryCell.self)
            ) as! YXMyAssetsDetailViaCategoryCell
            cell.bind(to: model)
            return cell
        } else if let model = model as? YXMyAssetsDetailViaMarketListItem  {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(YXMyAssetsDetailViaMarketCell.self)
            ) as! YXMyAssetsDetailViaMarketCell
            cell.bind(to: model)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.viewModel.assetDetailList[indexPath.row]

        if let model = model as? YXMyAssetsDetailViaCategroyListItem {
            if model.assetKind == .option {
                return 120
            }
            return 185
        } else if model is YXMyAssetsDetailViaMarketListItem  {
            return 135
        }

        return 0
    }

}
