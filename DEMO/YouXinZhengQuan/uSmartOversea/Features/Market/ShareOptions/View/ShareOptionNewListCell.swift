//
//  ShareOptionNewListCell.swift
//  uSmartOversea
//
//  Created by lennon on 2022/6/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class NewListQuoteView:UIView {
    
    lazy var gridView:QMUIGridView = {
        let view = QMUIGridView.init(column: 3, rowHeight: 30)!
        view.backgroundColor = QMUITheme().foregroundColor()
        view.padding = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        view.separatorWidth = 8
        view.separatorColor = .clear
        return view
    }()
    
    let itemTypes: [YXShareOptinosItem] = [.latestPrice, .pctchng, .bidPrice, .volume, .netchng, .askPrice, .amount, .openInt, .impliedVolatility]

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        for (_, type) in itemTypes.enumerated() {
            let itemView = YXShareOptionsItemView()
            itemView.type = type
            itemView.topLabel.text = "--"
            itemView.topLabel.font = .systemFont(ofSize: 10)
            itemView.topLabel.textAlignment = .left
            
            itemView.bottomLabel.text = "--"
            itemView.bottomLabel.font = .systemFont(ofSize: 10)
            itemView.bottomLabel.textAlignment = .left
            gridView.addSubview(itemView)
        }
        
        addSubview(gridView)
        
        gridView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


class ShareOptionNewListCell: UITableViewCell {
    
    var tapCellAction: ((_ market: String, _ code: String) -> Void)?
    
    class LeftView: UIView {
        lazy var priceLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = QMUITheme().textColorLevel1()
            label.textAlignment = .center
            return label
        }()
        
        lazy var caFlagView: UIImageView = {
            let view = UIImageView.init()
            view.image = UIImage(named: "optionFlag")
            view.isHidden = true
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(priceLabel)
            addSubview(caFlagView)
            
            priceLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            caFlagView.snp.makeConstraints { make in
                make.top.equalTo(priceLabel.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.equalTo(21)
                make.height.equalTo(12)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    lazy var leftView: LeftView = {
        let view = LeftView.init()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var callColorLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "bullbear_call_mark")
        label.backgroundColor = QMUITheme().stockRedColor()
        label.textColor = QMUITheme().longPressTextColor()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    lazy var putColorLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "bullbear_put_mark")
        label.backgroundColor = QMUITheme().stockGreenColor()
        label.textColor = QMUITheme().longPressTextColor()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    //call数据在前面
    lazy var callQuoteView: NewListQuoteView = {
        let view = NewListQuoteView()
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            if let item = self?.items?.first {
                if let market = item.market, let symbol = item.code {
                    self?.tapCellAction?(market, symbol)
                }
            }
        })
        view.addGestureRecognizer(tap)
        return view
    }()
    //put数据在后面
    lazy var putQuoteView: NewListQuoteView = {
        let view = NewListQuoteView()
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            if let market = self?.items?.last?.market, let symbol = self?.items?.last?.code {
                self?.tapCellAction?(market, symbol)
            }
        })
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var containView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var callOrPutQuoteView: NewListQuoteView = {
        let view = NewListQuoteView()
        view.isHidden = true
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            if let market = self?.items?.last?.market, let symbol = self?.items?.last?.code {
                self?.tapCellAction?(market, symbol)
            }
        })
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var disposeBag: DisposeBag? = DisposeBag()
    
    // 正股最新价格
    var stockPrice: Double = 0

    // 全部 看涨 看跌
    var optionsType: YXShareOptionsType = .call {
        didSet {
            
        }
    }
    
    var items: [YXShareOptionsChainItem]? {
        didSet {
            
            if let item = items?.first {
                // 行权价
                let strikePrice = item.strikePrice/pow(10.0, item.priceBase)
                let strikePriceStr = String(format: "%.3lf", strikePrice)
                // 去掉末尾多余的0，如2.100变成2.1
                let strikePriceStrDeleteZeroStr = String(format: "%@", NSNumber.init(value: Float(strikePriceStr) ?? 0.0))
                leftView.priceLabel.text = strikePriceStrDeleteZeroStr//String(format: "%.3lf", strikePrice)
                
                let color = UIColor(hexString: "#414FFF")?.withAlphaComponent(0.05)
                if stockPrice != 0 {
                    if optionsType == .all {
//                        if strikePrice < stockPrice {
//                            scrollView2.backgroundColor = color
//                        }else {
//                            scrollView2.backgroundColor = QMUITheme().foregroundColor()
//                        }
//
//                        if strikePrice > stockPrice {
//                            scrollView.backgroundColor = color
//                        }else {
//                            scrollView.backgroundColor = QMUITheme().foregroundColor()
//                        }
                        containView.isHidden = false
                        callOrPutQuoteView.isHidden = true
                    }else if optionsType == .call {
//                        if strikePrice < stockPrice {
//                            scrollView.backgroundColor = color
//                        }else {
//                            scrollView.backgroundColor = QMUITheme().foregroundColor()
//                        }
                        containView.isHidden = true
                        callOrPutQuoteView.isHidden = false
                    }else if optionsType == .put {
//                        if strikePrice > stockPrice {
//                            scrollView.backgroundColor = color
//                        }else {
//                            scrollView.backgroundColor = QMUITheme().foregroundColor()
//                        }
                        containView.isHidden = true
                        callOrPutQuoteView.isHidden = false
                    }
                }
                
                
                if item.CAFlag {
                    leftView.caFlagView.isHidden = false
                } else {
                    leftView.caFlagView.isHidden = true
                }
                
            }
            
            switch optionsType {
            case .all:
                setValue(model: items?.first, itemViews: self.callQuoteView.gridView.subviews.map { $0 as!YXShareOptionsItemView })
                setValue(model: items?.last, itemViews: self.putQuoteView.gridView.subviews.map { $0 as!YXShareOptionsItemView })
            case .call, .put:
                setValue(model: items?.first, itemViews: self.callOrPutQuoteView.gridView.subviews.map { $0 as!YXShareOptionsItemView })
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

                itemView.topLabel.text = itemView.type.title
                itemView.topLabel.textColor = QMUITheme().textColorLevel1()
                
                switch itemView.type {
                case .latestPrice:
                    itemView.bottomLabel.text = String(format: "%.3lf", item.latestPrice/pow(10.0, item.priceBase))
                    itemView.bottomLabel.textColor = color
                case .pctchng:
                    itemView.bottomLabel.text = op + String(format: "%.2lf%%", item.pctchng/100.0)
                    itemView.bottomLabel.textColor = color
                case .bidPrice:
                    itemView.bottomLabel.textColor = color
                    itemView.bottomLabel.text = String(format: "%.3lf(%d)", item.bidPrice/pow(10.0, item.priceBase),item.bidVolume)
                case .askPrice:
                    itemView.bottomLabel.text = String(format: "%.3lf(%d)", item.askPrice/pow(10.0, item.priceBase),item.bidVolume)
                case .netchng:
                    itemView.bottomLabel.text = op + String(format: "%.3lf", item.netchng/pow(10.0, item.priceBase))
                    itemView.bottomLabel.textColor = color
                case .volume:
                    let page = YXLanguageUtility.kLang(key: "options_page")
                    if item.volume >= 1000 {
                        itemView.bottomLabel.attributedText = YXToolUtility.stocKNumberData(item.volume, deciPoint: 2, stockUnit: page, priceBase: 0, number:  .systemFont(ofSize: 10), unitFont:  .systemFont(ofSize: 10))
                    }else {
                        itemView.bottomLabel.attributedText = nil
                        itemView.bottomLabel.text = "\(item.volume)" + page
                    }

                case .amount:
                    itemView.bottomLabel.attributedText = YXToolUtility.stocKNumberData(Int64(item.amount), deciPoint: 2, stockUnit: "", priceBase: Int(item.priceBase), number:  .systemFont(ofSize: 10), unitFont:  .systemFont(ofSize: 10))
                case .openInt:
                    if item.openInt >= 1000 {
                        itemView.bottomLabel.attributedText = YXToolUtility.stocKNumberData(item.openInt, deciPoint: 2, stockUnit: "", priceBase: 0, number:  .systemFont(ofSize: 10), unitFont: .systemFont(ofSize: 10))
                    }else {
                        itemView.bottomLabel.attributedText = nil
                        itemView.bottomLabel.text = "\(item.openInt)"
                    }
                case .impliedVolatility:
                    itemView.bottomLabel.text = String(format: "%.2lf%%", item.impliedVolatility/100.0)
                default:
                    itemView.topLabel.text = "--"
                }
            }
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(75)
        }
        
        //call And put
        contentView.addSubview(containView)
        containView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right)
            make.top.right.bottom.equalToSuperview()
        }
        
        containView.addSubview(callColorLabel)
        containView.addSubview(callQuoteView)
        
        containView.addSubview(putColorLabel)
        containView.addSubview(putQuoteView)
        

        callColorLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        
        callQuoteView.snp.makeConstraints { make in
            make.top.equalTo(callColorLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(122)
        }
        
        putColorLabel.snp.makeConstraints { make in
            make.top.equalTo(callQuoteView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        
        putQuoteView.snp.makeConstraints { make in
            make.top.equalTo(putColorLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(122)
        }
        
        
        //call Or put
        contentView.addSubview(callOrPutQuoteView)
        callOrPutQuoteView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.equalTo(leftView.snp.right)
            make.height.equalTo(122)
        }
        
        let lineView = UIView.init()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
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
}
