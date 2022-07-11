//
//  OSSVSettingsVc.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SwiftyJSON

class OSSVSettingsVc: OSSVBaseVcSw {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableFooterView?.isHidden = !OSSVAccountsManager.shared().isSignIn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = STLLocalizedString_("Settings")
        self.setupGroupSection()
        self.stlInitView()
        self.stlAutoLayoutView()
        
    }
    
    override func stlInitView() {
        self.view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        self.view.addSubview(self.tableView)
    }
    
    override func stlAutoLayoutView() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.init(top: 0, left: 12, bottom: .bottomSafeHeight, right: 12))
        }
    }
    
    var datasArray:NSMutableArray = NSMutableArray.init()

    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .grouped)
        table.rowHeight = 52;
        table.backgroundColor = OSSVThemesColors.stlClearColor()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        //给了尾部，不给头部，grouped模式上面有一个空白区域
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 12))
        headerView.backgroundColor = OSSVThemesColors.col_F5F5F5()
        table.tableHeaderView = headerView
        table.tableFooterView = self.footerView
        table.delegate = self
        table.dataSource = self
        table.register(STLSettingCell.self, forCellReuseIdentifier: NSStringFromClass(STLSettingCell.self))
        return table
    }()
    
    lazy var footerView:UIView = {
        let footer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 60))
        
        let signOutButton = UIButton.init(type: .custom)
        signOutButton.setTitle(STLLocalizedString_("SignOut")?.uppercased(), for: .normal)
        signOutButton.setTitleColor(OSSVThemesColors.stlBlackColor(), for: .normal)
        signOutButton.titleLabel?.font = UIFont.stl_buttonFont(14)
        signOutButton.backgroundColor = OSSVThemesColors.stlWhiteColor()
        signOutButton.layer.borderWidth = 1
        signOutButton.layer.borderColor = OSSVThemesColors.col_EEEEEE().cgColor
        
        signOutButton.rx.tap.subscribe { [weak self] _ in
            self?.alertSignOut()
        }.disposed(by: self.disposeBag)
        
        footer.addSubview(signOutButton)
        
        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(footer.snp.top).offset(12)
            make.leading.trailing.equalTo(footer)
            make.height.equalTo(44)
        }
        
        return footer
    }()
    
    func alertSignOut() {
        OSSVAlertsViewNew.showAlert(frame: UIScreen.main.bounds, alertType: STLAlertType.button, isVertical: true, messageAlignment: .center, isAr: false, showHeightIndex: 1, title: nil, message: STLLocalizedString_("sureSignOut"), buttonTitles:app_type == 3 ? [STLLocalizedString_("cancel") ?? "",STLLocalizedString_("sure") ?? ""] : [STLLocalizedString_("cancel")?.uppercased() ?? "",STLLocalizedString_("sure")?.uppercased() ?? ""]) { flag, _ in
            if flag == 1 {
                
                OSSVAnalyticsTool.analyticsGAEvent(withName: "setting_action", parameters: ["screen_group":"Setting","action":"Logout"])

                OSSVCartsOperateManager.shared().cartSaveValidGoodsAllCount(0)
                OSSVAccountsManager.shared().clearUserInfo()
                self.navigationController?.popToRootViewController(animated: false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotif_Logout), object: nil)
            }
        }

    }
    
    
    func setupGroupSection() {
        let curRateModel = ExchangeManager.localCurrency()
        var currencyString = "\(curRateModel?.code ?? "") \(curRateModel?.symbol ?? "")"
        
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            currencyString = "\(curRateModel?.symbol ?? "") \(curRateModel?.code ?? "")"
        }
        
        //国家设置 APP不控制国家站切换 暂时没使用
//        let countryModel: STLSettingModel = STLSettingModel.init()
//        countryModel.title = STLLocalizedString_("country_region")
//        countryModel.detailTitle = "occxxxx"
//        countryModel.type = .country
        
        let currencyModel: STLSettingModel = STLSettingModel.init()
        currencyModel.title = STLLocalizedString_("Currency")
        currencyModel.detailTitle = currencyString
        currencyModel.type = .currency
        
        let currentLanagure = STLLocalizationString.shareLocalizable().currentLanguageName()
        let languageModel = STLSettingModel.init()
        languageModel.title = STLLocalizedString_("Setting_Cell_Languege")
        languageModel.detailTitle = currentLanagure
        languageModel.type = .language
        
        let clearSize = String.init(format: "%.1lf MB", CacheFileManager.folderSize(atPath: .kDocument_Path))
        let clearModel = STLSettingModel.init()
        clearModel.title = STLLocalizedString_("Clear_Cache")
        clearModel.detailTitle = clearSize
        clearModel.type = .clear
        
        let rateUsModel = STLSettingModel.init()
        rateUsModel.title = STLLocalizedString_("RateUs")
        rateUsModel.detailTitle = ""
        rateUsModel.type = .rate
        
        let versionModel = STLSettingModel.init()
        versionModel.title = STLLocalizedString_("Version")
        versionModel.detailTitle = .currentVersion
        versionModel.isArrow = false
        versionModel.type = .version
        
        let notificationModel = STLSettingModel.init()
        notificationModel.title = STLLocalizedString_("notification")
        notificationModel.detailTitle = ""
        notificationModel.type = .notification
        
        let aboutUsModel = STLSettingModel.init()
        aboutUsModel.title = STLLocalizedString_("AboutUs")
        aboutUsModel.detailTitle = ""
        aboutUsModel.type = .aboutUs
        
        let privacyPolicyModel = STLSettingModel.init()
        privacyPolicyModel.title = STLLocalizedString_("PrivacyPolicy")
        privacyPolicyModel.detailTitle = ""
        privacyPolicyModel.type = .privacy
        
        let termOfUsageModel = STLSettingModel.init()
        termOfUsageModel.title = STLLocalizedString_("Term_of_Usage")
        termOfUsageModel.detailTitle = ""
        termOfUsageModel.type = .termsOfUsage
        
        let firsGroup = [currencyModel,languageModel,clearModel,rateUsModel,versionModel,notificationModel]
        let secondGroup = [aboutUsModel,privacyPolicyModel,termOfUsageModel]
        self.datasArray.add(firsGroup)
        self.datasArray.add(secondGroup)
    }

}

extension OSSVSettingsVc:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.datasArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datas = self.datasArray[section] as? Array<Any> {
            return datas.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(STLSettingCell.self), for: indexPath) as! STLSettingCell
        if let datas = self.datasArray[indexPath.section] as? Array<Any> {
            if let model = datas[indexPath.row] as? STLSettingModel {
                cell.model = model
                cell.showLine(show: !(indexPath.row == datas.count-1))
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.roundedGroup(willDisplay: cell, forRowAt: indexPath, radius: 6, backgroundColor: OSSVThemesColors.stlWhiteColor(), horizontolPadding: 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let datas = self.datasArray[indexPath.section] as? Array<Any> {
            if let model = datas[indexPath.row] as? STLSettingModel {
                settiongActon(model: model)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 0.01))
        view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 8))
        view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return 0.01
    }
}

extension OSSVSettingsVc {
    
    func settiongActon(model: STLSettingModel) {
        
        OSSVAnalyticsTool.analyticsGAEvent(withName: "setting_action", parameters: ["screen_group":"Setting","action":model.title ?? ""])

        if model.type == .country {
            let ctrl = SettingCountryRegionVC.init()
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if model.type == .currency {
            let ctrl = OSSVCurrencyVc.init()
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if (model.type == .language) {
            let ctrl = OSSVLanguageVC.init()
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if (model.type == .clear) {
            
            OSSVAlertsViewNew.showAlert(frame: UIScreen.main.bounds, alertType: STLAlertType.button, isVertical: true, messageAlignment: .center, isAr: false, showHeightIndex: 1, title: nil, message: STLLocalizedString_("Are_you_clear_cache"), buttonTitles: app_type == 3 ? [STLLocalizedString_("cancel") ?? "",STLLocalizedString_("ok") ?? ""] : [STLLocalizedString_("cancel")?.uppercased() ?? "",STLLocalizedString_("ok")?.uppercased() ?? ""]) { index, value in
                if index == 1 {
                    
                    CacheFileManager.clearCache(.kDocument_Path)
                    let clearSize = String.init(format: "%.1lf MB", CacheFileManager.folderSize(atPath: .kDocument_Path))
                    model.detailTitle = clearSize
                    self.tableView.reloadData()
                    HUDManager.showHUD(withMessage: STLLocalizedString_("clearCache_Tip"))
                }
            }
            
            
            
        } else if (model.type == .rate) {
            let sharedApp = UIApplication.shared
            let url = URL.init(string: OSSVLocaslHosstManager.appStoreReviewUrl().removingPercentEncoding ?? "")
            if sharedApp.canOpenURL(url!) {
                sharedApp.open(url!, options: [:], completionHandler: nil)
            }
            
        } else if (model.type == .version) {
            
            STLNetworkStateManager.shared().networkState { [weak self] in
                let api = OSSVChecksUpadtesAip.init()
                api.start { request in
                    if let reqDic = OSSVNSStringTool.desEncrypt(request) as? [String:Any]{
                        if reqDic[kStatusCode] as? Int32 == kStatusCode_200 {
                            if let dic = reqDic[kResult] as? NSDictionary,
                               let state = dic["status"] as? Bool,
                               let contnetDic = dic["data"] as? NSDictionary {
                                
                                if state {
                                    self?.showUpdateView(dic: contnetDic)
                                }
                                
                            }
                        }
                    }
                } failure: { request, error in
                    
                }

                
            } exception: {
                
            }

        } else if(model.type == .notification) {
            let ctrl = OSSVNotificationSettingVC.init()
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if (model.type == .aboutUs) {
            let ctrl = STLWKWebCtrl.init()
            ctrl.urlType = SystemURLType.aboutUs
            ctrl.title = STLLocalizedString_("AboutUs")
            ctrl.isNoNeedsWebTitile = true
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if (model.type == .privacy) {
            let ctrl = STLWKWebCtrl.init()
            ctrl.urlType = SystemURLType.privacyPolicy
            ctrl.title = STLLocalizedString_("PrivacyPolicy")
            ctrl.isNoNeedsWebTitile = true
            self.navigationController?.pushViewController(ctrl, animated: true)
            
        } else if (model.type == .termsOfUsage) {
            let ctrl = STLWKWebCtrl.init()
            ctrl.urlType = SystemURLType.termsOfUs
            ctrl.title = STLLocalizedString_("Term_of_Usage")
            ctrl.isNoNeedsWebTitile = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        }
    }
    
    func showUpdateView(dic: NSDictionary) {
        let content = dic["content"] as? NSString
        let url = dic["url"] as? NSString
        
        OSSVAlertsViewNew.showAlert(frame: UIScreen.main.bounds, alertType: STLAlertType.button, isVertical: true, messageAlignment: .center, isAr: false, showHeightIndex: 1, title: STLLocalizedString_("updatesInformation"), message: content, buttonTitles: [STLLocalizedString_("updateRemindMeLater") ?? "",STLLocalizedString_("updateNow") ?? ""]) { index, value in
            if index == 1 {
                
                let sharedApp = UIApplication.shared
                let url = URL.init(string: (url ?? "") as String)
                if sharedApp.canOpenURL(url!) {
                    sharedApp.open(url!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
}
