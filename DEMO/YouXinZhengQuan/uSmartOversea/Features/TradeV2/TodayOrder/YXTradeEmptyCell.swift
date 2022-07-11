//
//  YXTradeEmptyCell.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeEmptyCell: YXTableViewCell {
    
    @objc var emptyType: YXDefaultEmptyEnums = .noPositon {
        didSet {
            emptyImageView.image = emptyType.image()
            emptyTipLabel.text = emptyType.tip()
        }
    }
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = YXDefaultEmptyEnums.noPositon.image()
        imageView.sizeToFit()
        return imageView
    }()
    
    @objc lazy var emptyTipLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.text = YXDefaultEmptyEnums.noPositon.tip()
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
        super.initialUI()
        
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(emptyImageView)
        contentView.addSubview(emptyTipLabel)
        
        emptyImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(-30)
        }
        
        emptyTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
        }
        
    }
    
    @objc func showEmptyImage( _ show:Bool){
        emptyImageView.isHidden = !show
        emptyTipLabel.snp.removeConstraints()
        if !show {
            emptyTipLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(self).offset(30)
            }
        }else{
            emptyTipLabel.snp.makeConstraints { (make) in
                make.top.equalTo(emptyImageView.snp.bottom).offset(10)
                make.centerX.equalTo(self)
            }
        }
    }

}
