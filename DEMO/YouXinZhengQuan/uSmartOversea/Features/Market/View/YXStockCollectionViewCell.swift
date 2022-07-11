//
//  YXStockCollectionViewCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXStockCollectionViewCell: UICollectionViewCell, HasDisposeBag {
    
    lazy var simpleLineView: YXSimpleTimeLine = {
        YXSimpleTimeLine(frame: CGRect(x: 0, y: 0, width: 75, height: 30), market: YXMarketType.HK.rawValue)
    }()
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
    
    lazy var priceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var rocLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    var level: Int? {
        didSet {
            if let l = level, l == 0 {
                stockInfoView.delayLabel.isHidden = false
            }else {
                stockInfoView.delayLabel.isHidden = true
            }
        }
    }
    
    var info: YXMarketRankCodeListInfo? {
        didSet {
            stockInfoView.name = info?.chsNameAbbr ?? "--"
            stockInfoView.symbol = info?.secuCode ?? "--"
            stockInfoView.market = info?.trdMarket ?? "--"
            
            if let now = info?.latestPrice, let priceBase = info?.priceBase, now > 0 {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(now)/Double(pow(10.0, Double(priceBase))))
            } else {
                priceLabel.text = "--";
            }
            
            var op = ""
            if let roc = info?.pctChng, roc > 0 {
                op = "+"
                priceLabel.textColor = QMUITheme().stockRedColor()
                rocLabel.textColor = QMUITheme().stockRedColor()
            } else if let change = info?.netChng, change < 0 {
                priceLabel.textColor = QMUITheme().stockGreenColor()
                rocLabel.textColor = QMUITheme().stockGreenColor()
            } else {
                priceLabel.textColor = QMUITheme().stockGrayColor()
                rocLabel.textColor = QMUITheme().stockGrayColor()
            }
            
            rocLabel.text = op + String(format: "%.2f%%", Double(info?.pctChng ?? 0)/100.0)
        }
    }
    
    var timeLineData: YXBatchTimeLine? {
        didSet {
            simpleLineView.market = timeLineData?.market ?? ""
            simpleLineView.symbol = timeLineData?.symbol ?? ""

            let timeLineModel = YXTimeLineModel()
            timeLineModel.price_base = "\(timeLineData?.priceBase ?? 0)"
            timeLineModel.market = timeLineData?.market ?? ""
            timeLineModel.delay = timeLineData?.delay ?? true
            timeLineModel.type = timeLineData?.type ?? 0
            let timeLineList =  timeLineData?.data?.map({ (simpleTimeLine) -> YXTimeLineSingleModel in
                let singleModel = YXTimeLineSingleModel()
                singleModel.time = "\(simpleTimeLine.latestTime ?? 0)"
                singleModel.pclose = "\(simpleTimeLine.preClose ?? 0)"
                singleModel.price = "\(simpleTimeLine.price ?? 0)"
                return singleModel
            }) ?? []
            timeLineModel.list = NSMutableArray(array: timeLineList)

            simpleLineView.timeModel = timeLineModel
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(stockInfoView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(rocLabel)
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(priceLabel.snp.left).offset(-5)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-130)
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
        }
    
        rocLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(80)
            make.centerY.equalTo(priceLabel)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

