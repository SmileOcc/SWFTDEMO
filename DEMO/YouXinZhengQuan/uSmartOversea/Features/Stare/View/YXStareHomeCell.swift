//
//  YXStareHomeCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXStareHomeCell: UITableViewCell {
    
    var stareView: YXStareHomeView
    
    @objc var model: YXStareSignalModel? {
        didSet {
            self.stareView.model = self.model

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        stareView = YXStareHomeView.init(frame: .zero, isMarketPage: false)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
//        self.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(stareView)
        stareView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



class YXStareHomeView: UIView {
    
    @objc var model: YXStareSignalModel? {
        didSet {
            if let model = self.model {
                
                self.timeLabel.text = model.unixTimeStr;
                self.stockLabel.text = model.stockName;
                if isMarkMarket {
                    var market = "US."
                    if model.stockCode.hasPrefix("hk") || model.stockCode.hasPrefix("HK") {
                        market = "HK."
                    }
                    self.stockLabel.text = market + model.stockName;
                }
                self.typeLabel.text = model.signalName;
                
                var color = QMUITheme().stockGrayColor()
                
                if model.color == "1" {
                    color = QMUITheme().stockRedColor()
                } else if model.color == "0" {
                    color = QMUITheme().stockGrayColor()
                } else {
                    color = QMUITheme().stockGreenColor()
                }
                self.typeLabel.textColor = color
                self.dataLabel.textColor = color
                
                if let subModel = model.subModel {
                    var str = ""
                    if model.signalId == 7 || model.signalId == 8 || model.signalId == 9 {
                        // 区间放量
                        if let multiple = subModel.multiple {
                            str += multiple
                        }
                        if let amplitude = subModel.amplitude {
                            if str.count > 0 {
                                str += "\n"
                            }
                            str += amplitude
                        }
                        
                    } else if model.signalId == 1 || model.signalId == 2 {
                        // 大幅信号
                        if let amplitude = subModel.amplitude {
                            str += amplitude
                        }
                        if let price = subModel.price {
                            if str.count > 0 {
                                str += "\n"
                            }
                            str += price
                        }
                        
                    } else if model.signalId == 15 || model.signalId == 16 {
                        // 历史新高低
                        if let price = subModel.price {
                             str += price
                         }
                    } else if model.signalId == 3 || model.signalId == 4 {
                        // 急速信
                        if let amplitude = subModel.amplitude {
                            str += amplitude
                        }
//                        if let amplitude = subModel.amplitude {
//                            if str.count > 0 {
//                                str += "\n"
//                            }
//                            str += amplitude
//                        }
                    } else if model.signalId == 5 || model.signalId == 6 {
                        // 大笔买入卖出
                        if let lots = subModel.lots {
                            str += lots
                        }
                        if let tradePrice = subModel.tradePrice {
                            if str.count > 0 {
                                str += "\n"
                            }
                            str += tradePrice
                        }
                    } else {
                        // 打开涨停,涨停,打开跌停,跌停 ...
                        if let price = subModel.price {
                            str += price
                        }
                        if let amplitude = subModel.amplitude {
                            if str.count > 0 {
                                str += "\n"
                            }
                            str += amplitude
                        }
                    }
                    let array = str.components(separatedBy: "\n")
                    self.dataLabel.numberOfLines = array.count;
                    self.dataLabel.text = str
                    if isOptional {
                        if self.dataLabel.numberOfLines == 1 {
                            self.dataLabel.font = UIFont.systemFont(ofSize: 12)
                        } else {
                            self.dataLabel.font = UIFont.systemFont(ofSize: 10)
                        }
                    }
                }
            }
            
        }
    }
    
    var timeLabel: UILabel
    var stockLabel: UILabel
    var typeLabel: UILabel
    var dataLabel: UILabel
    
    var isMarketPage = false
    var isOptional = false
    var isMarkMarket = false

    let lineView = UIView.init()
    
    convenience init(frame: CGRect, isMarketPage: Bool) {
        self.init(frame: frame)
        self.isMarketPage = isMarketPage
        initUI()
    }
    
    override init(frame: CGRect) {
        
        self.timeLabel = UILabel.init(text: "--", textColor: UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65), textFont: UIFont.systemFont(ofSize: 14))
        self.stockLabel = UILabel.init(text: "--", textColor: UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65), textFont: UIFont.systemFont(ofSize: 14))
        self.typeLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))
        self.dataLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))
        self.dataLabel.adjustsFontSizeToFitWidth = true
        self.dataLabel.minimumScaleFactor = 0.6
        self.dataLabel.numberOfLines = 0;
        self.dataLabel.textAlignment = .right
        self.stockLabel.minimumScaleFactor = 12 / 14.0
        self.stockLabel.adjustsFontSizeToFitWidth = true
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension YXStareHomeView {

    func optionalConfig() {
        isOptional = true
        self.timeLabel.textColor = QMUITheme().textColorLevel1()
        self.timeLabel.font = UIFont.systemFont(ofSize: 14)

        self.stockLabel.textColor = QMUITheme().textColorLevel1()
        self.stockLabel.font = UIFont.systemFont(ofSize: 12)

        self.typeLabel.textColor = QMUITheme().textColorLevel1()
        self.typeLabel.font = UIFont.systemFont(ofSize: 12)

        self.dataLabel.textColor = QMUITheme().textColorLevel1()
        self.dataLabel.font = UIFont.systemFont(ofSize: 12)

        self.dataLabel.adjustsFontSizeToFitWidth = true
        self.dataLabel.minimumScaleFactor = 0.6
        self.dataLabel.numberOfLines = 0;
        self.dataLabel.textAlignment = .right
        self.stockLabel.minimumScaleFactor = 0.8
        self.stockLabel.adjustsFontSizeToFitWidth = true

        lineView.backgroundColor = QMUITheme().separatorLineColor()

        let scale = UIScreen.main.bounds.size.width / 375.0
        typeLabel.snp.updateConstraints { (make) in
            make.trailing.equalToSuperview().offset(-scale * 80)
        }
    }

    func initUI() {

        lineView.backgroundColor = QMUITheme().separatorLineColor()
        if self.isMarketPage {
            self.timeLabel.textColor = QMUITheme().textColorLevel1()
            self.stockLabel.textColor = QMUITheme().textColorLevel1()
            self.typeLabel.textColor = QMUITheme().textColorLevel1()
            self.dataLabel.textColor = QMUITheme().textColorLevel1()
            lineView.backgroundColor = QMUITheme().separatorLineColor()
        }
        
        let scale = UIScreen.main.bounds.size.width / 375.0
                        
        
        addSubview(timeLabel)
        addSubview(typeLabel)
        addSubview(stockLabel)
        addSubview(dataLabel)
        addSubview(lineView)
        
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        typeLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-scale * 104)
            make.centerY.equalToSuperview()
        }
        stockLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(scale * 84)
            make.centerY.top.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualTo(typeLabel.snp.leading).offset(-10)
        }
        dataLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(typeLabel.snp.trailing).offset(2)
        }
        lineView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

    }
}
