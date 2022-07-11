//
//  YXNewStockUSConfirmView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

let USRuleUrl5130 = "https://www.finra.org/rules-guidance/rulebooks/finra-rules/5130"
let USRuleUrl5131 = "https://www.finra.org/rules-guidance/rulebooks/finra-rules/5131"

class YXNewStockUSConfirmView: UIView {
    
    var subscribeRulesBlock: ((_ url: String, _ title: String) -> Void)?
    var purchaseButtonEnabled: ((_ isEnable: Bool) -> Void)?
    
    
    func refreshUI(_ userName: String) {
        let placeholderString = YXLanguageUtility.kLang(key: "newStock_signature_input_tip") + ":" +  userName
        signatureTextField.attributedPlaceholder = NSAttributedString.init(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
    }
    
    func refreshEnabled() {
        if ruleView1.isSelected, ruleView2.isSelected, ruleView3.isSelected,
            ruleView4.isSelected, ruleView5.isSelected, ruleView6.isSelected, ruleView7.isSelected, ruleView8.isSelected, let text = signatureTextField.text, text.count > 0 {
            purchaseButtonEnabled?(true)
        } else {
            purchaseButtonEnabled?(false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        
        signatureTextField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
                self.refreshEnabled()
                
            }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("YXNewStockSubsTypeView init error")
    }
    
    func initializeView() {
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(ruleView1)
        addSubview(ruleView2)
        addSubview(ruleView3)
        addSubview(ruleView4)
        addSubview(ruleView5)
        addSubview(ruleView6)
        addSubview(ruleView7)
        addSubview(ruleView8)

        
        let margin: CGFloat = 18
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-margin)
        }
        titleLabel.text = YXLanguageUtility.kLang(key: "us_stock_subscribe_declare")
        
        let tipMessage = String(format: YXLanguageUtility.kLang(key: "us_stock_subscribe_declare_tip"), YXLanguageUtility.kLang(key: "us_rule_5130"), YXLanguageUtility.kLang(key: "us_rul3_5131"))
        let height = (tipMessage as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 2 * margin, height: 500), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.height + 3.0
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(height)
        }
        
        ruleView1.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(contentLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView1.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule1")
        
        ruleView2.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView1.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView2.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule2")
        
        ruleView3.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView2.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView3.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule3")
        
        ruleView4.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView3.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView4.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule4")
        
        ruleView5.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView4.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView5.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule5")
        
        ruleView6.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView5.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView6.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule6")
        
        ruleView7.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView6.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView7.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule7")
        
        ruleView8.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(ruleView7.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-margin)
        }
        ruleView8.contentLabel.text = YXLanguageUtility.kLang(key: "stock_subscribe_rule8")
        
        
        addSubview(signatureLabel)
        addSubview(signatureTextField)
        addSubview(lineView)
        
        signatureLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(self.snp.right).offset(-margin)
            make.top.equalTo(ruleView8.snp.bottom).offset(30)
        }
        
        signatureTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(self.snp.right).offset(-margin)
            make.top.equalTo(signatureLabel.snp.bottom).offset(10)
            make.height.equalTo(25)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(self.snp.right).offset(-margin)
            make.top.equalTo(signatureTextField.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        
        do {
            
            let urlStrings: [String] = [USRuleUrl5130, USRuleUrl5131]
            let webTitles: [String] = [YXLanguageUtility.kLang(key: "us_rule_5130"), YXLanguageUtility.kLang(key: "us_rul3_5131")]
            
            
            let agreeString = tipMessage
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 2
            let attributeString = NSMutableAttributedString.init(string: agreeString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.paragraphStyle : paragraph])
            
            for (index, string) in webTitles.enumerated() {
                let range = (agreeString as NSString).range(of: string)
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], range: range)
                
                attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTextColor(), backgroundColor: UIColor.clear, tapAction: { [weak self] (view, attstring, range, rect) in
                    guard let `self` = self else { return }
                    
                    self.signatureTextField.resignFirstResponder()
                    var webTitle = ""
                    if index < webTitles.count {
                        webTitle = webTitles[index]
                    }
                    if index < urlStrings.count, urlStrings[index].count > 0 {
                        self.subscribeRulesBlock?(urlStrings[index], webTitle)
                    }
                })
            }
            
            contentLabel.attributedText = attributeString
         
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    lazy var contentLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var ruleView1: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView2: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView3: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView4: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView5: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView6: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView7: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var ruleView8: YXNewStockUSConfirmRuleView = {
        let view = YXNewStockUSConfirmRuleView()
        view.selectButton.isSelected = true
        view.isSelected = true
        view.selectBlock = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.refreshEnabled()
        }
        return view
    }()
    
    lazy var signatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sign")
        return label
    }()
    
    lazy var signatureTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = QMUITheme().textColorLevel1()
        textField.textAlignment = .left
        textField.attributedPlaceholder = NSAttributedString.init(string: YXLanguageUtility.kLang(key: "newStock_signature_input_tip"), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        return textField
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()

}

class YXNewStockUSConfirmRuleView: UIView {
    
    var isSelected: Bool = false
    
    var selectBlock: ((_ isSelected: Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        self.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
            self.selectButton.isSelected = !self.selectButton.isSelected
            self.isSelected = !self.isSelected
            self.selectBlock?(self.isSelected)
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("YXNewStockSubsTypeView init error")
    }
    
    func initializeView() {
        addSubview(selectButton)
        addSubview(contentLabel)
        selectButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.equalTo(14)
            make.top.equalToSuperview().offset(2)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(selectButton.snp.right).offset(5)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    
    @objc func selectButtonAction() {
        selectButton.isSelected = !selectButton.isSelected
        isSelected = !isSelected
        selectBlock?(isSelected)
    }
    
    lazy var selectButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "confirm_unchoose"), for: .normal)
        button.setImage(UIImage(named: "confirm_choose"), for: .selected)
        button.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
}
