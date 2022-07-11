//
//  YXMarqueeNoticeView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/1/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarqueeNoticeView: UIView {


    var clickBlock: (() -> Void)?

    @objc func clickButtonAction() {
        self.clickBlock?()
    }

    @objc lazy var actionButton: QMUIButton = {
        let button = QMUIButton()
        button.addTarget(self, action: #selector(clickButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var titleIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage.init(named: "notice")
        return icon
    }()
    
    @objc lazy var detailLabel: QMUIMarqueeLabel = {
        let label = QMUIMarqueeLabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.white
        
        label.textAlignment = .left
        label.automaticallyValidateVisibleFrame = false
        label.pauseDurationWhenMoveToEdge = 0.0
        label.shouldFadeAtEdge = false
        label.text = ""
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "notice_arrow")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().normalStrongNoticeBackgroundColor()
        
        addSubview(titleIcon)
        addSubview(detailLabel)
        addSubview(arrowImageView)
        addSubview(actionButton)
        
        titleIcon.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(18)
            make.centerY.equalTo(self)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
            make.left.equalTo(titleIcon.snp.right).offset(15)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-12)
            make.width.height.equalTo(15)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
