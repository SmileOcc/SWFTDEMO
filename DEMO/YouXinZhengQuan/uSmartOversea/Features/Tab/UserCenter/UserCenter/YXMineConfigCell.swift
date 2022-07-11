//
//  YXMineConfigCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXMineConfigCell: UITableViewCell {
    
    let iconView = UIImageView.init()
    let titleLabel = UILabel.init()
    let subTitleLabel = UILabel.init()
    let bottomLineView = UIView.init()
    let redLabel = UILabel.init()
    let arrowImage = UIImageView.init()
    let redDotView = UIImageView.init(image: UIImage.init(named: "mine_redDot"))
    let lineView = UIView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = QMUITheme().foregroundColor()
        redLabel.backgroundColor = UIColor.qmui_color(withHexString: "#F84646")
        bottomLineView.backgroundColor = QMUITheme().separatorLineColor()
        arrowImage.image = UIImage(named: "mine_arrow")
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.minimumScaleFactor = 0.3
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXMineConfigOneColCell: YXMineConfigCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        subTitleLabel.textColor = QMUITheme().textColorLevel3()
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        redDotView.isHidden = true
                
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(arrowImage)
        contentView.addSubview(redDotView)
        contentView.addSubview(lineView)
        
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(52)
            make.centerY.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-42)
            make.centerY.equalToSuperview()
        }
        
        arrowImage.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
        
        redDotView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
        }
    
        lineView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.right.equalToSuperview().offset(-16)
        }
        lineView.backgroundColor = QMUITheme().separatorLineColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

