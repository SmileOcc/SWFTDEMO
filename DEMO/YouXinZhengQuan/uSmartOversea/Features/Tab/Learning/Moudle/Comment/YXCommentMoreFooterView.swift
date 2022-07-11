//
//  YXCommentMoreView.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/27.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit

class YXCommentMoreFooterView: UIView {
    
    lazy var moreButton: QMUIButton = {
        let more = QMUIButton()
        more.imagePosition = .right
        more.setTitle(YXLanguageUtility.kLang(key: "beerich_comment_btn_more"), for: .normal)
        more.setTitle(YXLanguageUtility.kLang(key: "beerich_comment_btn_less"), for: .selected)
        more.titleLabel?.font = .systemFont(ofSize: 14)
        more.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        return more
    }()
    
    lazy var bg: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().popSeparatorLineColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        clipsToBounds = true
        
        addSubview(bg)
        
        bg.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
        }
        
        bg.addSubview(moreButton)
        addSubview(line)
        
        moreButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(12)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
