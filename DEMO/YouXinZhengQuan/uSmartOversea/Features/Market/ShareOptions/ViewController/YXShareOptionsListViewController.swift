//
//  YXShareOptionsListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//T型
class YXShareOptionsListViewController: YXTableViewController {
    
    var disposeBag = DisposeBag()
    
    var listViewModel: YXShareOptionsListViewModel {
        return self.viewModel as! YXShareOptionsListViewModel
    }
            
    var pollingTimer: Timer?
    
    var stockPriceCellIndexPath: IndexPath?
    
    // 是否自动滑动到股票现价处
    var shouldScrollToMiddle = true
    
    var isAutoScrolling = false
    
    lazy var callBgView: UIView = {
        return creatBGLabel(type: .call)
    }()
    
    lazy var putBgView: UIView = {
        return creatBGLabel(type: .put)
    }()
    
    func creatBGLabel(type: YXShareOptionsType) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.text = type.title
        label.textAlignment = .center
        label.backgroundColor = type == .call ? QMUITheme().stockRedColor() : QMUITheme().stockGreenColor()
        
        return label
    }
    
    lazy var scrollHeader: YXShareOptionsListScrollHeader = {
        let header = YXShareOptionsListScrollHeader.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 32))
        header.optionsType = self.listViewModel.optionsType
        header.scrollView.rx.contentOffset.filter({ [weak self](point) -> Bool in
            let value = try self?.listViewModel.contentOffset.value()
            return point != value
        }).bind(to: listViewModel.contentOffset).disposed(by: disposeBag)
        
        listViewModel.contentOffset.filter({ (point) -> Bool in
            return point != header.scrollView.contentOffset
        }).bind(to: header.scrollView.rx.contentOffset).disposed(by: disposeBag)
        
        header.scrollView2.rx.contentOffset.filter({ [weak self](point) -> Bool in
            let value = try self?.listViewModel.contentOffset2.value()
            return point != value
        }).bind(to: listViewModel.contentOffset2).disposed(by: disposeBag)
        
        listViewModel.contentOffset2.filter({ (point) -> Bool in
            return point != header.scrollView2.contentOffset
        }).bind(to: header.scrollView2.rx.contentOffset).disposed(by: disposeBag)
        
        listViewModel.contentOffset2.map({ (point) -> CGPoint in
            return CGPoint.init(x: (header.scrollView2.contentSize.width - header.scrollView2.frame.size.width - point.x), y: point.y)
        }).bind(to: header.scrollView.rx.contentOffset).disposed(by: disposeBag)
        
        listViewModel.contentOffset.map({ (point) -> CGPoint in
            return CGPoint.init(x: (header.scrollView2.contentSize.width - header.scrollView2.frame.size.width - point.x), y: point.y)
        }).bind(to: header.scrollView2.rx.contentOffset).disposed(by: disposeBag)
        
        return header
    }()
    
    lazy var header: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = QMUITheme().foregroundColor()
        
        if listViewModel.optionsType == .all {
            view.addSubview(callBgView)
            view.addSubview(putBgView)
            view.addSubview(scrollHeader)
            
            callBgView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(34)
                make.right.equalTo(view.snp.centerX)
            }
            
            putBgView.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
                make.top.equalTo(callBgView)
                make.height.equalTo(34)
                make.left.equalTo(view.snp.centerX)
            }
            
            scrollHeader.snp.makeConstraints { (make) in
                make.top.equalTo(callBgView.snp.bottom).offset(4)
                make.left.right.equalToSuperview()
                make.height.equalTo(38)
            }
            
        }else {
            view.addSubview(scrollHeader)
            
            scrollHeader.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(38)
            }
        }
        
        
        return view
    }()
    
    lazy var callPutHeader: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        view.backgroundColor = QMUITheme().foregroundColor()
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = listViewModel.optionsType.title
        let blueView = UIView()
        blueView.backgroundColor = QMUITheme().mainThemeColor()
        view.addSubview(blueView)
        view.addSubview(label)
        
        blueView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(12)
            make.top.equalToSuperview().offset(7)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(blueView)
        }
        return view
    }()
        
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
        
        self.tableView.register(YXShareOptionsListCell.self, forCellReuseIdentifier: NSStringFromClass(YXShareOptionsListCell.self))
        self.tableView.register(YXShareOptinosCurrentPriceCell.self, forCellReuseIdentifier: NSStringFromClass(YXShareOptinosCurrentPriceCell.self))
        self.tableView.register(YXShareOptionsCommonCell.self, forCellReuseIdentifier: NSStringFromClass(YXShareOptionsCommonCell.self))
        view.addSubview(header)
        let h = listViewModel.optionsType == .all ? 76 : 38
        header.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(h)
        }
        
        listViewModel.dataSoureSubject.subscribe(onNext: { [weak self]dataSource in
            if let vc = self?.parent as? YXShareOptionsViewController {
                vc.noOptionsView.isHidden = (dataSource.first?.count ?? 0) != 0
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let point = try? listViewModel.contentOffset.value() {
            listViewModel.contentOffset.onNext(point)
        }
        
        self.getData(showLoading: true)
        
        startPolling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPolling()
    }
    
    override func tableViewTop() -> CGFloat {
        if listViewModel.optionsType == .all {
            return 76
        }else {
            return 38
        }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXShareOptionsListCell.self), for: indexPath) as! YXShareOptionsListCell
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
        
        if cell.disposeBag != nil {
            cell.scrollView.rx.contentOffset.filter({ [weak self](point) -> Bool in
                let value = try self?.listViewModel.contentOffset.value()
                return point != value
            }).bind(to: listViewModel.contentOffset).disposed(by: cell.disposeBag!)

            listViewModel.contentOffset.filter({ [weak cell](point) -> Bool in
                point != cell?.scrollView.contentOffset
            }).bind(to: cell.scrollView.rx.contentOffset).disposed(by: cell.disposeBag!)
            
            cell.scrollView2.rx.contentOffset.filter({ [weak self](point) -> Bool in
                let value = try self?.listViewModel.contentOffset2.value()
                return point != value
            }).bind(to: listViewModel.contentOffset2).disposed(by: cell.disposeBag!)
            
            listViewModel.contentOffset2.filter({ [weak cell](point) -> Bool in
                return point != cell?.scrollView2.contentOffset
            }).bind(to: cell.scrollView2.rx.contentOffset).disposed(by: cell.disposeBag!)
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
//        if
//            let model = self.listViewModel.dataSource[indexPath.section][indexPath.row] as? [String: YXShareOptionsChainItem],
//            let item = model[listViewModel.optionsType.key],
//            let market = item.market,
//            let code = item.code {
//
//            let orderModel = YXTradeOrderModel()
//            orderModel.name = item.name
//            orderModel.symbol = code
//            orderModel.market = market
//
//            let viewModel = YXOptionTradeOrderViewModel.init(services: listViewModel.services,
//                                                             params: ["tradeModel": orderModel,
//                                                                      "tradeType": YXTradeType.normal.rawValue,
//                                                                      "limitType": YXTradeLimit.normal.rawValue])
//            listViewModel.services.push(viewModel, animated: true)
//        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let model = self.listViewModel.dataSource[indexPath.section][indexPath.row] as? String, model == "stockPrice" {
            return 20
        }
        
        return 38
        
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


extension YXShareOptionsListViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let parentVC = self.parent
        if !isAutoScrolling {
            if let vc = parentVC as? YXShareOptionsViewController {
                vc.listViewDidScrollCallback?(scrollView)
            }
        }
    }
}
