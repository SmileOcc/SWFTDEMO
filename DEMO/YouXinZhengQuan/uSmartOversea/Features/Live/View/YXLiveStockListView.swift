//
//  YXLiveStockListView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

class YXLiveStockListView: UIControl {
    
    var stockIdList: [String] = [] {

        didSet {
            var tableViewHeight = 72 * stockIdList.count + 16 + 20
            if tableViewHeight > 396 {
                tableViewHeight = 396
            }
            stockTableView.snp.updateConstraints { (make) in
                make.height.equalTo(tableViewHeight)
            }
            if oldValue != stockIdList {
                requestStockQuote()
            }
            
        }
    }
    
    var quoteLists: [YXV2Quote] = [] {
        didSet {
            stockTableView.reloadData()
        }
    }
    
    lazy var stockTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 16))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 16))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 20))
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 12
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(YXLiveStockListCell.self, forCellReuseIdentifier: "YXLiveStockListCell")

        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stockTableView)
        
        stockTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(36)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestStockQuote() {
        let secus = stockIdList.reversed().map { (string) -> Secu in
            let secuId = YXSecuID(string: string)
            return Secu(market: secuId.market, symbol: secuId.symbol)
        }
        self.quoteLists = secus.map({ (secu) -> YXV2Quote in
            let quote = YXV2Quote()
            quote.market = secu.market
            quote.symbol = secu.symbol
            return quote
        })
        let levelSecus = LevelSecus(secus: secus)
        
        for index in 0...3 {
            var array: [Secu] = []
            var level: QuoteLevel = .delay
            switch index {
            case 0:
                array = levelSecus.delay
                level = .delay
            case 1:
                array = levelSecus.bmp
                level = .bmp
            case 2:
                array = levelSecus.level1
                level = .level1
            case 3:
                array = levelSecus.level2
                level = .level2
            default:
                break
            }
            
            if array.count > 0 {

                YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: array, level: level, handler: ({ [weak self] (quotes, scheme) in
                    guard let strongSelf = self else { return }
                    
                    quotes.forEach { (quote) in
                        for (index, item) in strongSelf.quoteLists.enumerated() {
                            if item.market == quote.market, item.symbol == quote.symbol {
                                strongSelf.quoteLists[index] = quote
                                break
                            }
                        }
                    }
                    
                    strongSelf.stockTableView.reloadData()
                }))
            }
        }
    }
    
}

extension YXLiveStockListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quoteLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXLiveStockListCell", for: indexPath) as! YXLiveStockListCell
        cell.quote = quoteLists[indexPath.row]
        cell.indexLabel.text = "\(quoteLists.count - indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quote = quoteLists[indexPath.row]
        if let symbol = quote.symbol, let market = quote.market {
            if let currentViewController = UIViewController.current() as? YXWatchLiveViewController {
                YXFloatingView.shared().sourceViewController = currentViewController
                currentViewController.showFloatingView()

                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = quote.name
                
                currentViewController.viewModel.services.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex":  0], animated: true)
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

