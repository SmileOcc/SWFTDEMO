//
//  YXBullBearAssetView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearAssetView: UIView {
    
    var tapAssetAction: (() -> Void)?
    var tapItemAction: ((_ market: String, _ symbol: String) -> Void)?
    
    var quoteModel: YXV2Quote? {
        didSet {
            if let model = quoteModel {
                let base = pow(10.0, Double(model.priceBase?.value ?? 0))
                assetItem.nameLabel.text = model.name
                
                if let price = model.latestPrice?.value {
                    assetItem.priceLabel.text = String(format: "%.2lf", Double(price) / base)
                }
                
                var op = ""
                var color: UIColor = QMUITheme().stockGrayColor()
                if let change = model.netchng?.value {
                    if change > 0 {
                        op = "+"
                        color = QMUITheme().stockRedColor()
                    }else if change < 0 {
                        color = QMUITheme().stockGreenColor()
                    }
                    assetItem.changeLabel.text = String(format: "%@%.2lf", op, Double(change) / base)
                }
                
                if let roc = model.pctchng?.value {
                    assetItem.ratioLabel.text = String(format: "(%@%.2lf%%)", op, Double(roc) / 100.0)
                }

                assetItem.priceLabel.textColor = color
                assetItem.changeLabel.textColor = color
                assetItem.ratioLabel.textColor = color
                
                if let open = model.open?.value {
                    assetItem.begin.valueLabel.text = String(format: "%.2lf", Double(open) / base)
                }
                
                if let high = model.high?.value {
                    assetItem.max.valueLabel.text = String(format: "%.2lf", Double(high) / base)
                }
                
                if let low = model.low?.value {
                    assetItem.min.valueLabel.text = String(format: "%.2lf", Double(low) / base)
                }
                
                assetItem.charView.quoteModel = model
            }
        }
    }
    
    var warrantCBBCModel: YXWarrantBullBearModel? {
        didSet {
            if let item = warrantCBBCModel?.bull {
                setUI(itemView: bull, item: item, type: .bullBear)
            }else {
                setNoDataUI(itemView: bull, type: .bullBear)
            }
            
            if let item = warrantCBBCModel?.bear {
                setUI(itemView: bear, item: item, type: .bullBear)
            }else {
                setNoDataUI(itemView: bear, type: .bullBear)
            }
            
            if let item = warrantCBBCModel?.call {
                setUI(itemView: buy, item: item, type: .warrant)
            }else {
                setNoDataUI(itemView: buy, type: .warrant)
            }
            
            if let item = warrantCBBCModel?.put {
                setUI(itemView: sell, item: item, type: .warrant)
            }else {
                setNoDataUI(itemView: sell, type: .warrant)
            }
        }
    }
    
    func setUI(itemView: YXBullBearAssetObjectView, item: YXBullBearItem, type: YXDerivativeType?) {
        let base = pow(10.0, Double(item.priceBase))
        itemView.nameLabel.text = item.name
        itemView.codeLabel.text = (item.symbol ?? "--") + ".\(item.market?.uppercased() ?? "--")"
        let formatExercisePrice = YXNewStockPurchaseUtility.moneyFormat(value: (Double(item.exercisePrice) / base), decPoint: 3)
        itemView.exercisePrice.valueLabel.text = (formatExercisePrice ?? "--")
        
        
        if type == .warrant {
            itemView.recyclePrice.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_volatility") + "："
            itemView.recyclePrice.valueLabel.text = String(format: "%.3lf", Double(item.impliedVolatility) / base)
            itemView.lever.titleLabel.text = YXLanguageUtility.kLang(key: "effective_eff_gearing") + "："
            itemView.lever.valueLabel.text = String(format: "%.2lf", Double(item.effectiveGearing) / base)
        }else {
            let formatRecoveryPrice = YXNewStockPurchaseUtility.moneyFormat(value: (Double(item.recoveryPrice) / base), decPoint: 3)
            itemView.recyclePrice.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_call_level") + "："
            itemView.recyclePrice.valueLabel.text = (formatRecoveryPrice ?? "--")
            itemView.lever.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_gearing") + "："
            itemView.lever.valueLabel.text = String(format: "%.2lf", Double(item.gearing) / base)
        }
        
        itemView.endDate.valueLabel.text = YXDateHelper.commonDateString(item.maturityDate)        
    }
    
    func setNoDataUI(itemView: YXBullBearAssetObjectView, type: YXDerivativeType?) {
        itemView.nameLabel.text = "--"
        itemView.codeLabel.text = "--"
        itemView.exercisePrice.valueLabel.text = "--"
        
        if type == .warrant {
            itemView.recyclePrice.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_volatility") + "："
            itemView.lever.titleLabel.text = YXLanguageUtility.kLang(key: "effective_eff_gearing") + "："
        }else {
            itemView.recyclePrice.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_call_level") + "："
            itemView.lever.titleLabel.text = YXLanguageUtility.kLang(key: "warrants_gearing") + "："
            
        }
        
        itemView.recyclePrice.valueLabel.text = "--"
        itemView.lever.valueLabel.text = "--"
        itemView.endDate.valueLabel.text = "--"
    }
    
    lazy var assetItem: YXBullBearAssetItemView = {
        let view = YXBullBearAssetItemView()
        
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapAssetAction {
                action()
            }
        }
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var buy: YXBullBearAssetObjectView = {
        return objectView(type: .buy)
    }()
    
    lazy var sell: YXBullBearAssetObjectView = {
        return objectView(type: .sell)
    }()
    
    lazy var bull: YXBullBearAssetObjectView = {
        return objectView(type: .bull)
    }()
    
    lazy var bear: YXBullBearAssetObjectView = {
        return objectView(type: .bear)
    }()
    
    func objectView(type: YXWarrantType) -> YXBullBearAssetObjectView {
        let view = YXBullBearAssetObjectView()
        view.type = type
        
        
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapItemAction {
                guard let `self` = self else {return}
                var market, symbol: String?
                switch type {
                case .buy:
                    market = self.warrantCBBCModel?.call?.market
                    symbol = self.warrantCBBCModel?.call?.symbol
                case .sell:
                    market = self.warrantCBBCModel?.put?.market
                    symbol = self.warrantCBBCModel?.put?.symbol
                case .bull:
                    market = self.warrantCBBCModel?.bull?.market
                    symbol = self.warrantCBBCModel?.bull?.symbol
                case .bear:
                    market = self.warrantCBBCModel?.bear?.market
                    symbol = self.warrantCBBCModel?.bear?.symbol
                }
                if let mkt = market, let code = symbol {
                    action(mkt, code)
                }
            }
        }
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(assetItem)
        addSubview(buy)
        addSubview(sell)
        addSubview(bull)
        addSubview(bear)
        
        assetItem.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(144.0)
        }
        
        buy.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(assetItem.snp.bottom)
            make.height.equalTo(131)
            make.width.equalTo(YXConstant.screenWidth/2.0)
        }
        
        sell.snp.makeConstraints { (make) in
            make.top.equalTo(buy.snp.bottom)
            make.left.width.height.equalTo(buy)
        }
        
        bull.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(buy)
            make.left.equalTo(buy.snp.right)
        }
        
        bear.snp.makeConstraints { (make) in
            make.top.equalTo(bull.snp.bottom)
            make.left.width.height.equalTo(bull)
        }
        
        
        let vLine = UIView.line()
        let hLine1 = UIView.line()
        let hLine2 = UIView.line()
        let hLine3 = UIView.line()
        
        addSubview(vLine)
        addSubview(hLine1)
        addSubview(hLine2)
        addSubview(hLine3)
        
        vLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.top.equalTo(assetItem.snp.bottom)
            make.bottom.equalTo(bear)
        }
        
        hLine1.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(buy)
        }
        
        hLine2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(buy.snp.bottom)
        }
        hLine3.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(bear)
        }
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXBullBearAssetObjectView: UIView {
    
    var type: YXWarrantType = .bull
    
    class YXAssetTitleValueItem: UIView {
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
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "--"
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.textAlignment = .right
        
        return label
    }()
    
    lazy var exercisePrice: YXAssetTitleValueItem = {
        let item = YXAssetTitleValueItem()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_strike") + "："//"行权价："
        return item
    }()
    
    lazy var recyclePrice: YXAssetTitleValueItem = {
        let item = YXAssetTitleValueItem()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_call") + "："//"回收价："
        return item
    }()
    
    lazy var lever: YXAssetTitleValueItem = {
        let item = YXAssetTitleValueItem()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "effective_eff_gearing") + "："//"实际杠杆："
        return item
    }()
    
    lazy var endDate: YXAssetTitleValueItem = {
        let item = YXAssetTitleValueItem()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_maturity") + "："//"到期日："
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(codeLabel)
        addSubview(exercisePrice)
        addSubview(recyclePrice)
        addSubview(lever)
        addSubview(endDate)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-5)
        }
        
        codeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
        }
        
        exercisePrice.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalTo(codeLabel.snp.bottom).offset(7)
        }
        
        recyclePrice.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalTo(exercisePrice.snp.bottom).offset(3)
        }
        
        lever.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalTo(recyclePrice.snp.bottom).offset(3)
        }
        
        endDate.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalTo(lever.snp.bottom).offset(3)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXBullBearAssetItemView: UIView {
    
    lazy var charView: YXIndexConstituentStockOverView = {
        let view = YXIndexConstituentStockOverView()
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        label.textAlignment = .center
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 26, weight: .medium)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var begin: YXTitleValueItemView = {
        let item = YXTitleValueItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_open")
        return item
    }()
    
    lazy var max: YXTitleValueItemView = {
        let item = YXTitleValueItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_high")
        return item
    }()
    
    lazy var min: YXTitleValueItemView = {
        let item = YXTitleValueItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_low")
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(ratioLabel)
        addSubview(begin)
        addSubview(max)
        addSubview(min)
        addSubview(charView)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalToSuperview().offset(14)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(4)
            make.centerY.equalTo(priceLabel).offset(-10)
        }
        
        ratioLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(4)
            make.centerY.equalTo(priceLabel).offset(10)
        }
        
        begin.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.left).offset(54)
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
        }
        
        max.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
        }
        
        min.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.right).offset(-54)
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
        }
        
        charView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(priceLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXTitleValueItemView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.left.right.equalToSuperview()
            make.width.equalTo(65.0)
            make.height.equalTo(22.0)
            make.bottom.equalToSuperview()
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXIndexConstituentStockOverView: UIView {
    
    let totlalWidth = 140 * YXConstant.screenWidth/375.0
    
    var quoteModel: YXV2Quote? {
        didSet {
            if let model = quoteModel {
                if let up = model.up?.value, let down = model.down?.value, let unchange = model.unchange?.value {
//                    let base = pow(10.0, Double(model.priceBase?.value ?? 0))
                    var total = up + down + unchange
                    if total == 0 {
                        total = 1
                    }
                    var downWidth = CGFloat(down)/CGFloat(total) * totlalWidth
                    var flatWidth = CGFloat(unchange)/CGFloat(total) * totlalWidth
                    var upWidth = CGFloat(up)/CGFloat(total) * totlalWidth
                    
                    if downWidth < 6 {
                        downWidth = 6
                    }
                    
                    if flatWidth < 6 {
                        flatWidth = 6
                    }
                    
                    if upWidth < 6 {
                        upWidth = 6
                    }

                    let titleWidth = ((titleLabel.text ?? "") as NSString).boundingRect(with: CGSize(width: 300, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : titleLabel.font!], context: nil).width;
                    if (upWidth + flatWidth + downWidth) < titleWidth {
                        titleLabel.snp.remakeConstraints { (make) in
                            make.top.equalToSuperview()
                            make.right.equalTo(downLabel)
                        }
                    } else {
                        titleLabel.snp.remakeConstraints { (make) in
                            make.top.equalToSuperview()
                            make.left.equalTo(upLabel)
                        }
                    }
                    
                    downLabel.text = "\(down)"//String(format: "%.0lf", Double(down)/base)
                    flatLabel.text = "\(unchange)"//String(format: "%.0lf", Double(unchange)/base)
                    upLabel.text = "\(up)"//String(format: "%.0lf", Double(up)/base)
                    
                    downLabel.snp.updateConstraints { (make) in

                        make.width.equalTo(downWidth)
                    }
                    
                    flatLabel.snp.updateConstraints { (make) in
                        
                        make.width.equalTo(flatWidth)
                    }
                    
                    upLabel.snp.updateConstraints { (make) in
                        
                        make.width.equalTo(upWidth)
                    }
                }
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "index_constituent")
        return label
    }()
    
    lazy var downLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().foregroundColor()
        label.textAlignment = .right
        label.backgroundColor = QMUITheme().stockGreenColor()
        return label
    }()
    
    lazy var flatLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().foregroundColor()
        label.textAlignment = .center
        label.backgroundColor = QMUITheme().stockGrayColor()
        return label
    }()
    
    lazy var upLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().foregroundColor()
        label.textAlignment = .left
        label.backgroundColor = QMUITheme().stockRedColor()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView()
        containerView.addSubview(downLabel)
        containerView.addSubview(flatLabel)
        containerView.addSubview(upLabel)
        
        upLabel.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(totlalWidth/3.0)
        }
        
        flatLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(upLabel.snp.right)
            make.width.equalTo(totlalWidth/3.0)
        }
        
        downLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(flatLabel.snp.right)
            make.width.equalTo(totlalWidth/3.0)
            make.right.equalToSuperview()
        }
        
        addSubview(titleLabel)
        addSubview(containerView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(upLabel)
        }
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
