//
//  YXMarketETFCellCollectionViewCell.swift
//  uSmartOversea
//
//  Created by ysx on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SDCycleScrollView
import FLAnimatedImage


class YXMarketETFSubCell: UIView {
    typealias ClosureClick = () -> Void
    @objc var onClick: ClosureClick?
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3 //12.0 / 14.0
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3

        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()

    
    var secu: YXV2Quote? {
        didSet {
            update()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeViews() {
        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(rocLabel)

        let tap = UITapGestureRecognizer()
        tap.addActionBlock { [weak self] _ in
            self?.onClick?()
        }
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.height.equalTo(19)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2);
            make.left.height.equalTo(nameLabel)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.right.equalTo(-10)
            make.centerY.equalTo(nameLabel)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right).offset(5)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.height.equalTo(14)
            make.centerY.equalTo(priceLabel)
            make.left.greaterThanOrEqualTo(priceLabel.snp.right).offset(5)
        }

    }
    
    func update() {
        if let secuObject = secu {
            var indexName = "--"
            switch secuObject.symbol {
            case "HSI":
                indexName = YXMarketIndex.HSI.rawValue
            case "HSCEI":
                indexName = YXMarketIndex.HSCEI.rawValue
            case "HSTECH":
                indexName = YXMarketIndex.HSTECH.rawValue
            case "HSCCI":
                indexName = YXMarketIndex.HSCCI.rawValue
            case "SPHKGEM":
                indexName = YXMarketIndex.SPHKGEM.rawValue
            case "VHSI":
                indexName = YXMarketIndex.VHSI.rawValue
            case "DIA":
                indexName = YXMarketIndex.DIA.rawValue
            case "QQQ":
                indexName = YXMarketIndex.QQQ.rawValue
            case "SPY":
                indexName = YXMarketIndex.SPY.rawValue
            case "000001":
                indexName = YXMarketIndex.HSSSE.rawValue
            case "399001":
                indexName = YXMarketIndex.HSSZSE.rawValue
            case "399006":
                indexName = YXMarketIndex.HSGEM.rawValue
            default:
                indexName =  "--"
            }
            
            nameLabel.text = secuObject.symbol ?? indexName
            var op = ""
            if let value = secuObject.netchng?.value, value > 0 {
                op = "+"
                priceLabel.textColor = QMUITheme().stockRedColor()
                changeLabel.textColor = QMUITheme().stockRedColor()
                rocLabel.textColor = QMUITheme().stockRedColor()

            } else if let value = secuObject.netchng?.value, value < 0 {
                priceLabel.textColor = QMUITheme().stockGreenColor()
                changeLabel.textColor = QMUITheme().stockGreenColor()
                rocLabel.textColor = QMUITheme().stockGreenColor()

            
            } else {
                priceLabel.textColor = QMUITheme().stockGrayColor()
                changeLabel.textColor = QMUITheme().stockGrayColor()
                rocLabel.textColor = QMUITheme().stockGrayColor()
            }
            
            if let priceBase = secuObject.priceBase?.value, let value = secuObject.latestPrice?.value, value > 0 {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(value)/pow(10.0, Double(priceBase)))
            } else {
                priceLabel.text = "--";
            }
            
            if let priceBase = secuObject.priceBase?.value, let change = secuObject.netchng?.value {
                changeLabel.text = op + String(format: "%.\(priceBase)f", Double(change)/pow(10.0, Double(priceBase)))
            }
            
            if let roc = secuObject.pctchng?.value {
                rocLabel.text = op + String(format: "%.2f%%", Double(roc)/100.0)
            }
            
        }
    }
}

class YXMarketETFCell: UICollectionViewCell{
    typealias ClosureIndexPath = (_ indexPath: Int) -> Void
    @objc var onClickIndexPath: ClosureIndexPath?
    var selectedIndex : Int = 0
    
    var disposeBag: DisposeBag? = DisposeBag()
    
    var dataSource: [YXV2Quote] = [YXV2Quote]() {
        didSet {
            if dataSource.count == 3 {
                self.leftView.secu = dataSource[0]
                self.rightTopView.secu = dataSource[1]
                self.rightBottomView.secu = dataSource[2]
            }else {
                
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftView :YXMarketETFSubCell = {
        let view = YXMarketETFSubCell()
        view.onClick = { [weak self]  in
            self?.onClickIndexPath?(0)
        }
        return view
    }()
    
    lazy var rightTopView :YXMarketETFSubCell = {
        let view = YXMarketETFSubCell()
        view.onClick = { [weak self]  in
            self?.onClickIndexPath?(1)
        }
        return view
    }()
    
    lazy var rightBottomView :YXMarketETFSubCell = {
        let view = YXMarketETFSubCell()
        view.onClick = { [weak self]  in
            self?.onClickIndexPath?(2)
        }
        return view
    }()
    
    
    lazy var simpleLineView: YXSimpleTimeLine = {
        let view = YXSimpleTimeLine(frame: CGRect(x: 12, y: 69, width: YXConstant.screenWidth-36, height: 40), market: YXMarketType.US.rawValue)
//        _ = view.rx.tapGesture().skip(1).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](_) in
//            if let action = self?.onClickTimeLineView {
//                if let selectedIndex = self?.selectedIndex {
//                    action(selectedIndex)
//                }
//            }
//        })
        
        view.enableLongPress = false
        
        return view
    }()
    
    var timeLineData: YXTimeLineData? {
        didSet {
            if oldValue?.market == timeLineData?.market, oldValue?.symbol == timeLineData?.symbol, oldValue?.list?.count == timeLineData?.list?.count{
                return
            }

            simpleLineView.market = timeLineData?.market ?? ""
            //simpleLineView.symbol = timeLineData?.symbol ?? ""
            if self.selectedIndex < self.dataSource.count {
                simpleLineView.quote = self.dataSource[self.selectedIndex]
            }
            simpleLineView.quote = self.dataSource[0]
            
            
            let timeLineModel = YXTimeLineModel()
            timeLineModel.price_base = "\(timeLineData?.priceBase?.value ?? 0)"
            timeLineModel.market = timeLineData?.market ?? ""
            timeLineModel.type = Int(timeLineData?.type?.value ?? 0)
            
            let priceBase = timeLineModel.price_base
            
            let timeLineList =  timeLineData?.list?.map({ (simpleTimeLine) -> YXTimeLineSingleModel in
                let singleModel = YXTimeLineSingleModel()
                singleModel.pclose = "\(simpleTimeLine.preClose?.value ?? 0)"
                singleModel.price = "\(simpleTimeLine.price?.value ?? 0)"
                singleModel.priceBase = priceBase
                singleModel.time = "\(simpleTimeLine.latestTime?.value ?? 0)"
                return singleModel
            }) ?? []
            
            timeLineModel.list = NSMutableArray(array: timeLineList)
        
            simpleLineView.dashPointCount = 0
            simpleLineView.timeModel = timeLineModel
        }
    }
    
    func initializeViews()  {
        let leftCardView = cardView()
        leftCardView.addSubview(leftView)
        leftCardView.addSubview(simpleLineView)
        contentView.addSubview(leftCardView)
        
        
        let rightCardView = cardView()
        rightCardView.addSubview(rightTopView)
        rightCardView.addSubview(rightBottomView)
        contentView.addSubview(rightCardView)
        
        leftCardView.snp.makeConstraints { make in
            make.height.equalTo(117)
            make.left.equalToSuperview()
        }
        
        simpleLineView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(leftView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        leftView.snp.makeConstraints { make in
            make.height.equalTo(58)
            make.left.right.top.equalToSuperview()
        }
        
        rightCardView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.top.equalTo(leftCardView)
            make.left.equalTo(leftCardView.snp.right).offset(10)
            make.width.equalTo(leftCardView)
        }
        
        rightTopView.snp.makeConstraints { make in
            make.height.equalTo(58)
            make.left.right.top.equalToSuperview()
        }
        
        rightBottomView.snp.makeConstraints { make in
            make.height.equalTo(58)
            make.left.right.equalToSuperview()
            make.top.equalTo(rightTopView.snp.bottom)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        rightCardView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(0.5)
            make.centerY.equalToSuperview()
        }
        
    }
    
    fileprivate func cardView() -> UIView{
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        QMUITheme().itemBorderColor()
        view.layer.borderColor =  QMUITheme().pointColor().cgColor
        return view
    }
}
