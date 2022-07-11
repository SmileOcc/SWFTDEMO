//
//  YXReportToolBar.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXReportToolbar: UIView {
    
    lazy var textNumLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = String(format: "0/300")
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel4()
        lab.textAlignment = .right
        lab.numberOfLines = 1
        return lab;
    }()
    
    lazy var reportStockButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "report_stock"), for: .normal)
//        button.setTitle(YXLanguageUtility.kLang(key: "stock_name"), for: .normal)
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 5
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        return button
    }()
    
    lazy var reportImageButton: QMUIButton = {
        let button = QMUIButton()        
        button.setImage(UIImage(named: "report_image"), for: .normal)
//        button.setTitle(YXLanguageUtility.kLang(key: "mine_picture"), for: .normal)
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 5
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().popupLayerColor()
    
        let floatLayoutView = QMUIFloatLayoutView()
        floatLayoutView.minimumItemSize = CGSize(width: 64, height: 40)
//        floatLayoutView.itemMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        floatLayoutView.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        addSubview(floatLayoutView)
        
        floatLayoutView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        let breakLine = UIView()
        breakLine.backgroundColor = QMUITheme().popSeparatorLineColor()
        addSubview(breakLine)
        breakLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(64)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(0.5)
        }

        
        floatLayoutView.addSubview(reportImageButton)
//        floatLayoutView.addSubview(lineBgView)
        floatLayoutView.addSubview(reportStockButton)
        
        let topLine = UIView()
        topLine.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(topLine)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(bottomLine)
        
        topLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        addSubview(textNumLabel)

        textNumLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
