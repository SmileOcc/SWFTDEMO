//
//  OSSVSettingsVC.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//电话号码复用 CellTextfield

class OSSVCODVierifyVC: UIViewController {
    
    @objc var phone:String!
    @objc var phoneCode:String!
    @objc var orderId:String!
    @objc var orderSn:String!{
        didSet{
            ABTestTools.shared.codPaymentPopup(orderSn: orderSn)
        }
    }
    
    @objc var amountStr:String!
    
    private let disposeBag = DisposeBag()
    weak var amountlbl:UILabel?
    weak var cellIpunt:CellTextfield?
    weak var codeView:JHVerificationCodeView?
    weak var verifyBtn:UIButton?
    weak var codeViewErr:UILabel?
    weak var skipButton:UIButton?
    
    @objc var success:((Bool,String)->Void)?
    
    lazy var config:JHVCConfig = {
        let config = JHVCConfig()
        config.inputBoxNumber = 4
        config.inputBoxSpacing = 4
        config.inputBoxWidth   = ((CGFloat.screenWidth - 40)-12)/4
        config.inputBoxHeight  = 25
        config.tintColor = OSSVThemesColors.col_0D0D0D()
        config.underLineColor = OSSVThemesColors.col_CCCCCC()
        config.underLineHighlightedColor = OSSVThemesColors.col_0D0D0D()
        config.secureTextEntry = false
        config.font = UIFont.boldSystemFont(ofSize: 14)
        config.textColor = OSSVThemesColors.col_0D0D0D()
        config.inputType = .number_Alphabet
        config.showUnderLine = true
        config.inputBoxBorderWidth = 0
        config.keyboardType = .numberPad
        config.autoShowKeyboard = true
        return config
        
    }()
    
    lazy var countDown:JKCountDownButton = {
        let countDown = JKCountDownButton()
        countDown.setTitleColor(OSSVThemesColors.col_0D0D0D(), for: .normal)
        countDown.setTitleColor(OSSVThemesColors.col_B2B2B2(), for: .disabled)
        countDown.countDownButtonHandler {[weak self] sender, tag in
//            self?.codeView?.clear()
            sender?.isEnabled = false
            self?.requestSendSMS(userClicked: true)
            
            self?.codeViewErr?.snp.updateConstraints({ make in
                make.height.equalTo(0)
            })
            self?.codeViewErr?.text = ""
        }
        countDown.countDownChanging { sender, seconds in
            var str:NSString? = nil
            if OSSVSystemsConfigsUtils.isRightToLeftShow() {
                str = NSString(format: "（%zd%@）%@", seconds,"S",STLLocalizedString_("didSent")!)
            }else{
                str = NSString(format: "%@（%zd%@）",STLLocalizedString_("didSent")!, seconds,"S")
            }
            sender?.isEnabled = false
            return str as String?
        }
        
        countDown.countDownFinished { sender, seconds in
            sender?.isEnabled = true
            return STLLocalizedString_("resendCode")! as String
        }
        countDown.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        countDown.setTitle(STLLocalizedString_("resendCode"), for: .normal)
        return countDown
    }()
    
    var country:STLBindCountryModel?{
        didSet{
            cellIpunt?.countryModel = country
            cellIpunt?.clearError()
        }
    }
    
    
    var bindPhoneModel = STLBindPhoneNumViewModel()
    
    func requestSendSMS(userClicked:Bool = false){
        
        //时间未过直接开始倒计时
        if let date = OSSVAccountsManager.shared().msgDate,
           let sendedPhone = OSSVAccountsManager.shared().verifiPhoneNumber,
           sendedPhone == phone,
           !userClicked{
            let finishedTime = date.addingTimeInterval(TimeInterval(OSSVAccountsManager.shared().count))
            let nowTile = Date()
            if finishedTime > nowTile {
                let inteval = finishedTime.timeIntervalSince(nowTile)
                self.countDown.startCountDown(withSecond: UInt(inteval))
                return
            }
        }
        
        
        CODSMSSendApi(phone: phone, phoneCode: phoneCode, orderId: orderId)
            .requesSendCode(view: view).subscribe(onNext:{[weak self] result in
                if result.0 {
                    self?.countDown.startCountDown(withSecond: UInt(result.2 ?? 60))
                    OSSVAccountsManager.shared().msgDate = Date()
                    OSSVAccountsManager.shared().verifiPhoneNumber = self?.phone
                    OSSVAccountsManager.shared().count = result.2 ?? 60
                    if let showSkip = result.3{
                        self?.skipButton?.isHidden = !showSkip
                    }
                        
                }else{
                    HUDManager.showHUD(withMessage: result.1)
                    self?.countDown.stopCountDown()
                }
            print(result)
        }).disposed(by: disposeBag)
    }

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
        devider.backgroundColor = OSSVThemesColors.col_EEEEEE();
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
        
        let smsCodLbl = UILabel()
        view.addSubview(smsCodLbl)
        smsCodLbl.textColor = OSSVThemesColors.col_6C6C6C()
        smsCodLbl.font = UIFont.systemFont(ofSize: 12)
        smsCodLbl.convertTextAlignmentWithARLanguage()
        smsCodLbl.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(cellTextFiled.snp.bottom).offset(24)
        }
        smsCodLbl.text = STLLocalizedString_("enterFourCode")
        
        
        let codeView = JHVerificationCodeView(frame: CGRect(x: 0, y: 0, width: CGFloat.screenWidth - 40, height: 36), config: config)!
        
        view.addSubview(codeView)
        codeView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(smsCodLbl.snp.bottom).offset(12)
            make.height.equalTo(36)
        }
        self.codeView = codeView
        
        codeView.finishBlock = { codeView,code in
            self.checkCode(code: code ?? "")
        }
        
        let codeViewErr = UILabel()
        view.addSubview(codeViewErr)
        codeViewErr.convertTextAlignmentWithARLanguage()
        codeViewErr.textColor = OSSVThemesColors.col_B62B21()
        codeViewErr.font = UIFont.systemFont(ofSize: 10)
        codeViewErr.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(codeView.snp.bottom).offset(-4)
            make.height.equalTo(0)
        }
        self.codeViewErr = codeViewErr

        view.addSubview(countDown)
        countDown.sensor_element_id = "COD_SMS_Verify_Resend"
        countDown.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(codeViewErr.snp.bottom).offset(12)
            make.height.equalTo(14)
        }
        
        let verifyBtn = UIButton()
        view.addSubview(verifyBtn)
        verifyBtn.sensor_element_id = "COD_SMS_Verify_Pass"
        verifyBtn.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(countDown.snp.bottom).offset(24)
            make.height.equalTo(44)
        }
        verifyBtn.setTitle(STLLocalizedString_("sms_verify_btn")?.uppercased(), for: .normal)
        verifyBtn.backgroundColor = OSSVThemesColors.col_0D0D0D()
        verifyBtn.titleLabel?.font = UIFont.stl_buttonFont(14)
        verifyBtn.setTitleColor(.white, for: .normal)
        self.verifyBtn = verifyBtn
        verifyBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.checkCode(code: self?.codeView?.textView.text ?? "")
        }).disposed(by: disposeBag)
        
        let skipBtn = UIButton()
//        skipBtn.setTitle(STLLocalizedString_("sms_code_skip"), for: .normal)
        let skipText = STLLocalizedString_("sms_code_skip")!
        let underLineText = (skipText as NSString).underLine(lineColor: OSSVThemesColors.col_0D0D0D(), textColor: OSSVThemesColors.col_0D0D0D(), font: UIFont.systemFont(ofSize: 12))
        skipBtn.setAttributedTitle(underLineText, for: .normal)
        
        skipBtn.sensor_element_id = "COD_SMS_Verify_Fail_Skip"
//        skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(skipBtn)
        self.skipButton = skipBtn
        skipBtn.snp.makeConstraints { make in
            make.centerX.equalTo(verifyBtn.snp.centerX)
            make.top.equalTo(verifyBtn.snp.bottom).offset(15)
            make.height.equalTo(24)
        }
        skipBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.skipAction()
        }).disposed(by: disposeBag)
        skipBtn.isHidden = true
    }
    
    func skipAction(){
        OSSVOrdereCodChangeeStatusAip(orderId: orderId).requestChangeStatus(view: view)
            .subscribe(onNext:{[weak self] passed,_ in
                if passed {
                    if let success = self?.success {
                        success(true,"skip")
                        self?.dismiss(animated: true, completion: nil)
                        HUDManager.showHUD(withMessage: STLLocalizedString_("sms_code_will_contact"))
                    }
                }
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
                self.requestSendSMS()
                self.cellIpunt?.regionCodeLbl?.text = self.phoneCode
                return
            }
        }
        
        for country in obj.countries {
            if country.countryId == obj.default_country_id{
                self.country = country
                self.requestSendSMS()
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
            self?.codeViewErr?.snp.updateConstraints({ make in
                make.height.equalTo(result.0 ? 0 : 12)
            })
            //成功后执行成功回调
            if let success = self?.success {
                success(result.0,"cod")
            }
            if result.0 {
                self?.codeView?.setAllUnderLineColor(OSSVThemesColors.col_CCCCCC())
                self?.codeViewErr?.text = ""
                
                self?.dismiss(animated: true, completion: nil)
            }else{
//                if let showSkip = result.3 {
//                    self?.skipButton?.isHidden = !showSkip
//                }
                self?.codeView?.setAllUnderLineColor(OSSVThemesColors.col_B62B21())
                self?.codeViewErr?.text = result.1
            }
        }).disposed(by: disposeBag)
    }
}


///手机号码
extension OSSVCODVierifyVC:DetailTextFieldDelegate{
    func textFieldDidEndEditing(_ detailField: DetailTextField, filed field: UITextField) {
        ///1..对比
        if field.text == self.phone{
            return
        }
        
        if field.text?.isContainArabic ?? false || field.text?.isAllSameNumber ?? false{
            detailField.setError(STLLocalizedString_("id_num_format_err")!, color: OSSVThemesColors.col_B62B21())
            return
        }

        
        countDown.stopCountDown()
        ///2.校验
        OSSVAddresseCheckePhoneAip(checkPhone: field.text ?? "", countryId: country?.countryId ?? "", countryCode: country?.country_code ?? "")
            .requestCheckPhone(view: view)
            .subscribe(onNext:{[weak self] result in
                self?.countDown.isEnabled = result.0
//                self?.verifyBtn?.isEnabled = result.0
                if result.0{
//                    self?.verifyBtn?.backgroundColor = OSSVThemesColors.col_0D0D0D()
                    self?.cellIpunt?.setError("", color: OSSVThemesColors.col_CCCCCC())
                    self?.phone = field.text
                    ABTestTools.shared.changePhoneNum()
                }else{
                    self?.verifyBtn?.backgroundColor = OSSVThemesColors.col_B2B2B2()
                    self?.cellIpunt?.setError(result.1 ?? "", color: OSSVThemesColors.col_B62B21())
                }
            }).disposed(by: disposeBag)
    }
    
    func textFieldDidBeginEditing(_ detailField: DetailTextField, filed field: UITextField) {
//        codeView?.resignFirstResponder()
        codeView?.textView.resignFirstResponder()
        codeView?.keyBoardWillHidden(nil)
    }
    
    func textFieldShouldReturn(_ detailField: DetailTextField, filed field: UITextField) -> Bool {
        guard let text = field.text else { return true }
        return !text.isContainArabic && !text.isAllSameNumber
    }
    
    func textField(_ textField: UITextField, detailText detailField: DetailTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !string.isContainArabic
    }
    
    
}
