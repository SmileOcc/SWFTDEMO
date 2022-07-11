//
//  YXIntradayHodeDetailExpandCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayHodeDetailExpandCell: YXTableViewCell {
    
    typealias ClosureClick = () -> Void
    
    @objc var onClickHoldDetail: ClosureClick?
    @objc var onClickShare: ClosureClick?
    
    fileprivate lazy var holdDetailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "hold_detail"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_detail"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.setButtonImagePostion(.top, interval: 4)
        button.addTarget(self, action: #selector(holdDetailAction), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "hold_share"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_share"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.setButtonImagePostion(.top, interval: 4)
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        return button
    }()

    fileprivate var buttons: [UIButton] = []
    override func initialUI() {
        super.initialUI()
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(holdDetailButton)
        contentView.addSubview(shareButton)
        buttons = [holdDetailButton, shareButton]
        buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
        buttons.snp.makeConstraints { (make) in
            make.height.top.equalTo(self)
        }
        
    }
    
    override func refreshUI() {
        super.refreshUI()
    }
    
    @objc func shareAction() {
        onClickShare?()
    }
    
    @objc func holdDetailAction() {
        onClickHoldDetail?()
    }
}
