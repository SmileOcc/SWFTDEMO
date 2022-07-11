//
//  YXCommentDetailNoDataView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailNoDataView: UIView {
    
    @objc var clickActionBlock:(() -> Void)?
    
    @objc var topOffset:CGFloat = 0.0 {
        didSet {
            emptyImageView.snp.updateConstraints{ make in
                make.top.equalToSuperview().offset(topOffset)
            }
        }
    }
    
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
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = QMUITheme().themeTextColor()
        btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)

        return btn
    }()
    
    @objc lazy var isWhiteStyle:Bool = false {
        didSet {
            self.titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
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
        addSubview(emptyImageView)
        addSubview(titleLabel)
        addSubview(subTitleButton)
        
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.centerX.equalToSuperview()
            
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(10)
            make.centerX.equalTo(emptyImageView)
            
        }
        
        subTitleButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalTo(emptyImageView)
//            make.width.equalTo(137)
            make.height.equalTo(30)
        }
    }
    
    @objc func clickAction(_ sender: QMUIButton) {
        self.clickActionBlock?()
    }

}
