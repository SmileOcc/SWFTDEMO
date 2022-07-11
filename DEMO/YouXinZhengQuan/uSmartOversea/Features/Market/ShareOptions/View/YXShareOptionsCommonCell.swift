//
//  YXShareOptionsCommonCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/1.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTitleValueItem: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(70)
        }
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXShareOptionsCommonCell: UITableViewCell {
    
    var tapPriceAction: (() -> Void)?
    
    var tapMoreInfoAction: ((_ market: String, _ code: String) -> Void)?
    
    var type: YXStockRankSortType = .now
    
    lazy var infoBgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            self?.tapPriceAction?()
        })
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var infoLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var directionView: UIImageView = {
        let directionView = UIImageView()
        directionView.image = UIImage(named: "direction_up")
        return directionView
    }()
    
    lazy var subLabel1: QMUILabel = {
        let label = QMUILabel()
        label.adjustsFontSizeToFitWidth  = true
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var subLabel2: QMUILabel = {
        let label = QMUILabel()
        label.adjustsFontSizeToFitWidth  = true
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .right
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var strikePriceItem: YXTitleValueItem = {
        let item = YXTitleValueItem()
        item.titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        item.titleLabel.textColor = QMUITheme().textColorLevel1()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_strike") + ":"
        return item
    }()
    
    lazy var unCloseOutItem: YXTitleValueItem = {
        let item = YXTitleValueItem()
        item.titleLabel.font = .systemFont(ofSize: 12)
        item.titleLabel.textColor = QMUITheme().textColorLevel2()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "options_non_closedContract") + ":"
        return item
    }()
    
    lazy var volumeItem: YXTitleValueItem = {
        let item = YXTitleValueItem()
        item.titleLabel.font = .systemFont(ofSize: 12)
        item.titleLabel.textColor = QMUITheme().textColorLevel2()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "market_volume") + ":"
        return item
    }()
    
    lazy var moreInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "options_moreinfo"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let market = self.model?.market, let symbol = self.model?.code {
                self.tapMoreInfoAction?(market, symbol)
            }
        })
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var model: YXShareOptionsChainItem? {
        didSet {
            
            if let item = model {
                // 行权价
                let strikePrice = item.strikePrice/pow(10.0, item.priceBase)
                let strikePriceStr = String(format: "%.3lf", strikePrice)
                // 去掉末尾多余的0，如2.100变成2.1
                let strikePriceStrDeleteZeroStr = String(format: "%@", NSNumber.init(value: Float(strikePriceStr) ?? 0.0))
                // 行使价
                let strikePriceValueAttrStr = NSMutableAttributedString.init(string: strikePriceStrDeleteZeroStr, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)])
                
                strikePriceItem.valueLabel.attributedText = strikePriceValueAttrStr
                
                // 未平仓合约
                if item.openInt >= 10000 {
                    let unCloseOutValueAttrStr = YXToolUtility.stocKNumberData(item.openInt, deciPoint: 2, stockUnit: "", priceBase: 0, number: .systemFont(ofSize: 12), unitFont:  .systemFont(ofSize: 12))
                    unCloseOutValueAttrStr?.addAttribute(NSAttributedString.Key.foregroundColor, value: QMUITheme().textColorLevel2(), range: NSRange.init(unCloseOutValueAttrStr?.string ?? "") ?? NSRange.init())
                    unCloseOutItem.valueLabel.attributedText = unCloseOutValueAttrStr
                }else {
                    unCloseOutItem.valueLabel.attributedText = nil
                    unCloseOutItem.valueLabel.text = "\(item.openInt)"
                }
                
                
                // 成交量
                if item.volume >= 10000 {
                    let volumeValueAttrStr = YXToolUtility.stocKNumberData(item.volume, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "options_page"), priceBase: 0, number: .systemFont(ofSize: 12), unitFont:  .systemFont(ofSize: 12))
                    volumeValueAttrStr?.addAttribute(NSAttributedString.Key.foregroundColor, value: QMUITheme().textColorLevel2(), range: NSRange.init(volumeValueAttrStr?.string ?? "") ?? NSRange.init())
                    volumeItem.valueLabel.attributedText = volumeValueAttrStr
                }else {
                    volumeItem.valueLabel.attributedText = nil
                    volumeItem.valueLabel.text = "\(item.volume)" + YXLanguageUtility.kLang(key: "options_page")
                }
                
                var op = ""
                var color: UIColor
                if item.netchng > 0 {
                    op = "+"
                    color = QMUITheme().stockRedColor()
                    self.directionView.image = UIImage(named: "direction_up")
                }else if item.netchng < 0 {
                    color = QMUITheme().stockGreenColor()
                    self.directionView.image = UIImage(named: "direction_down")
                }else {
                    color = QMUITheme().stockGrayColor()
                    self.directionView.image = nil
                }
                
                self.infoBgView.backgroundColor = color
                
                let price = String(format: "%.3lf", item.latestPrice/pow(10.0, item.priceBase))
                let change = op + String(format: "%.3lf", item.netchng/pow(10.0, item.priceBase))
                let roc = op + String(format: "%.2lf%%", item.pctchng/100.0)
                
                subLabel1.textColor = color
                subLabel2.textColor = color
                
                switch self.type {
                case .change:
                    infoLabel.text = change
                    subLabel1.text = roc
                    subLabel2.text = price
                    
                case .roc:
                    infoLabel.text = roc
                    subLabel1.text = price
                    subLabel2.text = change
                    
                case .now:
                    infoLabel.text = price
                    subLabel1.text = roc
                    subLabel2.text = change
                    
                default:
                    break
                }
            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(infoBgView)
        contentView.addSubview(directionView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(subLabel1)
        contentView.addSubview(subLabel2)
        
        infoBgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(27)
            make.height.equalTo(24)
            make.width.equalTo(96)
        }
        
        directionView.snp.makeConstraints { (make) in
            make.left.equalTo(infoBgView).offset(6)
            make.centerY.equalTo(infoBgView)
            make.height.width.equalTo(15)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.right.equalTo(infoBgView).offset(-6)
            make.height.centerY.equalTo(infoBgView)
            make.left.equalTo(infoBgView).offset(25)
        }
        
        subLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(infoBgView)
            make.height.equalTo(15)
            make.top.equalTo(infoLabel.snp.bottom).offset(6)
        }
        
        subLabel2.snp.makeConstraints { (make) in
            make.right.equalTo(infoBgView)
            make.height.equalTo(15)
            make.top.equalTo(infoLabel.snp.bottom).offset(6)
        }
        
        contentView.addSubview(strikePriceItem)
        strikePriceItem.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(8)
        }
        
        contentView.addSubview(unCloseOutItem)
        unCloseOutItem.snp.makeConstraints { (make) in
            make.top.equalTo(strikePriceItem.snp.bottom).offset(6)
            make.left.equalTo(strikePriceItem)
        }
        
        contentView.addSubview(volumeItem)
        volumeItem.snp.makeConstraints { (make) in
            make.top.equalTo(unCloseOutItem)
            make.right.equalTo(infoBgView.snp.left).offset(-30)
        }
        
        contentView.addSubview(moreInfoButton)
        moreInfoButton.snp.makeConstraints { (make) in
            make.top.equalTo(unCloseOutItem.snp.bottom).offset(5)
            make.left.equalTo(strikePriceItem)
        }
        
        let lineView = UIView()
        contentView.addSubview(lineView)
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
