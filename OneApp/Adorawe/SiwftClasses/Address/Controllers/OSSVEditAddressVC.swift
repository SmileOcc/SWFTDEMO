//
//  OSSVEditAddressVC.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/3.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import CoreLocation
import MapKit

class OSSVEditAddressVC: STLBaseCtrl {
    
    lazy var isJpSite = STLWebsitesGroupManager.shared().currentWebsitesModel.site_code == "vivaia_jp"
        
    @objc var needPopToLastBefore:NSNumber?
        
    @objc var saveBtnTitle = app_type == 3 ? STLLocalizedString_("SaveAddress")! : STLLocalizedString_("SaveAddress")!.uppercased()

    private var disposeBag = DisposeBag()
        
    var viewModel = OSSVModifyeAddresseViewModel()
    
    var isPositioned = false
    
    var location:CLLocation?
    var googleApiParams:(country:String,countryCode:String,province:String,detailAddress:String,cityName:String,area:String) = (country:"",countryCode:"",province:"",detailAddress:"",cityName:"",area:"")
    
    ///是否发送网络请求
    //Google地址收集api
    lazy var sentAddres:PublishSubject<Bool> = {
        let sub = PublishSubject<Bool>()
        sub.subscribe(onNext:{[weak self] needSend in
            if needSend {
                GATools.logAddEditAddressEvent(action: "Address_Submit")
                if self?.isModify == 1{
                    self?.requestModify()
                }else{
                    self?.requestAdd()
                }
            }
        }).disposed(by: disposeBag)
        return sub
    }()
    
    @objc var model:OSSVAddresseBookeModel?{
        didSet{
            isMapCheck    = (model?.map_check ?? 0) == 1
            isNeedZipCode = (model?.need_zip_code ?? 0) == 1
            fillInDatas(model: model)
        }
    }
    
    var phoneCodeRuleModel:PhoneCodeRulesModel?
    
    lazy var popView:OSSVLocationePopeView = {
        let pop = OSSVLocationePopeView(frame: CGRect(x: 0, y: 0, width: CGFloat.screenWidth, height: CGFloat.screenHeight))
        pop.delegate = self
        return pop
    }()
    ///控制是否发送Google 自动填充API
    var isSelectedCompleteList:Bool = false
    lazy var autoCompliteListView:OSSVAddresseRelatedeSearchView = {
        let popView = OSSVAddresseRelatedeSearchView()
        popView.backgroundColor = .white
        popView.isHidden = true
        self.tableView?.addSubview(popView)
        self.tableView?.bringSubviewToFront(popView)
        let rect = self.tableView?.rectForRow(at: IndexPath(row: 1, section: 0)) ?? .zero
        popView.snp.makeConstraints { make in
            make.top.equalTo(rect.maxY - 14)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.width.equalTo(CGFloat.screenWidth - 84)
            make.height.equalTo(192)
        }
        popView.selectAddressDetail = {[weak self] address in
            self?.locateAddressInput?.text = address
            self?.isSelectedCompleteList = true
            self?.model?.street = address
        }
       
        popView.updateCountryAndCity = { [weak self] countryCode,countryName,proviceName,cityName,_,_,address,areaName,_ in
            self?.googleApiParams.country = countryName
            self?.googleApiParams.countryCode = countryCode
            self?.googleApiParams.province = proviceName
            self?.googleApiParams.cityName = cityName
            self?.googleApiParams.detailAddress = address
            self?.googleApiParams.area = areaName
        }

        return popView
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        popView.hiddenView()
    }
    
    lazy var locationDiscription:NSAttributedString = {
        let clickStr = STLLocalizedString_("Click")!
        let locateStr = STLLocalizedString_("Locate")!
        let helpStr = STLLocalizedString_("helpFillAddress")!
        let infoText = "\(clickStr) \(locateStr)\(helpStr)"
        let attrStr = NSMutableAttributedString(string: infoText)
        attrStr.addAttribute(.foregroundColor, value: OSSVThemesColors.col_B3B3B3(), range: NSRange(location: 0, length: clickStr.count))

        attrStr.addAttributes([
            .foregroundColor: OSSVThemesColors.col_0D0D0D(),
            NSAttributedString.Key.underlineStyle:0x01,
        ], range: NSRange(location: clickStr.count + 1, length: locateStr.count))
        
        attrStr.addAttribute(.foregroundColor, value: OSSVThemesColors.col_B3B3B3(), range: NSRange(location: clickStr.count+1 + locateStr.count, length: helpStr.count))
        return attrStr.copy() as! NSAttributedString
    }()
    
    //存BOOL
    @objc var isModify:NSNumber?
    
    @objc var successBlock:((String)->Void)?
    @objc var getAddressModelBlock:((OSSVAddresseBookeModel)->Void)?
    
    ///输入
    weak var countryRegionInput:CountryDisplayField?
    weak var cityInput:NormalInputFiled?
    weak var stateInput:NormalInputFiled?
    weak var locateAddressInput:CustomTalingTextField?
    weak var detailAddressInput:NormalInputFiled?
    
    weak var lastNameInput:NormalInputFiled?
    weak var firstNameInput:NormalInputFiled?
    weak var phoneInput:PhoneNumTextField?
    weak var idNumberInput:NormalInputFiled?
    
    weak var zipCodeInput:ZipCodeInputField?
    weak var alterPhoneInput:PhoneNumTextField?
    
    weak var addressTypeCell:AddressTypeCell?
    weak var setasDefaultCell:SetAsDefaultCell?
    
    ///分组数据
    var groupDatas:[AddressGroupModel] = []
    
    ///邮编是否必填
    var isNeedZipCode:Bool = false
    //是否展示定位功能
    var isMapCheck:Bool = true
    
    weak var tableView:UITableView?
    weak var bottomView:UIView?
    
    ///联系人信息
    var contactInfos:[UITableViewCell]?
    ///地址信息
    var locationInfos:[UITableViewCell]?
    ///
    var optionInfos:[UITableViewCell]?

    /// 个人信息组
    var idNumberCell:UITableViewCell?
    var nameCell:UITableViewCell?
    var phoneCell:UITableViewCell?
    
    /// 地址信息组
    var countryCell:UITableViewCell?
    var addressCell:UITableViewCell?
    var cityCell:UITableViewCell?
    var stateCell:UITableViewCell?
    var additionAddressCell:UITableViewCell?
    
    /// 可选信息组
    var zipCodeCell:UITableViewCell?
    var alternatPhoneCell:UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.controller = self
        setupDatas()
        setupSubViews()
        
        if isModify == 1{
            title = String.modifyAddress.capitalized
        }else{
            title = String.addressAddAdress.capitalized
            let model = OSSVAddresseBookeModel()
            model.phone = OSSVAccountsManager.shared().account.phone
            self.model = model
        }
        
        self.navigationController?.navigationBar.backgroundColor = .white
//        UIApplication.shared.sta
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillInDatas(model: model)
        updateIdFieldShowHide(countryCode: model?.country_Code)
        updatePostCodePos(isNeeded: isNeedZipCode || isJpSite)
        self.requestPhomeApi(countryCode: model?.country_Code)
    }
    
    deinit {
        contactInfos = nil
        idNumberCell = nil
    }
    
}

//MARK: 子视图
extension OSSVEditAddressVC{
    
    func setupSubViews() {
        setupBottomView()
        setupTable()
    }
    
    func setupBottomView() {
        let bottomView = UIView(frame: .zero)
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(67)
        }
        bottomView.backgroundColor = .white
        self.bottomView = bottomView

        let bottomButton = UIButton(frame: .zero)
        bottomView.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.bottom.equalTo(-8)
            make.height.equalTo(44)
        }
        bottomButton.backgroundColor = OSSVThemesColors.col_0D0D0D()
        bottomButton.setTitle(self.saveBtnTitle.uppercased(), for: .normal)
        bottomButton.titleLabel?.font = UIFont.stl_buttonFont(14)
        bottomButton.addTarget(self, action: #selector(saveAddress), for: .touchUpInside)
        
        let fillV = UIView()
        fillV.backgroundColor = .white
        view.addSubview(fillV)
        fillV.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(0)
            make.top.equalTo(bottomView.snp.bottom)
        }
    }
    
    @objc func saveAddress() {
        ///校验
        var needRequest = true
        var (result,messg) = CheckTools.checkCountry(text: countryRegionInput?.text)
        if !result{
            countryRegionInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        
        (result,messg) = CheckTools.checkStreet(text: locateAddressInput?.text)
        needRequest = result && needRequest
        if !result{
            locateAddressInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        //firstNameInput?.text
        (result,messg) = CheckTools.checkFirstName(text: firstNameInput?.text)
        needRequest = result && needRequest
        if !result{
            firstNameInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        (result,messg) = CheckTools.checkLastName(text: lastNameInput?.text)
        needRequest = result && needRequest
        if !result{
            lastNameInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        
        (result,messg) = CheckTools.checkPhoneBasic(text: phoneInput?.text)
        needRequest = result && needRequest
        if !result{
            phoneInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        needRequest = checkAltPhone() && needRequest
        
        (result,messg) = CheckTools.checkIdNum(text: idNumberInput?.text, country_Code: model?.country_Code)
        needRequest = result && needRequest
        if !result{
            idNumberInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        
        needRequest = checkZipCode() && needRequest
        
                
        (result,messg) = CheckTools.checkCity(text: cityInput?.text, cityId: model?.cityId)
        needRequest = result && needRequest
        if !result{
            cityInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        
        (result,messg) = CheckTools.checkState(text: stateInput?.text, stateId: model?.stateId)
        needRequest = result && needRequest
        if !result{
            stateInput?.errorMessage = messg
            self.tableView?.reloadData()
        }
        if (!needRequest){
            return
        }
        
        if model?.addressType == nil{
            model?.addressType = "0"
        }
        //先校验地址 再发请求
        if let value = self.phoneInput?.text,
           let countryId = model?.countryId,
           let countryCode = model?.country_Code{
            OSSVAddresseCheckePhoneAip(checkPhone: value, countryId: countryId, countryCode: countryCode)
                .requestCheckPhone(view: self.view)
                .subscribe(onNext:{ (valid,errMsg) in
                    if valid {
                        self.sentAddres.onNext(true)
                    }else{
                        self.phoneInput?.errorMessage = errMsg
                    }
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    func requestAdd(){
        viewModel.requestNetwork(model) {[self] addressId in
            //埋点
            OSSVGoogleeMapAddresseCollectAip(
                googleMapAddressWithCountryCode: self.googleApiParams.countryCode ,
                countryName: self.googleApiParams.country ,
                proviceName: self.googleApiParams.province ,
                cityName: self.googleApiParams.cityName ,
                latitude: String(self.model?.latitude ?? 0),
                longitude: String(self.model?.longitude ?? 0),
                address: self.googleApiParams.detailAddress ,
                areaName: self.googleApiParams.area )
                .start { _ in
                } failure: { _, _ in
                }
            
            let paramDict = [
                "receiver_name":model?.firstName,
                "receiver_country":model?.country,
                "receiver_city":model?.city,
                "receiver_province":model?.province,
                "receiver_district":model?.district,
                "receiver_address":model?.area,
                "is_positioning":isPositioned ? "1" : "0",
                "number":model?.phone,
                "zip":model?.zipPostNumber,
                "adress_type":model?.addressType ?? "0"
            ]
            OSSVAnalyticsTool.analyticsSensorsEvent(withName: "FillInAdreess", parameters: paramDict as [AnyHashable : Any])
            self.successBlock?((addressId as? String) ?? "")
            self.getAddressModelBlock?(self.model!)
            if  let count = self.navigationController?.viewControllers.count,
                count >= 3,
                let vc = self.navigationController?.viewControllers[count - 3],
                self.needPopToLastBefore == true{
                self.navigationController?.popToViewController(vc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        } failure: { _ in
            HUDManager.showHUD(withMessage: .errorMsg)
        }

    }
    
    func requestModify() {
        viewModel.requestEditAddressNetwork(model) { [self] obj in
            
            OSSVGoogleeMapAddresseCollectAip(
                googleMapAddressWithCountryCode: self.googleApiParams.countryCode ,
                countryName: self.googleApiParams.country ,
                proviceName: self.googleApiParams.province ,
                cityName: self.googleApiParams.cityName ,
                latitude: String(self.model?.latitude ?? 0),
                longitude: String(self.model?.longitude ?? 0),
                address: self.googleApiParams.detailAddress ,
                areaName: self.googleApiParams.area )
                .start { _ in
                } failure: { _, _ in
                }
            //埋点
            let paramDict = [
                "receiver_name":model?.firstName,
                "receiver_country":model?.country,
                "receiver_city":model?.city,
                "receiver_province":model?.province,
                "receiver_district":model?.district,
                "receiver_address":model?.area,
                "is_positioning":isPositioned ? "1" : "0",
                "number":model?.phone,
                "zip":model?.zipPostNumber,
                "adress_type":model?.addressType ?? "0"
            ]
            OSSVAnalyticsTool.analyticsSensorsEvent(withName: "FillInAdreess", parameters: paramDict as [AnyHashable : Any])
            self.successBlock?("")
            self.getAddressModelBlock?(self.model!)
            
        
            if  let count = self.navigationController?.viewControllers.count,
                count >= 3,
                let vc = self.navigationController?.viewControllers[count - 3],
                self.needPopToLastBefore == true{
                self.navigationController?.popToViewController(vc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        } failure: { err in
            //提示用户更新失败
            HUDManager.showHUD(withMessage: .errorMsg)
        }
    }
    
    func setupTable() {
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = OSSVThemesColors.col_F5F5F5()
        view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        tableView.estimatedRowHeight = 44;
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.bottom.equalTo(self.bottomView!.snp_topMargin)
        }
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: TableViewDelegate
extension OSSVEditAddressVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupDatas[section,true]?.cells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        groupDatas[indexPath.section,true]?.cells?[indexPath.row] ?? UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        groupDatas.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.roundedGroup(willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groupDatas[section,true]?.groupTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView{
            header.textLabel?.text = header.textLabel?.text?.capitalized
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = groupDatas[section,true]?.groupTitle, !title.isEmpty else { return 4 }
        return 44
    }
}

//MARK: 数据
extension OSSVEditAddressVC {
    func setupDatas() {
        setupAddressInfo()
        setupContactInfo()
        setupOptionInfo()
        setUptagInfo()
        
    }
    
    ///A站使用 V站中东站使用地图
    func isCanUseMap() -> Bool {
        let appSetCode: String = STLWebsitesGroupManager.currentCountrySiteCode()!
        let isVAr = appSetCode.contains("ar")
        if app_type == 1 {
            return true
        } else if (app_type == 3 && isVAr) {
            return true
        }
        return false
    }
    
    func setupAddressInfo() {
        let addressInfo = AddressGroupModel()
        //拿到sessionToken 用于定位谷歌地址联想api使用
        let sessionToken = UUID().uuidString as NSString
        print("sessionToken的 值\(sessionToken)")
        
        //1.四级联动
        let countryRegionCell = CountryRegionCell()
        self.countryCell = countryRegionCell
        countryRegionInput = countryRegionCell.detailTextfield
        let jumpToCountrySelectTap = UITapGestureRecognizer()
        countryRegionCell.contentView.addGestureRecognizer(jumpToCountrySelectTap)
        jumpToCountrySelectTap.rx.event.subscribe {[weak self] _ in
            GATools.logAddEditAddressEvent(action: "Select Country")
            let countrySelectVC = CascadeSelectViewController()
            countrySelectVC.finishedSelect = { country,province,city,area in
                self?.countryRegionInput?.errorMessage = nil
                if country == nil{
                    self?.locateAddressInput?.errorMessage = .CountryEmptyMsg
                }
                
                self?.updateIdFieldShowHide(countryCode: country?.country_code)
                self?.model?.country = country?.address_name ?? nil
                self?.model?.map_check = country?.map_check ?? 1
                self?.model?.countryId = country?.address_id ?? nil
                self?.model?.country_Code = country?.country_code ?? nil
                self?.model?.city = city?.address_name ?? nil
                self?.model?.cityId = city?.address_id ?? nil
                
                self?.model?.state = province?.address_name ?? nil
                self?.model?.stateId = province?.address_id ?? nil
                
                self?.model?.area = area?.address_name ?? nil
                self?.model?.area_id = area?.address_id ?? nil
                
                self?.isMapCheck    = (country?.map_check ?? 0) == 1
                
                self?.fillInDatas(model: self?.model)
                
                ///根据国家邮编是否必填更新邮编位置
                var isNeedZip = false
                if let needZip = country?.need_zip_code {
                    isNeedZip = needZip == 1
                }
                
                if !isNeedZip{
                    self?.zipCodeInput?.errorMessage = nil
                }
                
                self?.isNeedZipCode = isNeedZip || self?.isJpSite == true
                
                UIView.performWithoutAnimation {
                    self?.tableView?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    self?.updatePostCodePos(isNeeded: isNeedZip || self?.isJpSite == true)
                }
                
                self?.requestPhomeApi(countryCode: country?.country_code)
            }
            countrySelectVC.lastSelected = LastSelectItem(country_id: nil, province_id: nil, city_id:nil, area_id: nil) //只回显国家
//            countrySelectVC.modalPresentationStyle = .overCurrentContext
//            countrySelectVC.isModalPresent = true
            self?.present(countrySelectVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        //1.5 城市Cell
        let cityCell = STLAddressNormalInputCell()
        cityInput = cityCell.detailTextfield
        cityInput?.placeholder = STLLocalizedString_("City")!
        cityInput?.delegate = self
        self.cityCell = cityCell
        
        //1.6 省份
        let stateCell = STLAddressNormalInputCell()
        stateInput = stateCell.detailTextfield
        stateInput?.placeholder = STLLocalizedString_("State")!
        stateInput?.delegate = self
        self.stateCell = stateCell

        //2.地址cell
        let addressLocateCell = AddressLocateCell()
        locateAddressInput = addressLocateCell.detailTextfield
        locateAddressInput?.delegate = self
        self.addressCell = addressLocateCell
        
        //定位图标
        ///APP站点区分使用
        
        if isMapCheck == true &&
            isCanUseMap(){ ///只在A站使用 V站中东站使用地图
//        if true{ //这样测试地图入口的 放开注释
            locateAddressInput?.attributeMessage = locationDiscription
            locateAddressInput?.isHiddingTralling = false
        }else{
            locateAddressInput?.attributeMessage = NSAttributedString()
            locateAddressInput?.isHiddingTralling = true
        }
        
        ///APP站点区分使用
        if isCanUseMap() {///只在A站使用
            
            locateAddressInput?.messageView?.sensor_element_id = "Address_Book_Location_Click"
            locateAddressInput?.traillingView?.sensor_element_id = "Address_Book_Location_Click"
            let buttontap = UITapGestureRecognizer()
            let labelTap = UITapGestureRecognizer()
            locateAddressInput?.messageView?.addGestureRecognizer(labelTap)
            locateAddressInput?.traillingView?.addGestureRecognizer(buttontap)
            buttontap.rx.event.subscribe { _ in
                //跳转到地图
                self.jumpToMapViewController()
            }.disposed(by: disposeBag)
            
            labelTap.rx.event.subscribe { _ in
                self.jumpToMapViewController()
            }.disposed(by: disposeBag)
        }
       //取出默认国家的code
        let userDefaults = UserDefaults.standard
        var defaultCountryCode = ""
        defaultCountryCode = userDefaults.string(forKey: kDefaultCountryCode) ?? ""
        
        print("----------------userDefaultValue", defaultCountryCode)

        //地址输入框，调用方法
        if isCanUseMap(){///只在A站使用
            locateAddressInput?.inputFiled?.rx.text
                .asObservable()
                .throttle(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
                .subscribe(onNext:{ text in
                    if let text = text?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                        let countryCode:String = self.model?.country_Code ?? ""
                        var countryCodePara:String = ""

                        
                        if (countryCode.count != 0) {
                            countryCodePara = "country:" + countryCode
                        } else {
                            if (defaultCountryCode.count != 0) {
                                countryCodePara = "country:" + defaultCountryCode
                            }
                        }
                        
                        let currentLanagure:String = STLLocalizationString.shareLocalizable().nomarLocalizable

                        let url = String.googleSearchApi(input: text, components: countryCodePara, language: currentLanagure, sessionToken: sessionToken as String)
                        
                        if text.count >= 2 {
                                                OSSVGoogleeSearcheAddressApi(url: url)
                                                    .requestAddressList(view: self.view)
                                                    .subscribe(onNext:{[weak self] result in
                                                        self?.autoCompliteListView.dataArray = result
                                                        self?.autoCompliteListView.isHidden = result.isEmpty || self?.isSelectedCompleteList ?? false
                                                        let hasCity = self?.model?.cityId != nil || self?.model?.countryId == nil
                                                        let rect = self?.tableView?.rectForRow(at: IndexPath(row: hasCity ? 1 : 2, section: 0)) ?? .zero
                                                        self?.autoCompliteListView.keyWord = text
                                                        if self?.isMapCheck == true {
                                                            self?.autoCompliteListView.snp.updateConstraints { make in
                                                                make.top.equalTo(rect.maxY - 28)
                                                            }

                                                        } else {
                                                            self?.autoCompliteListView.snp.updateConstraints { make in
                                                                make.top.equalTo(rect.maxY - 14)
                                                            }

                                                        }
                                                    }).disposed(by: self.disposeBag)

                        }
                        print(text)
                    }
            }).disposed(by: disposeBag)
        }
        

        
        //3.地址详情
        let detailAddresCell = STLAddressNormalInputCell()
        self.additionAddressCell = detailAddresCell
        detailAddressInput = detailAddresCell.detailTextfield
        detailAddressInput?.placeholder = STLLocalizedString_("placeholderApartment")!
        detailAddressInput?.delegate = self
        addressInfo.cells = [
            countryRegionCell,
            stateCell,
            cityCell,
            addressLocateCell,
            detailAddresCell
        ]
        self.locationInfos = addressInfo.cells
        groupDatas.append(addressInfo)
    }
    
    func setupContactInfo() {
        let contactInfo = AddressGroupModel()
        
        let nameCell = AddresNameCell()
        lastNameInput = nameCell.lastNameTextfield
        firstNameInput = nameCell.firstNameTextfield
        lastNameInput?.delegate = self
        firstNameInput?.delegate = self
        
        let phoneCell = AddressPhoneCell()
        phoneInput = phoneCell.detailTextfield
        phoneInput?.placeholder = STLLocalizedString_("PhoneNumber")!
        phoneInput?.delegate = self
        
        let idcard = STLAddressNormalInputCell()
        idNumberInput = idcard.detailTextfield
        idNumberInput?.placeholder = STLLocalizedString_("idNumber")!
        idNumberInput?.delegate = self
        idNumberInput?.keyBoardType = .numberPad
        
        self.idNumberCell = idcard
        self.nameCell = nameCell
        self.phoneCell = phoneCell
        
        contactInfo.cells = [
            nameCell,
            phoneCell,
//            idcard
        ]
        contactInfos = contactInfo.cells
        groupDatas.append(contactInfo)
    }
    
    @objc func defaultTagChanged(sender:UISwitch){
        model?.isDefault = sender.isOn
        GATools.logAddEditAddressEvent(action: "Defualt_Address_\(sender.isOn)")
    }

    
    func setUptagInfo() {
        let tagInfo = AddressGroupModel()
        let addressTypeCell = AddressTypeCell()
        self.addressTypeCell = addressTypeCell
        addressTypeCell.pub.subscribe(onNext:{ addressType in
            self.model?.addressType = "\(addressType)"
            GATools.logAddEditAddressEvent(action: "Address_Type_\(addressType)")
        }).disposed(by: disposeBag)

        let setAsDefalutCell = SetAsDefaultCell()
        self.setasDefaultCell = setAsDefalutCell
        
        setAsDefalutCell.defaultSwitch?.addTarget(self, action: #selector(defaultTagChanged(sender:)), for: .valueChanged)
        
        tagInfo.cells = [
            addressTypeCell,
            setAsDefalutCell
        ]
        groupDatas.append(tagInfo)
    }
    
    
    func setupOptionInfo() {
        let optionInfo = AddressGroupModel()
        optionInfo.groupTitle = "Optional Information"
        optionInfo.groupTitle = STLLocalizedString_("address_option_info")
        
        let zipCodeCell = AddressZipCell()
        self.zipCodeCell = zipCodeCell
        zipCodeCell.isFirstCell = false
        zipCodeInput = zipCodeCell.detailTextfield
        zipCodeInput?.delegate = self
        zipCodeInput?.placeholder = STLLocalizedString_("Zip")!
        
        
        let alterPhoneCell = AddressPhoneCell()
        alterPhoneCell.isFirstCell = true
        alterPhoneInput = alterPhoneCell.detailTextfield
        alterPhoneInput?.placeholder = STLLocalizedString_("Alternative_phone_number")!
        alterPhoneInput?.delegate = self
        self.alternatPhoneCell = alterPhoneCell
        
        optionInfo.cells = [
            alterPhoneCell,
            zipCodeCell,
        ]
        self.optionInfos = optionInfo.cells
        groupDatas.append(optionInfo)
    }
    
    //填充数据到界面
    func fillInDatas(model:OSSVAddresseBookeModel?) {
        firstNameInput?.text = model?.firstName
        lastNameInput?.text = model?.lastName
        detailAddressInput?.text = model?.streetMore
        locateAddressInput?.text = model?.street
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
       
        countryRegionInput?.text = regiontxts.joined(separator: "\n")
        stateInput?.text = model?.state
        cityInput?.text = model?.city
        
        zipCodeInput?.text = model?.zipPostNumber
        zipCodeInput?.regionCode = isJpSite ? "〒" : nil
        zipCodeInput?.keyBoardType = isJpSite ? .numberPad : .default
        
        alterPhoneInput?.text = model?.secondPhone
        phoneInput?.text = model?.phone
        phoneInput?.errorMessage = nil
        
        alterPhoneInput?.regionCode = model?.countryCode
        phoneInput?.regionCode = model?.countryCode
        
        addressTypeCell?.addressType = AddressType(rawValue: Int(model?.addressType ?? "") ?? 0)
        setasDefaultCell?.isDefault = model?.isDefault
        idNumberInput?.text = model?.idCard
        
        //定位图标
        if isMapCheck &&
            isCanUseMap(){///只在A站使用
//        if true{ //这样测试地图入口的 放开注释
            locateAddressInput?.attributeMessage = locationDiscription
            locateAddressInput?.isHiddingTralling = false
        }else{
            locateAddressInput?.attributeMessage = NSAttributedString()
            locateAddressInput?.isHiddingTralling = true
        }
    }
    
    ///更新邮编信息
    func updatePostCodePos(isNeeded:Bool){
        
        let hasCity = self.model?.cityId != nil || self.model?.countryId == nil
        let hasState = self.model?.stateId != nil || self.model?.countryId == nil
        
        if isNeeded{//邮编移动到分组1
            locationInfos?.removeAll()
            optionInfos?.removeAll()
            
            locationInfos?.append(countryCell!)
            if !hasState{
                locationInfos?.append(stateCell!)
            }
            if !hasCity{
                locationInfos?.append(cityCell!)
            }
            
            locationInfos?.append(addressCell!)
            locationInfos?.append(additionAddressCell!)
            locationInfos?.append(zipCodeCell!)
            
            optionInfos?.append(alternatPhoneCell!)
        }else{//邮编移动到option
            locationInfos?.removeAll()
            optionInfos?.removeAll()
            
            locationInfos?.append(countryCell!)
            if !hasState{
                locationInfos?.append(stateCell!)
            }
            if !hasCity{
                locationInfos?.append(cityCell!)
            }
            locationInfos?.append(addressCell!)
            locationInfos?.append(additionAddressCell!)
            
            optionInfos?.append(alternatPhoneCell!)
            optionInfos?.append(zipCodeCell!)
           
        }
        
//        if let zipCell = zipCodeCell as? STLAddressNormalInputCell {
//            zipCell.isFirstCell = !isNeeded
//        }
//        
//        if let alterPhoneCell = alternatPhoneCell as? AddressPhoneCell{
//            alterPhoneCell.isFirstCell = !isNeeded
//        }
        self.isNeedZipCode = isNeeded
        zipCodeInput?.placeholder = isNeeded ? STLLocalizedString_("Zip*") : STLLocalizedString_("Zip")!
        groupDatas[0].cells = locationInfos
        groupDatas[2].cells = optionInfos
        
        tableView?.reloadData()
    }
    
    ///根据国家确定是否展示ID card
    func updateIdFieldShowHide(countryCode:String?) {
        let indexSet = IndexSet(integer: 1)
        if let countryCode = countryCode {
            if (countryCode == .JO || countryCode == .QA) {
                contactInfos?.removeAll()
                contactInfos?.append(nameCell!)
                contactInfos?.append(phoneCell!)
                contactInfos?.append(idNumberCell!)
                model?.idCard = idNumberInput?.text
            }else{
                contactInfos?.removeAll()
                contactInfos?.append(nameCell!)
                contactInfos?.append(phoneCell!)
                model?.idCard = nil
            }
            groupDatas[1].cells = contactInfos
            tableView?.reloadSections(indexSet, with: .none)
        }
    }
}

///网络请求与跳转
extension OSSVEditAddressVC{
    //直接定位
    func jumpToMapViewController() { ///1.4.6 直接在当前界面操作
        OSSVMyLocationeManager.startLocation { loc in
            self.location = loc
            self.model?.latitude = loc?.coordinate.latitude ?? 0
            self.model?.longitude = loc?.coordinate.longitude ?? 0
            self.isPositioned = true
        } address: {[weak self] address in
            self?.locateAddressInput?.text = address
            self?.model?.street = address
        } failure: {[weak self] status, err in
            if status == .denied{
                self?.popView.show()
                OSSVMyLocationeManager.stopLocation()
            }
        }
    }
    
    func requestPhomeApi(countryCode:String?) {
        STLNetworkStateManager.shared().networkState {
            let api = OSSVGetePhoneAreaeCodeAip(getPhoneAreaCodeForCountryCode: countryCode ?? "")
            api.start {[weak self] req in
                if let reqJson = OSSVNSStringTool.desEncrypt(req) as? [String:Any],
                   let statusCode =  reqJson[String.kStatusCode] as? Int,
                   let resultMap = reqJson[String.kResult] as? [String:Any]{
                    if statusCode == 200{
                        self?.phoneCodeRuleModel = PhoneCodeRulesModel.yy_model(with: resultMap)
                        self?.model?.countryCode = self?.phoneCodeRuleModel?.country_area_code
                        self?.fillInDatas(model: self?.model)
                    }
                }
            } failure: { _, _ in
                HUDManager.showHUD(withMessage: .errorMsg)
            }
        } exception: {
            HUDManager.showHUD(withMessage: .errorMsg)
        }

    }
}

//MARK: - 输入框代理 与校验
extension OSSVEditAddressVC:NormalInputDelegate{
    
    func checkAltPhone()->Bool{
        guard let text = alterPhoneInput?.text else{
            return true
        }
        
        if text.isContainArabic || text.isAllSameNumber{
            alterPhoneInput?.errorMessage = STLLocalizedString_("id_num_format_err")
            self.tableView?.reloadData()
            return false
        }
        
        guard let ruleLenStr = self.phoneCodeRuleModel?.phone_rule?.phone_number_length,
              let ruleLen = Int(ruleLenStr),
              let ruleErrMsg = OSSVSystemsConfigsUtils.isRightToLeftShow() ? self.phoneCodeRuleModel?.phone_rule?.error_text_ar : self.phoneCodeRuleModel?.phone_rule?.error_text_en,
              !text.isEmpty else{
            return true
        }
        
        if ruleLen == text.count {
            return true
        }else{
            alterPhoneInput?.errorMessage = ruleErrMsg
            return false
        }
        
       
    }
    
    func checkZipCode() ->Bool {
        if isNeedZipCode{
            let(result,message) = CheckTools.checkZipCode(text: zipCodeInput?.text)
            if !result{
                zipCodeInput?.errorMessage = message
            }
            return result
        }else{
            zipCodeInput?.errorMessage = nil
            self.tableView?.reloadData()
        }
        return true
    }
    
    func reloadtableWithAnim(){
        UIView.performWithoutAnimation {
            tableView?.reloadData()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField, _ inputField: NormalInputFiled) {
        if inputField == locateAddressInput {
            isSelectedCompleteList = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, _ inputField: NormalInputFiled) {
        let value = textField.text
        if inputField == alterPhoneInput {
            model?.secondPhone = value
            GATools.logAddEditAddressEvent(action: "AlternativePhone")
        }
        if inputField == phoneInput {
            GATools.logAddEditAddressEvent(action: "PhoneNumber")
            let (result,messg) = CheckTools.checkPhoneBasic(text: value)
            if result{
                //请求接口校验
                if let value = value,
                   let countryId = model?.countryId,
                   let countryCode = model?.country_Code{
                    OSSVAddresseCheckePhoneAip(checkPhone: value, countryId: countryId, countryCode: countryCode)
                        .requestCheckPhone(view: self.view)
                        .subscribe(onNext:{ (valid,errMsg) in
                            if valid {
                                self.model?.phone = value
                            }else{
                                inputField.errorMessage = errMsg
                            }
                        })
                        .disposed(by: disposeBag)
                }
            }else{
                inputField.errorMessage = messg
            }
        }
        if inputField == firstNameInput {
            GATools.logAddEditAddressEvent(action: "FirstName")
            let (result,messg) = CheckTools.checkFirstName(text: value)
            if result{
                model?.firstName = value
            }else{
                inputField.errorMessage = messg
                reloadtableWithAnim()
            }
        }
        if inputField == lastNameInput {
            GATools.logAddEditAddressEvent(action: "FirstName")
            let (result,messg) = CheckTools.checkLastName(text: value)
            if result{
                model?.lastName = value
            }else{
                inputField.errorMessage = messg
                reloadtableWithAnim()
            }
        }
        if inputField == idNumberInput {
            GATools.logAddEditAddressEvent(action: "IdentityNumber")
            let (result,messg) = CheckTools.checkIdNum(text: idNumberInput?.text, country_Code: model?.country_Code)
            if result{
                model?.idCard = value
            }else{
                idNumberInput?.errorMessage = messg
            }
        }
        if inputField == zipCodeInput {
            GATools.logAddEditAddressEvent(action: "ZipPostal")
            if isNeedZipCode {
                let (result,messg) = CheckTools.checkZipCode(text: value)
                if !result{
                    zipCodeInput?.errorMessage = messg
                }else{
                    model?.zipPostNumber = value
                }
            }else{
                model?.zipPostNumber = value
            }
            
        }
        if inputField == detailAddressInput {
            GATools.logAddEditAddressEvent(action: "AdditionalAddress")
            if value?.isEmpty ?? true{
            }else if OSSVNSStringTool.streetAddressIsIncludeSpecialCharacterString(value!){
                inputField.errorMessage = .StreetValidMsg
                reloadtableWithAnim()
            }
            model?.streetMore = value
        }
        
        if inputField == locateAddressInput{
            if app_type == 1{///只在A站调用
                self.autoCompliteListView.isHidden = true
            }
           
            isSelectedCompleteList = true
            GATools.logAddEditAddressEvent(action: "StreetAddress")
            if value?.isEmpty ?? true{
                inputField.errorMessage = .StreetEmptyMsg
                reloadtableWithAnim()
            }else if OSSVNSStringTool.streetAddressIsIncludeSpecialCharacterString(value!){
                inputField.errorMessage = .StreetValidMsg
                reloadtableWithAnim()
            }
            model?.street = value
        }
        
        if inputField == cityInput{
            let (result,messg) = CheckTools.checkCity(text: value, cityId: model?.cityId)
            if result{
                model?.city = value
            }else{
                inputField.errorMessage = messg
            }
        }
        
        if inputField == stateInput{
            let (result,messg) = CheckTools.checkState(text: value, stateId: model?.stateId)
            if result{
                model?.state = value
            }else{
                inputField.errorMessage = messg
            }
        }
    }
}

extension OSSVEditAddressVC:STLLocationPopViewDelegate{
    func jumpToSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) {[weak self] _ in
                self?.popView.hiddenView()
            }
        }
    }
    
    func cancelAction() {
        self.popView.hiddenView()
    }
}

extension String{
    static let JO = "JO"
    static let QA = "QA"
}

