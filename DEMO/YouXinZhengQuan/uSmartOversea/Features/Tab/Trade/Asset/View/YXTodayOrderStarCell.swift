//
//  YXTodayOrderStarCell.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTodayOrderStarCell: UITableViewCell {
    
    @objc var model: YXOrderModel? {
        didSet {
            if let m = model {
                iconLabel.market = m.market
            }
        }
    }
    
    lazy var iconLabel: YXMarketIconLabel = {
        return YXMarketIconLabel()
    }()
    
    lazy var nameLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var priceLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var numLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var statusLabel: UILabel = {
        return creatStarLabel()
    }()
    
    func creatStarLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "****"
        label.textAlignment = .right
        return label
    }
    
    lazy var margin: Int  = {
        var margin = 9;
        return margin;
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(numLabel)
        contentView.addSubview(statusLabel)
        
        iconLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16);
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconLabel.snp.right).offset(4);
            make.centerY.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(margin + 41+20)
            make.centerY.equalToSuperview()
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(statusLabel.snp.left).offset(-margin);
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(numLabel.snp.left).offset(-margin)
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
