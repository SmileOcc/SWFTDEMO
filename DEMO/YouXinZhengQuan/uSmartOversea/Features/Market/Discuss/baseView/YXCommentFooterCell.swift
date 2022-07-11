//
//  YXYGCCommentFooterCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

import UIKit

class YXCommentFooterCell: UICollectionViewCell {
    typealias ShowMoreBlock = () -> Void
    var showMoreBlock: ShowMoreBlock?
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.03)
        view.isHidden = true
        return view
    }()
    
    lazy var moreButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 15
        btn.expandY = 15
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "more_comment_open"), for: .normal)
        btn.addTarget(self, action: #selector(showMoreAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    lazy var isWhiteStyle:Bool = false {
        didSet {
            updateWhiteUI()
        }
    }
    private func updateWhiteUI() {
        bgView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.03)
        bottomLine.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(moreButton)
        contentView.addSubview(bottomLine)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(64)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }

    }
    
    var commentCount: UInt64? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let count = commentCount {
            if count > 3 {
                self.bgView.isHidden = false
                self.moreButton.isHidden = false
            }else{
                self.bgView.isHidden = true
                self.moreButton.isHidden = true
            }
        }
    }
    
    @objc func showMoreAction(_ sender: YXExpandAreaButton) {
        showMoreBlock?()
    }
}

