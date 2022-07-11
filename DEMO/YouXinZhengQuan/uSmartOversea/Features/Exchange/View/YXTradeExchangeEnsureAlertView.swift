//
//  YXTradeExchangeEnsureAlertView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class YXTradeExchangeEnsureAlertView: UIView {
    var completed :(()->Void)?
    
    var cancel :(()->Void)?
    
    let disposeBag = DisposeBag()
    
    private var model: YXCurrencyExchangeModel?
    
    private var sourceType: YXCurrencyType = .hk
    
    private var targetType: YXCurrencyType = .us
    
    private var inputText: String = ""
    
    var didSelected: (Bool)->() = { index in
        
    }
    
    // 取消
    @objc lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().pointColor().cgColor
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.rx.tap.asObservable().subscribe(onNext: {[weak self] (_) in
            self?.didSelected(false)
        }).disposed(by: self.disposeBag)
        return btn
    }()
    
    //确定
    @objc lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        btn.rx.tap.asObservable().subscribe(onNext: {[weak self] (_) in
            self?.didSelected(true)
        }).disposed(by: self.disposeBag)
        return btn
    }()
    
    convenience init(frame: CGRect, sourceType: YXCurrencyType,targetType: YXCurrencyType,model: YXCurrencyExchangeModel?, inputText: String) {
        self.init(frame: frame)
        self.sourceType = sourceType
        self.targetType = targetType
        self.model = model
        self.inputText = inputText
        
        initialUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        //initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //initialUI()
    }
    
    func initialUI() {
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = QMUITheme().backgroundColor()
        
        let horizontalMargin: CGFloat = 16.0
        
        //标题
        let titleLab: UILabel = {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.numberOfLines = 0
            label.text = YXLanguageUtility.kLang(key: "exchange_tip_ensure")
            return label
        }()
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.trailing.equalToSuperview().offset(-horizontalMargin)
            make.top.equalToSuperview().offset(24)
        }
        
        ///兑换方向
        let directionLab: UILabel = self.buildBlackLabel(with: YXLanguageUtility.kLang(key: "exchange_tip_direction"))
        addSubview(directionLab)
        directionLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.top.equalTo(titleLab.snp.bottom).offset(24)
        }
        //从右往左约束 排列
        let dirTargetLab: UILabel = self.buildGrayLabel(with: self.targetType.name())
        let dirArrowImgView = UIImageView(image: UIImage(named: "exchange_blue_right_arrow"))
        let dirSourceLab: UILabel = self.buildGrayLabel(with: self.sourceType.name())
        addSubview(dirTargetLab)
        addSubview(dirArrowImgView)
        addSubview(dirSourceLab)
        dirTargetLab.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-horizontalMargin)
            make.centerY.equalTo(directionLab)
        }
        dirArrowImgView.snp.makeConstraints { (make) in
            make.trailing.equalTo(dirTargetLab.snp.leading).offset(-4)
            make.centerY.equalTo(directionLab)
        }
        dirSourceLab.snp.makeConstraints { (make) in
            make.trailing.equalTo(dirArrowImgView.snp.leading).offset(-4)
            make.centerY.equalTo(directionLab)
            make.leading.greaterThanOrEqualTo(directionLab.snp.trailing)
        }
        
        
        ///兑换金额
        let amountLab: UILabel = self.buildBlackLabel(with: YXLanguageUtility.kLang(key: "exchange_tip_amount"))
        addSubview(amountLab)
        amountLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.top.equalTo(directionLab.snp.bottom).offset(16)
        }
        amountLab.setContentCompressionResistancePriority(.required, for: .horizontal)//setContentHuggingPriority(.defaultHigh, for: .horizontal)
        //TODO: 算金额
        var sourceDouble: Double = 0.0
        var targetDouble: Double = 0.0
        var sourceBalance: Double = 0.0     //source 可用现金
        var targetBalance: Double = 0.0     //target 可用现金
        if self.inputText.count > 0, let textDouble = Double(self.inputText) {
            sourceDouble = textDouble
            targetDouble = getExchangeNumber(with: textDouble)
        }

        if let withdrawBalanceStr = self.model?.sourceWithdrawBalance,
           let withdrawBalance = Double(withdrawBalanceStr) {
            sourceBalance = withdrawBalance
        }

        if let withdrawBalanceStr = self.model?.targetWithdrawBalance,
           let withdrawBalance = Double(withdrawBalanceStr) {
            targetBalance = withdrawBalance
        }

        //从右往左约束 排列
        let amTargetLab: UILabel = self.buildGrayLabel(with: String(format: "%.2f%@", targetDouble, self.targetType.name()))
        let amArrowImgView = UIImageView(image: UIImage(named: "exchange_blue_right_arrow"))
        let amSourceLab: UILabel = self.buildGrayLabel(with: self.inputText + self.sourceType.name())
        //amTargetLab.font = amSourceLab.font
        addSubview(amTargetLab)
        addSubview(amArrowImgView)
        addSubview(amSourceLab)
        amTargetLab.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-horizontalMargin)
            make.centerY.equalTo(amountLab)
        }
        amArrowImgView.snp.makeConstraints { (make) in
            make.trailing.equalTo(amTargetLab.snp.leading).offset(-4)
            make.centerY.equalTo(amountLab)
        }
        amSourceLab.snp.makeConstraints { (make) in
            make.trailing.equalTo(amArrowImgView.snp.leading).offset(-4)
            make.centerY.equalTo(amountLab)
            make.width.equalTo(amTargetLab)
            make.leading.greaterThanOrEqualTo(amountLab.snp.trailing)
        }
        
        ///兑换后%@可用现金 - source
        let leftUseLab: UILabel = self.buildBlackLabel(with: String(format: YXLanguageUtility.kLang(key: "exchange_tip_useable"), self.sourceType.name() ) )
        leftUseLab.font = .systemFont(ofSize: 12)
        addSubview(leftUseLab)

        let useSourceLab: UILabel = self.buildGrayLabel(with: String(format: "%.2f%@", sourceBalance - sourceDouble, self.sourceType.name()))
        useSourceLab.setContentCompressionResistancePriority(.required, for: .horizontal)
        if sourceBalance - sourceDouble < 0.0 {
            useSourceLab.textColor = .red
        }
        addSubview(useSourceLab)

        leftUseLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.centerY.equalTo(useSourceLab)
            make.height.equalTo(30)
        }

        useSourceLab.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-horizontalMargin)
            make.top.equalTo(amountLab.snp.bottom).offset(18)
            make.leading.greaterThanOrEqualTo(leftUseLab.snp.trailing)
        }
        
        ///兑换后%@可用现金  - target
        let rightUseLab: UILabel = self.buildBlackLabel(with: String(format: YXLanguageUtility.kLang(key: "exchange_tip_useable"), self.targetType.name() ))
        rightUseLab.font = .systemFont(ofSize: 12)
        addSubview(rightUseLab)

        let useTargetLab: UILabel = self.buildGrayLabel(with: String(format: "%.2f%@", targetBalance + targetDouble, self.targetType.name()))
        useTargetLab.setContentCompressionResistancePriority(.required, for: .horizontal)
        if targetBalance + targetDouble < 0.0 {
            useTargetLab.textColor = .red
        }
        addSubview(useTargetLab)

        rightUseLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.centerY.equalTo(useTargetLab)
            make.height.equalTo(30)
        }

        useTargetLab.snp.makeConstraints { (make) in
            make.top.equalTo(useSourceLab.snp.bottom).offset(18)
            make.trailing.equalToSuperview().offset(-horizontalMargin)
            make.leading.greaterThanOrEqualTo(rightUseLab.snp.trailing)
        }
        
        //底部提示
        let bottomLab: UILabel = {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel3()
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.numberOfLines = 0
            label.text = YXLanguageUtility.kLang(key: "exchange_tip_bottom")
            return label
        }()
        addSubview(bottomLab)
        bottomLab.snp.makeConstraints { (make) in
            make.top.equalTo(useTargetLab.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(horizontalMargin)
            make.trailing.equalToSuperview().offset(-horizontalMargin)
        }

        let btnWidth = (self.frame.size.width - 48) / 2.0
        //取消
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(btnWidth)
            make.height.equalTo(36)
        }

        //确认
        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(btnWidth)
            make.height.equalTo(36)
        }
        
    }
    
    fileprivate func buildBlackLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 14.0
        label.numberOfLines = 0
        label.text = title
        return label
    }
    fileprivate func buildGrayLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 0
        label.text = title
        return label
    }
    
    //可兑换金额  和 YXTradeExchangeView 的  initExchangeNumber 方法一样的计算方式
    func getExchangeNumber(with source: Double) -> Double {
        if let model = self.model,
            let rateStr = model.rate,
            let rate = Double(rateStr) {

            var value: Double = 0
            if model.targetCurrency == model.baseCurrency {
                value = source / rate
            } else {
                value = source * rate
            }

            return floor(value * 100) / 100.00
        }
        return 0.0
    }
    
}
