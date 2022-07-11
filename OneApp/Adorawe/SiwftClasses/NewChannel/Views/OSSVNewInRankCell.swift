//
//  OSSVNewInRankCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVNewInRankCell: OSSVThemeGoodsItesRankCCell {
    
    weak var last7DaysLbl:UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bgView.snp.remakeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12))
        }
        
        let last7DaysLbl = UILabel()
        contentView.addSubview(last7DaysLbl)
        last7DaysLbl.text = STLLocalizedString_("last7days")
        last7DaysLbl.textColor = OSSVThemesColors.col_B2B2B2()
        last7DaysLbl.font = UIFont.systemFont(ofSize: 11)
        self.last7DaysLbl = last7DaysLbl
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    override func setHomeGoodsModel(_ model: STLHomeCGoodsModel) {
        super.setHomeGoodsModel(model)
        last7DaysLbl?.isHidden = hotNumLabel.isHidden && favourNumLabel.isHidden
        
        guard let last7DaysLbl = last7DaysLbl,
              last7DaysLbl.isHidden == false else{
            return
        }
//        let targetLbl = hotNumLabel.isHidden ? favourNumLabel : hotNumLabel
//        last7DaysLbl.snp.remakeConstraints { make in
//            make.leading.equalTo(targetLbl.snp.trailing).offset(2)
//            make.bottom.equalTo(targetLbl.snp.bottom)
//        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        last7DaysLbl?.isHidden = true
    }
}
