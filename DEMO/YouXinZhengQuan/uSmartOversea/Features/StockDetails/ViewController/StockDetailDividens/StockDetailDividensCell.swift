//
//  StockDetailDividensCell.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class StockDetailDividensCell: YXTableViewCell {
    
    lazy var dateLabel:UILabel = {
        let label = UILabel.init()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var stateLabel:UILabel = {
        let label = UILabel.init()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var valueLabel:UILabel = {
        let label = UILabel.init()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    
    override func initialUI() {
        super.initialUI()
        
        contentView.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(valueLabel)

        dateLabel.snp.makeConstraints{
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        stateLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints{
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
    
    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? StockDetailDividensDataModel else {
            return
        }
        
        dateLabel.text = YXDateHelper.commonDateString(cellViewModel.date,format: YXCommonDateFormat.DF_MD)
        stateLabel.text = cellViewModel.stateStr
        if let div_amount = cellViewModel.div_amount?.doubleValue {
            let roundedNum = div_amount.roundTo(places: 4)
            valueLabel.text = String.init(format: "%.3f", roundedNum)
            
        } else {
            valueLabel.text = "--"
        }
    }
    
}


extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
