//
//  YXStreetCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStreetCell: YXTableViewCell {
    
    @objc var priceBase: Int = 0
    
    @objc var maxOutstanding: Int = 1
    
    @objc var prcLowerString: String = "0"
    
    @objc var prcUpperString: String = "0"
    
    let prcWidth = YXConstant.screenWidth/4.0 - 8
    
    let maxOutstandingWidth: Double = Double(YXConstant.screenWidth/2.0 - 6)
    
    lazy var prcLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 11)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var outstandLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .right
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 11)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialUI() {
        super.initialUI()
        
        backgroundColor = QMUITheme().foregroundColor()
        
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        contentView.addSubview(prcLabel)
        contentView.addSubview(outstandLabel)
        contentView.addSubview(changeLabel)
        
        prcLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.height.equalTo(self)
            make.width.equalTo(prcWidth)
        }
        
        outstandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(prcLabel.snp.right).offset(4)
            make.height.equalTo(12)
            make.centerY.equalTo(self)
            make.width.equalTo(maxOutstandingWidth)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outstandLabel.snp.right).offset(2)
            make.height.equalTo(20)
            make.centerY.equalTo(self)
            make.right.lessThanOrEqualTo(self).offset(-2)
        }
    }
    
    override func refreshUI() {
        super.refreshUI()
        
        let priceBaseFormat = "%.\(priceBase)f"
        if let cell = model as? CbbcCell {
            let prcLower = Double(cell.prcLower)/pow(10.0, Double(priceBase))
            let prcUpper = Double(cell.prcUpper)/pow(10.0, Double(priceBase))
            prcLowerString = String(format: priceBaseFormat, prcLower)
            prcUpperString = String(format: priceBaseFormat, prcUpper)
            
            let lowerNumberString = NSNumber(floatLiteral: prcLower).stringValue
            if YXToolUtility.isPureInt(lowerNumberString) {
                prcLowerString = lowerNumberString
            }
            prcLabel.text = "\(prcLowerString)~\(prcUpperString)"
            
            var outstandWidth = 0.0
            if maxOutstanding > 0 {
                outstandWidth = maxOutstandingWidth * Double(cell.outstanding)/Double(maxOutstanding)
            }
            outstandLabel.snp.updateConstraints { (make) in
                make.width.equalTo(outstandWidth)
            }

            let outstandString = String(format: "%.1f", Double(cell.outstanding) / 100.0)
            let changeString = String(format: "%.1f", Double(cell.change) / 100.0)
            if cell.change > 0 {
                changeLabel.text = "\(outstandString) [+\(changeString)]  "
            } else {
                changeLabel.text = "\(outstandString) [\(changeString)]  "
            }
            
            if cell.callPutFlag == 3 {
                outstandLabel.backgroundColor = QMUITheme().stockRedColor()
            } else if cell.callPutFlag == 4 {
                outstandLabel.backgroundColor = QMUITheme().stockGreenColor()
            }
        
            var text = ""
            var minWidth = 0.0
            if cell.heavyCargo && cell.maxIncrease {
                text = "\(YXLanguageUtility.kLang(key: "cbbc_hightest"))/\(YXLanguageUtility.kLang(key: "cbbc_topIncrease"))"//"重货区/最多新增"
                minWidth = 80.0
            } else if cell.heavyCargo {
                text = YXLanguageUtility.kLang(key: "cbbc_hightest")
                minWidth = 35.0
            } else if cell.maxIncrease {
                text = YXLanguageUtility.kLang(key: "cbbc_topIncrease")
                minWidth = 45.0
            }

            if outstandWidth < minWidth, text.count > 0 {
                outstandLabel.text = ""
                let attributeString = NSMutableAttributedString(string: changeLabel.text ?? "", attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 10)])
                attributeString.append(NSAttributedString(string: text, attributes: [.foregroundColor: outstandLabel.backgroundColor!, .font: UIFont.systemFont(ofSize: 10)]))
                changeLabel.text = nil
                changeLabel.attributedText = attributeString
            } else {
                outstandLabel.text = text
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
