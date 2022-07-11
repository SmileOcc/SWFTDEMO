//
//  YXCommentTitleSectionCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentTitleSectionCollectionViewCell: UICollectionViewCell {
    
    lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    @objc lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        return label
    }()
    
    lazy var flagView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTextColor()
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var isWhiteStyle:Bool = false {
        didSet {
            updateWhiteStyleUI()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()

        addSubview(topLineView)
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(bottomLine)

        topLineView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(8)
        }
        bgView.snp.makeConstraints { make in
            make.top.equalTo(topLineView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(bgView.snp.centerY)
        }
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    private func updateWhiteStyleUI() {
        
    }
}
