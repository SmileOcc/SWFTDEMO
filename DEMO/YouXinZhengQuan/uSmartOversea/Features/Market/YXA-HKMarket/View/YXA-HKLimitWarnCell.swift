//
//  YXA-HKLimitWarnCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXA_HKLimitWarnCell: YXTableViewCell {

    override var model: Any? {
        didSet {
            
            if let item = model as? YXA_HKLimitWarningItem {
                setStockInfo(name: item.name, code: item.code, market: item.market)
                if let date = item.tradeDay {
                    firstColLabel.text = date
                }else {
                    firstColLabel.text = "--"
                }
                
                thirdColLabel.text = String(format: "%.2lf", Double(item.holdVolume)/Double(pow(10.0, Double(item.priceBase))))
                
                fourthColLabel.text = String(format: "%.2lf%%", Double(item.ratio)/Double(pow(10.0, Double(item.priceBase))))
            }
        }
    }
    
    func setStockInfo(name: String?, code: String?, market: String?) {
        stockNameLabel.text = name
        stockCodeLabel.text = "\(code ?? "--").\(market?.uppercased() ?? "--")"
    }
    
    lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
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
    
    // 第一列
    lazy var firstColLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
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
        return label
    }()
    
    // 第四列
    lazy var fourthColLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [firstColLabel, stockView, thirdColLabel, fourthColLabel])
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(10, after: firstColLabel)
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
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
    }

}
