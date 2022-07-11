//
//  YXSmartNoticeView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa

class YXSmartNoticeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
        handleBlock()
        
        contentLabel.text = YXLanguageUtility.kLang(key: "smart_noticeContent")
        openButton.setTitle(YXLanguageUtility.kLang(key: "smart_noticeOpen"), for: .normal)
    }
    
    typealias NoticeBlock = () -> Void
    var handleNoticeBlock: NoticeBlock?
    
    func handleBlock() {
        openButton.rx.tap.takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] in
                self?.handleNoticeBlock?()
            }).disposed(by: rx.disposeBag)
    }
    
    func initializeViews() {
        self.backgroundColor = UIColor.qmui_color(withHexString: "#538FFF")
        addSubview(contentLabel)
        addSubview(openButton)
        
        let margin = 18.0
        openButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(openButton.snp.left).offset(10)
        }
        
    }
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var openButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 5.0
        button.setImage(UIImage(named: "right_arrow"), for: .normal)
        return button
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
