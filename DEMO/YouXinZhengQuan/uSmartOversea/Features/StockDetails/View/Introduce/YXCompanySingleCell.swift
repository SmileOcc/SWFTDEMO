//
//  YXCompanySingleCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCompanySingleCell: UITableViewCell {
    
    var model: YXIntroduceMaincomp? {
        didSet {
            self.firstLabel.text = self.model?.mainBusiness
            
            if let operatingIncome = self.model?.operatingIncome {
                let att = YXToolUtility.stockData(Double(operatingIncome), deciPoint: 2, stockUnit: "", priceBase: 0)
                self.secondLabel.text = att
            } else {
                self.secondLabel.text = "--"
            }
            
            if let ratio = self.model?.proportion, ratio > 0 {
                self.thirdLabel.text = String(format: "%.2f%@", ratio, "%")
            } else {
                self.thirdLabel.text = "--"
            }
        }
    }
    
    var HSModel: YXHSIntroduceMaincomp? {
        didSet {
            self.firstLabel.text = self.HSModel?.mainBusiness
            
            if let operatingIncome = self.HSModel?.businessIncome {
                let att = YXToolUtility.stockData(Double(operatingIncome), deciPoint: 2, stockUnit: "", priceBase: 0)
                self.secondLabel.text = att
            } else {
                self.secondLabel.text = "--"
            }
            
            if let ratio = self.HSModel?.businessIncomeRate, ratio > 0 {
                self.thirdLabel.text = String(format: "%.2f%@", ratio, "%")
            } else {
                self.thirdLabel.text = "--"
            }
        }
    }

    let cycleView = UIView.init()
    
    let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.selectionStyle = .none
        cycleView.layer.cornerRadius = 4
        cycleView.clipsToBounds = true
        
        firstLabel.numberOfLines = 2
        
        contentView.addSubview(cycleView)
        contentView.addSubview(secondLabel)
        contentView.addSubview(firstLabel)
        contentView.addSubview(thirdLabel)
        
        cycleView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        secondLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-100)
        }
        firstLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(secondLabel.snp.leading).offset(-10)
        }
        thirdLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}
