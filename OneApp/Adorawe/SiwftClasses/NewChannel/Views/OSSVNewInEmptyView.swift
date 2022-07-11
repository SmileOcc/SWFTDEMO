//
//  OSSVNewInEmptyView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import YYImage

class OSSVNewInEmptyView: UIView {
    
    weak var emptyImg:YYAnimatedImageView!
    weak var titleLbl:UILabel!
    weak var actionBtn:UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = OSSVThemesColors.col_F5F5F5()
        
        let img = YYAnimatedImageView()
        addSubview(img)
        img.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(40)
            make.size.equalTo(CGSize(width: 120, height: 120))
            make.centerX.equalTo(self.snp.centerX)
        }
        self.emptyImg = img
        img.image = UIImage(named: "loading_failed_newin")
        
        let lbl = UILabel()
        lbl.textColor = OSSVThemesColors.col_6C6C6C()
        lbl.font = UIFont.systemFont(ofSize: 14)
        titleLbl = lbl
        addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(img.snp.bottom).offset(8)
        }
        lbl.text = STLLocalizedString_("load_failed")
        
        let btn = UIButton()
        btn.backgroundColor = OSSVThemesColors.col_0D0D0D()
        btn.setTitleColor(.white, for: .normal)
        if app_type == 3 {
            btn.setTitle(STLLocalizedString_("retry"), for: .normal)
        } else {
            btn.setTitle(STLLocalizedString_("retry")?.uppercased(), for: .normal)
        }
        
        btn.titleLabel?.font = UIFont.stl_buttonFont(12)
        addSubview(btn)
        btn.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(36)
            make.width.equalTo(UIScreen.main.bounds.size.width / 2.0)
            make.top.equalTo(lbl.snp.bottom).offset(16)
        }
        self.actionBtn = btn
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
