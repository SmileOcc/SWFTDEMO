//
//  OSSVCODConfirmWithoutSmsNewVC.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OSSVCODConfirmWithoutSmsNewVC: UIViewController {
    
    @objc var phone:String!
    @objc var phoneCode:String!
    @objc var orderId:String!
    @objc var orderSn:String!
    
    @objc var amountStr:String!
        
    private let disposeBag = DisposeBag()
    weak var amountlbl:UILabel?
    weak var cellIpunt:CellTextfield?
    weak var verifyBtn:UIButton?
    
    @objc var success:((Bool,String)->Void)?
    @objc var jumpToSMS:((_ paymentStr:String,_ phone:String)->Void)?
    
    var country:STLBindCountryModel?{
        didSet{
            cellIpunt?.countryModel = country
            cellIpunt?.clearError()
        }
    }
    
    
    var bindPhoneModel = STLBindPhoneNumViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupSubViews()
        bindPhoneModel.requestInfo {[weak self] obj, _ in
            if let result = obj as? STLBindCountryResultModel{
                self?.afterInfoGod(obj: result)
            }
        } failure: { _, _ in
            
        }
    }
    
    func setupSubViews(){
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "close_cod_sms"), for: .normal)
        closeBtn.sensor_element_id = "COD_SMS_Verify_Closed"
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.top.equalTo(15)
            make.trailing.equalTo(-20)
        }
        closeBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.dismiss(animated: true, completion: nil);
        }).disposed(by: disposeBag)
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = OSSVThemesColors.col_0D0D0D()
        title.text = STLLocalizedString_("cod_verify_title");
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(15)
        }
        
        let devider = UIView()
        devider.backgroundColor = OSSVThemesColors.col_EEEEEE()
        view.addSubview(devider)
        devider.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(0.5)
            make.top.equalTo(48.5)
        }
        
        let amountLbl = UILabel()
        view.addSubview(amountLbl)
        self.amountlbl = amountLbl
        amountLbl.text = STLLocalizedString_("cod_payment_amount")
        amountLbl.font = UIFont.boldSystemFont(ofSize: 18)
        amountLbl.convertTextAlignmentWithARLanguage()
        amountLbl.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(devider.snp.bottom).offset(12)
            make.height.equalTo(22)
        }
        
        let amountValue = UILabel()
        view.addSubview(amountValue)
        amountValue.text = amountStr
        amountValue.font = UIFont.boldSystemFont(ofSize: 18)
        amountValue.textColor = OSSVThemesColors.col_B62B21()
        amountValue.snp.makeConstraints { make in
            make.leading.equalTo(amountLbl.snp.trailing).offset(4)
            make.bottom.equalTo(amountLbl.snp.bottom)
            make.height.equalTo(22)
        }
        
        
        let tipInfo = UILabel()
        view.addSubview(tipInfo)
        tipInfo.convertTextAlignmentWithARLanguage()
        tipInfo.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(amountLbl.snp.bottom).offset(12)
            make.height.equalTo(14)
        }
        tipInfo.textColor = OSSVThemesColors.col_6C6C6C()

        tipInfo.font = UIFont.systemFont(ofSize: 12)
        tipInfo.text = STLLocalizedString_("cod_verify_info")
        
        //手机号
        
        let floatingPhone = UILabel()
        view.addSubview(floatingPhone)
        floatingPhone.convertTextAlignmentWithARLanguage()
        floatingPhone.text = STLLocalizedString_("bind_phone_num")
        floatingPhone.font = UIFont.systemFont(ofSize: 10)
        floatingPhone.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(tipInfo.snp.bottom).offset(24)
        }
        floatingPhone.textColor = OSSVThemesColors.col_6C6C6C()

        
        
        let cellTextFiled = CellTextfield()
        view.addSubview(cellTextFiled)
        cellTextFiled.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(floatingPhone.snp.bottom).offset(10)
        }
        cellTextFiled.placeholder = STLLocalizedString_("bind_phone_num")!
        cellTextFiled.deviderColor = OSSVThemesColors.col_CCCCCC()
        cellTextFiled.floatPlaceholderColor = OSSVThemesColors.col_6C6C6C()
        cellTextFiled.delegate = self
        cellTextFiled.text = phone
        cellTextFiled.tintColor = OSSVThemesColors.col_0D0D0D()
        cellTextFiled.canSelectCountry = false
        self.cellIpunt = cellTextFiled
        
        let verifyBtn = UIButton()
        view.addSubview(verifyBtn)
        verifyBtn.sensor_element_id = "COD_SMS_Verify_Pass"
        verifyBtn.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(cellTextFiled.snp.bottom).offset(24)
            make.height.equalTo(44)
        }
        verifyBtn.setTitle(STLLocalizedString_("sms_verify_btn")?.uppercased(), for: .normal)
        verifyBtn.backgroundColor = OSSVThemesColors.col_0D0D0D()
        verifyBtn.titleLabel?.font = UIFont.stl_buttonFont(14)
        verifyBtn.setTitleColor(.white, for: .normal)
        self.verifyBtn = verifyBtn
        verifyBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.checkCode(code: "")
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kKeyWindow()?.backgroundColor = OSSVThemesColors.col_0D0D0D().withAlphaComponent(0.3)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        kKeyWindow()?.backgroundColor = UIColor.white
    }
    
    func afterInfoGod(obj:STLBindCountryResultModel){
        let phoneCode = phoneCode.replacingOccurrences(of: "+", with: "")
        for country in obj.countries {
            if country.code == phoneCode{
                self.country = country
                self.cellIpunt?.regionCodeLbl?.text = self.phoneCode
                return
            }
        }
        
        for country in obj.countries {
            if country.countryId == obj.default_country_id{
                self.country = country
                return
            }
        }
    }
    
    func checkCode(code:String){
        ///2.校验
        OSSVAddresseCheckePhoneAip(checkPhone: self.cellIpunt?.text ?? "", countryId: country?.countryId ?? "", countryCode: country?.country_code ?? "")
            .requestCheckPhone(view: view)
            .subscribe(onNext:{[weak self] result in
                if result.0{
                    self?.checkCodeReq(code: code)
                }else{
                    self?.cellIpunt?.setError(result.1 ?? "", color: OSSVThemesColors.col_B62B21())
                }
            }).disposed(by: disposeBag)
    }
    
    func checkCodeReq(code:String){
        let api = CODSMSSendApi(phone: phone, phoneCode: phoneCode, orderId: orderId,reqType: .sendCheck)
        api.code = code
        api.requesSendCode(view: view).subscribe(onNext:{[weak self] result in
            //成功后执行成功回调
            if result.0 {
                if let success = self?.success {
                    success(result.0,"cod")
                }
                self?.dismiss(animated: true, completion: nil)
            }else{
                //下一步
                if  result.4 == 402{
                    if let callback =  self?.jumpToSMS{
                        self?.dismiss(animated: true, completion: {
                            callback(self?.amountStr ?? "","\(self?.phoneCode ?? "") " + (self?.cellIpunt?.text ?? ""))
                        })
                    }
                }else{
                    HUDManager.showHUD(withMessage: result.1)
                }
            }
        }).disposed(by: disposeBag)
    }
}

///手机号码
extension OSSVCODConfirmWithoutSmsNewVC:DetailTextFieldDelegate{
    func textFieldDidEndEditing(_ detailField: DetailTextField, filed field: UITextField) {
        ///1..对比
        if field.text == self.phone{
            return
        }
        
        if field.text?.isContainArabic ?? false || field.text?.isAllSameNumber ?? false{
            detailField.setError(STLLocalizedString_("id_num_format_err")!, color: OSSVThemesColors.col_B62B21())
            return
        }
        ///2.校验
        OSSVAddresseCheckePhoneAip(checkPhone: field.text ?? "", countryId: country?.countryId ?? "", countryCode: country?.country_code ?? "")
            .requestCheckPhone(view: view)
            .subscribe(onNext:{[weak self] result in
//                self?.verifyBtn?.isEnabled = result.0
                if result.0{
//                    self?.verifyBtn?.backgroundColor = OSSVThemesColors.col_0D0D0D()
                    self?.cellIpunt?.setError("", color: OSSVThemesColors.col_CCCCCC())
                    self?.phone = field.text
                    ABTestTools.shared.changePhoneNum()
                }else{
//                    self?.verifyBtn?.backgroundColor = OSSVThemesColors.col_B2B2B2()
                    self?.cellIpunt?.setError(result.1 ?? "", color: OSSVThemesColors.col_B62B21())
                }
            }).disposed(by: disposeBag)
    }
    
    func textFieldDidBeginEditing(_ detailField: DetailTextField, filed field: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ detailField: DetailTextField, filed field: UITextField) -> Bool {
        guard let text = field.text else { return true }
        return !text.isContainArabic && !text.isAllSameNumber
    }
    
    func textField(_ textField: UITextField, detailText detailField: DetailTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !string.isContainArabic
    }
    
    
}
