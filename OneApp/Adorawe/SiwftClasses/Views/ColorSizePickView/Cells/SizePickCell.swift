//
//  SizePickCell.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/1.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import YYImage
import SnapKit
import RxRelay
import RxSwift
import SwiftyJSON

class SizePickCell: UICollectionViewCell {
    weak var firstIntoDetail:BehaviorRelay<Bool>?
    weak var updateSizeTipPub:PublishSubject<OSSVAttributeItemModel?>?
    //选中的颜色
    var currentColorAttr:OSSVAttributeItemModel?
    ///尺码模型
    var model:OSSVAttributeItemModel?{
        didSet{
            if model?.checked == true && firstIntoDetail?.value != true{
                bgView.borderColor = OSSVThemesColors.col_000000(1)
                bgView.fillColor = OSSVThemesColors.col_000000(1)
                
                sizeLbl.textColor = OSSVThemesColors.col_FFFFFF()
                updateSizeTipPub?.onNext(model)
            }else{
                bgView.borderColor = OSSVThemesColors.col_E1E1E1()
                bgView.fillColor =  OSSVThemesColors.col_FFFFFF()
                
                sizeLbl.textColor = OSSVThemesColors.col_000000(1)
               
            }
            
            if let goodNumber = model?.goodsNumber as? Int,
            goodNumber < 20 && goodNumber > 0{
                leftLbl.isHidden = false
                var str = ""
                let template = STLLocalizedString_("left")!
                if OSSVSystemsConfigsUtils.isRightToLeftShow(){
                    str = "\(template) \(goodNumber)"
                }else{
                    str = "\(goodNumber) \(template)"
                }
                leftLbl.text = str
                let w = leftLbl.sizeThatFits(CGSize(width: .max, height: 10)).width + 4
                leftLbl.snp.updateConstraints { make in
                    make.width.equalTo(w)
                }
            }else{
                leftLbl.isHidden = true
            }
            
            ///无效商品处理
            var hasGoodsAttr = true
            var intersectionSet:Set<String>?
            if let currentOtherSet = currentColorAttr?.groupIdsSet{
                if let intersection = model?.groupIdsSet.intersection(currentOtherSet){
                    //有效数据
                    hasGoodsAttr = !intersection.isEmpty
                    intersectionSet = intersection
                }else{
                    hasGoodsAttr = false
                }
            }
            ///test
//            hasGoods = false
//            maskImg.isHidden = hasGoodsAttr
            maskImg.isHidden = true
            bgView.fillColor = hasGoodsAttr ?  bgView.fillColor : OSSVThemesColors.col_E1E1E1()
            sizeLbl.textColor = hasGoodsAttr ? sizeLbl.textColor : OSSVThemesColors.col_C4C4C4()
//            bgView.lineDashPattern = hasGoods ? nil : [3,3]
            bgView.borderColor = hasGoodsAttr ? bgView.borderColor : nil
            
            var hasGoods = true
            if let goodsNumber = model?.goodsNumber,
               goodsNumber == 0{
                hasGoods = false
            }
            
            ///下架无库存处理
            if let targetGoodsId = intersectionSet?.first {
                let targetStauts = model?.disable_state?.filter({ status in
                    let json = JSON(status)
                    return json["goods_id"].string == targetGoodsId
                })
                if let targetStauts = targetStauts?.first,
                   let disabled = JSON(targetStauts)["disabled"].int,
                   disabled == 1{
                    hasGoods = false
                }
               
            }
            
            if let isOnSale = model?.isOnSale?.boolValue,
                isOnSale == false{
                hasGoods = false
            }
            
            if hasGoodsAttr{
                bgView.fillColor = hasGoods ?  bgView.fillColor : OSSVThemesColors.col_F2F2F2()
                sizeLbl.textColor = hasGoods ? sizeLbl.textColor : OSSVThemesColors.col_C4C4C4()
                bgView.lineDashPattern = hasGoods ? nil : [3,3]
                if !hasGoods {
                    bgView.borderColor = !(model?.checked == true && firstIntoDetail?.value != true) ? UIColor.clear : bgView.borderColor
                    maskImg.isHidden = false
                }
            }
            
        }
    }
    
    
    var sizeText:String?{
        didSet{
            sizeLbl.text = sizeText
        }
    }
    
    weak var sizeLbl:UILabel!
    weak var bgView:BorderView!
    weak var maskImg:YYAnimatedImageView!
    
    weak var leftLbl:UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        let bg = BorderView(frame: .zero)

        bg.borderWidth = 1
        bg.cornerRadius = 16.5
        
        contentView.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(33)
            make.leading.trailing.equalTo(contentView)
        }
        bgView = bg
        
        
        let sizeLbl = UILabel()
        bg.addSubview(sizeLbl)
        sizeLbl.font = UIFont.systemFont(ofSize: 14)
        sizeLbl.snp.makeConstraints { make in
            make.center.equalTo(bg.snp.center)
        }
        sizeLbl.textAlignment = .center
        self.sizeLbl = sizeLbl
        
        let maskView = YYAnimatedImageView()
        maskView.image = UIImage(named: "out_of_stock")
        bg.addSubview(maskView)
        maskImg = maskView
        maskView.snp.makeConstraints { make in
            make.height.equalTo(sizeLbl)
            make.center.equalTo(sizeLbl.snp.center)
        }
        
        let leftLbl = UILabel()
        contentView.addSubview(leftLbl)
        leftLbl.font = UIFont.boldSystemFont(ofSize: 8)
        self.leftLbl = leftLbl
        leftLbl.backgroundColor = OSSVThemesColors.col_FBE9E9()
        leftLbl.textColor = OSSVThemesColors.col_B62B21()
        leftLbl.textAlignment = .center
        
        leftLbl.snp.makeConstraints { make in
            make.trailing.equalTo(8)
            make.height.equalTo(10)
            make.width.equalTo(0)
            make.top.equalTo(0)
        }
        
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        bgView.borderColor = OSSVThemesColors.col_E1E1E1()
        bgView.fillColor =  OSSVThemesColors.col_FFFFFF()
        sizeLbl.textColor = OSSVThemesColors.col_000000(1)
        leftLbl.isHidden = true
        bgView.lineDashPattern = nil
    }
}
