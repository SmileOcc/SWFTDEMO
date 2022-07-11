//
//  YXStockEmptyDataView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockEmptyDataView: UIView {

    var textLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: .systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "common_string_of_emptyPicture"))
    
    var imageView = UIImageView.init(image: UIImage(named: "empty_noData"))

    func setCenterYOffset(_ offset: CGFloat) {
        imageView.snp.updateConstraints { (make) in
            make.centerY.equalToSuperview().offset(offset)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(imageView)
        addSubview(textLabel)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(120)
            make.centerY.equalToSuperview().offset(-35)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(16)
        }
    }
    
}
