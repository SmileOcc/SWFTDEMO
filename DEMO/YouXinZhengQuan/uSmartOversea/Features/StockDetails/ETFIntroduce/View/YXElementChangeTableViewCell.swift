//
//  YXElementChangeTableViewCell.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXElementChangeTableViewCell: UITableViewCell {

    lazy var dateLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.text = ""
        lab.numberOfLines = 0
//        lab.adjustsFontSizeToFitWidth = true
//        lab.minimumScaleFactor = 0.5
        lab.textAlignment = .left
        
        return lab
    }()
    
    lazy var codeLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.text = ""
        lab.textAlignment = .left
        lab.numberOfLines = 0
        
        return lab
    }()
    
    lazy var holdLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.text = ""
        lab.textAlignment = .right
        lab.numberOfLines = 0
        
        return lab
    }()
    
    lazy var resultLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.text = ""
        lab.textAlignment = .right
        lab.numberOfLines = 0
        
        return lab
    }()
 
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        
        return line
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
       
    }
    
    func initUI() {
        self.selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(dateLab)
        contentView.addSubview(codeLab)
        contentView.addSubview(holdLab)
        contentView.addSubview(resultLab)
        //contentView.addSubview(line)
        
        let unitWidth: CGFloat = (YXConstant.screenWidth - 24.0)/4.0
        
        dateLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(unitWidth - 2)
            make.centerY.equalToSuperview()
        }
        codeLab.snp.makeConstraints { (make) in
            make.width.equalTo(unitWidth - 8)
            make.left.equalTo(dateLab.snp.right).offset(4);
            make.centerY.equalToSuperview()
        }
        holdLab.snp.makeConstraints { (make) in
            make.width.equalTo(unitWidth + 2)
            make.left.equalTo(codeLab.snp.right);
            make.centerY.equalToSuperview()
        }
        resultLab.snp.makeConstraints { (make) in
            make.width.equalTo(unitWidth - 2)
            make.left.equalTo(holdLab.snp.right).offset(4);
            make.centerY.equalToSuperview()
        }
        
//        line.snp.makeConstraints { (make) in
//            make.left.bottom.right.equalToSuperview()
//            make.height.equalTo(1)
//        }
    }
    
    
     var model: YXUSElementChangeItemModel? {
        didSet {
            self.refreshUI()
        }
    }
    
    func refreshUI() {
        if let model = model {
            if let dateChanged = model.dateChanged {
                self.dateLab.text = String(dateChanged.prefix(10))
            } else {
                self.dateLab.text = "--"
            }

            self.codeLab.text = model.secuCodeElement

            var isInterger = false
            if YXUserManager.isENMode() {
                isInterger = abs(model.holder) < 1000
            } else {
                isInterger = abs(model.holder) < 10000
            }
            if (isInterger) {

                resultLab.text = String(model.holder) + YXLanguageUtility.kLang(key: "stock_unit_en")
            } else {
                resultLab.text = YXToolUtility.stockData(Double(model.holder), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
            }

            if YXUserManager.isENMode() {
                isInterger = abs(model.holderChanged) < 1000
            } else {
                isInterger = abs(model.holderChanged) < 10000
            }
            var string = ""
            if (isInterger) {

                string = String(model.holderChanged) + YXLanguageUtility.kLang(key: "stock_unit_en")

            } else {
                string = YXToolUtility.stockData(Double(model.holderChanged), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
            }

            if model.holderChanged > 0 {
                self.holdLab.text = "+" + string
            } else {
                self.holdLab.text = string
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
