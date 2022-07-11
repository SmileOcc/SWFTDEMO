//
//  YXOptionalAccessView.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa

import NSObject_Rx

class YXOptionalAccessView: UIView {
    
    lazy var infoBgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var infoLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.minimumScaleFactor = 0.9
        return label
    }()
    
    lazy var subLabel2: QMUILabel = {
        let label = QMUILabel()
        label.adjustsFontSizeToFitWidth  = true
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        label.minimumScaleFactor = 0.9
        return label
    }()
    
    let quoteTypeRelay: BehaviorRelay<YXStockRankSortType> = BehaviorRelay<YXStockRankSortType>(value:.now)
    
    var quoteType: YXStockRankSortType?
    
    var quote: YXV2Quote?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        addSubview(infoBgView)
        addSubview(directionView)
        addSubview(infoLabel)
        addSubview(subLabel1)
        addSubview(subLabel2)
        
        infoBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(12)
            make.height.equalTo(30)
        }
        
        directionView.snp.makeConstraints { (make) in
            make.left.equalTo(infoBgView).offset(6)
            make.centerY.equalTo(infoBgView)
//            make.height.width.equalTo(15)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.right.equalTo(infoBgView).offset(-6)
            make.height.centerY.equalTo(infoBgView)
            make.left.equalTo(infoBgView).offset(25)
        }
        
        subLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self.snp.centerX).offset(-1)
            make.height.equalTo(15)
            make.top.equalTo(infoLabel.snp.bottom).offset(4)
        }
        
        subLabel2.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.left.equalTo(self.snp.centerX).offset(1)
            make.height.equalTo(15)
            make.top.equalTo(subLabel1)
        }
        
        quoteTypeRelay.subscribe(onNext: { [weak self] (type) in
            guard let strongSelf = self, let quote = strongSelf.quote, strongSelf.quoteType != type else {
                return
            }
            
            let priceBase = quote.priceBase?.value ?? 3
            let operatorFormat = String(format: "%%+.%df", priceBase)
            let priceBaseFormat = String(format: "%%.%df", priceBase)
            
            var marketStatus: OBJECT_MARKETMarketStatus?
            if let status = quote.msInfo?.status?.value {
                marketStatus = OBJECT_MARKETMarketStatus(rawValue: status)
            }
            
            var changeText: String = "--"
            if let change = quote.netchng?.value {
                if change == 0 {
                    changeText = String(format: priceBaseFormat, Double(change)/pow(10.0, Double(priceBase)))
                } else {
                    changeText = String(format: operatorFormat, Double(change)/pow(10.0, Double(priceBase)))
                }
            }
            
            var rocText: String = "--"
            if let roc = quote.pctchng?.value {
                if roc == 0 {
                    rocText = "0.00%"
                } else {
                    rocText = String(format: "%+.2f%%", Double(roc)/100.0)
                }
            }

            var priceText: String = "--"
            if let now = quote.latestPrice?.value, now != 0 {
                priceText = String(format: priceBaseFormat, Double(now)/pow(10.0, Double(priceBase)))
            }
            
            switch type {
            case .change:
                strongSelf.infoLabel.text = changeText
                strongSelf.subLabel1.text = rocText
                strongSelf.subLabel2.text = priceText
                
            case .roc:
                strongSelf.infoLabel.text = rocText
                strongSelf.subLabel1.text = priceText
                strongSelf.subLabel2.text = changeText
                
            case .now:
                strongSelf.infoLabel.text = priceText
                strongSelf.subLabel1.text = rocText
                strongSelf.subLabel2.text = changeText
                
            default:
                break
            }
            
            strongSelf.quoteType = type
            
            var color: UIColor?
            if let change = quote.netchng?.value {
                if change > 0 {
                    color = QMUITheme().stockRedColor()
                    strongSelf.directionView.image = UIImage(named: "direction_up")
                } else if change < 0 {
                    color = QMUITheme().stockGreenColor()
                    strongSelf.directionView.image = UIImage(named: "direction_down")
                } else {
                    color = QMUITheme().stockGrayColor()
                    strongSelf.directionView.image = nil
                }
            } else {
                color = QMUITheme().stockGrayColor()
                strongSelf.directionView.image = nil
            }
            
            strongSelf.infoBgView.backgroundColor = color
            
            let sQuote = quote.sQuote
            if let latestPrice = sQuote?.latestPrice?.value, latestPrice > 0, let pctchng = sQuote?.pctchng?.value, let netchng = sQuote?.netchng?.value, let marketStatus = marketStatus {
                if marketStatus == .msPreHours {
                    strongSelf.subLabel1.text = nil
                    if pctchng == 0 {
                        strongSelf.subLabel2.text = YXLanguageUtility.kLang(key: "common_pre_opening") + " " + "0.00%"
                        color = QMUITheme().stockGrayColor()
                    } else {
                        strongSelf.subLabel2.text = YXLanguageUtility.kLang(key: "common_pre_opening") + " " + String(format:"%+.2f%%", Double(pctchng)/100.0)
                        if netchng > 0 {
                            color = QMUITheme().stockRedColor()
                        } else {
                            color = QMUITheme().stockGreenColor()
                        }
                    }
                    strongSelf.subLabel2.snp.remakeConstraints { (make) in
                        make.right.equalTo(strongSelf)
                        make.left.equalTo(strongSelf)
                        make.height.equalTo(15)
                        make.top.equalTo(strongSelf.infoLabel.snp.bottom).offset(6)
                    }
                } else if marketStatus == .msClose || marketStatus == .msAfterHours ||  marketStatus == .msStart {
                    strongSelf.subLabel1.text = nil
                    if pctchng == 0 {
                        strongSelf.subLabel2.text = YXLanguageUtility.kLang(key: "common_after_opening") + " " + "0.00%"
                        color = QMUITheme().stockGrayColor()
                    } else {
                        strongSelf.subLabel2.text = YXLanguageUtility.kLang(key: "common_after_opening") + " " +  String(format:"%+.2f%%", Double(pctchng)/100.0)
                        if netchng > 0 {
                            color = QMUITheme().stockRedColor()
                        } else {
                            color = QMUITheme().stockGreenColor()
                        }
                    }
                    strongSelf.subLabel2.snp.remakeConstraints { (make) in
                        make.right.equalTo(strongSelf)
                        make.left.equalTo(strongSelf)
                        make.height.equalTo(15)
                        make.top.equalTo(strongSelf.infoLabel.snp.bottom).offset(6)
                    }
                } else {
                    strongSelf.subLabel2.snp.remakeConstraints { (make) in
                        make.right.equalTo(strongSelf)
                        make.left.equalTo(strongSelf.snp.centerX).offset(1)
                        make.height.equalTo(15)
                        make.top.equalTo(strongSelf.infoLabel.snp.bottom).offset(6)
                    }
                }
            }
            
            strongSelf.subLabel1.textColor = color
            strongSelf.subLabel2.textColor = color
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
