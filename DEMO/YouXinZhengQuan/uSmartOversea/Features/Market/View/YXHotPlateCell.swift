//
//  YXHotPlateCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXTopIndustryScrollCell: UICollectionViewCell {
    
    var didTapAction: ((_ market: String, _ symbol: String, _ name:String) -> Void)?
    
    var datas: [YXMarketRankCodeListInfo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = QMUITheme().foregroundColor()
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        }
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.alwaysBounceHorizontal = true
//        collectionView.alwaysBounceVertical = false
        collectionView.register(YXHotPlateCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXHotPlateCell.self))
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXTopIndustryScrollCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHotPlateCell.self), for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = datas[indexPath.item]
        let cell = cell as! YXHotPlateCell
        cell.info = item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = datas[indexPath.item]
        if let market = item.trdMarket, let symbol = item.yxCode {
            self.didTapAction?(market, symbol,item.chsNameAbbr ?? "")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 160)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
}

class YXHotPlateCell: UICollectionViewCell, HasDisposeBag {
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.8
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center;
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var stockRocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    var info: YXMarketRankCodeListInfo? {
        didSet {
            updateInfo()
        }
    }
    
    var leadStockInfo: YXMarketRankCodeListInfo? {
        didSet {
            if let stock = leadStockInfo {
                if let stockName = stock.chsNameAbbr {
                    stockNameLabel.text = stockName
                }
                
                var color = QMUITheme().stockGrayColor()
                if let stockRoc = stock.pctChng {
                    var op = ""
                    if stockRoc > 0 {
                        op = "+"
                        color = QMUITheme().stockRedColor()
                    }else if stockRoc < 0 {
                        color = QMUITheme().stockGreenColor()
                    }
                    
                    stockRocLabel.textColor = color
                    stockRocLabel.text = op + String(format: "%.2f%%", Double(Double(stockRoc))/100.0)
                    priceLabel.textColor = stockRocLabel.textColor
                }
                
                if let stockPrice = stock.latestPrice, let priceBase = stock.priceBase {
                    priceLabel.text = String(format: "%.\(priceBase)f", Double(stockPrice)/pow(10.0, Double(priceBase)))
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().blockColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateInfo() {
        if let name = info?.chsNameAbbr {
            titleLabel.text = name
        }else {
            titleLabel.text = "--"
        }
        
        if let roc = info?.pctChng {
            var op = ""
            
            rocLabel.textColor = QMUITheme().stockGrayColor()
            if roc > 0 {
                op = "+"
                rocLabel.textColor = QMUITheme().stockRedColor()
            } else if roc < 0 {
                rocLabel.textColor = QMUITheme().stockGreenColor()
            }
            rocLabel.text = op + String(format: "%.2f%%", Double(Double(roc)/100.0))
        }
        
        if let stock = info?.leadStock {
            if let stockName = stock.chsNameAbbr {
                stockNameLabel.text = stockName
            }
            
            var color = QMUITheme().stockGrayColor()
            if let stockRoc = stock.pctChng {
                var op = ""
                if stockRoc > 0 {
                    op = "+"
                    color = QMUITheme().stockRedColor()
                }else if stockRoc < 0 {
                    color = QMUITheme().stockGreenColor()
                }
                
                stockRocLabel.textColor = color
                stockRocLabel.text = op + String(format: "%.2f%%", Double(Double(stockRoc))/100.0)
                priceLabel.textColor = stockRocLabel.textColor
            }
            
            if let stockPrice = stock.latestPrice, let priceBase = stock.priceBase {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(stockPrice)/pow(10.0, Double(priceBase)))
            }
        }
    }
    
    fileprivate func initializeViews() {
        
//        let stackView = UIStackView.init(arrangedSubviews: [priceLabel, stockRocLabel])
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(rocLabel)
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(stockRocLabel)
        
//        contentView.addSubview(stackView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview()
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(61)
            make.left.equalTo(titleLabel)
        }
        
        stockNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rocLabel.snp.bottom).offset(24)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
        
        stockRocLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(stockNameLabel.snp.bottom).offset(8)
            make.right.equalToSuperview()
        }
        
//        stackView.snp.makeConstraints { (make) in
//            make.top.equalTo(stockNameLabel.snp.bottom).offset(2)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(titleLabel)
//            make.height.equalTo(15)
//        }
    }
    
    
}


class YXETFCollectionViewCell: UICollectionViewCell {
    
    lazy var hotPlateView: YXHotPlateCell = {
        let view = YXHotPlateCell()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 0
        view.stockNameLabel.font = .systemFont(ofSize: 12)
        view.stockRocLabel.font = .systemFont(ofSize: 12)
        
        view.titleLabel.snp.updateConstraints { (make) in
            make.top.equalTo(0)
        }
        view.rocLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(23)
        }
        
        view.stockRocLabel.snp.updateConstraints { (make) in
            make.top.equalTo(view.stockNameLabel.snp.bottom).offset(3)
        }
        
        return view
    }()
    
    lazy var line: UIView = {
        return UIView.line()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hotPlateView.isUserInteractionEnabled = false
        
        addSubview(hotPlateView)
        addSubview(line)
        hotPlateView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0.5)
            make.right.equalToSuperview().offset(-1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
