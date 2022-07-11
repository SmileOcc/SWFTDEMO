//
//  YXDoneOrderTipCell.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDoneOrderTipCell: YXTableViewCell {
    
    @objc var isCondition: Bool = false
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "tip_final_state_today_order")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func initialUI() {
        super .initialUI()
        
        backgroundColor = QMUITheme().blockColor()
        
        contentView.addSubview(tipLabel)
        
        tipLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.centerY.equalToSuperview()
        }
    }
    
    override func refreshUI() {
        if isCondition == true {
            tipLabel.text = YXLanguageUtility.kLang(key: "tip_final_conditional_order")
        } else {
            tipLabel.text = YXLanguageUtility.kLang(key: "tip_final_state_today_order")
        }
    }

}
