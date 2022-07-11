//
//  YXIntradayChangeMoneyCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayChangeMoneyCell: UITableViewCell {
    
    var titleLeftLabel:QMUILabel = QMUILabel()
    
    lazy var rightTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.text = ""
        return label
    }()
    
    var leftOneLabel:QMUILabel = QMUILabel()
    
    lazy var rightOneValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    
    lazy var midOneValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    
    var leftTwoLabel:QMUILabel = QMUILabel()
    
    lazy var rightTwoValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = ""
        return label
    }()
    
    lazy var midTwoValueLabel: QMUILabel = {
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
        let titleLeftLab:QMUILabel = createLabel(text: "", color: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 16))
        titleLeftLabel = titleLeftLab
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
        
        let leftLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "webview_detailTitle"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftLabel)
        let midLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "change_pre"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(midLabel)
        let rightLabel:UILabel = createLabel(text: YXLanguageUtility.kLang(key: "adjust_margin_after"), color: QMUITheme().textColorLevel1().withAlphaComponent(0.5), font: .systemFont(ofSize: 14))
        contentView.addSubview(rightLabel)
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(titleLeftLabel.snp.bottom).offset(14)
            make.height.equalTo(22)
        }
        midLabel.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(50)
            make.centerY.equalTo(leftLabel.snp.centerY)
            make.height.equalTo(22)
        }
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftLabel.snp.centerY)
            make.height.equalTo(22)
        }
        
        leftOneLabel = createLabel(text: "", color: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftOneLabel)
        contentView.addSubview(midOneValueLabel)
        contentView.addSubview(rightOneValueLabel)
        leftOneLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        midOneValueLabel.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(50)
            make.centerY.equalTo(leftOneLabel.snp.centerY)
            make.height.equalTo(22)
        }
        rightOneValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftOneLabel.snp.centerY)
            make.height.equalTo(22)
        }
       
        leftTwoLabel = createLabel(text: "", color: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 14))
        contentView.addSubview(leftTwoLabel)
        contentView.addSubview(midTwoValueLabel)
        contentView.addSubview(rightTwoValueLabel)
        leftTwoLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLeftLabel)
            make.top.equalTo(leftOneLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        midTwoValueLabel.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(50)
            make.centerY.equalTo(leftTwoLabel.snp.centerY)
            make.height.equalTo(22)
        }
        rightTwoValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftTwoLabel.snp.centerY)
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
    
    func createLabel(text:String, color:UIColor, font:UIFont) -> QMUILabel {
        let label = QMUILabel()
        label.textColor = color
        label.font = font
        label.text = text
        
        return label
    }
    
    var model:YXIntradayShippingListModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let model = model {
            let numberFormatter = NumberFormatter()
            numberFormatter.positiveFormat = "###,##0.00"
            numberFormatter.locale = Locale(identifier: "zh")
            if model.changeType == 1 {
                titleLeftLabel.text = YXLanguageUtility.kLang(key: "adjust_margin_title")
                leftOneLabel.text = YXLanguageUtility.kLang(key: "hold_baozheng_money")
                leftTwoLabel.text = YXLanguageUtility.kLang(key: "stock_detail_effect_gear")
                if let before = model.marginBefore {
                    midOneValueLabel.text = numberFormatter.string(from: before)
                }
                if let after = model.marginAfter {
                    rightOneValueLabel.text = numberFormatter.string(from: after)
                }
                midTwoValueLabel.text = model.actualLeverBefore + "X"
                rightTwoValueLabel.text = model.actualLeverAfter + "X"

            }else {
                titleLeftLabel.text = YXLanguageUtility.kLang(key: "change_up_down_ratio")
                leftOneLabel.text = YXLanguageUtility.kLang(key: "intraday_stop_loss_ratio")
                leftTwoLabel.text = YXLanguageUtility.kLang(key: "intraday_stop_win_ratio")
                if let before = model.stopLossRateBefore {
                    midOneValueLabel.text =  String(format: "%d%%", Int(before.floatValue * 100))
                }
                if let after = model.stopLossRateAfter {
                    rightOneValueLabel.text = String(format: "%d%%", Int(after.floatValue * 100))
                }
                if let before = model.stopWinRateBefore {
                    midTwoValueLabel.text =  String(format: "%d%%", Int(before.floatValue * 100))
                }
                if let after = model.stopWinRateAfter {
                    rightTwoValueLabel.text = String(format: "%d%%", Int(after.floatValue * 100))
                }
            }
           
            rightTimeLabel.text = model.updateTime
        }
    }
}
