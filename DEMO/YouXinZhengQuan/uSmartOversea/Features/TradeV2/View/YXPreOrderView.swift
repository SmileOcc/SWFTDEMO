//
//  YXPreOrderView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/1/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXPreOrderView: UIView {
    
    lazy var panLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 8)
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        label.layer.cornerRadius = 1
        label.layer.masksToBounds = true
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        label.isHidden = true
        
        return label
    }()
    
    lazy var textLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        return label
    }()
    
    var text: String? {
        didSet {
            self.textLabel.text = text
        }
    }
    
    var textColor: UIColor? {
        didSet {
            self.textLabel.textColor = textColor
        }
    }
    
    var sessionType: Int?{
        didSet {
            if (sessionType == 1 || sessionType == 2) {
                self.panLabel.isHidden = false
                let panName : String = (sessionType == 1 ) ? "common_pre_opening" : "common_after_opening"
                self.panLabel.text = YXLanguageUtility.kLang(key: panName)
                self.panLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(24)
                }
            }else{
                self.panLabel.isHidden =  true
                self.panLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        
    }
    
    func initUI() {
        addSubview(textLabel)
        addSubview(panLabel)
        
        textLabel.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.bottom.equalTo(0)
        }
        
        panLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview()
            make.right.equalTo(textLabel.snp.left).offset(-3)
            make.width.equalTo(0)
            make.height.equalTo(12)
            make.centerY.equalTo(textLabel.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
