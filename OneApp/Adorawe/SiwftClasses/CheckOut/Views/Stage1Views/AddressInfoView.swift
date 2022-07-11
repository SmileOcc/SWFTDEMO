//
//  AddressInfoView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SwiftyJSON


///地址详情 交互重
class AddressInfoView: UIView {
    
    weak var scrollParent:UIScrollView?
    
    lazy var autoCompliteListView:AutoCompleteView = {
        let popView = AutoCompleteView()
        popView.backgroundColor = .white
        popView.isHidden = true
        self.scrollParent!.addSubview(popView)
        self.bringSubviewToFront(popView)
        popView.snp.makeConstraints { make in
            make.top.equalTo(addressLine1.messageView!.snp.top)
            make.leading.trailing.equalTo(addressLine1)
            make.height.equalTo(170)
        }
        
        popView.selectedObj.subscribe(onNext:{[weak self] obj in
            self?.didselectAutoColplete(obj: obj)
            self?.manualEdit.accept(true)
            self?.autoCompliteListView.isHidden = true
        }).disposed(by: disposeBag)
        
        return popView
    }()
    
    let sessionToken = UUID().uuidString as NSString
    
    private let disposeBag = DisposeBag()
    
    lazy var manualEdit:BehaviorRelay<Bool> = {
        let publish = BehaviorRelay<Bool>(value:false)
        publish.subscribe(onNext:{[weak self] newValue in
            self?.addressLine1View.isHidden = newValue
            self?.groupManual.forEach { view in
                view.isHidden = !newValue
            }
           
        }).disposed(by: disposeBag)
        return publish
    }()
    
    private lazy var needZip:BehaviorRelay<Bool> = {
        let reply = BehaviorRelay<Bool>(value: false)
        reply.subscribe(onNext:{[weak self] newValue in
            self?.zipInput.placeholder = newValue ?  STLLocalizedString_("Zip*") : STLLocalizedString_("Zip")
        }).disposed(by: disposeBag)
        return reply
    }()
    
    private lazy var needIdNum:BehaviorRelay<Bool> = {
        let reply = BehaviorRelay<Bool>(value: false)
        reply.subscribe(onNext:{[weak self] newValue in
            self?.idInput.isHidden = !newValue
        }).disposed(by: disposeBag)
        return reply
    }()
    
    private lazy var displayCity:BehaviorRelay<Bool> = {
        let reply = BehaviorRelay<Bool>(value: false)
        reply.subscribe(onNext:{[weak self] newValue in
            self?.cityInput.isHidden = !newValue
        }).disposed(by: disposeBag)
        return reply
    }()
    ///引用直接更改
    weak var model:OSSVAddresseBookeModel?
    

    var addressLine1:NormalInputFiled! ///后面再自定义
    var countryDisplay:CountryDisplayField! ///后面再自定义
    var additionalInput:NormalInputFiled!
    var zipInput:ZipCodeInputField!
    var phoneNumInput:PhoneNumTextField!
    var idInput:NormalInputFiled!
    var cityInput:NormalInputFiled!
    var streetInput:NormalInputFiled!
    
    var enterManualButton:UIButton!
    
    //两个展示互斥组
    var groupManual:[UIView] = []
    var addressLine1View:UIView!
    
    var phoneValid = BehaviorRelay<Bool>(value:false)
    
    var regionValid = BehaviorRelay<Bool>(value:false)
    
    var streetValid = BehaviorRelay<Bool>(value:false)
    
    ///根据国家
    var zipValid = BehaviorRelay<Bool>(value:true)
    ///根据国际
    var idnumValid = BehaviorRelay<Bool>(value:true)
    ///根据国家
    var cityValid = BehaviorRelay<Bool>(value:true)
    
    private var phoneCodeRuleModel: PhoneCodeRulesModel?
    

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
            make.edges.equalTo(UIEdgeInsets(top: 15, left: 15, bottom: 5, right: 15))
        }
        
        setupAddressLine1(stackView: stackView)
        
        setupManualInput(stackView: stackView)
        
    }
    
    ///google 自动匹配的
    func setupAddressLine1(stackView:UIStackView){
        let addressLine1View = UIView()
        stackView.addArrangedSubview(addressLine1View)
        self.addressLine1View = addressLine1View
        
        let addressLine1 = NormalInputFiled(frame: .zero)
        addressLine1View.addSubview(addressLine1)
        addressLine1.placeholder = "*\(STLLocalizedString_("Address")!)"
        addressLine1.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(-20)
        }
        addressLine1.errorStyle = .Border
        self.addressLine1 = addressLine1
        let enterManualButton = UIButton()
        enterManualButton.setTitle(STLLocalizedString_("enter address manually"), for: .normal)
        enterManualButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        enterManualButton.setTitleColor(OSSVThemesColors.col_000000(0.5), for: .normal)
        addressLine1View.addSubview(enterManualButton)
        self.enterManualButton = enterManualButton
        enterManualButton.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.bottom.equalTo(addressLine1.snp.bottom).offset(8)
        }
        
        enterManualButton.rx.tap.subscribe(onNext:{
            self.manualEdit.accept(true)
        }).disposed(by: disposeBag)
        
        let underLine = UIView()
        underLine.backgroundColor = UIColor(patternImage: UIImage(named: "spic_dash_line_black")!)
        enterManualButton.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(-4)
            make.height.equalTo(1)
        }
        
        let maskView = AutoCompleteMaskView(frame: .zero)
        addressLine1View.addSubview(maskView)
        let targetView = addressLine1.inputContainer!
        maskView.snp.makeConstraints { make in
            make.leading.equalTo(targetView.snp.leading).offset(5)
            make.trailing.equalTo(targetView.snp.trailing).offset(-10)
            make.top.bottom.equalTo(targetView)
        }
        maskView.inputBtn.rx.tap.subscribe(onNext:{
            IQKeyboardManager.shared().isEnabled = false
            maskView.isHidden = true
            addressLine1.inputFiled?.becomeFirstResponder()
            
            UIView.animate(withDuration: 0.3) {
                self.scrollParent?.contentOffset = CGPoint(x: 0, y: (self.frame.origin.y - 10))
            }
        }).disposed(by: disposeBag)
        
        maskView.navBtn.rx.tap.subscribe(onNext:{
            ///定位
            ///self.manualEdit.onNext(true)
        }).disposed(by: disposeBag)
        
        addressLine1.inputFiled?.rx.controlEvent(.editingDidEnd).subscribe(onNext:{
            IQKeyboardManager.shared().isEnabled = true
        }).disposed(by: disposeBag)
        
        addressLine1.inputFiled?.rx.controlEvent(.editingDidBegin).subscribe(onNext:{
            IQKeyboardManager.shared().isEnabled = false
            UIView.animate(withDuration: 0.3) {
                self.scrollParent?.contentOffset = CGPoint(x: 0, y: (self.frame.origin.y - 10))
            }
        }).disposed(by: disposeBag)
        
        //MARK: - 地址填充逻辑
        let urlResult = addressLine1.inputFiled?.rx.text
            .asObservable()
            .throttle(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .filter({ str in
                return (str ?? "").count > 2
            })///截流后
            .map({[weak self] str ->String in
                let text = str?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                let countryCode:String = self?.model?.country_Code ?? ""
                var countryCodePara:String = ""

                let userDefaults = UserDefaults.standard
                var defaultCountryCode = ""
                defaultCountryCode = userDefaults.string(forKey: kDefaultCountryCode) ?? ""
                
                if (countryCode.count != 0) {
                    countryCodePara = "country:" + countryCode
                } else {
                    if (defaultCountryCode.count != 0) {
                        countryCodePara = "country:" + defaultCountryCode
                    }
                }
                
                let currentLanagure:String = STLLocalizationString.shareLocalizable().nomarLocalizable

                let url = String.googleSearchApi(input: text ?? "", components: countryCodePara, language: currentLanagure, sessionToken: self!.sessionToken as String)
                return url
            })
        
        let reqResult = urlResult?.flatMap({ str in
            return OSSVGoogleeSearcheAddressApi(url: str)
                .requestAddressList(view: self.viewContainingController!.view)
        })
        reqResult?.map({ dic in
            return JSON(dic)
        }).subscribe(onNext:{[weak self] dict in
            if let arr = dict.array,
               arr.count > 0 && self?.manualEdit.value == false{
                self?.autoCompliteListView.isHidden = false
                self?.autoCompliteListView.predications = arr
            }else{
                self?.autoCompliteListView.isHidden = true
            }
        }).disposed(by: disposeBag)
            
    }
    
    ///手动输入的几个框子
    func setupManualInput(stackView:UIStackView){
        let countryDisplay = CountryDisplayField(frame: .zero)
        countryDisplay.deviderColor = OSSVThemesColors.col_CCCCCC()
        countryDisplay.floatPlaceholderColor = OSSVThemesColors.col_999999()
        stackView.addArrangedSubview(countryDisplay)
        countryDisplay.placeholder = STLLocalizedString_("text_address_select_city")!
        countryDisplay.text = nil
        countryDisplay.errorStyle = .Border
        let accerryView = YYAnimatedImageView()
        accerryView.image = UIImage(named: "address_arr")
        accerryView.convertUIWithARLanguage()
        countryDisplay.traillingView?.addSubview(accerryView)
        accerryView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.trailing.equalTo(countryDisplay.traillingView!.snp.trailing)
            make.centerY.equalTo(countryDisplay.displayLbl!.snp.centerY)
        }
        self.countryDisplay = countryDisplay
        groupManual.append(countryDisplay)
        countryDisplay.touchButton?.isEnabled = true
        
        countryDisplay.touchButton?.rx.tap.subscribe(onNext:{[weak self] in
            let vc = CascadeSelectViewController()
            vc.doneSelected.subscribe(onNext:{[weak self] selectedItem in
                ///选中国家城市
                self?.countryRegionSelected(selectedItem: selectedItem)
            }).disposed(by: self!.disposeBag)
            self?.viewContainingController?.present(vc, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
        let cityInput = NormalInputFiled(frame: .zero)
        stackView.addArrangedSubview(cityInput)
        cityInput.placeholder = STLLocalizedString_("City")!
        cityInput.errorStyle = .Border
        self.cityInput = cityInput
        cityInput.isHidden = true
        cityInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            let (result,message) = CheckTools.checkCity(text: cityInput.text, cityId: self?.model?.cityId)
            cityInput.errorMessage = message
            self?.model?.city = cityInput.text
            self?.cityValid.accept(result)
        }).disposed(by: disposeBag)
        
        let streetInput = NormalInputFiled(frame: .zero)
        stackView.addArrangedSubview(streetInput)
        streetInput.placeholder = STLLocalizedString_("user_address_street")!
        streetInput.errorStyle = .Border
        self.streetInput = streetInput
        streetInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            let (result,message) = CheckTools.checkStreet(text: streetInput.text)
            streetInput.errorMessage = message
            self?.streetValid.accept(result)
            self?.model?.street = streetInput.text
        }).disposed(by: disposeBag)
        groupManual.append(streetInput)
        
        let additionalInput = NormalInputFiled(frame: .zero)
        stackView.addArrangedSubview(additionalInput)
        additionalInput.placeholder = STLLocalizedString_("placeholderApartment")!
        additionalInput.errorStyle = .Border
        self.additionalInput = additionalInput
        groupManual.append(additionalInput)
        additionalInput.inputFiled?.rx.text.subscribe(onNext:{[weak self] text in
            self?.model?.streetMore = text
        }).disposed(by: disposeBag)
        
        let zipInput = ZipCodeInputField(frame: .zero)
        zipInput.regionCode = CheckTools.isJpSite ? "〒" : nil
        zipInput.keyBoardType = CheckTools.isJpSite ? .numberPad : .default
        zipInput.errorStyle = .Border
        stackView.addArrangedSubview(zipInput)
        zipInput.placeholder = STLLocalizedString_("Zip*")
        self.zipInput = zipInput
        groupManual.append(zipInput)
        zipInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            if self?.needZip.value == true || CheckTools.isJpSite{
                let (result,message) = CheckTools.checkZipCode(text: zipInput.text)
                zipInput.errorMessage = message
                self?.zipValid.accept(result)
                self?.model?.zipPostNumber = zipInput.text
            }else{
                self?.zipValid.accept(true)
            }
        }).disposed(by: disposeBag)
        
        let phoneNumInput = PhoneNumTextField(frame: .zero)
        phoneNumInput.regionCode = nil
        phoneNumInput.errorStyle = .Border
        stackView.addArrangedSubview(phoneNumInput)
        phoneNumInput.placeholder = STLLocalizedString_("PhoneNumber")
        self.phoneNumInput = phoneNumInput
        phoneNumInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            let (result,message) = CheckTools.checkPhoneBasic(text: phoneNumInput.text)
            phoneNumInput.errorMessage = message
            if result{
                self?.model?.phone = phoneNumInput.text
            }
            self?.phoneValid.accept(result)
        }).disposed(by: disposeBag)
        
        let phoneCheck = phoneNumInput.inputFiled?.rx.controlEvent([.editingDidEnd])
            .filter({ _ in
                if let str = phoneNumInput.text?.count {
                    return str > 2
                }
                return false
            })
            .flatMap({[weak self] _ in
            return OSSVAddresseCheckePhoneAip(checkPhone: phoneNumInput.text ?? "", countryId: self?.model?.countryId ?? "", countryCode: self?.model?.country_Code ?? "")
                .requestCheckPhone(view: self!.viewContainingController!.view)
        })
        phoneCheck?.subscribe(onNext:{[weak self] (success,message) in
            self?.phoneValid.accept(success)
            phoneNumInput.errorMessage = message
        }).disposed(by: disposeBag)
        
        let idInput = NormalInputFiled(frame: .zero)
        idInput.errorStyle = .Border
        stackView.addArrangedSubview(idInput)
        idInput.placeholder = STLLocalizedString_("idNumber")!
        idInput.isHidden = true
        self.idInput = idInput
//        groupManual.append(idInput)
        idInput.inputFiled?.rx.controlEvent([.editingChanged,.editingDidEnd]).subscribe(onNext:{[weak self] in
            let (result,message) = CheckTools.checkIdNum(text: idInput.text, country_Code: self?.model?.country_Code)
            self?.idnumValid.accept(result)
            idInput.errorMessage = message
            self?.model?.idCard = idInput.text
        }).disposed(by: disposeBag)
    }
    
    func updateCountryDisplay(){
        var regiontxts:[String] = []
        if let country = model?.country{
//            regiontxt += "\(country)"
            regiontxts.append(country)
        }
        if let state = model?.state {
            regiontxts.append(state)
        }
        if let city = model?.city {
            regiontxts.append(city)
        }
        if let area = model?.area {
            regiontxts.append(area)
        }
        regiontxts = regiontxts.filter{ !$0.isEmpty }
        
        self.countryDisplay.text = regiontxts.joined(separator: "\n")
    }
    
    ///国家选择完成处理
    func countryRegionSelected(selectedItem: SelectedResult){
        if selectedItem.country == nil{
            self.countryDisplay.errorMessage = .CountryEmptyMsg
        }
        
        if let countryCode = selectedItem.country?.country_code {
            needIdNum.accept(countryCode == .JO || countryCode == .QA)
            idnumValid.accept(!(countryCode == .JO || countryCode == .QA))
        }
        model?.country = selectedItem.country?.address_name ?? nil
        model?.countryId = selectedItem.country?.address_id ?? nil
        model?.country_Code = selectedItem.country?.country_code ?? nil
        model?.city = selectedItem.city?.address_name ?? nil
        model?.cityId = selectedItem.city?.address_id ?? nil
        model?.state = selectedItem.province?.address_name ?? nil
        model?.stateId = selectedItem.province?.address_id ?? nil
        model?.area = selectedItem.area?.address_name ?? nil
        model?.area_id = selectedItem.area?.address_id ?? nil
        
        updateCountryDisplay()
        
        displayCity.accept(model?.cityId == nil)
        cityValid.accept(model?.cityId != nil)
        if let country = selectedItem.country,
           let need_zip = country.need_zip_code{
            needZip.accept(need_zip == 1 || CheckTools.isJpSite)
            zipValid.accept(!(need_zip == 1 || CheckTools.isJpSite))
        }
//        print("country.need_zip_code \(selectedItem.country?.need_zip_code)")
        
        
        let (result,messg) = CheckTools.checkCountry(text: countryDisplay?.text)
        if !result{
            countryDisplay?.errorMessage = messg
        }
        self.regionValid.accept(result)
        
        checkPhoneWhenSelectedCountry()
        
    }
    
    func checkPhoneWhenSelectedCountry(){
        let phoneCodeApi = OSSVGetePhoneAreaeCodeAip(getPhoneAreaCodeForCountryCode: model?.country_Code ?? "")
        phoneCodeApi.requestPhoneCode().subscribe(onNext:{[weak self] (success,phoneCodeModel) in
            self?.phoneCodeRuleModel = phoneCodeModel
            self?.model?.countryCode = self?.phoneCodeRuleModel?.country_area_code
            self?.phoneNumInput?.regionCode = self?.model?.countryCode
        }).disposed(by: disposeBag)
        phoneNumInput?.regionCode = model?.countryCode
        
        if let phone = self.model?.phone,
           phone.count > 1{
            OSSVAddresseCheckePhoneAip(checkPhone: phone, countryId: self.model?.countryId ?? "", countryCode: self.model?.country_Code ?? "")
                .requestCheckPhone(view: self.viewContainingController!.view)
                .subscribe(onNext:{[weak self] (success,message)in
                    self?.phoneValid.accept(success)
                    self?.phoneNumInput.errorMessage = message
                }).disposed(by: disposeBag)
        }
    }
    
    ///选中Google 自动匹配
    func didselectAutoColplete(obj: JSON?){
        model?.streetMore = obj?["description"].string
        if let placeId = obj?["place_id"].string {
            GMSPlaceHelper.getDetailsInfo(placeId: placeId).subscribe(onNext:{[weak self] place in
                if let place = place,
                   let components = place.addressComponents{
                    for comp in components {
                        if let type = comp.types.first {
                            switch type{
                            case "country":
                                self?.model?.country = comp.name
                                self?.model?.countryCode = comp.shortName
                            case "administrative_area_level_1":
                                self?.model?.state = comp.name
                            case "locality","administrative_area_level_2":
                                self?.model?.city = comp.name
                                self?.cityInput.text = comp.name
                                self?.displayCity.accept(true)
                            case "postal_code":
                                self?.model?.zipPostNumber = comp.name
                                self?.zipInput.text = comp.name
                            case "sublocality","neighborhood","sublocality_level_1":
                                self?.model?.area = comp.name
                            default:
                                break;
                            }
                        }
                    }
                    self?.model?.street = place.formattedAddress
                    self?.streetInput.text = place.formattedAddress
                    ///更新组件内容
                    self?.reMatchInputs()
                    print(place)
                }
            }).disposed(by: disposeBag)
        }
    }
    
    func reMatchInputs(){
        ///级联匹配
        if let countryCode = model?.countryCode {
            let matchedCountry = AddressCascadeAPI(val: "", type: 1, level: 1).loadData().compactMap({ model -> AddressItemModel? in
                let filterd = model?.result?.filter { ele in
                    ele.country_code == countryCode
                }
                return filterd?.first
            })
            
            matchedCountry.subscribe(onNext:{[weak self] matchCountry in
                self?.model?.countryId = matchCountry.address_id
                self?.model?.country_Code = matchCountry.country_code
                ///更新视图
                self?.checkPhoneWhenSelectedCountry()
                self?.updateCountryDisplay()
                
                let (result,messg) = CheckTools.checkCountry(text: self?.countryDisplay?.text)
                if !result{
                    self?.countryDisplay?.errorMessage = messg
                }
                self?.regionValid.accept(result)
                
                
                if let stateName = self?.model?.state,
                    matchCountry.have_children == "1"{
                    let matchedState = AddressCascadeAPI(val: matchCountry.address_id!, type: 1, level: 2).loadData().compactMap({ model -> AddressItemModel? in
                        let filterd = model?.result?.filter { ele in
                            ele.address_name == stateName
                        }
                        return filterd?.first
                    })
                    matchedState.subscribe(onNext:{ matchState in
                        ///更新视图
                        self?.updateCountryDisplay()
                        self?.model?.stateId = matchState.address_id
                    }).disposed(by: self!.disposeBag)
                }
            }).disposed(by: disposeBag)
        }
    }
}
