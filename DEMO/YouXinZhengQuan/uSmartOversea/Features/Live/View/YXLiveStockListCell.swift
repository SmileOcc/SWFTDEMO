//
//  YXLiveStockListCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveStockListCell: UITableViewCell {
    
    typealias ClosureClick = () -> Void
    
    @objc var onClickLook: ClosureClick?
    
    var quote: YXV2Quote? {
        didSet {
            nameLabel.text = quote?.name ?? "--"
            if let symbol = quote?.symbol, let market = quote?.market {
                symbolLabel.text = symbol + "." + market.uppercased()
            } else {
                symbolLabel.text = "--"
            }
            
            let change = quote?.netchng?.value ?? 0
            var color = UIColor(hexString: "#191919")?.withAlphaComponent(0.45)
            if (change > 0) {
                color = QMUITheme().stockRedColor()
            } else if (change < 0) {
                color = QMUITheme().stockGreenColor()
            }
            priceLabel.textColor = color
            rocLabel.textColor = color
            
            let priceBase = quote?.priceBase?.value ?? 3
            if let price = quote?.latestPrice?.value {
                priceLabel.text = YXToolUtility.stockPriceData(Double(price), deciPoint: Int(priceBase), priceBase: Int(priceBase))
            } else {
                priceLabel.text = "--"
            }
            
            if let roc = quote?.pctchng?.value {
                rocLabel.text =  YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
            } else {
                rocLabel.text = "--"
            }
            
            if let level = quote?.level?.value, level == 0 {
                delayLabel.isHidden = false
            } else {
                delayLabel.isHidden = true
            }
            
        }
    }
    
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        return line
    }()

    lazy var indexLabel: QMUILabel = {
        let label = QMUILabel(frame: CGRect(x: 0, y: 4, width: 28, height: 16))
        label.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        label.textColor = QMUITheme().themeTextColor()
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        label.text = "1"
        label.layer.cornerRadius = 8
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var nameLabel: YXSecuNameLabel = {
        let label = YXSecuNameLabel()
        label.textColor = UIColor(hexString: "#191919")!
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#191919")?.withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
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
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var lookButton: UIButton = {
        let button = UIButton()
        button.setBtnBgImageGradientBlue()
        button.isHidden = true
        button.setTitle(YXLanguageUtility.kLang(key: "hold_trade_title"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            }).disposed(by: rx.disposeBag)
        return button
    }()
    
    lazy var contentContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        //contentView.addSubview(lookButton)
        contentView.addSubview(contentContentView)
        contentView.addSubview(indexLabel)
        contentContentView.addSubview(priceLabel)
        contentContentView.addSubview(rocLabel)
        contentContentView.addSubview(nameLabel)
        contentContentView.addSubview(symbolLabel)
        contentContentView.addSubview(delayLabel)
        contentView.addSubview(line)

//        lookButton.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-12)
//            make.top.equalTo(29)
//            make.size.equalTo(CGSize(width: 64, height: 32))
//        }
        contentContentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(24)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(22)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.right.equalTo(priceLabel)
            make.top.equalTo(priceLabel.snp.bottom)
            make.width.equalTo(priceLabel)
            make.height.equalTo(17)
        }
        

        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.right.equalTo(priceLabel.snp.left).offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(22)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom)
            make.height.equalTo(17)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(symbolLabel.snp.right).offset(2)
            make.centerY.equalTo(symbolLabel)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
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

        // Configure the view for the selected state
    }

}
