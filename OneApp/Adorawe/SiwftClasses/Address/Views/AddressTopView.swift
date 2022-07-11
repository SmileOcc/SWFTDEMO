//
//  AddressTopView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/8/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddressTopView: UIView {
    
    
    @objc var address:OSSVAddresseBookeModel?{
        didSet{
            guard let address = address else{
                imageView.image = UIImage(named: "address_white")
                contentLbl.text = STLLocalizedString_("Please_fill_Shipping_address")
                return
            }
            contentLbl.text = NSString.addressString(addres: address)
            if let addressType = address.addressType {
                switch addressType {
                case "1":
                    imageView.image = UIImage(named: "home_button_white")
                case "2":
                    imageView.image = UIImage(named: "school_button_white")
                case "3":
                    imageView.image = UIImage(named: "company_button_white")
                default:
                    imageView.image = UIImage(named: "address_white")
                }
            }
        }
    }
    
    weak var imageView:UIImageView!
    weak var contentLbl:AddressShowLabel!
    weak var arrowImage:UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews(){
        backgroundColor = OSSVThemesColors.col_FFF3E4()
        let imageV = UIImageView(image: UIImage(named: "address_white"))
        imageV.backgroundColor = OSSVThemesColors.col_0D0D0D()
        imageV.layer.cornerRadius = 10
        addSubview(imageV)
        imageView = imageV
        imageV.contentMode = .center
        imageV.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.leading.equalTo(12)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        let arrImg = UIImageView(image: UIImage(named: "address_arr_right"))
        addSubview(arrImg)
        self.arrowImage = arrImg
        arrImg.snp.makeConstraints { make in
            make.trailing.equalTo(-12)
            make.width.height.equalTo(12)
            make.centerY.equalTo(self.snp.centerY)
        }
        arrImg.convertUIWithARLanguage()
        
        let contentLbl = AddressShowLabel(frame: .zero)
        addSubview(contentLbl)
        self.contentLbl = contentLbl
        contentLbl.font = UIFont.systemFont(ofSize: 12)
        contentLbl.textColor = OSSVThemesColors.col_0D0D0D()
        contentLbl.numberOfLines = 2
        contentLbl.convertTextAlignmentWithARLanguage()
        
        
        contentLbl.snp.makeConstraints { make in
            make.leading.equalTo(imageV.snp.trailing).offset(8)
            make.trailing.equalTo(arrImg.snp.leading).offset(-8)
            make.top.equalTo(self.snp.top).offset(8)
            make.bottom.equalTo(self.snp.bottom).offset(-8)
        }
    }

}
