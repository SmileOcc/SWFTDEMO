//
//  VIVColorPicCell.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import YYImage
import SnapKit
import RxSwift

class VIVColorPicCell: UICollectionViewCell {
    //选中的尺码
    var currentSizeAttr:OSSVAttributeItemModel?
    
    var model:OSSVAttributeItemModel?{
        didSet{
            if let urlStr = model?.goods_thumb,
               let url = URL(string: urlStr) {
                mainImage.yy_setImage(with: url, placeholder: UIImage(named: "color_pick_loading"))
            }
            if model?.checked == true{
                statesView.borderColor = OSSVThemesColors.col_000000(1)
                ringView.borderColor = UIColor.white
            }else{
                statesView.borderColor = UIColor.clear
                ringView.borderColor = UIColor.clear
            }
            
            self.hotLbl.isHidden = true
            if let isHot = model?.is_hot,
            isHot == 1{
                self.hotLbl.isHidden = false
            }
            
            
            ///无效商品处理
            var hasAttr = true
            if let currentOtherSet = currentSizeAttr?.groupIdsSet{
                if let intersection = model?.groupIdsSet.intersection(currentOtherSet){
                    //有效数据
                    hasAttr = !intersection.isEmpty
                }else{
                    hasAttr = false
                }
            }
            
            var hasGoods = true
            if let goodsNumber = model?.goodsNumber,
               goodsNumber == 0{
                hasGoods = false
            }
            
            if let isOnSale = model?.isOnSale?.boolValue,
                isOnSale == false{
                hasGoods = false
            }
            ///test
//            hasGoods = false
            statesView.lineDashPattern = hasAttr ? nil : [3,3]
            statesView.fillColor = hasAttr ? statesView.fillColor : OSSVThemesColors.col_E1E1E1().withAlphaComponent(0.4)
            statesView.borderColor = hasAttr ? statesView.borderColor : OSSVThemesColors.col_E1E1E1()
            ringView.borderColor = hasAttr ? ringView.borderColor : OSSVThemesColors.col_EFEFEF()
            
            if !hasGoods{
                statesView.lineDashPattern = [3,3]
                statesView.fillColor = OSSVThemesColors.col_FFFFFF().withAlphaComponent(0.8)
            }
        }
    }
    
    private weak var mainImage:YYAnimatedImageView!
    private weak var hotLbl:UILabel!
    private weak var statesView:BorderView!
    private weak var ringView:BorderView!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
       
        
        let mainImage = YYAnimatedImageView()
        contentView.addSubview(mainImage)
        mainImage.snp.makeConstraints { make in
            make.center.equalTo(contentView.snp.center)
            make.width.height.equalTo(40)
        }
        self.mainImage = mainImage
        mainImage.layer.borderWidth = 0
        mainImage.layer.cornerRadius = 20
        mainImage.layer.masksToBounds = true
        
        let ring = BorderView(frame: .zero)
        ringView = ring
        contentView.addSubview(ring)
        ring.borderWidth = 4
        ring.cornerRadius = 18
        ring.borderColor = OSSVThemesColors.col_FFFFFF()
        ring.fillColor = UIColor.clear
        ring.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.center.equalTo(contentView.snp.center)
        }
        
        let stateView = BorderView(frame: .zero)
        stateView.cornerRadius = 20
        contentView.addSubview(stateView)
        self.statesView = stateView
        stateView.borderWidth = 1
        stateView.snp.makeConstraints { make in
            make.width.height.equalTo(42)
            make.center.equalTo(contentView.snp.center)
        }
        
        
        
        
        
        let hotLbl = UILabel()
        hotLbl.text = STLLocalizedString_("hot")
        contentView.addSubview(hotLbl)
        hotLbl.font = UIFont.boldSystemFont(ofSize: 8)
        self.hotLbl = hotLbl
        hotLbl.backgroundColor = OSSVThemesColors.col_FBE9E9()
        hotLbl.textColor = OSSVThemesColors.col_B62B21()
        hotLbl.textAlignment = .center
        let w = hotLbl.sizeThatFits(CGSize(width: .max, height: 10)).width + 4
        
        hotLbl.snp.makeConstraints { make in
            make.trailing.equalTo(0)
            make.height.equalTo(10)
            make.width.equalTo(w)
            make.top.equalTo(0)
        }
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        statesView.borderColor = UIColor.clear
        statesView.fillColor =  UIColor.clear
        statesView.lineDashPattern = nil
        hotLbl.isHidden = true
        ringView.borderColor = UIColor.clear
    }
}
