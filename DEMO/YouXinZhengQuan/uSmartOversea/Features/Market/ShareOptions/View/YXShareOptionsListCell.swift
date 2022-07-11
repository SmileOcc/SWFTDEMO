//
//  YXShareOptionsListCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXShareOptionsListCell: UITableViewCell {
    var disposeBag: DisposeBag? = DisposeBag()
    // 正股最新价格
    var stockPrice: Double = 0
    // 指标
    let itemTypes: [YXShareOptinosItem] = [.latestPrice, .pctchng, .bidPrice, .askPrice, .netchng, .volume, .amount, .openInt, .impliedVolatility]//[.latestPrice, .pctchng, .openInt, .volume]
    
    let itemViewWidth: CGFloat = 80.0
    let spacing: CGFloat = 5.0
    
    var tapCellAction: ((_ market: String, _ code: String) -> Void)?
    
    // 全部 看涨 看跌
    var optionsType: YXShareOptionsType = .call {
        didSet {
            switch optionsType {
            case .all:
                centerView.label.textAlignment = .center
                contentView.addSubview(scrollView2)
                centerView.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(60)
                }
                scrollView.snp.remakeConstraints { (make) in
                    make.right.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.left.equalTo(centerView.snp.right)
                }
                scrollView2.snp.remakeConstraints { (make) in
                    make.left.top.bottom.equalToSuperview()
                    make.right.equalTo(centerView.snp.left)
                }
                
            case .call, .put:
                
                if scrollView2.superview != nil {
                    scrollView2.removeFromSuperview()
                }
                centerView.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview()
                    make.width.equalTo(60)
                }
                scrollView.snp.remakeConstraints { (make) in
                    make.right.top.bottom.equalToSuperview()
                    make.left.equalTo(centerView.snp.right)
                }
            }
        }
    }
    
    lazy var itemViews: [YXShareOptionsItemView] = {
        return creatItemViews(itemTypes: itemTypes)
    }()
    
    lazy var itemViews2: [YXShareOptionsItemView] = {
        return creatItemViews(itemTypes: itemTypes.reversed(), textAlignment: .left)
    }()
    
    func creatItemViews(itemTypes: [YXShareOptinosItem], textAlignment: NSTextAlignment = .right) -> [YXShareOptionsItemView] {
        return itemTypes.map { (itemType) -> YXShareOptionsItemView in
            let itemView = YXShareOptionsItemView()
            itemView.type = itemType
            itemView.topLabel.text = "--"
            itemView.bottomLabel.text = "--"
            itemView.bottomLabel.isHidden = true
            itemView.topLabel.textAlignment = textAlignment
            itemView.bottomLabel.textAlignment = textAlignment
            
            return itemView
        }
    }
    
    lazy var centerView: ShareOptionsCellCenterView = {
        let view = ShareOptionsCellCenterView.init()
        return view
    }()
    //右scrollView
    lazy var scrollView: UIScrollView = {
        let scrollView = creatScrollView(itemViews: itemViews)
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            
            if let market = self?.items?.last?.market, let symbol = self?.items?.last?.code {
                self?.tapCellAction?(market, symbol)
            }
        })
        
        scrollView.addGestureRecognizer(tap)
        return scrollView
    }()
    //左scrollView
    lazy var scrollView2: UIScrollView = {
        let scrollView = creatScrollView(itemViews: itemViews2)
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            if let item = self?.items?.first {
                if let market = item.market, let symbol = item.code {
                    self?.tapCellAction?(market, symbol)
                }
            }
        })
        
        scrollView.addGestureRecognizer(tap)
        return scrollView
    }()
    
    var scrollView2ContentSizeWidth: CGFloat {
        return CGFloat(itemTypes.count) * itemViewWidth + CGFloat(itemTypes.count - 1) * spacing + 2*spacing
    }
    
    lazy var line: UIView = {
        let line = UIView.line()
        return line
    }()
    
    func creatScrollView(itemViews: [YXShareOptionsItemView]) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.isUserInteractionEnabled = false
        itemViews.forEach { (view) in
            scrollView.addSubview(view)
        }
        itemViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        itemViews.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(itemViewWidth)
        }
        return scrollView
    }
    
    
    var items: [YXShareOptionsChainItem]? {
        didSet {
            
            if let item = items?.first {
                // 行权价
                let strikePrice = item.strikePrice/pow(10.0, item.priceBase)
                let strikePriceStr = String(format: "%.3lf", strikePrice)
                // 去掉末尾多余的0，如2.100变成2.1
                let strikePriceStrDeleteZeroStr = String(format: "%@", NSNumber.init(value: Float(strikePriceStr) ?? 0.0))
                centerView.label.text = strikePriceStrDeleteZeroStr//String(format: "%.3lf", strikePrice)
                
                let color = UIColor(hexString: "#414FFF")?.withAlphaComponent(0.05)
                if stockPrice != 0 {
                    if optionsType == .all {
                        if strikePrice < stockPrice {
                            scrollView2.backgroundColor = color
                        }else {
                            scrollView2.backgroundColor = QMUITheme().foregroundColor()
                        }
                        
                        if strikePrice > stockPrice {
                            scrollView.backgroundColor = color
                        }else {
                            scrollView.backgroundColor = QMUITheme().foregroundColor()
                        }
                    }else if optionsType == .call {
                        if strikePrice < stockPrice {
                            scrollView.backgroundColor = color
                        }else {
                            scrollView.backgroundColor = QMUITheme().foregroundColor()
                        }
                    }else if optionsType == .put {
                        if strikePrice > stockPrice {
                            scrollView.backgroundColor = color
                        }else {
                            scrollView.backgroundColor = QMUITheme().foregroundColor()
                        }
                    }
                }
                
                if item.CAFlag {
                    centerView.caContainView.isHidden = false
                } else {
                    centerView.caContainView.isHidden = true
                }
                
            }
            
            switch optionsType {
            case .all:
                setValue(model: items?.last, itemViews: itemViews)
                setValue(model: items?.first, itemViews: itemViews2)
            case .call, .put:
                setValue(model: items?.first, itemViews: itemViews)
            }
            
        }
    }
    
    func setValue(model: YXShareOptionsChainItem?, itemViews: [YXShareOptionsItemView]) {
        if let item = model {
            var op = ""
            var color: UIColor
            if item.netchng > 0 {
                op = "+"
                color = QMUITheme().stockRedColor()
            }else if item.netchng < 0 {
                color = QMUITheme().stockGreenColor()
            }else {
                color = QMUITheme().stockGrayColor()
            }
            
            for itemView in itemViews {
                
                switch itemView.type {
                case .latestPrice:
                    itemView.topLabel.text = String(format: "%.3lf", item.latestPrice/pow(10.0, item.priceBase))
                    itemView.topLabel.textColor = color
                case .pctchng:
                    itemView.topLabel.text = op + String(format: "%.2lf%%", item.pctchng/100.0)
                    itemView.topLabel.textColor = color
                case .bidPrice:
                    itemView.topLabel.text = String(format: "%.3lf", item.bidPrice/pow(10.0, item.priceBase))
                    itemView.bottomLabel.isHidden = false
                    itemView.bottomLabel.text = "\(item.bidVolume)"
                case .askPrice:
                    itemView.topLabel.text = String(format: "%.3lf", item.askPrice/pow(10.0, item.priceBase))
                    itemView.bottomLabel.isHidden = false
                    itemView.bottomLabel.text = "\(item.askVolume)"
                case .netchng:
                    itemView.topLabel.text = op + String(format: "%.3lf", item.netchng/pow(10.0, item.priceBase))
                    itemView.topLabel.textColor = color
                case .volume:
                    let page = YXLanguageUtility.kLang(key: "options_page")
                    if item.volume >= 1000 {
                        itemView.topLabel.attributedText = YXToolUtility.stocKNumberData(item.volume, deciPoint: 2, stockUnit: page, priceBase: 0, number:  .systemFont(ofSize: 12), unitFont:  .systemFont(ofSize: 12))
                    }else {
                        itemView.topLabel.attributedText = nil
                        itemView.topLabel.text = "\(item.volume)" + page
                    }
                    
                case .amount:
                    itemView.topLabel.attributedText = YXToolUtility.stocKNumberData(Int64(item.amount), deciPoint: 2, stockUnit: "", priceBase: Int(item.priceBase), number:  .systemFont(ofSize: 12), unitFont:  .systemFont(ofSize: 12))
                case .openInt:
                    if item.openInt >= 1000 {
                        itemView.topLabel.attributedText = YXToolUtility.stocKNumberData(item.openInt, deciPoint: 2, stockUnit: "", priceBase: 0, number:  .systemFont(ofSize: 12), unitFont: .systemFont(ofSize: 12))
                    }else {
                        itemView.topLabel.attributedText = nil
                        itemView.topLabel.text = "\(item.openInt)"
                    }
                    
                case .premium:
                    itemView.topLabel.text = String(format: "%.2lf%%", item.premium/100.0)
                case .impliedVolatility:
                    itemView.topLabel.text = String(format: "%.2lf%%", item.impliedVolatility/100.0)
                case .delta:
                    itemView.topLabel.text = String(format: "%.3lf", item.delta)
                case .gamma:
                    itemView.topLabel.text = String(format: "%.3lf", item.gamma)
                case .vega:
                    itemView.topLabel.text = String(format: "%.3lf", item.vega)
                case .theta:
                    itemView.topLabel.text = String(format: "%.3lf", item.theta)
                case .rho:
                    itemView.topLabel.text = String(format: "%.3lf", item.rho)
                default:
                    itemView.topLabel.text = "--"
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(centerView)
        contentView.addSubview(scrollView)
        
        
//        contentView.addSubview(line)
//        line.backgroundColor = QMUITheme().separatorLineColor()
//        line.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
        
        centerView.snp.remakeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(60)
        }
        scrollView.snp.remakeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(centerView.snp.right)
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
}



class YXShareOptionsItemView: UIView {
    
    var type: YXShareOptinosItem = .latestPrice
    
    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(bottomLabel)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ShareOptionsCellCenterView: UIView {
    
    
    lazy var label: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.backgroundColor = QMUITheme().blockColor()
        label.textAlignment = .center
        return label
    }()
    
    lazy var caFlagView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage(named: "optionFlag")
        return view
    }()
    
    lazy var caContainView:UIView = {
        let view = UIView.init()
        view.backgroundColor = QMUITheme().blockColor()
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        caContainView.addSubview(caFlagView)
        caFlagView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(11)
            make.width.equalTo(22)
        }
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(caContainView)
        addSubview(stackView)
        
        
        label.snp.makeConstraints { make in
            make.height.equalTo(38/2)
        }
        
        caContainView.snp.makeConstraints { make in
            make.height.equalTo(38/2)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
