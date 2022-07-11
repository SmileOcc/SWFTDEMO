//
//  YXMarketHSFundCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXMarketHSFundCell: UICollectionViewCell, HasDisposeBag {
    
    typealias QuestionActionClosure = () -> Void
    
    @objc var questionActionClosure: QuestionActionClosure?
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var questionButton: YXExpandAreaButton = {
        let image = UIImage.init(named: "analyze_info")
        let button = YXExpandAreaButton.init(type: .custom)
        button.setImage(image, for: .normal)
        button.target(forAction: #selector(questionAction), withSender: self)
        button.rx.tap.subscribe(onNext: {[weak self] in
            let msg = YXLanguageUtility.kLang(key: "markets_news_cn_formula")
            let alertView = YXAlertView.init(title: nil, message: msg, prompt: nil, style: .default, messageAlignment: .left)
            alertView.clickedAutoHide = false
            
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
                alertView.hide()
            }))
            
            alertView.showInWindow()

            }).disposed(by: disposeBag)
        return button
    }()
    
    fileprivate lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_balance")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var balanceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "markets_news_remaining")
        return label
    }()
    
    fileprivate lazy var ratioValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left;
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    @objc func questionAction() {
        if let action = questionActionClosure {
            action()
        }
    }
    
    var info: YXMarketHSSCMItem? {
        didSet {
            updateInfo()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateInfo() {
        if let code = info?.code, code == "HKSCSH" {
            titleLabel.text = YXLanguageUtility.kLang(key: "markets_news_sh_balance")
            questionButton.isHidden = true
            
        }else if let code = info?.code, code == "HKSCSZ" {
            questionButton.isHidden = false
            titleLabel.text = YXLanguageUtility.kLang(key: "markets_news_sz_balance")
        }else {
            questionButton.isHidden = true
            titleLabel.text = "--"
        }
        
        if titleLabel.text?.count ?? 0 > 8 {
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(5)
                make.centerX.equalTo(self)
                make.width.lessThanOrEqualToSuperview().offset(10)
            }
            titleLabel.font = .systemFont(ofSize: 12)
        }else {
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(15)
                make.centerX.equalTo(self)
                make.width.lessThanOrEqualToSuperview().offset(10)
            }
            titleLabel.font = .systemFont(ofSize: 14)
        }
        
        if let posAmt = info?.posAmt {
            balanceValueLabel.text = YXToolUtility.stockData(Double(posAmt), deciPoint: 2, stockUnit: "", priceBase: (info?.priceBase ?? 0))
        }else {
            balanceValueLabel.text = "--"
        }
        
        if let posAmt = info?.posAmt, let thresholdAmount = info?.thresholdAmount {
            if Double(thresholdAmount) == 0 {
                ratioValueLabel.text = "--"
            }else {
                ratioValueLabel.text = String(format: "%.2lf%%", Double(posAmt)/Double(thresholdAmount)*100.0)
            }
        }else {
            ratioValueLabel.text = "--"
        }
        
    }
    
    fileprivate func initializeViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(questionButton)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(balanceValueLabel)
        contentView.addSubview(ratioLabel)
        contentView.addSubview(ratioValueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.centerX.equalTo(self)
            make.width.lessThanOrEqualToSuperview().offset(5)
        }

        if YXUserManager.isENMode() {
            questionButton.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(1)
                make.width.height.equalTo(20)
                make.centerX.equalTo(titleLabel).offset(23)
            }
        } else {
            questionButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.width.height.equalTo(30)
                make.left.equalTo(titleLabel.snp.right).offset(-5)
            }
        }
        
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(9)
        }
        
        balanceValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(2)
            make.left.equalTo(balanceLabel)
            make.right.lessThanOrEqualToSuperview()
        }
        
        ratioLabel.snp.makeConstraints { (make) in
            make.top.equalTo(balanceValueLabel.snp.bottom).offset(10)
            make.left.equalTo(balanceLabel)
        }
        
        ratioValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(ratioLabel.snp.bottom).offset(2)
            make.left.equalTo(ratioLabel)
            make.right.lessThanOrEqualToSuperview()
        }
    }
}
