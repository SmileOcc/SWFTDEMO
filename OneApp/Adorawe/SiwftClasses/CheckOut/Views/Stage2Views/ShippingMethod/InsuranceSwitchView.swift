//
//  InsuranceSwitchView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit

class InsuranceSwitchView: UIView {
    
    weak var insureLbl:UILabel!
    weak var switchBtn:UISwitch!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let switchBtn = UISwitch()
        switchBtn.onTintColor = OSSVThemesColors.col_0D0D0D()
//        switchBtn.tintColor = OSSVThemesColors.col_C4C4C4()
        addSubview(switchBtn)
        switchBtn.snp.makeConstraints { make in
            make.trailing.equalTo(0)
            make.top.equalTo(-4)
        }
        self.switchBtn = switchBtn
        switchBtn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        let shipping_security = UIImageView(image: UIImage(named: "shipping_security"))
        addSubview(shipping_security)
        shipping_security.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.centerY.equalTo(self.snp.centerY)
            make.width.height.equalTo(12)
        }
        
        let insureLbl = UILabel()
        insureLbl.font = UIFont.systemFont(ofSize: 14)
        insureLbl.text = STLLocalizedString_("shipInsurance")! + ": "
        addSubview(insureLbl)
        insureLbl.snp.makeConstraints { make in
            make.leading.equalTo(shipping_security.snp.trailing).offset(4)
            make.centerY.equalTo(self.snp.centerY)
        }
        self.insureLbl = insureLbl
        
        let infoImg = UIImageView(image: UIImage(named: "shipping_securitydescription"))
        addSubview(infoImg)
        infoImg.snp.makeConstraints { make in
            make.leading.equalTo(insureLbl.snp.trailing).offset(4)
            make.width.height.equalTo(12)
            make.centerY.equalTo(self.snp.centerY).offset(2)
        }
        
    }

}
