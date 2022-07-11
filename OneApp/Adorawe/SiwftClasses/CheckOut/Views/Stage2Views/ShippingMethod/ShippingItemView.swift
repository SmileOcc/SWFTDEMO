//
//  ShippingItemView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit

class ShippingItemView: UIControl {
    
    override var isSelected: Bool{
        didSet{
            borderView.borderColor = isSelected ? OSSVThemesColors.col_000000(1) : OSSVThemesColors.col_E1E1E1()
            checkMarkImg.isHighlighted = isSelected
        }
    }
    
    private var borderView:BorderView!
    private var checkMarkImg:UIImageView!
    
    var isCod = false
    
    var shippingId:String? = ""
    
    var shippingName:UILabel!
    var shippingDdesc:UILabel!
    
    var freemark:UILabel!
    var freePrice:UILabel!
    
    var normarPrice:UILabel!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let borderView = BorderView(frame: .zero)
        borderView.borderWidth = 1
        borderView.borderColor = OSSVThemesColors.col_E1E1E1()
        borderView.isUserInteractionEnabled = false
        
        self.borderView = borderView
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.leading.equalTo(1)
            make.trailing.bottom.equalTo(-1)
            make.top.equalTo(10)
        }
        
        let shippingName = UILabel()
        borderView.addSubview(shippingName)
        self.shippingName = shippingName
        shippingName.font = UIFont.boldSystemFont(ofSize: 14)
        shippingName.textColor = OSSVThemesColors.col_000000(1)
        shippingName.snp.makeConstraints { make in
            make.leading.top.equalTo(15)
            make.height.equalTo(17)
        }
        
        let shippingDdesc = UILabel()
        borderView.addSubview(shippingDdesc)
        self.shippingDdesc = shippingDdesc
        shippingDdesc.font = UIFont.systemFont(ofSize: 12)
        shippingDdesc.textColor = OSSVThemesColors.col_9d9d9d()
        shippingDdesc.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalTo(-16)
            make.height.equalTo(14)
            make.top.equalTo(shippingName.snp.bottom)
        }
        
        
        let checkMarkImg = UIImageView(image: UIImage(named: "radio"), highlightedImage: UIImage(named: "radio_on"))
        borderView.addSubview(checkMarkImg)
        self.checkMarkImg = checkMarkImg
        checkMarkImg.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.trailing.equalTo(-15)
            make.centerY.equalTo(borderView.snp.centerY)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        borderView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.trailing.equalTo(checkMarkImg.snp.leading).offset(-15)
            make.centerY.equalTo(borderView.snp.centerY)
        }
        
        let freemark = UILabel()
        let freePrice = UILabel()
        let normarPrice = UILabel()
        stackView.addArrangedSubview(freemark)
        stackView.addArrangedSubview(freePrice)
        stackView.addArrangedSubview(normarPrice)
        self.freemark = freemark
        self.freePrice = freePrice
        self.normarPrice = normarPrice
        freemark.text = STLLocalizedString_("FREE")
        freemark.textColor = OSSVThemesColors.col_9F5123()
        freemark.font = UIFont.boldSystemFont(ofSize: 14)
        freePrice.font = UIFont.systemFont(ofSize: 12)
        freePrice.textColor = OSSVThemesColors.col_000000(0.5)
        normarPrice.textColor = OSSVThemesColors.col_000000(1)
        normarPrice.font = UIFont.boldSystemFont(ofSize: 14)
        
    }

}
