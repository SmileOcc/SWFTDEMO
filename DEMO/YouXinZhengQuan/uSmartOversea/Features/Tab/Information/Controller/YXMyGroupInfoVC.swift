//
//  YXMyGroupInfoVC.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMyGroupInfoVC: YXHKTableViewController, HUDViewModelBased {

    typealias ViewModelType = YXMyGroupInfoViewModel
    var viewModel: YXMyGroupInfoViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    let reuseIdentifier = "myGroupInfoVCCellIdentifier"
    var scrollCallback: YXTabPageScrollBlock?
    
    var addBtn: UIButton?
    
    lazy var optionlEmptyView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.tabBarHeight() - YXConstant.navBarHeight() - 60))
        view.backgroundColor = QMUITheme().foregroundColor()
        let imageView = UIImageView.init(image: UIImage(named: "empty_noData"))
        let label = UILabel.init(with: QMUITheme().textColorLevel3(), font: .systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "no_relevant_data"))
        let btn = UIButton.init()
        btn.setTitle(YXLanguageUtility.kLang(key: "add_opt_stocks"), for: .normal)
        btn.setDisabledTheme()
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 6
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(self.seachClick(_:)), for: .touchUpInside)
        self.addBtn = btn
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(btn)
        
        imageView.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }

        btn.snp.makeConstraints{ (make) in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.height.equalTo(48)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.bindModel()
        initUI()
        self.viewModel.loadDown()
    }
    
    func initUI() {

        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.estimatedRowHeight = 50
        tableView.register(YXInfomationCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.mj_header = YXRefreshHeader.init { [weak self] in
            self?.viewModel.loadDown()
        }
        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.viewModel.loadUp()
        })
        
        self.tableView.addSubview(self.optionlEmptyView)
    }

    func bindModel() {
        self.bindHUD()
        self.viewModel.loadDownSubject.subscribe(onNext: { [weak self] status in
            guard let `self` = self else { return }
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.resetNoMoreData()
            
            // 0 有数据正常  1 是无数据添加自选股  2 网络错误
            if let status = status as? Int {
                if status == 2 {
                    // 无网络d
                    if self.viewModel.list.count == 0 {
                        self.showErrorEmptyView()
                    }
                } else {
                    if self.viewModel.list.count == 0 {
                        // 无数据
                        self.optionlEmptyView.isHidden = false
                        if status == 1 {
                            self.addBtn?.isHidden = false
//                            self.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "no_optinal_goto"), false))
                        } else {
                            self.addBtn?.isHidden = true
                        }
                    } else {
                        self.optionlEmptyView.isHidden = true
                    }
                }
            }

            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.viewModel.loadUpSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            if list == nil {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer?.endRefreshing()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.viewModel.refreshSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            let cells = self.tableView.visibleCells
            for cell in cells {
                if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                    if let model = model.stocks?.first {
                        cell.updateRoc(with: model)
                    }
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    override func emptyRefreshButtonAction() {
        self.tableView.mj_header?.beginRefreshing()
    }
    
    @objc func seachClick(_ sender: UIButton) {
        if !YXUserManager.isLogin() {
            YXToolUtility.handleBusinessWithLogin {

            }
            return
        }
        self.viewModel.navigator.present(YXModulePaths.search.url, animated: false)
    }
}

// MARK: UITableViewDelegate
extension YXMyGroupInfoVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.list.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.qmui_heightForCell(withIdentifier: reuseIdentifier, cacheBy: indexPath, configuration: { [weak self] (tableCell) in
            guard let `self` = self else { return }
            if let cell = tableCell as? YXInfomationCell {
//                if indexPath.row == 0 {
//                    cell.type = 1
//                } else if indexPath.row == (self.viewModel.list.count - 1) {
//                    cell.type = 2
//                } else {
//                    cell.type = 0
//                }
                cell.stockArticleData = self.viewModel.list[indexPath.row]
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXInfomationCell
        let infoModel = self.viewModel.list[indexPath.row]
        // 添加newsId至曝光的新闻列表中
//        if let newsid = infoModel.newsid {
//            YXSensorsAnalyticsService.addExposeInfoId(newsid, algorithm: infoModel.alg ?? "undefined")
//        }
        cell.stockArticleData = infoModel
        
        cell.clickStockCallBack = { [weak self] model in
            if let market = model.market, let symbol = model.symbol {
                if let type2 = model.type2, type2 == 202 {
                    let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_DETAIL_PAGE_URL(market + symbol)]
                    self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                } else {

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = model.name ?? ""
                    self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = self.viewModel.list[indexPath.row]
        if !model.isRead {
            model.isRead = true
            // 保存状态
            if let newsId = model.newsid {
                YXTabInfomationTool.saveReadStatus(with: newsId)
            }
        }
        tableView.reloadRows(at: [indexPath], with: .none)
//        let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: [
//            "newsId" : model.newsid ?? "",
//            "type" : YXInfomationType.Normal,
//            "source" : YXPropInfoSourceValue.infoStock,
//            "newsTitle" : model.title ?? ""
//            ]))
//        self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
        
        let viewModel = YXImportantNewsDetailViewModel.init(services: self.viewModel.navigator, params: ["cid": model.newsid ?? ""])
        self.viewModel.navigator.push(viewModel, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = self.tableView.visibleCells
        var arr = [YXInfomationModel]()
        for cell in cells {
            if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                arr.append(model)
            }
        }
        // 刷新
        self.viewModel.loadQuota(with: arr)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cells = self.tableView.visibleCells
        var arr = [YXInfomationModel]()
        for cell in cells {
            if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                arr.append(model)
            }
        }
        // 刷新
        self.viewModel.loadQuota(with: arr)
    }
}




extension YXMyGroupInfoVC: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallback = callback
    }
}

extension YXMyGroupInfoVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}
