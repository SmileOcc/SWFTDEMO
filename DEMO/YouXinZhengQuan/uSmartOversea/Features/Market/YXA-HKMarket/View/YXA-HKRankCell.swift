//
//  YXA-HKRankCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKRankCell: YXTableViewCell {
    
    var type: YXA_HKRankType? {
        didSet {
            switch type {
            case .roc:
                stackView.removeArrangedSubview(secondColLabel)
            default:
                break
            }
        }
    }
    
    override var model: Any? {
        didSet {
            
            if let item = model as? YXA_HKFundDirectionRankItem {
                setFundDirection(item: item)
            }else if let item = model as? YXTradeActiveItem {
                setVolume(item: item)
            }
        }
    }
    
    func setStockInfo(name: String?, code: String?, market: String?) {
        stockNameLabel.text = name
        stockCodeLabel.text = "\(code ?? "--").\(market?.uppercased() ?? "--")"
    }
    
    // 资金流向
    func setFundDirection(item: YXA_HKFundDirectionRankItem) {
        setStockInfo(name: item.name, code: item.code, market: item.market)
        let count = Int64(Double(item.volume)/pow(10.0, Double(item.priceBase)))
        if let formatStr = YXNewStockPurchaseUtility.int64Format(value: count) {
            if item.volume > 0 {
                secondColLabel.text = "+" + formatStr
                secondColLabel.textColor = QMUITheme().stockRedColor()
            }else if item.volume < 0 {
                secondColLabel.text = formatStr
                secondColLabel.textColor = QMUITheme().stockGreenColor()
            }else {
                secondColLabel.text = formatStr
                secondColLabel.textColor = QMUITheme().textColorLevel1()
            }
        }else {
            secondColLabel.text = "--"
            secondColLabel.textColor = QMUITheme().textColorLevel1()
        }
        
        var color: UIColor
        if item.amount > 0 {
            color = QMUITheme().stockRedColor()
        }else if item.amount < 0 {
            color = QMUITheme().stockGreenColor()
        }else {
            color = QMUITheme().textColorLevel1()
        }
        
        thirdColLabel.attributedText =  YXToolUtility.stocKNumberData(item.amount, deciPoint: 2, stockUnit: "", priceBase: item.priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16), color: color)
        fourthColTopLabel.text = String(format: "%.2f%%", Double(item.ratio)/Double(pow(10.0, Double(item.priceBase))))
    }
    
    
    // 成交量
    func setVolume(item: YXTradeActiveItem) {
        setStockInfo(name: item.name, code: item.code, market: item.market)
        
        secondColLabel.attributedText = YXToolUtility.stocKNumberData(item.bid, deciPoint: 2, stockUnit: "", priceBase: item.priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
        
        thirdColLabel.attributedText = YXToolUtility.stocKNumberData(item.ask, deciPoint: 2, stockUnit: "", priceBase: item.priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
        
        fourthColTopLabel.attributedText = YXToolUtility.stocKNumberData(item.total, deciPoint: 2, stockUnit: "", priceBase: item.priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
        
        var color: UIColor
        if item.netFlow > 0 {
            color = QMUITheme().stockRedColor()
        }else if item.netFlow < 0 {
            color = QMUITheme().stockGreenColor()
        }else {
            color = QMUITheme().textColorLevel1()
        }
        fourthColBottomLabel.attributedText = YXToolUtility.stocKNumberData(item.netFlow, deciPoint: 2, stockUnit: "", priceBase: item.priceBase, number: .systemFont(ofSize: 14), unitFont: .systemFont(ofSize: 14), color: color)
    }
    
    
    lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    lazy var stockCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.49)
        return label
    }()
    
    lazy var marketImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var stockView: UIView = {
        let view = UIView()
        view.addSubview(stockNameLabel)
        view.addSubview(stockCodeLabel)
        
        stockNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        stockCodeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stockNameLabel.snp.bottom).offset(2)
            make.left.equalTo(stockNameLabel)
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    // 第二列
    lazy var secondColLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    // 第三列
    lazy var thirdColLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    // 第四列
    lazy var fourthColTopLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        return label
    }()
    
    // 第四列
    lazy var fourthColBottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        return label
    }()
    
    // 第四个stackview，里面装两个label，垂直方向
    lazy var fourthColStackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [fourthColTopLabel, fourthColBottomLabel])
        stackView.alignment = .trailing
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [stockView, secondColLabel, thirdColLabel, fourthColStackView])
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(10, after: secondColLabel)
        } else {
            // Fallback on earlier versions
        }
        
        return stackView
    }()
    
    fileprivate var linePatternLayer: CALayer?
    
    override func draw(_ rect: CGRect) {
        
        DispatchQueue.main.async {
            if  self.linePatternLayer == nil {
                let color = UIColor.qmui_color(withHexString: "#0013BA")?.withAlphaComponent(0.07) ?? UIColor.white
                
                self.linePatternLayer = YXDrawHelper.drawDashLine(superView: self.contentView, strokeColor: color, topMargin:self.contentView.frame.height - 2, lineHeight: 1, leftMargin: 18, rightMargin: 0)
            }
        }
    }
    
    override func initialUI() {
        
        super.initialUI()
        
        self.selectionStyle  = .none
        
//        let lineView = UIView.line()
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
        
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(self)
//            make.height.equalTo(1)
//        }
    }
}
