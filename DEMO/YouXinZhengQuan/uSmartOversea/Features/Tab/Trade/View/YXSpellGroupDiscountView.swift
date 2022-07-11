//
//  YXSpellGroupDiscountView.swift
//  uSmartOversea
//
//  Created by Mac on 2020/1/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXSpellGroupDiscountView: UIView {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "hold_spell_group_logo"))
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.numberOfLines = 0
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lab.textAlignment = .left
        lab.isUserInteractionEnabled = true
        lab.text = YXLanguageUtility.kLang(key: "hold_spell_group_title")
        return lab
    }()
    
    lazy var descLab: QMUIMarqueeLabel = {
        let lab = QMUIMarqueeLabel()
        lab.numberOfLines = 0
        lab.textColor = QMUITheme().mainThemeColor()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textAlignment = .right
        lab.isUserInteractionEnabled = true
        lab.automaticallyValidateVisibleFrame = false
        lab.shouldFadeAtEdge = false
        lab.text = YXLanguageUtility.kLang(key: "hold_spell_group_tip")
        return lab
    }()
    
    lazy var arrowImgView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "grey_right_arrow")
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(10)
        }
        
        self.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
        
        self.addSubview(descLab)
        descLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowImgView.snp.leading).offset(-10)
            make.leading.greaterThanOrEqualTo(titleLab.snp.trailing).offset(5)
            //make.width.equalTo(YXConstant.screenWidth / 2.0 + 10 )
        }
    }

}
