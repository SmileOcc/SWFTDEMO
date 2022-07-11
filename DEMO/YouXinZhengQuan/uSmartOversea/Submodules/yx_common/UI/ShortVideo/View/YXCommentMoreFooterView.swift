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
        more.setTitle(YXLanguageUtility.kLang(key: "live_expand"), for: .normal)
        more.setTitle(YXLanguageUtility.kLang(key: "live_hide"), for: .selected)
        more.titleLabel?.font = .systemFont(ofSize: 12)
        more.setTitleColor(UIColor(hexString: "2F79FF"), for: .normal)
        more.setImage(UIImage(named: "arrow_down_orange"), for: .normal)
        more.setImage(UIImage(named: "arrow_up_orange"), for: .selected)
        more.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        return more
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        clipsToBounds = true
        
        addSubview(moreButton)
        
        moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(56)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
