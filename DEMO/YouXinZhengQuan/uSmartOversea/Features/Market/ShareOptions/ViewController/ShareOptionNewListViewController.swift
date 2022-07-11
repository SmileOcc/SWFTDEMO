//
//  File.swift
//  uSmartOversea
//
//  Created by lennon on 2022/6/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//列表
class ShareOptionNewListViewController: YXTableViewController {
    
    var disposeBag = DisposeBag()
    
    var market: String = ""
    var symbol: String = ""
    
    var listViewModel: YXShareOptionsListViewModel {
        return self.viewModel as! YXShareOptionsListViewModel
    }
    
    var pollingTimer: Timer?
    
    var stockPriceCellIndexPath: IndexPath?
    
    // 是否自动滑动到股票现价处
    var shouldScrollToMiddle = true
    
    var isAutoScrolling = false

    
    func startPolling() {
        let rankInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.rankFreq))
        pollingTimer = Timer.scheduledTimer(timeInterval: rankInterval, target: self, selector: #selector(pollingData), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    deinit {
        stopPolling()
    }
    
    func getData(showLoading: Bool) {
        listViewModel.showLoading = showLoading
        loadFirstPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        self.tableView.register(ShareOptionNewListCell.self, forCellReuseIdentifier: NSStringFromClass(ShareOptionNewListCell.self))
        self.tableView.register(YXShareOptinosCurrentPriceCell.self, forCellReuseIdentifier: NSStringFromClass(YXShareOptinosCurrentPriceCell.self))

        listViewModel.dataSoureSubject.subscribe(onNext: { [weak self]dataSource in
            if let vc = self?.parent as? YXShareOptionsViewController {
                vc.noOptionsView.isHidden = (dataSource.first?.count ?? 0) != 0
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getData(showLoading: true)
        
        startPolling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPolling()
    }
    
    override func tableViewTop() -> CGFloat {
        return 0
    }
    
    override func reloadData() {
        super.reloadData()
        if shouldScrollToMiddle, listViewModel.stockPriceIndex > 0, listViewModel.stockPriceIndex < (listViewModel.dataSource?.first?.count ?? 0) {
           
            let indexPath = IndexPath.init(row: listViewModel.stockPriceIndex, section: 0)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.isAutoScrolling = true
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.isAutoScrolling = false
                }
            }
            shouldScrollToMiddle = false
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let model = self.listViewModel.dataSource[indexPath.section][indexPath.row] as? String, model == "stockPrice" {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXShareOptinosCurrentPriceCell.self), for: indexPath) as! YXShareOptinosCurrentPriceCell
            let op = listViewModel.stockChange > 0 ? "+" : ""
            let priceStr = String(format: "%.3lf", listViewModel.stockPrice)
            let changeStr = op + String(format: "%.3lf", listViewModel.stockChange)
            let rocStr = op + String(format: "%.2lf%%", listViewModel.stockRoc)
            cell.label.text = String(format: "%@：%@ %@ %@", YXLanguageUtility.kLang(key: "hold_share_price"), priceStr, changeStr, rocStr)
            var color: UIColor
            if listViewModel.stockChange > 0 {
                color = QMUITheme().stockRedColor()
            }else if listViewModel.stockChange < 0 {
                color = QMUITheme().stockGreenColor()
            }else {
                color = QMUITheme().stockGrayColor()
            }
            cell.label.textColor = color
            cell.backgroundColor = color.withAlphaComponent(0.1)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ShareOptionNewListCell.self), for: indexPath) as! ShareOptionNewListCell
        cell.optionsType = self.listViewModel.optionsType
        cell.stockPrice = self.listViewModel.stockPrice
        cell.disposeBag = DisposeBag()
        if let model = self.listViewModel.dataSource[indexPath.section][indexPath.row] as? [String: YXShareOptionsChainItem] {
            if let callItem = model["callItem"], let putItem = model["putItem"], self.listViewModel.optionsType == .all {
                cell.items = [callItem, putItem]
            } else if let callItem = model["callItem"], self.listViewModel.optionsType == .call {
                cell.items = [callItem]
            } else if let putItem = model["putItem"], self.listViewModel.optionsType == .put {
                cell.items = [putItem]
            }
        }


        if let action = listViewModel.tapCellAction {
            cell.tapCellAction = action
        } else {
            cell.tapCellAction = { [weak self](market, symbol) in
                guard let `self` = self else { return }
                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = ""
                let stockCode = self.listViewModel.market + self.listViewModel.symbol
                let option_code = market + symbol
                self.trackViewClickEvent(name: "us option_item", other: ["option_code": option_code, "stock_code": stockCode])
                if self.listViewModel.isLandscape {
                    self.listViewModel.services.pushPath(.landStockDetail, context: ["dataSource": [input], "selectIndex":  0], animated: true)
                }else {
                    self.listViewModel.services.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex":  0], animated: true)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let model = self.listViewModel.dataSource[indexPath.section][indexPath.row] as? String, model == "stockPrice" {
            return 20
        }
        
        if listViewModel.optionsType == .all {
            return 295
        }else {
            return 122
        }
    }
    
    override func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let str = YXLanguageUtility.kLang(key:"common_no_data")//"暂无数据"
//        return NSAttributedString.init(string: str, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel3()])
        return NSAttributedString()
    }

    override func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        UIImage(.init(named: "empty_noData"))
        return nil
    }
    
    override func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString()
    }
    
    @objc func pollingData() {
        
        if self.listViewModel.stockPrice > 0 {
            getData(showLoading: false)
        }
    }
    
    override func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        let shouldDisplay = super.emptyDataSetShouldDisplay(scrollView)
        return shouldDisplay && listViewModel.stockPrice > 0
    }
}


extension ShareOptionNewListViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let parentVC = self.parent
        if !isAutoScrolling {
            if let vc = parentVC as? YXShareOptionsViewController {
                vc.listViewDidScrollCallback?(scrollView)
            }
            
        }
    }
}

