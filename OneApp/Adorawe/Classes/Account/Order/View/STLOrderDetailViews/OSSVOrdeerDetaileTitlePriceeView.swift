//
//  OSSVOrdeerDetaileTitlePriceeView.swift
// XStarlinkProject
//
//  Created by odd on 2021/9/4.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVOrdeerDetaileTitlePriceeView: UIView {

    @objc lazy var titleLabel: UILabel = {
        $0.textColor = OSSVThemesColors.col_0D0D0D()
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            $0.textAlignment = .right
        }
        return $0
    }(UILabel.init());
    
    @objc lazy var priceLabel: UILabel = {
        let labe = UILabel.init()
        labe.textColor = OSSVThemesColors.col_0D0D0D()
        labe.font = UIFont.systemFont(ofSize: 12)
        labe.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            labe.textAlignment = .right
        }
        return labe
    }()
    
    
    
    @objc init(frame:CGRect, title: String!) {
        super.init(frame: frame)

        self.titleLabel.text = title

        self.addSubview(self.titleLabel)
        self.addSubview(self.priceLabel)

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(14)
            make.centerY.equalTo(self.snp.centerY)
        }

        self.priceLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-14)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
