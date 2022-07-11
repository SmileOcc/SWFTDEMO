//
//  YXCommentLoadMoreCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentLoadMoreCollectionViewCell: UICollectionViewCell {
    
    typealias ShowMoreBlock = () -> Void
    var showMoreCommentBlock: ShowMoreBlock?
    
    lazy var moreButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 15
        btn.expandY = 15
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "more_comment_open"), for: .normal)
        btn.addTarget(self, action: #selector(showMoreAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func showMoreAction(_ sender: YXExpandAreaButton) {
        showMoreCommentBlock?()
    }
}
