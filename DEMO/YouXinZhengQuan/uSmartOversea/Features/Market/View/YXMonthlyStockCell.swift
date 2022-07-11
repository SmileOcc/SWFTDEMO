//
//  YXMonthlyStockCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXMonthlyStockCell: UICollectionViewCell, HasDisposeBag {
    
    let greyLineViewWidth = 100.0
    
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.isHidden = true
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        return label
    }()
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 16.0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var symbolLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var priceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var lowPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var highPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var ratioLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var greyLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#ECECEC")
        view.layer.cornerRadius = 3
        return view
    }()
    
    lazy var arrowUpImgageView: UIImageView = {
        let image = UIImage(named: "green_up")?.qmui_image(withTintColor: UIColor(hexString: "#1E93F3"))
        let imageView = UIImageView.init(image: image)
        return imageView
    }()
    
    var level: Int? {
        didSet {
            if let l = level, l == 0 {
                delayLabel.isHidden = false
            }else {
                delayLabel.isHidden = true
            }
        }
    }
    
    var info: YXMarketRankCodeListInfo? {
        didSet {
            nameLabel.text = info?.chsNameAbbr ?? "--"
            symbolLabel.text = (info?.secuCode ?? "") + ".\(info?.trdMarket?.uppercased() ?? "")"
            
            if let now = info?.latestPrice, let priceBase = info?.priceBase, now > 0 {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(now)/Double(pow(10.0, Double(priceBase))))
            } else {
                priceLabel.text = "--";
            }
            
            if let dividendYield = info?.dividendYield {
                ratioLabel.text = String(format: "%.2f%%", Double(dividendYield)/100.0)
            }else {
                ratioLabel.text = "--"
            }
            
            if let low = info?.low_52week, let priceBase = info?.priceBase {
                lowPriceLabel.text = String(format: "%.\(priceBase)f", Double(low)/Double(pow(10.0, Double(priceBase))))
            } else {
                lowPriceLabel.text = "--";
            }
            
            if let high = info?.high_52week, let priceBase = info?.priceBase {
                highPriceLabel.text = String(format: "%.\(priceBase)f", Double(high)/Double(pow(10.0, Double(priceBase))))
            } else {
                highPriceLabel.text = "--";
            }
            
            if let now = info?.latestPrice, let low = info?.low_52week, let high = info?.high_52week {
                let leftOffset = Double(now - low) / Double(high - low) * greyLineViewWidth
                arrowUpImgageView.snp.updateConstraints { (make) in
                    make.centerX.equalTo(greyLineView.snp.left).offset(leftOffset)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        contentView.addSubview(ratioLabel)
        ratioLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(9)
            make.right.equalTo(ratioLabel.snp.left).offset(-10)
            make.left.equalTo(18)
            make.height.equalTo(22)
        }
        
        contentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.left.equalTo(nameLabel)
        }
        
        contentView.addSubview(delayLabel)
        delayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(symbolLabel.snp.right).offset(4)
            make.centerY.equalTo(symbolLabel)
            make.height.equalTo(14)
        }
        
        delayLabel.rx.observeWeakly(String.self, "text").subscribe(onNext: {  [weak self] (_) in
            self?.delayLabel.layer.cornerRadius = 2
            self?.delayLabel.layer.masksToBounds = true
        }).disposed(by: disposeBag)
        
        contentView.addSubview(greyLineView)
        greyLineView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(greyLineViewWidth)
            make.centerY.equalToSuperview()
            make.height.equalTo(6)
        }
        
        contentView.addSubview(lowPriceLabel)
        lowPriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(greyLineView)
            make.bottom.equalTo(greyLineView.snp.top).offset(-3)
        }
        
        contentView.addSubview(highPriceLabel)
        highPriceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(greyLineView)
            make.bottom.equalTo(greyLineView.snp.top).offset(-3)
        }
        
        contentView.addSubview(arrowUpImgageView)
        arrowUpImgageView.snp.makeConstraints { (make) in
            make.top.equalTo(greyLineView)
            make.centerX.equalTo(greyLineView.snp.left).offset(0)
//            make.height.equalTo(6)
//            make.width.equalTo(12)
        }
        
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowUpImgageView)
            make.top.equalTo(arrowUpImgageView.snp.bottom).offset(-2)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
