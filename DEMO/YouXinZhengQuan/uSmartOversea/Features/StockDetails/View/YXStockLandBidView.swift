//
//  YXStockLandBidView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit


class YXStockLandBidCell: UITableViewCell {
    
    lazy var titleLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "stock_detail_buy") + "1"
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = QMUITheme().textColorLevel2()
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    
    lazy var bidValueLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "0.000"
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()

    lazy var bidNumLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "0"
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        
//        bidView.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.02)
//        askView.backgroundColor = QMUITheme().financialRedColor().withAlphaComponent(0.02)
        
        self.selectionStyle = .none
        addSubview(titleLabel)
        addSubview(bidValueLabel)
        addSubview(bidNumLabel)

        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.lessThanOrEqualTo(bidValueLabel.snp.left).offset(-3)
        }
        
        bidValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(47)
        }
        
        bidNumLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
    }
}

class YXStockLandBidView: UIView {

    var list: [PosData]? {
        didSet {
            
            self.tableView.reloadData()
        }
    }

    var items: [BTOrderBookItem]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    var pClose: Double = 0
    var priceBase: Int = 0
    var decimalCount = 2
    
    var market: String = "hk"
    
    let tableView = UITableView.init(frame: .zero, style: .plain)

    convenience init(frame: CGRect,_ market: String) {
        self.init(frame: frame)
        initUI()
        self.market = market
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(YXStockLandBidCell.self, forCellReuseIdentifier: "YXStockLandBidCell")
        tableView.separatorStyle = .none
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension YXStockLandBidView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.market == kYXMarketCryptos {
            let count = self.items?.count ?? 1

            return count * 2
        } else {
            let count = self.list?.count ?? 1

            return count * 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: YXStockLandBidCell = tableView.dequeueReusableCell(withIdentifier: "YXStockLandBidCell") as! YXStockLandBidCell
        if self.market == kYXMarketCryptos {
            let count = self.items?.count ?? 0
            if count == 0 {
                if indexPath.row == 0 {
                    cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sale") + "1"
                    cell.bidNumLabel.text = "0"
                    cell.bidValueLabel.text = "--"
                } else {
                    cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy") + "1"
                    cell.bidNumLabel.text = "0"
                    cell.bidValueLabel.text = "--"
                }
            }
            if indexPath.row < count {

                let index = count - (indexPath.row + 1)
                // 卖
                let model = self.items?[index]
                cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sale") + "\(index + 1)"

                if let askSizeStr = model?.askVolume, let askSize = Double(askSizeStr),  askSize > 0 {

                    cell.bidNumLabel.text = YXToolUtility.btNumberString(askSizeStr, isVol: true)
                } else {
                    cell.bidNumLabel.text = "--"
                }

                if let askPriceStr = model?.askPrice, let askPrice = Double(askPriceStr), askPrice > 0 {
                    cell.bidValueLabel.text = YXToolUtility.btNumberString(askPriceStr, decimalPoint: 0)
                    if self.pClose > 0 {
                        cell.bidValueLabel.textColor = YXToolUtility.priceTextColor(Double(askPrice), comparedData: Double(self.pClose))
                    }
                } else {
                    cell.bidValueLabel.text = "--"
                }

            } else if indexPath.row < (count * 2) {
                let index = indexPath.row - count
                // 买
                let model = self.items?[index]
                cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy") + "\(index + 1)"

                if let bidSizeStr = model?.bidVolume, let bidSize = Double(bidSizeStr),  bidSize > 0 {

                    cell.bidNumLabel.text = YXToolUtility.btNumberString(bidSizeStr, isVol: true)
                } else {
                    cell.bidNumLabel.text = "--"
                }

                if let bidPriceStr = model?.bidPrice, let bidPrice = Double(bidPriceStr), bidPrice > 0 {
                    cell.bidValueLabel.text = YXToolUtility.btNumberString(bidPriceStr, decimalPoint: 0)
                    if self.pClose > 0 {
                        cell.bidValueLabel.textColor = YXToolUtility.priceTextColor(Double(bidPrice), comparedData: Double(self.pClose))
                    }
                } else {
                    cell.bidValueLabel.text = "--"
                }
            }
        } else {
            let count = self.list?.count ?? 0
            if count == 0 {
                if indexPath.row == 0 {
                    cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sale") + "1"
                    cell.bidNumLabel.text = "0"
                    cell.bidValueLabel.text = "--"
                } else {
                    cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy") + "1"
                    cell.bidNumLabel.text = "0"
                    cell.bidValueLabel.text = "--"
                }
            }
            if indexPath.row < count {

                let index = count - (indexPath.row + 1)
                // 卖
                let model = self.list?[index]
                cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sale") + "\(index + 1)"

                if let bidSize = model?.askSize?.value, bidSize > 0 {
                    cell.bidNumLabel.text = YXToolUtility.stockVolumeUnit(Int(bidSize))
                } else {
                    cell.bidNumLabel.text = "--"
                }

                let priceBase = self.priceBase
                if let askPrice = model?.askPrice?.value, askPrice > 0 {
                    cell.bidValueLabel.text = YXToolUtility.stockPriceData(Double(askPrice), deciPoint: priceBase, priceBase: priceBase)
                    if self.pClose > 0 {
                        cell.bidValueLabel.textColor = YXToolUtility.priceTextColor(Double(askPrice), comparedData: Double(self.pClose))
                    }
                } else {
                    cell.bidValueLabel.text = "--"
                }

            } else if indexPath.row < (count * 2) {
                let index = indexPath.row - count
                // 买
                let model = self.list?[index]
                cell.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy") + "\(index + 1)"
                if let bidSize = model?.bidSize?.value, bidSize > 0 {
                    cell.bidNumLabel.text = YXToolUtility.stockVolumeUnit(Int(bidSize))
                } else {
                    cell.bidNumLabel.text = "--"
                }


                if let askPrice = model?.bidPrice?.value, askPrice > 0 {
                    cell.bidValueLabel.text = YXToolUtility.stockPriceData(Double(askPrice), deciPoint: priceBase, priceBase: self.priceBase)
                    if self.pClose > 0 {
                        cell.bidValueLabel.textColor = YXToolUtility.priceTextColor(Double(askPrice), comparedData: Double(self.pClose))
                    }
                } else {
                    cell.bidValueLabel.text = "--"
                }
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        20
    }
    
    // 底部的view
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        UIView.init()
    }
    
}

