//
//  YXTradeOptionChainView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/1/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit

@objcMembers class YXTradeOptionChainView: UIView, YXTradeHeaderSubViewProtocol {
    
    lazy var baseView: YXInputBaseView = {
        let view = YXInputBaseView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: YXLanguageUtility.kLang(key: "trade_view_options"), attributes:
                                                    [.font: UIFont.systemFont(ofSize: 14),
                                                     .foregroundColor: QMUITheme().textColorLevel3()
                                                    ])
        return label
    }()
    
    lazy var chainButton: QMUIButton = {
        let button = QMUIButton()
        button.setAttributedTitle(NSAttributedString(string: YXLanguageUtility.kLang(key: "trade_options_chain"),
                                                     attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                  .foregroundColor: QMUITheme().textColorLevel1()
                                                     ]),
                                  for: .normal)
        button.imagePosition = .right
        button.setImage(UIImage(named: "optionchain_arrow"), for: .normal)
        button.spacingBetweenImageAndTitle = 4
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(4)
        }
        
        baseView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        
        baseView.addSubview(chainButton)
        chainButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
        }
        
        contentHeight = 44
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
