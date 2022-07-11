//
//  PriceList.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SwiftyJSON

struct PriceItemData{
    var name:String
    var price:String
    var priceColor:UIColor?
}
/*
 [self.totalBottomView addSubview:self.totalTrackingCostView];
 [self.totalBottomView addSubview:self.totalInsuranceCostView];
 [self.totalBottomView addSubview:self.totalCodCostView];
 
 
 */
class PriceList: UIView {
    
    var data:JSON?{
        didSet{
            stackView.arrangedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            
            var datas:[PriceItemData] = []
            ///商品总价
            if let price = data?["fee_data"]["product_converted"].string {
                let name = STLLocalizedString_("protudts_total")! + ":"
                datas.append(PriceItemData(name: name, price: price))
            }
            ///运费
            let hasShippingCoupon = (data?["is_have_ship_coupon"].int ?? 0) > 0
            if hasShippingCoupon{
                let name = STLLocalizedString_("shipCost")! + ":"
                datas.append(PriceItemData(name: name, price: STLLocalizedString_("FREE")!,priceColor: OSSVThemesColors.col_9F5123()))
            }else{
                let name = STLLocalizedString_("shipCost")! + ":"
                if let price = data?["fee_data"]["shipping_converted"].string{
                    datas.append(PriceItemData(name: name, price: price))
                }
            }
            ///折扣
            if let price = data?["fee_data"]["pay_discount_save_converted"].string,
               let priceValue = Float(data?["fee_data"]["pay_discount_save"].string ?? "0"),
                priceValue > 0{
                let name = STLLocalizedString_("disCountTitle")! + ":"
                datas.append(PriceItemData(name: name, price: price))
            }
            
            datas.forEach { priceItem in
                let priceItemView = PriceListItem(frame: .zero)
                stackView.addArrangedSubview(priceItemView)
                priceItemView.data = priceItem
            }
            
        }
    }
    
    weak var stackView:UIStackView!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        self.stackView = stackView
    }

}

class PriceListItem:UIView{
    
    var data:PriceItemData!{
        didSet{
            nameLbl.text = data.name
            priceLbl.text = data.price
            if let priceColor = data.priceColor {
                priceLbl.textColor = priceColor
            }
        }
    }
    
    weak var nameLbl:UILabel!
    weak var priceLbl:UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let nameLbl = UILabel()
        let priceLbl = UILabel()
        [nameLbl,priceLbl].forEach { lbl in
            lbl.font = UIFont.systemFont(ofSize: 12)
            lbl.textColor = OSSVThemesColors.col_000000(1)
        }
        
        addSubview(nameLbl)
        addSubview(priceLbl)
        
        self.nameLbl = nameLbl
        self.priceLbl = priceLbl
        
        nameLbl.snp.makeConstraints { make in
            make.leading.equalTo(14)
            make.height.equalTo(14)
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
        }
        
        priceLbl.snp.makeConstraints { make in
            make.trailing.equalTo(-14)
            make.bottom.equalTo(nameLbl.snp.bottom)
        }
    
    }
}
