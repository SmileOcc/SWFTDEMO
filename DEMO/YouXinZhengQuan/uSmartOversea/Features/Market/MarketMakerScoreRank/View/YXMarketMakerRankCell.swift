//
//  YXMarketMakerRankCellTableViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketMakerRankCell: YXStockListCell {
    
    @objc var item: YXMarketMakerRankItem? {
        didSet {
            let font = UIFont.systemFont(ofSize: 16)
            if let model = item {
                nameLabel.text = model.name ?? "--"
                for label in labels {
                    label.font = font
                    switch label.mobileBrief1Type {
                    case .yxScore:
                        label.text = "\(model.score)"
                    case .avgSpread:
                        label.text = String(format: "%.2lf", model.avgSpread)
                    case .openOnTime:
                        label.text = String(format: "%.2lf%%", model.openOnTime * 100.0)
                    case .liquidity:
                        label.attributedText = YXToolUtility.stocKNumberData(Int64(model.liquidity), deciPoint: 2, stockUnit: "", priceBase: 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    case .oneTickSpreadProducts:
                        label.text = "\(model.oneTickSpreadProducts)"
                    case .oneTickSpreadDuration:
                        label.text = String(format: "%.2lf%%", model.oneTickSpreadDuration * 100.0)
                    case .amount:
                        label.attributedText = YXToolUtility.stocKNumberData(Int64(model.avgAmount), deciPoint: 2, stockUnit: "", priceBase: 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    case .volume:
                        if model.avgVolume < 10000 {
                            label.text = "\(model.avgVolume)" //+ YXLanguageUtility.kLang(key: "newStock_stock_unit")
                        }else {
                            label.attributedText = YXToolUtility.stocKNumberData(Int64(model.avgVolume), deciPoint: 2, stockUnit: "", priceBase: 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                        }
                        
                    default:
                        label.text = "--"
                    }
                }
            }
        }
    }
    
    override func refreshUI() {
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        symbolLabel.isHidden = true
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.minimumScaleFactor = 0.5
        if nameLabel.superview == nil {
            contentView.addSubview(nameLabel)
        }
        nameLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(114)
        }

        self.resetScrollViewLeftOffset(130)
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
