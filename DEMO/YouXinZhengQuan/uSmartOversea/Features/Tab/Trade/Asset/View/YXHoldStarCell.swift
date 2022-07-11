//
//  YXHoldStarCell.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXHoldStarCell: UITableViewCell {
    
    @objc var model: YXAccountAssetHoldListItem? {
        didSet {
            if let m = model {
                iconLabel.market = model?.exchangeType
            }
        }
    }
    
    lazy var iconLabel: YXMarketIconLabel = {
        return YXMarketIconLabel()
    }()
    
    lazy var nameLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var marketValueLabel: UILabel = {
        return creatStarLabel()
    }()
    
    @objc lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var marketNumberLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var costLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var profitLabel: UILabel = {
        return creatStarLabel()
    }()
    
    lazy var profitPercentLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var todayProfitLabel: YXPreOrderView = {
        let label = YXPreOrderView(frame: .zero)
         
          return label
      }()
      
      lazy var todayProfitPercentLabel: YXCanHideTextLabel = {
          let label = YXCanHideTextLabel()
          label.textColor = QMUITheme().textColorLevel2()
          label.font = .systemFont(ofSize: 12)
          label.textAlignment = .right
          return label
      }()
    
    func creatStarLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "****"
        label.textAlignment = .right
        return label
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(nameLabel)
        
        contentView.addSubview(scrollView)
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        scrollView.addSubview(marketValueLabel)
        
        scrollView.addSubview(priceLabel)
        
        scrollView.addSubview(profitLabel)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(160)
            make.top.bottom.right.equalTo(self)
        }
        
        iconLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.centerY.equalTo(marketValueLabel)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconLabel.snp.right).offset(4)
            make.centerY.equalTo(iconLabel)
        }
        
        marketValueLabel.frame   = CGRect(x: 0, y: 16, width: 80, height: 20)
//        marketNumberLabel.frame = CGRect(x: 0, y: 36, width: 80, height: 15)
        
        priceLabel.frame  = CGRect(x: 100, y: 16, width: 80, height: 20)
//        costLabel.frame = CGRect(x: 100, y: 36, width: 80, height: 15)
        
        profitLabel.frame = CGRect(x: 220, y: 16, width: 80, height: 20)
//        profitPercentLabel.frame = CGRect(x: 220, y: 36, width: 80, height: 15)
        
        scrollView.contentSize = CGSize(width: 320, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
