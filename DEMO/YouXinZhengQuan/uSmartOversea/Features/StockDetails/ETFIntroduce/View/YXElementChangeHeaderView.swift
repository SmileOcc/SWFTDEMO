//
//  YXElementChangeHeaderView.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXElementChangeHeaderView: UITableViewHeaderFooterView {
    
    lazy var dateLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.text = YXLanguageUtility.kLang(key: "brife_change_date")
        lab.textAlignment = .left
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.7
        
        return lab
    }()
    
    lazy var codeLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.text = YXLanguageUtility.kLang(key: "brife_change_code")
        lab.textAlignment = .left
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.7
        
        return lab
    }()
    
    lazy var holdLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.text = YXLanguageUtility.kLang(key: "brife_hold_amount")
        lab.textAlignment = .right
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.7
        
        return lab
    }()
    
    lazy var resultLab: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.text = YXLanguageUtility.kLang(key: "brife_change_last")
        lab.textAlignment = .right
        lab.numberOfLines = 2
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.7
        
        return lab
    }()
 
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        
        return line
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        
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
}
