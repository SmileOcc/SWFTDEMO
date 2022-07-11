//
//  USQuoteGuideView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class USQuoteGuideView: YXStockDetailBaseView {
    
    lazy var titleLabel:UILabel = {
        let label = UILabel.init()
        label.text = YXLanguageUtility.kLang(key: "stock_detail_us_quote_tip")
        label.font = UIFont.systemFont(ofSize: 12)
        if YXThemeTool.isDarkMode() {
            label.textColor = UIColor.qmui_color(withHexString: "#1F2350")
        } else {
            label.textColor = UIColor.qmui_color(withHexString: "#2F346A")
        }
        label.contentMode = .center
        label.textAlignment = .left
        label.numberOfLines = 3
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor.qmui_color(withHexString: "#FFFFFF"), for: .normal)
//        button.titleLabel?.textAlignment = .center
        button.contentHorizontalAlignment = .center
        button.setTitle(YXLanguageUtility.kLang(key: "login_loginTip"), for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.backgroundColor = QMUITheme().mainThemeColor()
        button.qmui_tapBlock = {  [weak self] _ in
            YXToolUtility.handleBusinessWithLogin {
                
            }
        }
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
    
        backgroundColor = QMUITheme().foregroundColor()
        
        let containView = UIView.init()
        containView.layer.cornerRadius = 4
        containView.layer.masksToBounds = true
        addSubview(containView)
        
        let imageView = UIImageView.init(image: UIImage.init(named: "us_quote_tip"))
        containView.addSubview(imageView)
        
        containView.snp.makeConstraints{
            $0.top.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.right.equalToSuperview().offset(-16)
        }
        
        imageView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        
        containView.addSubview(titleLabel)
        containView.addSubview(button)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-94)
            make.bottom.equalToSuperview()
        }
        
        button.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(32)
        }
        
    }
}
