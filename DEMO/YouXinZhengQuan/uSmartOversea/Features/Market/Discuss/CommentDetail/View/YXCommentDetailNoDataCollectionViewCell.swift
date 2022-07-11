//
//  YXCommentDetailNoDataCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailNoDataCollectionViewCell: UICollectionViewCell {
    
    @objc var refreshBlock:(() -> Void)?
    @objc lazy var emptyImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    @objc lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    @objc lazy var subTitleButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = QMUITheme().themeTextColor()

        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.refreshBlock?()
        }
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(emptyImageView)
        addSubview(titleLabel)
        addSubview(subTitleButton)
        
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(10)
            make.centerX.equalTo(emptyImageView)
            
        }
        
        subTitleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalTo(emptyImageView)
            make.width.equalTo(137)
            make.height.equalTo(30)
        }
    }
    
    var model:YXCommentDetailNoDataModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let model = model {
            emptyImageView.image = UIImage.init(named: model.image)
            titleLabel.text = model.title
            subTitleButton.setTitle(model.subTitle, for: .normal)
        }
    }

}
