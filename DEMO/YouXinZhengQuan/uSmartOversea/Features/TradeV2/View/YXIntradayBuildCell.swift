//
//  YXIntradayBuildCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayBuildCell: UITableViewCell {

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
    
    lazy var rightSixValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    
    lazy var rightSevenValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    lazy var rightEightValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
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
        self.selectionStyle = .none
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
        let titleLeftLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_intraday"), color: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 16))
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
        
        let leftOneLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "trading_order_type"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
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
       
        let leftTwoLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_price_in"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
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
        
        let leftThreeLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "quantity"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
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
        
        let leftFourLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_money_in"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
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
        
        let leftFiveLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_money_amout"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
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
        
        let leftSixLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "hold_gangan"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftSixLabel)
        contentView.addSubview(rightSixValueLabel)
        leftSixLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftFiveLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightSixValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftSixLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftSevenLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "intraday_stop_loss_ratio"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftSevenLabel)
        contentView.addSubview(rightSevenValueLabel)
        leftSevenLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftSixLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightSevenValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftSevenLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        let leftEightLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "intraday_stop_win_ratio"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftEightLabel)
        contentView.addSubview(rightEightValueLabel)
        leftEightLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftSevenLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        rightEightValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftEightLabel.snp.centerY)
            make.height.equalTo(22)
        }
    }
    
    func createLabel(text:String, color:UIColor, font:UIFont) -> UILabel {
        let label = QMUILabel()
        label.textColor = color
        label.font = font
        label.text = text
        
        return label
    }
    
    var model:YXIntradayOpenRespModel? {
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
            
            rightTimeLabel.text = model.buyDate
            
            var title:String = YXLanguageUtility.kLang(key: "trade_market_order")
            if model.entrustProp == "e" {
                title = YXLanguageUtility.kLang(key: "limit_enhanced_order")
            }
            rightOneValueLabel.text = title
            if let price = model.buyPrice {
                rightTwoValueLabel.text = String(format: "%.3f", price.floatValue)
            }
            if let num = model.buyNum {
                rightThreeValueLabel.text = (countFormatter.string(from: num) ?? "0") + "股"
            }
            
            let moneyType = model.moneyType
            var currency:String = ""
            if moneyType == 1 {
                currency = YXLanguageUtility.kLang(key: "common_us_dollar")
            } else if moneyType == 2 {
                currency = YXLanguageUtility.kLang(key: "common_hk_dollar")
            } else {
                currency = YXLanguageUtility.kLang(key: "common_rmb")
            }
            if let buyBalance = model.buyBalance {
                rightFourValueLabel.text = (numberFormatter.string(from: buyBalance) ?? "0") + currency
            }
            rightFiveValueLabel.text = model.marginAfter + currency
            
            rightSixValueLabel.text = model.actualLeverAfter + "X"
          
            if let stoploss = model.stopLossRateAfter {
                rightSevenValueLabel.text =  String(format: "%d%%", Int(stoploss.floatValue * 100))
            }
          
            if let stopWin = model.stopWinRateAfter {
                rightEightValueLabel.text = String(format: "%d%%", Int(stopWin.floatValue * 100))
            }
        }
    }
}
