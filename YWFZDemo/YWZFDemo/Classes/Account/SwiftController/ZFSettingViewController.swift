//
//  ZFSettingViewController.swift
//  ZZZZZ
//
//  Created by YW on 2019/7/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

import UIKit
import SnapKit.Swift
import GlobalegrowIMSDK

protocol CellType {}

class ZFSettingTCell: UITableViewCell {
    
    private var _model: ZFSettingCellModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCell.SelectionStyle.none
        contentView.addSubview(iconImage)
        contentView.addSubview(detailLabel)
        contentView.addSubview(titleLabel)

        detailLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(iconImage.snp_leadingMargin).offset(-12)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        
        iconImage.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model : ZFSettingCellModel {
        set{
            _model = newValue
            titleLabel.text = newValue.title
            detailLabel.setTitle(newValue.detailTitle, for: UIControl.State.normal)
            detailLabel.setTitleColor(newValue.detailTitleColor, for: UIControl.State.normal)
            if newValue.detailTitleColor == UIColor.white {
                detailLabel.backgroundColor = UIColor.red
                detailLabel.contentEdgeInsets = UIEdgeInsets.init(top: 2, left: 4, bottom: 1, right: 4)
            } else {
                detailLabel.backgroundColor = UIColor.clear
                detailLabel.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            }
            
//            if newValue.cellAccessoryType == UITableViewCell.AccessoryType.disclosureIndicator {
                let isRight = SystemConfigUtils.isRightToLeftShow()
                if isRight {
                    iconImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
                iconImage.image = UIImage.init(named: "account_arrow_right")
//            } else {
//                iconImage.image = nil
//            }
        }
        get{
            return (_model ?? nil)!
        }
    }
    
    lazy var iconImage: UIImageView = {
        var iconImage = UIImageView.init()
        return iconImage
    }()
    
    lazy var detailLabel: UIButton = {
        var label = UIButton.init(type: UIButton.ButtonType.custom)
        label.setTitleColor(ZFSwiftColorDefine.RGBColor(_red: 153, _green: 153, _blue: 153, _alpha: 1.0), for: UIControl.State.normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        label.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        var titleLabel = UILabel.init()
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        return titleLabel
    }()
}

class ZFSettingViewController : ZFBaseViewController {
    
    var dataList:[Array<ZFSettingCellModel>] = []
    
    deinit {
        print("ZFSettingViewController was dealloc")
    }
    
    enum SettingCellType: CellType {
        case passwordCell(model : ZFSettingCellModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Setting_VC_Title")
        initDataSource()
        view.addSubview(tableView);
        tableView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initDataSource() {
        var oneSectionDataList = [ZFSettingCellModel]()
        oneSectionDataList.append(addressCellModel())        
        oneSectionDataList.append(passwordCellModel())
        oneSectionDataList.append(selectCountryCellModel())
        oneSectionDataList.append(selectCurrencyCellModel())
        let langCount = AccountManager.shared()?.initializeModel?.countryInfo?.support_lang?.count
        if langCount ?? 0 > 1 {
            oneSectionDataList.append(selectLanguageCellModel())
        }
   
        let list = AccountManager.shared()?.initializeModel?.set_url_list ?? [ZFInitUrlList]()
        for listItem in list {
            let urlListModel = ZFSettingCellModel.init()
            urlListModel.title = listItem.title
            urlListModel.detailTitle = listItem.tag
            let isFirstClickZZZZZStory = UserDefaults.standard.bool(forKey: "ZFisFirstClickZZZZZStory")
            if isFirstClickZZZZZStory == false {
                urlListModel.detailTitleColor = .white
            } else {
                urlListModel.detailTitleColor = .clear
                urlListModel.cellAccessoryType = .disclosureIndicator
            }
            urlListModel.cellSelectHandle = {[unowned self] (model) -> (Void) in
                let webVC = ZFWebViewViewController.init()
                webVC.link_url = listItem.url
                self.navigationController?.pushViewController(webVC, animated: true)
                UserDefaults.standard.set(true, forKey: "ZFisFirstClickZZZZZStory")
                urlListModel.detailTitleColor = .clear
                urlListModel.cellAccessoryType = .disclosureIndicator
                self.tableView.reloadData()
            }
            oneSectionDataList.append(urlListModel)
        }
        dataList.append(oneSectionDataList)
        
        var twoSectionDataList = [ZFSettingCellModel]()
        
        twoSectionDataList.append(selectAccountSurveyCellModel())
        twoSectionDataList.append(selectRateUSCellModel())
        twoSectionDataList.append(selectNotificationSettinsCellModel())
        twoSectionDataList.append(selectClearCacheCellModel())
        twoSectionDataList.append(selectVersionCellModel())
        dataList.append(twoSectionDataList)
    }
    
    //密码视图模型
    func passwordCellModel() -> ZFSettingCellModel {
        let passwordModel = ZFSettingCellModel.init()
        passwordModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("GameLogin_SetupPassword")
        passwordModel.cellAccessoryType = .disclosureIndicator
        passwordModel.cellSelectHandle = {[unowned self] (model) -> (Void) in
            if AccountManager.shared()?.account?.is_guest == 1 {
                //游客登录的时候，直接进去到注册页
                let registerVC = YWLoginViewController.init()
                registerVC.type = YWLoginEnterType.register
                let navigation = ZFNavigationController.init(rootViewController: registerVC)
                self.present(navigation, animated: true, completion: nil)
                return
            }
            
            self.presentLoginViewController {
                if self.tableView.tableFooterView != self.footerView {
                    self.tableView.tableFooterView = self.footerView
                }
                let changePasswordVC = ChangePasswordViewController.init()
                self.navigationController?.pushViewController(changePasswordVC, animated: true)
            }
        }
        return passwordModel
    }
    
    //地址视图模型
    func addressCellModel() -> ZFSettingCellModel {
        let addressModel = ZFSettingCellModel.init()
        addressModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Address_VC_Title")
        addressModel.cellAccessoryType = .disclosureIndicator
        addressModel.cellSelectHandle = {[unowned self] (model) -> (Void) in
            self.presentLoginViewController {
                if self.tableView.tableFooterView != self.footerView {
                    self.tableView.tableFooterView = self.footerView
                }
                let addressVC = ZFAddressViewController.init()
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
        }
        return addressModel
    }
    
    //选择国家视图模型
    func selectCountryCellModel() -> ZFSettingCellModel {
        let countryModel = ZFSettingCellModel.init()
        countryModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("modifyAddress_countryCity_country")
        countryModel.detailTitle = AccountManager.shared()?.accountCountryModel?.region_name ?? ""
        countryModel.cellAccessoryType = .disclosureIndicator
        countryModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            let countryVC = ZFAccountCountryViewController.init()
            countryVC.selectCountryBlcok = {[weak self] (addressCountryModel) -> (Void) in
                countryModel.detailTitle = addressCountryModel?.region_name
                self?.tableView.reloadData()
            }
            self?.navigationController?.pushViewController(countryVC, animated: true)
        }
        return countryModel
    }

    //选择货币模型
    func selectCurrencyCellModel() -> ZFSettingCellModel {
        let currencyModel = ZFSettingCellModel.init()
        currencyModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Currency_VC_Title")
        currencyModel.detailTitle = ExchangeManager.localCurrencyName()
        currencyModel.cellAccessoryType = .disclosureIndicator
        currencyModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            let currencyVC = ZFCurrencyViewController.init()
            currencyVC.convertCurrencyBlock = {[weak self] (model) -> Void in
                currencyModel.detailTitle = ExchangeManager.localCurrencyName()
                ZFCellHeightManager.share()?.clearCaches()
                self?.tableView.reloadData()
            }
            self?.navigationController?.pushViewController(currencyVC, animated: true)
        }
        return currencyModel
    }
    
    //选择语言模型
    func selectLanguageCellModel() -> ZFSettingCellModel {
        let languageModel = ZFSettingCellModel.init()
        languageModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Setting_Cell_Languege")
        languageModel.detailTitle = ZFLocalizationString.shareLocalizable()?.currentLanguageName()
        languageModel.cellAccessoryType = .disclosureIndicator
        languageModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            let languageVC = ZFLangugeSettingViewController.init()
            self?.navigationController?.pushViewController(languageVC, animated: true)
        }
        return languageModel
    }
    
    //account survey
    func selectAccountSurveyCellModel() -> ZFSettingCellModel {
        let surveyModel = ZFSettingCellModel.init()
        surveyModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Account_Survey")
        surveyModel.cellAccessoryType = .disclosureIndicator
        surveyModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            let surveyVC = ZFSurveyViewController.init()
            surveyVC.link_url = "https://www.surveymonkey.com/r/WTYJTH2";
            self?.navigationController?.pushViewController(surveyVC, animated: true)
        }
        return surveyModel
    }
    
    //App RateUS
    func selectRateUSCellModel() -> ZFSettingCellModel {
        let rateUSModel = ZFSettingCellModel.init()
        rateUSModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Setting_Cell_RateUs")
        rateUSModel.cellAccessoryType = .disclosureIndicator
        rateUSModel.cellSelectHandle = {(model) -> (Void) in
            UIViewController.showAppStoreReviewVC()
        }
        return rateUSModel
    }
    
    //Notifications Settings
    func selectNotificationSettinsCellModel() -> ZFSettingCellModel {
        let notificationModel = ZFSettingCellModel.init()
        notificationModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Push_Notifications_Settings")
        notificationModel.cellAccessoryType = .disclosureIndicator
        notificationModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            let pushVC = ZFAccountPushViewController.init()
            self?.navigationController?.pushViewController(pushVC, animated: true)
        }
        return notificationModel
    }
    
    //clear cache
    func selectClearCacheCellModel() -> ZFSettingCellModel {
        let clearCacheModel = ZFSettingCellModel.init()
        clearCacheModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Setting_Cell_ClearCache")
        let totalCost = {() -> (Float) in
            let cache = YYWebImageManager.shared().cache
            let totalCoast = cache?.diskCache.totalCost()
            let floatCoast = Float(totalCoast ?? 0)
            return (Float)(floatCoast/1024.0/1024.0)
        }
        clearCacheModel.detailTitle = String(format: "%.2fM", totalCost())
        clearCacheModel.cellAccessoryType = .disclosureIndicator
        clearCacheModel.cellSelectHandle = {[weak self] (model) -> (Void) in
            YYWebImageManager.shared().cache?.memoryCache.removeAllObjects()
            YYWebImageManager.shared().cache?.diskCache.removeAllObjects()
            clearCacheModel.detailTitle = String(format: "%.2fM", totalCost())
            self?.tableView.reloadData()
            ShowAlertSingleBtnView(nil, ZFLocalizationString.shareLocalizable()?.zfLocalizedString("SettingViewModel_Cache_Alert_Message"), ZFLocalizationString.shareLocalizable()?.zfLocalizedString("SettingViewModel_Cache_Alert_OK"));
        }
        return clearCacheModel
    }
    
    //version
    func selectVersionCellModel() -> ZFSettingCellModel {
        let versionModel = ZFSettingCellModel.init()
        versionModel.title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Setting_Cell_Version")
        versionModel.cellAccessoryType = .disclosureIndicator
        versionModel.detailTitle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionModel.cellSelectHandle = { (model) -> (Void) in
            ZFCommonRequestManager.checkUpgradeZFApp{ (hasNoNewVersion) in
                if hasNoNewVersion {
                    let alertTitle = ZFLocalizationString.shareLocalizable().zfLocalizedString("SettingViewModel_Version_Alert_Title")!
                    let systemVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    let title = String(format: "%@%@", alertTitle, systemVersion)
                    ShowAlertSingleBtnView(title, ZFLocalizationString.shareLocalizable()?.zfLocalizedString("SettingViewModel_Version_Latest_Alert_Message"), ZFLocalizationString.shareLocalizable()?.zfLocalizedString("SettingViewModel_Version_Latest_Alert_OK"));
                }
            }
        }
        return versionModel
    }
    
    @objc func logoutButtonAction() -> Void {
        let title = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Account_VC_SignOut_Alert_Message")
        let btnArr = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Account_VC_SignOut_Alert_Yes")
        let cancelTitle = ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Account_VC_SignOut_Alert_No")
        ShowAlertView(title, nil, [btnArr as Any], { (index, title) in
            // 退出登录时添加一个翻转的转场动画
            let window = UIApplication.shared.delegate?.window as? UIView
            UIView.transition(with: window!, duration: 0.8, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                AccountManager.shared()?.clearUserInfo()
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished) in
                ChatConfig.share.logout()
                ZFCellHeightManager.share()?.clearCaches()
                self.navigationController?.popViewController(animated: false)
                if GIDSignIn.sharedInstance()?.hasPreviousSignIn() == true {
                    GIDSignIn.sharedInstance()?.disconnect()
                }
            })
        }, cancelTitle) { (title) in
            
        }
    }
    
    lazy var footerView : UIView = {
        let view = UIView.init()
        view.backgroundColor = ZFSwiftColorDefine.RGBColor(_red: 245, _green: 245, _blue: 245, _alpha: 1.0)
        view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80)
        
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect.init(x: 0, y: 30, width: view.frame.size.width - 0, height: 40)
        button.addTarget(self, action: #selector(ZFSettingViewController.logoutButtonAction), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 3
//        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(ZFSwiftColorDefine.RGBColor(_red: 238, _green: 0, _blue: 36, _alpha: 1.0), for: UIControl.State.normal)
        button.setTitle(ZFLocalizationString.shareLocalizable()?.zfLocalizedString("Account_SignOut_Button"), for: UIControl.State.normal)
        view.addSubview(button)
        return view
    }()

    lazy var tableView : UITableView = {
        var view = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
        view.backgroundColor = ZFSwiftColorDefine.RGBColor(_red: 245, _green: 245, _blue: 245, _alpha: 1.0)
        view.delegate = self
        view.dataSource = self
        view.rowHeight = UITableView.automaticDimension
        view.sectionFooterHeight = 0.01
        view.sectionHeaderHeight = 10
        view.tableFooterView = {() -> (UIView) in
            if AccountManager.shared()?.isSignIn == true {
                return footerView
            } else {
                return UIView.init()
            }
        }()
        return view
    }()
}

extension ZFSettingViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.section][indexPath.row] as ZFSettingCellModel
        if model.cellSelectHandle != nil {
            model.cellSelectHandle!(model)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CellHeaderView")
        if headerView == nil {
            headerView = UITableViewHeaderFooterView.init(reuseIdentifier: "CellHeaderView")
            headerView?.backgroundColor = UIColor.groupTableViewBackground
        }
        return headerView
    }
}

extension ZFSettingViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataList[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : ZFSettingTCell! = tableView.dequeueReusableCell(withIdentifier: "Cell") as?ZFSettingTCell
        if cell == nil {
            cell = ZFSettingTCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        cell.model = dataList[indexPath.section][indexPath.row]
        return cell;
    }
}

extension ZFSettingViewController
{
    func presentLoginViewController(_ block: @escaping () -> Void) -> Void{
        if AccountManager.shared()?.isSignIn == true {
            block()
        } else {
            let loginVC = YWLoginViewController.init()
            loginVC.successBlock = block
            let navigation = ZFNavigationController.init(rootViewController: loginVC)
            self.present(navigation, animated: true, completion: nil)
        }
    }
}


