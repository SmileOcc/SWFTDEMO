//
//  YXAllDayInfoVC.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXAllDayInfoVC: YXHKTableViewController, HUDViewModelBased  {

    typealias ViewModelType = YXAllDayInfoViewModel
    var viewModel: YXAllDayInfoViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    let reuseIdentifier = "allDayCellIdentifier"
    var scrollCallback: YXTabPageScrollBlock?
    
    lazy var shadowView: YXStockCornerShadowView = {
        let bgView = YXStockCornerShadowView.init()
        bgView.topLeft = true
        bgView.topRight = true
//        bgView.bottomLeft = true
//        bgView.bottomRight = true
        bgView.cornerRadius = 8
        bgView.shadowColor = QMUITheme().separatorLineColor()
        bgView.shadowOffset = CGSize.init(width: 0, height: -2)
        bgView.shadowRadius = 20
        bgView.margins = UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
        return bgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.bindModel()
        initUI()
        self.viewModel.loadDown()
    }
    
    let sectionLabel = UILabel.init(with: .black, font: .systemFont(ofSize: 14), text: "")
    
    func initUI() {
        
        view.insertSubview(shadowView, at: 0)
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.estimatedRowHeight = 100

        tableView.register(YXAllDayInfoCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.mj_header = YXRefreshHeader.init { [weak self] in
            self?.viewModel.loadDown()
        }
        
        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.viewModel.loadUp()
        })
        
//        self.tableView.mj_header.beginRefreshing()
        
    }
    
    override func layoutTableView() {
        tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(20)
        }
    }
    
    override func emptyRefreshButtonAction() {
        self.tableView.mj_header?.beginRefreshing()
    }
    
    func bindModel() {
        
        self.bindHUD()
        
        self.viewModel.loadDownSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.resetNoMoreData()
            if list == nil {
                // 无网络d
                if self.viewModel.list.count == 0 {
                    self.showErrorEmptyView()
                }
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
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer?.endRefreshing()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.viewModel.refreshSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

// MARK: UITableViewDelegate
extension YXAllDayInfoVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.list.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.qmui_heightForCell(withIdentifier: reuseIdentifier, cacheBy: indexPath, configuration: { [weak self] (tableCell) in
            guard let `self` = self else { return }
            if let cell = tableCell as? YXAllDayInfoCell {
                cell.model = self.viewModel.list[indexPath.row]
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth - 36, height: 50))
        view.backgroundColor = QMUITheme().foregroundColor()
        sectionLabel.frame = CGRect.init(x: 15, y: 15, width: YXConstant.screenWidth - 36 - 15, height: 30)
        sectionLabel.removeFromSuperview()
        view.addSubview(sectionLabel)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXAllDayInfoCell
        cell.backgroundColor = QMUITheme().foregroundColor()
        cell.model = self.viewModel.list[indexPath.row]
        cell.showDataSource(with: indexPath.row == 0)
        cell.clickStockCallBack = { [weak self] model in
            
            if let market = model.market, let symbol = model.symbol {

                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = model.name ?? ""
                self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.viewModel.list[indexPath.row]
        model.isShow = !model.isShow
        if !model.isShow {
            model.isRead = true
//            if !model.isRead { // 没newsid
//                model.isRead = true
//                // 保存状态
//                if let newsId = model.newsid {
//                    YXTabInfomationTool.saveReadStatus(with: newsId)
//                }
//            }
        }
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? YXAllDayInfoCell {
            if let time = cell.model?.releaseTime {
                sectionLabel.text = YXDateHelper.dateSting(from: TimeInterval(time), formatterStyle: .scaleDay)
            }
        }
    }
}


extension YXAllDayInfoVC: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallback = callback
    }
}

extension YXAllDayInfoVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}
