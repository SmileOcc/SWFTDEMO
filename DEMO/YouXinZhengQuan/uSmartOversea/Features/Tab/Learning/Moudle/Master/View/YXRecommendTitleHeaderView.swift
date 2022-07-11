//
//  YXRecommendTitleHeaderView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit
import RxCocoa
import RxSwift

class YXRecommendTitleHeaderView: UIView {
    
    var moreTapCallback: (() -> Void)?
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var moreButton: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_btn_more"), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        btn.setImage(UIImage(named: "nb_arrow_more"), for: .normal)
        btn.imagePosition = .right
        let _ = btn.rx.tap.takeUntil(self.rx.deallocated).subscribe { [weak self]_ in
            self?.moreTapCallback?()
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
}
