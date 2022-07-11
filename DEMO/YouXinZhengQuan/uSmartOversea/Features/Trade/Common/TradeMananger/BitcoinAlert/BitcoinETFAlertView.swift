//
//  BitcoinAlert.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/6/17.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import TYAlertController

@objcMembers class BitcoinETFAlertView: UIView {

    var totalHeight: CGFloat {
        return messageHeight + chooseHeight + 20 + 20
    }
        
    private var messageHeight: CGFloat = 0
    private var chooseHeight: CGFloat = 0

    private lazy var messageLabel: YYLabel = {
        let label = YYLabel()
        let string = YXLanguageUtility.kLang(key: "bitcoin_etf_alert")
        let attributeString = NSMutableAttributedString(string: string,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                     .foregroundColor: QMUITheme().textColorLevel2()])
        let range = (string as NSString).range(of: YXLanguageUtility.kLang(key: "bitcoin_etf_doc_title"))
        attributeString.yy_setUnderlineStyle(.single, range: range)
        attributeString.yy_setUnderlineColor(QMUITheme().themeTintColor(), range: range)
        attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTintColor(), backgroundColor: nil) { [weak self] _, _, _, _ in
            self?.viewController().dismiss(animated: true, completion: {
                YXWebViewModel.pushToWebVC(YXH5Urls.bitcoinETFDocUrl())
            })
        }
        label.textVerticalAlignment = .top
        label.numberOfLines = 0
        label.attributedText = attributeString
        messageHeight = attributeString.height(limitWidth: self.width - 32)
        return label
    }()
    
    lazy var chooseLabel: YYLabel = {
        let label = YYLabel()
        let string = YXLanguageUtility.kLang(key: "bitcoin_etf_agree")
        
        let attributeString = NSMutableAttributedString(string: string,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                     .foregroundColor: QMUITheme().textColorLevel1()])
        label.textVerticalAlignment = .top
        label.numberOfLines = 0
        label.attributedText = attributeString
        chooseHeight = attributeString.height(limitWidth: self.width - 60)
        return label
    }()
    
    lazy var chooseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        btn.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .selected)
        btn.isSelected = true
        btn.qmui_tapBlock = { sender in
            if let button = sender {
                button.isSelected = !button.isSelected
            }
        }
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 285, height: 100))
        
        initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialUI() {
        
        addSubview(messageLabel)
        addSubview(chooseLabel)
        addSubview(chooseBtn)
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(messageHeight)
        }
        
        chooseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.width.equalTo(self.width - 60)
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.height.equalTo(chooseHeight)
        }
        
        chooseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(messageLabel)
            make.centerY.height.equalTo(chooseLabel)
        }

        frame = CGRect(x: 0, y: 0, width: 285, height: totalHeight)
      }
}
