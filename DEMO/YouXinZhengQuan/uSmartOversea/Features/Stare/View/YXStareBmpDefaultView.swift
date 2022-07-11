//
//  YXBmpPermissionsView.swift
//  uSmartOversea
//
//  Created by suntao on 2020/12/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStareBmpDefaultView: UIView {

    @objc var fetchClick : (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor =  QMUITheme().foregroundColor()
        addSubview(emptyImageView)
        addSubview(tipsLabel)
        addSubview(fetchNowButton)
        
        emptyImageView.snp.makeConstraints { (make) in
            make.top.equalTo(110)
            make.width.equalTo(130)
            make.height.equalTo(120)
            make.centerX.equalTo(self)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom).offset(10)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        fetchNowButton.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(11)
            make.centerX.equalTo(tipsLabel.snp.centerX)
        }
    }
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "bmp_unsupport_day")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.65)
        label.text = YXLanguageUtility.kLang(key: "stockST_BMP_nonsupport_viewing")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var fetchNowButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "stock_detail_eagerly_fetch"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().themeTintColor(), for: .normal)
        button.addTarget(self, action: #selector(fetchButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc func fetchButtonAction(){
        self.fetchClick?()
    }

}
