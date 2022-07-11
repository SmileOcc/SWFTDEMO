//
//  CheckoutStage2VC.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa

class CheckoutStage2VC: UIViewController {
    let disposeBag = DisposeBag()
    var checkoutData:JSON?
    
    var formData = [
        "wid":"",
        "address_id":"",
        "coupon_code":"",
        "use_point":"",
        "payToken":"",
        "isPaypalFast":"",
        "pay_code":"",
        "is_use_coin":"",
        "is_shipping_insurance":"",
        "shipping_id":"",
    ]
    
    
    @objc var rawData:NSDictionary?{
        didSet{
            if let rawData = rawData {
                checkoutData = JSON(rawData)
                formData["address_id"] = checkoutData?["result"]["address"]["address_id"].string
            }
        }
    }
    
    private weak var shippingMethodView:ShippingMethodGroupView!
    private weak var addressSelect:AddressSelectView!
    private weak var summaryView:SummaryGroupView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = OSSVThemesColors.col_F8F8F8()
        setupSubviews()
    }
    
    func setupSubviews(){
        self.title = STLLocalizedString_("Check Out")
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        let status = CheckOutStatusView(frame: .zero)
        scrollView.addSubview(status)
        status.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(0)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(34)
        }
        
        status.currentStep = 1
    
//MARK: 地址选择视图
        let addressSelect = AddressSelectView(frame: .zero)
        addressSelect.subviews.forEach { view in
            view.isUserInteractionEnabled = false
        }
        addressSelect.backgroundColor = OSSVThemesColors.col_FFFFFF()
        scrollView.addSubview(addressSelect)
        self.addressSelect = addressSelect
        addressSelect.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(status.snp.bottom).offset(8)
        }
        addressSelect.addressPub.onNext(checkoutData?["result"]["address"])
        addressSelect.rx.controlEvent(.touchUpInside).subscribe(onNext:{[weak self] in
            let addressVc = OSSVAddressOfsOrderEntersVC()
            addressVc.selectedAddressId = self?.checkoutData?["result"]["address"]["address_id"].string
            addressVc.chooseDefaultAddressBlock = {[weak self] address in
                self?.updateAddress(addressId: address?.addressId)
            }
            addressVc.directReBackActionBlock = {[weak self] address in
                self?.updateAddress(addressId: address?.addressId)
            }
            self?.navigationController?.pushViewController(addressVc, animated: true)
        }).disposed(by: disposeBag)
        
//MARK: 运送方式
        let shippingMethodView = ShippingMethodGroupView(frame: .zero)
        shippingMethodView.backgroundColor = OSSVThemesColors.col_FFFFFF()
        scrollView.addSubview(shippingMethodView)
        shippingMethodView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(addressSelect.snp.bottom).offset(8)
        }
        self.shippingMethodView = shippingMethodView
        ///给数据
        shippingMethodView.checkoutDataPub.onNext(checkoutData)
        ///运费险
        shippingMethodView.insureIsOn?.flatMap({ isOn -> Observable<JSON?> in
            self.formData["is_shipping_insurance"] = isOn ? "1" : ""
            let api = OSSVCartCheckAip(dict: self.formData)!
            return api.sendRequest(view: self.view)
        })
        .subscribe(onNext:{ data in
            self.updateData(data: data)
        }).disposed(by: disposeBag)
        
        ///切换运送方式
        let result = shippingMethodView.shippingMethodPub.flatMap { shippingMethodId -> Observable<JSON?> in
            self.formData["shipping_id"] = shippingMethodId ?? ""
            if shippingMethodId == "5"{
                self.formData["pay_code"] = "Cod" //只COD 需要传paycode
            }else{
                self.formData["pay_code"] = ""
            }
            let api = OSSVCartCheckAip(dict: self.formData)!
            return api.sendRequest(view: self.view)
        }
        result.subscribe(onNext:{ data in
            self.updateData(data: data)
        }).disposed(by: disposeBag)
        
//MARK: 概览
        let summaryView = SummaryGroupView(frame: .zero)
        summaryView.backgroundColor = OSSVThemesColors.col_FFFFFF()
        scrollView.addSubview(summaryView)
        summaryView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(shippingMethodView.snp.bottom).offset(8)
        }
        self.summaryView = summaryView
        ///给数据
        summaryView.checkoutDataPub.onNext(checkoutData)
        ///优惠券选中
        let couponReq = summaryView.couponInputSelect.couponCodePub.flatMap { couponCode -> Observable<JSON?>in
            self.formData["coupon_code"] = couponCode
            let api = OSSVCartCheckAip(dict: self.formData)!
            return api.sendRequest(view: self.view)
        }
        couponReq.subscribe(onNext:{[weak self] data in
            if(data?["statusCode"].int == 201){
                self?.formData["coupon_code"] = ""
                if let message = data?["message"].string {
                    HUDManager.showHUD(withMessage: message)
                }
            }else{
                self?.updateData(data: data)
            }
        }).disposed(by: disposeBag)

//MARK: 底部跳转到支付页
    }
        
    //MARK: 更新数据
    func updateData(data:JSON?){
        self.checkoutData = data
        shippingMethodView.shippingMethodId = self.formData["shipping_id"]
        shippingMethodView.checkoutDataPub.onNext(data)
        addressSelect.addressPub.onNext(data?["result"]["address"])
        summaryView.checkoutDataPub.onNext(data)
    }
    
    func updateAddress(addressId:String?){
        if let addressId = addressId {
            self.formData["pay_code"] = ""
            self.formData["shipping_id"] = ""
            self.formData["address_id"] = addressId
            let api = OSSVCartCheckAip(dict: self.formData)!
            api.sendRequest(view: self.view)
                .subscribe(onNext:{ data in
                    self.updateData(data: data)
                }).disposed(by: disposeBag)
        }
    }

}
