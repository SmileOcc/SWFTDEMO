//
//  YXStockDetailNewsVC.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/7/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import JXPagingView

class YXStockDetailNewsVC: YXHKTableViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockDetailNewsViewModel! = YXStockDetailNewsViewModel()
    let reuseIdentifier = "newsInfosCellIdentifier"
    var isLoaded = false
    //0: 全部, 1: 中文, 3: 英文 修改这里的顺序要注意 tabView的defaultSelectedIndex要对应上
    let articleInfoAPILangTypeArr = [YXArticleInfoAPILangType.ALL, YXArticleInfoAPILangType.CN, YXArticleInfoAPILangType.EN]
    override var emptyViewOffset: CGFloat {
        80
    }
    
    lazy var typeView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXArticleInfoAPILangType.ALL.articleInfoAPILangTypeName, YXArticleInfoAPILangType.CN.articleInfoAPILangTypeName, YXArticleInfoAPILangType.EN.articleInfoAPILangTypeName])
        view.tapAction = {
            [weak self] index in
            guard let `self` = self else { return }
            self.tableView.scrollToTop()
            YXStockDetailViewModel.stockDetailTab = Int(index)
            self.viewModel.lang = self.articleInfoAPILangTypeArr[Int(index)].rawValue;
            self.networkingHUD.showLoading("", in: self.view)
            self.viewModel.loadDown()
        }

        return view
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindModel()
        isLoaded = true
        initUI()
        initCurrentLanguageType()
        self.networkingHUD.showLoading("", in: self.view)
        refreshControllerData()
    }
    
    func initCurrentLanguageType() {
        if YXUserManager.isENMode() {
            self.viewModel.lang = YXArticleInfoAPILangType.EN.rawValue;
            self.typeView.resetSelectIndex(2)
        } else {
            self.viewModel.lang = YXArticleInfoAPILangType.CN.rawValue;
            self.typeView.resetSelectIndex(1)
        }
        if YXStockDetailViewModel.stockDetailTab >= 0 {
            self.typeView.resetSelectIndex(Int(YXStockDetailViewModel.stockDetailTab));
            self.viewModel.lang = self.articleInfoAPILangTypeArr[Int(YXStockDetailViewModel.stockDetailTab)].rawValue;
        }

    }

    @objc func refreshControllerData() {
        if isLoaded {
            self.viewModel.loadDown()
        }
    }
    
    func initUI() {
        title = YXLanguageUtility.kLang(key: "stock_detail_all_news")
        tableView.separatorStyle = .none
        self.view.backgroundColor = QMUITheme().foregroundColor()
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.estimatedRowHeight = 50
        tableView.register(YXStockDetailArticleCell.self, forCellReuseIdentifier: reuseIdentifier)

        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.viewModel.loadUp()
        })
        
        self.view.addSubview(typeView)

        typeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(typeView.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }
        //self.tableView.mj_header.beginRefreshing()
    }
    
    override func layoutTableView() {
        
    }
    
    override func jx_refreshData() {
        self.viewModel.loadDown()
    }
    
    func bindModel() {
        self.viewModel.loadDownSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            self.endRefreshCallBack?()
            self.networkingHUD.hide(animated: true)
            self.tableView.mj_footer?.resetNoMoreData()
            if list == nil {
                // 无网络d
                self.showErrorEmptyView()
            } else {
                if self.viewModel.list.count == 0 {
                    // 无数据
                    self.showNoDataEmptyView()
                } else {
                    self.hideEmptyView()
                }
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.viewModel.loadUpSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            if list == nil {
                if self.viewModel.list.count > 0 {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer?.removeFromSuperview()
                    self.tableView.mj_footer = nil
                }
            } else {
                self.tableView.mj_footer?.endRefreshing()
            }
            if self.viewModel.list.count == 0 {
                // 无数据
                self.showNoDataEmptyView()
            } else {
                self.hideEmptyView()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    override func emptyRefreshButtonAction() {
        self.viewModel.loadDown()
    }
}

// MARK: UITableViewDelegate
extension YXStockDetailNewsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.list.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        tableView.qmui_heightForCell(withIdentifier: reuseIdentifier, cacheBy: indexPath, configuration: { [weak self] (tableCell) in
            guard let `self` = self else { return }
            if let cell = tableCell as? YXStockDetailArticleCell {
                cell.stockArticleData = self.viewModel.list[indexPath.row]
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXStockDetailArticleCell
        cell.stockArticleData = self.viewModel.list[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = self.viewModel.list[indexPath.row]
//        let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: [
//            "newsId" : model.newsId ?? "",
//            "type" : YXInfomationType.Normal,
//            "source" : YXPropInfoSourceValue.infoStock,
//            "newsTitle" : model.title ?? ""
//            ]))
//        self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
//
//
        let viewModel = YXImportantNewsDetailViewModel.init(services: self.viewModel.navigator, params: ["cid": model.newsId ?? ""])
        self.viewModel.navigator.push(viewModel, animated: true)
    }
}



extension YXStockDetailNewsVC: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.tableView }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
    
    
}
