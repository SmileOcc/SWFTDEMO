//
//  CheckoutStage1VC.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

///游客登录第一步 这次直接用scrollview
class CheckoutStage1VC: UIViewController {
    
    @objc var nextStep:(()->Void)?
    ///只有没有地址才会进入到该页面
    var model = OSSVAddresseBookeModel()
    
    let disposebag = DisposeBag()
    ///邮箱姓名
    weak var baseInfoView:BaseInfoView!
    ///地址信息
    weak var addressInfoView:AddressInfoView!

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
        
        status.currentStep = 0
//MARK: 邮箱姓名
        let baseInfoView = BaseInfoView(frame: .zero)
        scrollView.addSubview(baseInfoView)
        self.baseInfoView = baseInfoView
        baseInfoView.model = model
        
        baseInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(status.snp.bottom).offset(10)
        }
        baseInfoView.backgroundColor = .white
        
//MARK: 地址
        let addressInfoView = AddressInfoView(frame: .zero)
        addressInfoView.scrollParent = scrollView
        scrollView.addSubview(addressInfoView)
        addressInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(baseInfoView.snp.bottom).offset(10)
        }
        self.addressInfoView = addressInfoView
        addressInfoView.backgroundColor = .white
        addressInfoView.model = model
        
        let buttonView = UIView()
        buttonView.backgroundColor = .white
        scrollView.addSubview(buttonView)
        buttonView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(addressInfoView.snp.bottom)
            make.bottom.equalTo(-500)//多点可滚动
        }
        
        let button = UIButton()
        button.isEnabled = false
        buttonView.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(48)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
        }
        button.setBackgroundColor(OSSVThemesColors.col_000000(1), for: .normal)
        button.setBackgroundColor(OSSVThemesColors.col_C4C4C4(), for: .disabled)
        button.setTitle(STLLocalizedString_("Continue to shipping"), for: .normal)
        button.setTitleColor(OSSVThemesColors.col_FFFFFF(), for: .normal)
        button.titleLabel?.font = UIFont.stl_buttonFont(18)
        
        
        let saveAction =  button.rx.tap.flatMap {[weak self] _ -> Observable<(Bool,String?)> in
            let api = OSSVAddresseAddeAip(addressAddRequestWith: self!.model).sendRequest(view: self!.view)
            return api
        }
        
        saveAction.subscribe(onNext:{[weak self] (success,message) in
            if success{
//                print("继续下一步")
                if let nextStep = self?.nextStep {
                    self?.navigationController?.popViewController(animated: false)
                    nextStep()
                }
            }else{
                HUDManager.showHUD(withMessage: message)
            }
        }).disposed(by: disposebag)
        
        
        
//MARK: 聚合事件
        let result =  Observable.combineLatest(
            baseInfoView.emailValid,
            baseInfoView.firstNameValid!,
            baseInfoView.lastNameValid!,
            addressInfoView.phoneValid,
            addressInfoView.regionValid,
            addressInfoView.cityValid,
            addressInfoView.zipValid,
            addressInfoView.idnumValid
        )
        
        result.subscribe(onNext:{ items in
            var result = true
            let children = Mirror(reflecting: items).children.map({$0.value}) as? [Bool]
            print(items)
            if let children = children {
                for item in children {
                    result = result && item
                }
            }
            button.isEnabled = result
        }).disposed(by: disposebag)
        
//        scrollView.rx.contentOffset.subscribe(onNext:{ value in
//            print(value)
//        })
        
        model.addressType = "0"
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.addressInfoView.manualEdit.accept(false)
        
        self.baseInfoView.emailInput.isHidden = OSSVAccountsManager.shared().account != nil //[OSSVAccountsManager sharedManager].account.email
        if let email = OSSVAccountsManager.shared().account?.email {
            self.baseInfoView.emailInput.text = email
            self.baseInfoView.emailValid.onNext(true)
        }
         
    }
}
