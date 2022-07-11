//
//  YXNewsStockCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class YXNewsStockCell: UICollectionViewCell {
    
    var quote: YXV2Quote? {
        didSet {
            let code = (quote?.symbol ?? "") + "." + (quote?.market?.uppercased() ?? "")
//            nameLabel.text = "\(quote?.name ?? "")(\(code))"

            let color = YXToolUtility.stockChangeColor(Double(quote?.pctchng?.value ?? 0))
            
            if let price = quote?.latestPrice, let priceBasic = quote?.priceBase?.value {
                priceLabel.text = YXToolUtility.stockPriceData(Double(price.value), deciPoint: Int(priceBasic), priceBase: Int(priceBasic))
            } else {
                priceLabel.text = "--"
            }
            
            nameLabel.text = "\(quote?.name ?? "")"

            if let roc = quote?.pctchng?.value {
                rocLabel.text = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            } else {
                rocLabel.text = "--"
            }
            
            priceLabel.textColor = color
            rocLabel.textColor = color
            
            let optionalSecu = YXOptionalSecu.init()
            optionalSecu.market = quote?.market ?? ""
            optionalSecu.symbol = quote?.symbol ?? ""
            optionalSecu.name = quote?.name ?? ""
            if let type1 = quote?.type1?.value {
                optionalSecu.type1 = type1
            }
            if let type2 = quote?.type2?.value {
                optionalSecu.type2 = type2
            }
            if let type3 = quote?.type3?.value {
                optionalSecu.type3 = type3
            }
            self.optionalSecu = optionalSecu
            if YXSecuGroupManager.shareInstance().containsSecu(optionalSecu) {
                self.selfSelectButotn.isSelected = true
            } else {
                self.self.isSelected = false
            }
            
        }
    }
    
    var optionalSecu: YXOptionalSecu  = YXOptionalSecu.init()
    
    let nameLabel = UILabel.init(text: "--", textColor: QMUITheme().themeTextColor(), textFont: UIFont.systemFont(ofSize: 12, weight: .regular))!
    
    let priceLabel = UILabel.init(text: "--", textColor: QMUITheme().stockGrayColor(), textFont: UIFont.systemFont(ofSize: 12, weight: .regular))!
    
    let rocLabel = UILabel.init(text: "--", textColor: QMUITheme().stockGrayColor(), textFont: UIFont.systemFont(ofSize: 12, weight: .regular))!
    lazy var selfSelectButotn: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 10
        btn.expandY = 10
        btn.setImage(UIImage.init(named: "newdetail_like_unselect"), for: .normal)
        btn.setImage(UIImage.init(named: "new_like_select"), for: .selected)
        btn.rx.tap.asObservable().throttle(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance).bind { [weak self] in
            guard let `self` = self else { return }

            if !YXUserManager.isLogin() {
                YXToolUtility.handleBusinessWithLogin{
                    
                }
            } else {
                if self.selfSelectButotn.isSelected {

                    YXSecuGroupManager.shareInstance().remove(self.optionalSecu)
                    self.selfSelectButotn.isSelected = false
                   YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "search_remove_from_favorite"))
                    
                } else {
                    YXToolUtility.addSelfStockToGroup(secu: self.optionalSecu) { (finish) in
                        if finish {
                            //埋点
                            self.selfSelectButotn.isSelected = true
                        } else {
                            self.selfSelectButotn.isSelected = false
                        }
                    }
                }
            }
        
        }.disposed(by: self.rx.disposeBag)

        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        
        contentView.addSubview(selfSelectButotn)
        contentView.addSubview(rocLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(nameLabel)
        
        priceLabel.textAlignment = .right
        
        rocLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(20)
            make.right.equalTo(selfSelectButotn.snp.left).offset(5)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(133)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(77)
        }
        
        selfSelectButotn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
}
