//
//  ShippingMethodGroupView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SwiftyJSON

class ShippingMethodGroupView: UIView {
    
    var shippingMethodId:String?
    
    let disposeBag = DisposeBag()
    
    lazy var checkoutDataPub:PublishSubject<JSON?> = {
        let pub = PublishSubject<JSON?>()
        pub.subscribe(onNext:{[weak self] data in
            self?.fillShippingData(data: data)
        }).disposed(by: disposeBag)
        return pub
    }()
    
    var insureIsOn:Observable<Bool>?
    
    let shippingMethodPub = PublishSubject<String?>()
    
    private weak var stackView:UIStackView!
    private weak var codService:UILabel!
    private weak var insureView:InsuranceSwitchView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let titleText = UILabel()
        addSubview(titleText)
        titleText.text = STLLocalizedString_("shipMethod")
        titleText.font = UIFont.boldSystemFont(ofSize: 14)
        titleText.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.top.equalTo(15)
            make.height.equalTo(17)
        }
        
        
        //MARK: 运费险
        let insureView = InsuranceSwitchView(frame: .zero)
        addSubview(insureView)
        self.insureView = insureView
        insureView.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-16)
            make.height.equalTo(20)
        }
        insureIsOn = insureView.switchBtn.rx.controlEvent(.valueChanged).map { el in
            return insureView.switchBtn.isOn
        }
        
        //MARK: 运送方式
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.equalTo(titleText.snp.bottom).offset(14)
            make.bottom.equalTo(insureView.snp.top).offset(-12)
        }
        self.stackView = stackView
    }
    
    
    func fillShippingData(data:JSON?){
        guard let shippingData = data?["result"]["shipping"].array else {
            return
        }
        self.stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    
        let codShipping = shippingData.filter({ item in
            item["id"].string == "5"
        }).first
        
        var hasTabFlag = false
        if let _ = codShipping,
           shippingData.count > 1{
            //加入 online payment cash on delivery Tab
            let tabView = TabView(frame: .zero)
            tabView.defaultIndex = shippingMethodId == "5" ? 1 : 0
            tabView.titles = [STLLocalizedString_("onlinePay")!,STLLocalizedString_("cod")!]
            stackView.addArrangedSubview(tabView)
            hasTabFlag = true
            let topLine = UIView()
            tabView.addSubview(topLine)
            topLine.snp.makeConstraints { make in
                make.leading.equalTo(0)
                make.trailing.equalTo(0)
                make.height.equalTo(1)
            }
            topLine.backgroundColor = OSSVThemesColors.col_E1E1E1()
            tabView.indexPub.subscribe(onNext:{[weak self] index in
                let showCod = index == 1
                self?.codService.isHidden = !showCod
                self?.stackView.arrangedSubviews.forEach { view in
                    if let item = view as? ShippingItemView {
                        if item.isCod{
                            item.isHidden = !showCod
                        }else{
                            item.isHidden = showCod
                        }
                    }
                }
            }).disposed(by: disposeBag)
        }
        
        let showFree = data?["result"]["is_have_ship_coupon"].int == 1
        //全部列出 再根据tab qie切换
        for shippingDatum in shippingData {
            let itemView = ShippingItemView(frame: .zero)
            stackView.addArrangedSubview(itemView)
            itemView.shippingName.text = shippingDatum["ship_name"].string
            itemView.shippingDdesc.text = shippingDatum["ship_desc"].string
            itemView.shippingId = shippingDatum["id"].string
            itemView.normarPrice.text = shippingDatum["shipping_fee_converted"].string
            itemView.freePrice.text = shippingDatum["shipping_fee_converted"].string
            itemView.freePrice.isHidden = !showFree
            itemView.freemark.isHidden = !showFree
            itemView.normarPrice.isHidden = showFree
            if shippingDatum["id"].string == "5"{
                itemView.isCod = true
            }
            if hasTabFlag{
                if shippingMethodId == "5"{
                    itemView.isHidden = shippingDatum["id"].string != "5"
                }else{
                    itemView.isHidden = shippingDatum["id"].string == "5"
                }
            }
            itemView.isSelected = shippingMethodId == shippingDatum["id"].string
            
            itemView.addTarget(self, action: #selector(didseletShipingMethod(_:)), for: .touchUpInside)
        }
        
        //COD 服务费
        let codService = UILabel()
        stackView.addArrangedSubview(codService)
        self.codService = codService
        codService.font = UIFont.systemFont(ofSize: 14)
        codService.textColor = OSSVThemesColors.col_000000(1)
        
        if let codFee = data?["result"]["fee_data"]["cod"].float,
           codFee > 0,
           let codFeeStr = data?["result"]["fee_data"]["cod_converted"].float{
            codService.text = "\(STLLocalizedString_("codServiceText")!) \(codFeeStr)"
        }else{
            codService.text = nil
        }
        
        //运费险
        self.insureView.insureLbl.text = STLLocalizedString_("shipInsurance")! + ": " + (data?["result"]["fee_data"]["shipping_insurance_converted_origin"].string ?? "")
        self.insureView.switchBtn.isOn = data?["result"]["is_shipping_insurance"].string == "1"
    }
    
    @objc func didseletShipingMethod(_ itemView:ShippingItemView){
        for view in stackView.arrangedSubviews {
            if let item = view as? ShippingItemView {
                item.isSelected = false
            }
        }
        itemView.isSelected = true
        shippingMethodPub.onNext(itemView.shippingId)
    }
}
