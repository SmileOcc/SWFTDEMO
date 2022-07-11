//
//  YXIntradayHoldCloseCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayHoldCloseCell: UITableViewCell {

    lazy var rightTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.text = ""
        return label
    }()
    
    lazy var rightOneValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    lazy var rightTwoValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    lazy var rightThreeValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    lazy var rightFourValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    lazy var rightFiveValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return view
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        
        let flagLabel = QMUILabel()
        flagLabel.backgroundColor = UIColor.qmui_color(withHexString: "#2F79FF")
        contentView.addSubview(flagLabel)
        let titleLeftLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "close_position"), color: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 16))
        contentView.addSubview(titleLeftLabel)
        contentView.addSubview(rightTimeLabel)
        
        titleLeftLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(22)
        }
        flagLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
            make.centerY.equalTo(titleLeftLabel)
        }
        rightTimeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLeftLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftOneLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "pingcang_avg_price"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftOneLabel)
        contentView.addSubview(rightOneValueLabel)
        leftOneLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(titleLeftLabel.snp.bottom).offset(14)
            make.height.equalTo(22)
        }
        rightOneValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftOneLabel.snp.centerY)
            make.height.equalTo(22)
        }
       
        let leftTwoLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_transaction_num"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftTwoLabel)
        contentView.addSubview(rightTwoValueLabel)
        leftTwoLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftOneLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightTwoValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftTwoLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftThreeLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_transaction_money"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftThreeLabel)
        contentView.addSubview(rightThreeValueLabel)
        leftThreeLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftTwoLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightThreeValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftThreeLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftFourLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "yingkui_money"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftFourLabel)
        contentView.addSubview(rightFourValueLabel)
        leftFourLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftThreeLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightFourValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftFourLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftFiveLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "yingkui_ratio"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftFiveLabel)
        contentView.addSubview(rightFiveValueLabel)
        leftFiveLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftFourLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightFiveValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftFiveLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func createLabel(text:String, color:UIColor, font:UIFont) -> UILabel {
        let label = QMUILabel()
        label.textColor = color
        label.font = font
        label.text = text
        
        return label
    }
    
    var model:YXIntradayCloseRespModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let model = model {
            let numberFormatter = NumberFormatter()
            numberFormatter.positiveFormat = "###,##0.00"
            numberFormatter.locale = Locale(identifier: "zh")
            let countFormatter = NumberFormatter()
            countFormatter.positiveFormat = "###,##0"
            countFormatter.locale = Locale(identifier: "zh")
            
            rightTimeLabel.text = model.sellLastTime
          
            rightOneValueLabel.text = model.sellPrice
            
            if let num = model.sellNum {
                rightTwoValueLabel.text = (countFormatter.string(from: num) ?? "0") + "股"
            }
            if let sellbalance = model.sellBalance {
                rightThreeValueLabel.text = String(format: "%.3f", sellbalance.floatValue)
            }
           
            
            if let profit = model.totalProfit {
                var profitStr:String = String(format: "%.2f", profit.floatValue)
                var profitColor:UIColor = QMUITheme().stockGrayColor()
                if profit.floatValue > 0 {
                    profitStr = "+" + String(format: "%.2f", profit.floatValue)
                    profitColor = QMUITheme().stockRedColor()
                }else if profit.floatValue < 0{
                    profitStr = String(format: "%.2f", profit.floatValue)
                    profitColor = QMUITheme().stockGreenColor()
                    
                }
                rightFourValueLabel.text = profitStr
                rightFourValueLabel.textColor = profitColor
            }
      
            if let profit = model.totalProfitRatio {
                var profitStr:String = String(format: "%.2f%%", profit.floatValue * 100)
                var profitColor:UIColor = QMUITheme().stockGrayColor()
                if profit.floatValue > 0 {
                    profitStr = String(format: "%.2f%%", profit.floatValue * 100)
                    profitColor = QMUITheme().stockRedColor()
                }else if profit.floatValue < 0{
                    profitStr = String(format: "%.2f%%", profit.floatValue * 100)
                    profitColor = QMUITheme().stockGreenColor()
                    
                }
                rightFiveValueLabel.text = profitStr
                rightFiveValueLabel.textColor = profitColor
            }
        }
    }
}
