//
//  CouponInputSelect.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import RxSwift
import RxCocoa

class CouponInputSelect: UIView {
    
    let couponCodePub = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    
    var data:JSON?{
        didSet{
            let hasCoupon = (data?["can_use_coupon_num"].int ?? 0) > 0
            couponSelect.isHidden = !hasCoupon
            couponInput.isHidden = hasCoupon
            
            let isUseCoupon = (Float(data?["fee_data"]["coupon_save"].string ?? "0") ?? 0) > 0
            var couponSave = data?["fee_data"]["coupon_save_converted"].string
            
            let defaultDisplay = data?["available_coupon_msg"].string
            if let couponSaveSrc = couponSave {
                couponSave = "-" + couponSaveSrc
            }else{
                couponSave = defaultDisplay
            }
            couponSelect.displayMsgTitle.text = isUseCoupon ? couponSave : defaultDisplay
        }
    }
    
    weak var couponSelect:CouponSelectView!
    weak var couponInput:CouponInputView!
    

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let topLine = UIView()
        addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        let bottomLine = UIView()
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalTo(-12)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        [topLine,bottomLine].forEach { $0.backgroundColor = OSSVThemesColors.col_E1E1E1() }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLine.snp.top).offset(-12)
            make.top.equalTo(topLine.snp.bottom).offset(12)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        
        let couponInput = CouponInputView(frame: .zero)
        stackView.addArrangedSubview(couponInput)
        
        let couponSelect = CouponSelectView(frame: .zero)
        stackView.addArrangedSubview(couponSelect)
        
        self.couponSelect = couponSelect
        self.couponInput = couponInput
        
        couponSelect.rx.controlEvent(.touchUpInside).subscribe(onNext:{[weak self] in
            self?.jumpToCouponSelect()
        }).disposed(by: disposeBag)
        
        couponInput.applyBtn.rx.tap.subscribe(onNext:{[weak self] in
            if let couponCode = couponInput.inputField.text,
               couponCode.count > 0{
                self?.couponCodePub.onNext(couponCode)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func jumpToCouponSelect(){
        let vc = OSSVCartSelectCouponVC()
        var goodsListArr:[JSON] = []
        data?["war_order_list"].array?.forEach({ warOrderList in
            warOrderList["goods_list"].array?.forEach({ goods in
                goodsListArr.append(goods)
            })
        })
        vc.cartGoodsArray = goodsListArr.compactMap({ item in
            if let dict = item.rawValue as? [AnyHashable : Any] ,
            let retdata = OSSVCartGoodsModel.yy_model(with: dict){
                return retdata
            }
            return nil
        })
        vc.selectedModel = OSSVMyCouponsListsModel()
        vc.selectedModel.couponCode = ""
        vc.viewModel.couponCode = ""
        vc.golBackBlock = {[weak self] couponModel in
            if let couponCode = couponModel?.couponCode {
                self?.couponCodePub.onNext(couponCode)
            }
        }
        let nav = OSSVNavigationVC(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        parentContainerViewController?.present(nav, animated: true, completion: nil)
    }

}

///优惠券输入框
class CouponInputView:UIView{
    
    weak var inputField:UITextField!
    weak var applyBtn:UIButton!
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        backgroundColor = OSSVThemesColors.col_F8F8F8()
        
        
        let applyBtn = UIButton()
        addSubview(applyBtn)
        
        applyBtn.setTitle(STLLocalizedString_("category_filter_apply")!.uppercased(), for: .normal)
        applyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        let width = applyBtn.titleLabel!.sizeThatFits(CGSize(width: CGFloat.infinity, height: 30)).width
        applyBtn.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.trailing.equalTo(-12)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(width + 16)
        }
        
        applyBtn.setBackgroundImage(UIImage.yy_image(with: OSSVThemesColors.col_000000(1)), for: .normal)
        applyBtn.setBackgroundImage(UIImage.yy_image(with: OSSVThemesColors.col_000000(0.3)), for: .disabled)
        
        let inputField = UITextField()
        inputField.rx.text.map { text in
           return (text ?? "").count > 0
        }.subscribe(onNext:{ enabled in
            applyBtn.isEnabled = enabled
        }).disposed(by: disposeBag)
        addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.trailing.equalTo(applyBtn.snp.leading).offset(-4)
            make.leading.equalTo(12)
        }
        inputField.autocapitalizationType = .none
        inputField.autocorrectionType = .no
        inputField.placeholder = STLLocalizedString_("input_coupon")
        inputField.font = UIFont.boldSystemFont(ofSize: 14)
        
        self.inputField = inputField
        self.applyBtn = applyBtn
    }
}

///优惠券选择
class CouponSelectView:UIControl{
    
    weak var displayMsgTitle:UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let arrImg = UIImageView(image: UIImage(named: "address_arr"))
        addSubview(arrImg)
       
        arrImg.snp.makeConstraints { make in
            make.trailing.equalTo(-15)
            make.width.height.equalTo(12)
            make.top.equalTo(24)
            make.bottom.equalTo(-24)
        }
        
        let couponDisplayMsg = UILabel()
        addSubview(couponDisplayMsg)
        couponDisplayMsg.snp.makeConstraints { make in
            make.trailing.equalTo(arrImg.snp.leading).offset(-11)
            make.centerY.equalTo(arrImg.snp.centerY)
        }
        couponDisplayMsg.font = UIFont.systemFont(ofSize: 12)
        couponDisplayMsg.textColor = OSSVThemesColors.col_9F5123()
        self.displayMsgTitle = couponDisplayMsg
        
        let couponImg = UIImageView(image: UIImage(named: "coupon_display"))
        addSubview(couponImg)
        couponImg.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(arrImg.snp.centerY)
            make.trailing.equalTo(couponDisplayMsg.snp.leading).offset(-4)
        }
        
        let titleText = UILabel()
        addSubview(titleText)
        titleText.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.centerY.equalTo(arrImg.snp.centerY)
        }
        titleText.font = UIFont.systemFont(ofSize: 14)
        titleText.text = STLLocalizedString_("Coupon")
        titleText.textColor = OSSVThemesColors.col_000000(1)
        
        let borderView = BorderView(frame: .zero)
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.leading.equalTo(couponImg.snp.leading).offset(-4)
            make.trailing.equalTo(couponDisplayMsg.snp.trailing).offset(4)
            make.top.equalTo(couponDisplayMsg.snp.top).offset(-4)
            make.bottom.equalTo(couponDisplayMsg.snp.bottom).offset(4)
        }
        borderView.borderColor = OSSVThemesColors.col_F5EEE9()
        borderView.borderWidth = 1
        borderView.isUserInteractionEnabled = false
        
    }
}
