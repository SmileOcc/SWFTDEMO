//
//  YXHistoryTableViewCell1.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXHistoryTableViewCell1: UITableViewCell {
    let disposeBag = DisposeBag()
    var model: YXHistoryList?
        
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = QMUITheme().foregroundColor()
        containerView.layer.cornerRadius = 10
        return containerView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        return titleLabel
    }()
    
    lazy var statusButton: QMUIButton = {
        let statusButton = QMUIButton()
        statusButton.setTitleColor(UIColor.qmui_color(withHexString: "#415CFD"), for: .normal)
        statusButton.titleLabel?.textAlignment = .right
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        statusButton.titleLabel?.lineBreakMode = .byTruncatingTail
        statusButton.titleLabel?.adjustsFontSizeToFitWidth = true
        statusButton.titleLabel?.minimumScaleFactor = 0.3
        statusButton.contentHorizontalAlignment = .right
        return statusButton
    }()
    
    lazy var leftLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var leftLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var leftLabel3: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rightLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rightLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rightLabel3: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialUI() {
        
        backgroundColor = QMUITheme().blockColor()
        
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(163)
        }
        
        // title部分
        self.containerView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        self.titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        self.titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751.0), for: .horizontal)
        
        self.containerView.addSubview(self.statusButton)
        self.statusButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }

        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        self.containerView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(50)
            make.height.equalTo(0.5)
        }
        
        // 第一行文字
        self.containerView.addSubview(self.leftLabel1)
        self.leftLabel1.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(line.snp.bottom).offset(15)
            make.width.lessThanOrEqualTo(120)
        }
        
        self.leftLabel1.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        self.leftLabel1.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751.0), for: .horizontal)
        
        self.containerView.addSubview(self.rightLabel1)
        self.rightLabel1.snp.makeConstraints { (make) in
            make.leading.equalTo(self.leftLabel1.snp.trailing).offset(8)
            make.centerY.equalTo(self.leftLabel1.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 第二行文字
        self.containerView.addSubview(self.leftLabel2)
        self.leftLabel2.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(self.leftLabel1.snp.bottom).offset(16)
            make.width.lessThanOrEqualTo(120)
        }
        
        self.leftLabel2.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        self.leftLabel2.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751.0), for: .horizontal)
        
        self.containerView.addSubview(self.rightLabel2)
        self.rightLabel2.snp.makeConstraints { (make) in
            make.leading.equalTo(self.leftLabel2.snp.trailing).offset(8)
            make.centerY.equalTo(self.leftLabel2.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 第三行文字
        self.containerView.addSubview(self.leftLabel3)
        self.leftLabel3.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(self.leftLabel2.snp.bottom).offset(16)
            make.width.lessThanOrEqualTo(120)
        }
        
        self.leftLabel3.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        self.leftLabel3.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751.0), for: .horizontal)
        
        self.containerView.addSubview(self.rightLabel3)
        self.rightLabel3.snp.makeConstraints { (make) in
            make.leading.equalTo(self.leftLabel3.snp.trailing).offset(8)
            make.centerY.equalTo(self.leftLabel3.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func refreshUI() {
        if let model = model {
            self.titleLabel.text = model.title

            if model.type == YXHistoryList.BizType.withdraw.rawValue {
                self.leftLabel1.text = YXLanguageUtility.kLang(key: "history_withdraw_money")
                self.leftLabel2.text = YXLanguageUtility.kLang(key: "history_starting_time")
                self.rightLabel1.text = model.occurBalance?.isEmpty ?? true ? "--" : model.occurBalance
                self.rightLabel2.text = YXDateHelper.commonDateString(model.applyTime, format: .DF_MDYHM)
                                                
                self.leftLabel3.isHidden = true
                self.rightLabel3.isHidden = true

                self.containerView.snp.updateConstraints { (make) in
                    make.height.equalTo(128)
                }
            } else {
                if model.type == YXHistoryList.BizType.deposit.rawValue {
                    // 入金
                    self.leftLabel1.text = YXLanguageUtility.kLang(key: "history_notify_money")
                    self.leftLabel2.text = YXLanguageUtility.kLang(key: "history_real_money")
                    self.leftLabel3.text = YXLanguageUtility.kLang(key: "history_starting_time")
                } else {
                    // 货币兑换
                    self.leftLabel1.text = YXLanguageUtility.kLang(key: "history_exchange_money")
                    self.leftLabel2.text = YXLanguageUtility.kLang(key: "history_exchange_result")
                    self.leftLabel3.text = YXLanguageUtility.kLang(key: "history_starting_time")
                }
                self.rightLabel1.text = model.occurBalance?.isEmpty ?? true ? "--" : model.occurBalance
                self.rightLabel2.text = model.postBalance?.isEmpty ?? true ? "--" : model.postBalance
                self.rightLabel3.text = YXDateHelper.commonDateString(model.applyTime, format: .DF_MDYHM)
                
                self.leftLabel3.isHidden = false
                self.rightLabel3.isHidden = false
                self.containerView.snp.updateConstraints { (make) in
                    make.height.equalTo(163)
                }
            }

            self.statusButton.setTitle(model.statusDesc, for: .normal)
            self.statusButton.setTitleColor(model.statusColor, for: .normal)
        }
    }
}
