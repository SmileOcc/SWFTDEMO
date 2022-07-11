//
//  YXOrderLiseCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa

class YXHKOrderListCell: QMUITableViewCell {
    
    lazy var order = BehaviorRelay<YXOrderItem?>(value: nil)

    lazy var stockInfoView: YXStockBaseinfoView = {
        let view = YXStockBaseinfoView()
        let tapGes = UITapGestureRecognizer(actionBlock: { [weak self] (tap)  in
            guard let strongSelf = self else { return }
            let input = YXStockInputModel.init()
            input.market = ""
            if let market = strongSelf.order.value?.market {
                input.market = market.lowercased()
            }
            if let symbolType = strongSelf.order.value?.symbolType, symbolType == "4" {
                input.market = kYXMarketUsOption
            }
            input.symbol = strongSelf.order.value?.symbol ?? ""
            input.name = strongSelf.order.value?.symbolName ?? ""
            
            guard let appdelegate = UIApplication.shared.delegate as? YXAppDelegate else { return }
            appdelegate.navigator.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex": 0], animated: true)
        })
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    lazy var costLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var tradeCostLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var numLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var tradeNumLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()

    @objc lazy var fractionFlagLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8)
        label.backgroundColor = UIColor.themeColor(withNormalHex: "#B0B6CB", andDarkColor: "#858999")
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.isHidden = true
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "fractions_flag")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var entrustDirectionLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var statusNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()
    
    lazy var openPreLabel: QMUILabel = {
        let label = QMUILabel()
        label.backgroundColor = QMUITheme().textColorLevel3()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        label.layer.cornerRadius = 1
        label.layer.masksToBounds = true
        
        return label
    }()
    
    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
        
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(costLabel)
        contentView.addSubview(numLabel)
        contentView.addSubview(tradeCostLabel)
        contentView.addSubview(tradeNumLabel)
        contentView.addSubview(stockInfoView)
        contentView.addSubview(fractionFlagLabel)
        contentView.addSubview(entrustDirectionLabel)
        contentView.addSubview(statusNameLabel)
        contentView.addSubview(openPreLabel)
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16);
            make.top.bottom.equalToSuperview()
            make.right.equalTo(costLabel.snp.left).offset(-2)
        }

        costLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-160)
            make.centerY.equalTo(stockInfoView.nameLabel)
            make.width.equalTo(80)
        }
        
        tradeCostLabel.snp.makeConstraints { (make) in
            make.right.equalTo(costLabel)
            make.centerY.equalTo(stockInfoView.symbolLabel)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-100)
            make.centerY.equalTo(stockInfoView.nameLabel)
            make.width.equalTo(60)
        }
        
        tradeNumLabel.snp.makeConstraints { (make) in
            make.right.equalTo(numLabel)
            make.centerY.equalTo(stockInfoView.symbolLabel)
        }
        
        statusNameLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(70)
            make.height.lessThanOrEqualTo(24)
            make.centerY.equalTo(stockInfoView.nameLabel)
        }

        fractionFlagLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(tradeNumLabel.snp.right).offset(5)
            make.right.equalTo(entrustDirectionLabel.snp.left).offset(-2)
            make.centerY.equalTo(entrustDirectionLabel)
        }
        
        entrustDirectionLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(stockInfoView.symbolLabel)
        }
        
        openPreLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(entrustDirectionLabel)
            make.width.equalTo(33)
            make.height.equalTo(11)
            make.right.equalTo(statusNameLabel.snp.left).offset(-3)
        }
    }

    func setColor(isfinal: Bool, direction: String)  {
        if direction == "B"{
            entrustDirectionLabel.textColor = QMUITheme().buy()
        } else {
            entrustDirectionLabel.textColor = QMUITheme().sell()
        }
    }

}
