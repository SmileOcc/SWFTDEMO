//
//  YXSetViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//设置
import UIKit
import RxSwift
import RxCocoa
import YXKit
import TYAlertController
import QCloudCore
import QMUIKit
 
fileprivate func getCache()->String{
//    let Msize = MMKV.default().totalSize()
    let Msize = 0
    let Isize = SDImageCache.shared.totalDiskSize()
    let fSize = (Float(Msize) + Float(Isize)) / (1024*1024)
    return String(format: "%0.2fM",fSize)
}

var isHasSkinSet: Bool {
    if #available(iOS 13.0, *) {
        return true
    }
    return false
}

class YXSetViewController: YXHKTableViewController, HUDViewModelBased {
    


    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXSetViewModel!
    
    let smartSortIndentifier = "smartSortIndentifier"
    
    var loginOutBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "user_loginout"), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18,weight: .medium)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 60)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        return btn
    }()
    
    var bottomBgView: UIView = {
        let view = UIView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    var dataSource: [[CommonCellData]] = {
        //section = 0
        var cellArr = [CommonCellData]()
        let accountSafeDescrib:String
        let personalDataDescrib:String
        //是否登录
        if YXUserManager.isLogin() {
            accountSafeDescrib = ""
            personalDataDescrib = ""
        } else {
            accountSafeDescrib = YXLanguageUtility.kLang(key: "login_unLogin")
            personalDataDescrib = YXLanguageUtility.kLang(key: "login_unLogin")
        }
        //账号与安全
        var accountSafeCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_accountSafe"), describeStr: accountSafeDescrib, showArrow: true, showLine: false)
        accountSafeCell.describeColor = QMUITheme().textColorLevel3()
        cellArr.append(accountSafeCell)
        
        //个人资料
        var personalDataCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_personalData"), describeStr: personalDataDescrib, showArrow: true, showLine: true)
        personalDataCell.describeColor = QMUITheme().textColorLevel3()
        cellArr.append(personalDataCell)
        
        //section = 1
        var cellArr2 = [CommonCellData]()
        // 隐私
        let privacyCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_privacy"), describeStr: "", showArrow: true, showLine: true)
        cellArr2.append(privacyCell)
        
        if isHasSkinSet {
            // 皮肤
            let skinStr = YXThemeTool.skinName()
            let skinCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "theme_title"), describeStr: skinStr, showArrow: true, showLine: true)
            cellArr2.append(skinCell)
        }
        let smartCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "initial_settings_smart_sorting"), describeStr:"", showArrow: false, showLine: false)
        cellArr2.append(smartCell)
        
        //section = 2
        var cellArr3 = [CommonCellData]()
        let languageCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_Language"), describeStr: "", showArrow: true, showLine: true)
        cellArr3.append(languageCell)

        
        //section = 3
        var cellArr4 = [CommonCellData]()
        let noticeCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_notice"), describeStr: "", showArrow: true, showLine: false)
        let promotionalCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "settings_promotional_message"), describeStr: "", showArrow: true, showLine: true)
//        let helpCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_help"), describeStr: "", showArrow: true, showLine: true)
        
        cellArr4.append(noticeCell)
        cellArr4.append(promotionalCell)
        
        
        var cellArr5 = [CommonCellData]()
        let cacheCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_cache"), describeStr: getCache(), showArrow: true, showLine: false,describeColor: QMUITheme().textColorLevel3())
        cellArr5.append(cacheCell)
       
        return [cellArr,cellArr2,cellArr3,cellArr4,cellArr5]
    }()
    
    override var pageName: String {
           return "Settings"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    } 

    func initUI() {
        
        self.tableView.separatorStyle = .none
        self.tableView.register(YXPreferSetSmartTableViewCell.self, forCellReuseIdentifier: smartSortIndentifier)

        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.view.backgroundColor = QMUITheme().foregroundColor()
//        let titleLab = UILabel(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 200, height: 40))
//        titleLab.textColor = QMUITheme().textColorLevel1()
//        titleLab.text = YXLanguageUtility.kLang(key: "user_set")
//        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        titleLab.textAlignment = .center
    
        title = YXLanguageUtility.kLang(key: "user_set")
//        self.navigationItem.titleView = titleLab
        
        self.view.addSubview(bottomBgView)
        
        if YXUserManager.isLogin() == true {
            view.addSubview(loginOutBtn)
            loginOutBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(45)
                make.bottom.equalToSuperview().offset(-42)
            }
        }
        
        bottomBgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
          
        reloadData()
    }
    
    func resetTableInset() {
        if YXUserManager.isLogin() == true {
            self.tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 42 + 45 + 10, right: 0)
            bottomBgView.snp.updateConstraints { make in
                make.height.equalTo(42 + 45 + 10)
            }
        } else {
            self.tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            bottomBgView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
    
    func bindViewModel() {
        //退出登录
        loginOutBtn.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.trackViewClickEvent(name: "Logout")
            self?.loginOutAlert()
        }).disposed(by: disposeBag)
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiLogin))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.reloadData()
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiLoginOut))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.reloadData()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiUpdateColor))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiUpdateQuoteChart))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiSkinChange))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })
    }
    
    func reloadData() {

        var cellArr = [CommonCellData]()
        let accountSafeDescrib:String
        let personalDataDescrib:String
        //是否登录
        if YXUserManager.isLogin() {
            accountSafeDescrib = ""
            personalDataDescrib = ""
        } else {
            accountSafeDescrib = YXLanguageUtility.kLang(key: "login_unLogin")
            personalDataDescrib = YXLanguageUtility.kLang(key: "login_unLogin")
        }
        //账号与安全
        var accountSafeCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_accountSafe"), describeStr: accountSafeDescrib, showArrow: true, showLine: false)
        accountSafeCell.describeColor = QMUITheme().textColorLevel3()
        cellArr.append(accountSafeCell)
        
        //个人资料
        var personalDataCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_personalData"), describeStr: personalDataDescrib, showArrow: true, showLine: true)
        personalDataCell.describeColor = QMUITheme().textColorLevel3()
        cellArr.append(personalDataCell)
        self.dataSource[0] = cellArr
        
        if isHasSkinSet {
            // 皮肤
            let skinStr = YXThemeTool.skinName()
            let skinCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "theme_title"), describeStr: skinStr, showArrow: true, showLine: true)
            self.dataSource[1][1] = skinCell
        }

        //语言
        var language: String

        switch YXUserManager.curLanguage() {
        case .CN:
            language = YXLanguageUtility.kLang(key: "mine_simplified")
        case .EN:
            language = YXLanguageUtility.kLang(key: "mine_english")
        case .HK:
            language = YXLanguageUtility.kLang(key: "mine_traditional")
        case .ML:
            language = YXLanguageUtility.kLang(key: "mine_malay")
        case .TH:
            language = YXLanguageUtility.kLang(key: "mine_thai")
        default:
            language = YXLanguageUtility.kLang(key: "mine_english")
        }
        let languageCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_Language"), describeStr: language, showArrow: true, showLine: true)
        self.dataSource[2][0] = languageCell
        
        //智能排序
        self.viewModel.sortHK = YXSecuGroupManager.shareInstance().sortflag == 1 ? .on : .off
                
        let cacheCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_cache"), describeStr: getCache(), showArrow: true, showLine: false ,describeColor: QMUITheme().textColorLevel3())
        self.dataSource[4][0] = cacheCell
        
        if YXUserManager.isLogin() == true {
            view.addSubview(loginOutBtn)
            loginOutBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(45)
                make.bottom.equalToSuperview().offset(-42)
            }
        }else {
            loginOutBtn.removeFromSuperview()
        }
        resetTableInset()
        self.tableView.reloadData()
    }
    
    func loginOutAlert() {
        
        let text = YXLanguageUtility.kLang(key: "user_loginoutTip")
        let alertView = YXAlertView(message: text)
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "cancel_btn"), style: .cancel, handler: {[weak self,weak alertView] action in
            self?.trackViewClickEvent(customPageName: "Confirm to logout", name: "Cancel_tab")
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "user_confirmLoginout"), style: .default, handler: {[weak self,weak alertView] action in
            self?.trackViewClickEvent(customPageName: "Confirm to logout", name: "Confirm_tab")
            YXUserManager.loginOut(request: true)
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
    
    func cleanChaceAlert() {
        
        let alertController = QMUIAlertController.init(title: YXLanguageUtility.kLang(key: "mine_clean_chace"), message:nil, preferredStyle: .alert)
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { (alertController, action) in
                   alertController.dismiss(animated: true, completion: nil)
        }
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        let okAction = QMUIAlertAction.init(title: YXLanguageUtility.kLang(key: "common_ok"), style: .default) {[weak self] (alertController, action) in
            MMKV.default().set(nil, forKey: YXGlobalConfigManager.getGlobalUrlConfigKey())
            SDImageCache.shared.clearDisk(onCompletion: nil)
        
            let tempPath = NSTemporaryDirectory()
            let manager = FileManager.default
            let url = URL(fileURLWithPath: tempPath)
            do {
                try  manager.removeItem(at: url)
            } catch {
            }
            self?.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "mine_cleaned"), false))
            self?.reloadData()
            alertController.dismiss(animated: true, completion: nil)
        }
        okAction.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().mainThemeColor(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        alertController.addAction(cancel)
        alertController.addAction(okAction)
        
        alertController.showWith(animated: true)

    }
    
    func changeCurrecy() {
        let height:CGFloat = YXConstant.deviceScaleEqualToXStyle() == true ? 196 : 162
        let alertView = UIView.init(frame: CGRect.init(x: 0, y: YXConstant.screenHeight - height, width: YXConstant.screenWidth, height: height))
        alertView.backgroundColor = QMUITheme().foregroundColor()
        alertView.layer.cornerRadius = 16
        alertView.clipsToBounds = true
        
        let USDView = UIButton.init(frame: CGRect.init(x: 24, y: 10, width: YXConstant.screenWidth-24, height: 54))
        USDView.titleLabel?.font = .systemFont(ofSize: 16)
        USDView.setTitle(YXLanguageUtility.kLang(key: "settings_currency_USD"), for: .normal)
        USDView.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        USDView.contentHorizontalAlignment = .left
        
        alertView.addSubview(USDView)
        
        let HKDView = UIButton.init(frame: CGRect.init(x: 24, y: 64, width: YXConstant.screenWidth-24, height: 54))
        HKDView.titleLabel?.font = .systemFont(ofSize: 16)
        HKDView.setTitle(YXLanguageUtility.kLang(key: "settings_currency_HKD"), for: .normal)
        HKDView.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        HKDView.contentHorizontalAlignment = .left
        
        alertView.addSubview(HKDView)
        
        let lineView = UIView.init(frame: CGRect.init(x: 24, y: 118, width: YXConstant.screenWidth - 48, height: 0.5))
        alertView.addSubview(lineView)
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        
        
        let selectView = UIImageView.init(image: UIImage.init(named: "settings_select"))
        selectView.x = YXConstant.screenWidth - 44
        selectView.size = CGSize.init(width: 20, height: 20)
        selectView.centerY = HKDView.centerY
        alertView.addSubview(selectView)
        
        
        let cancleView = UIButton.init(frame: CGRect.init(x: 0, y: 118, width: YXConstant.screenWidth, height: 46))
        cancleView.titleLabel?.font = .systemFont(ofSize: 16)
        cancleView.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        cancleView.titleLabel?.textAlignment = .center
        cancleView.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        
        alertView.addSubview(cancleView)
    
        
        let alertVC = YXAlertController.init(alert: alertView, preferredStyle: .actionSheet, transitionAnimation: .fade)
        alertVC?.backgoundTapDismissEnable = true
        self.present(alertVC!, animated: true, completion: nil)
        
        USDView.addBlock(for: .touchUpInside) {[weak self,weak alertVC] (_) in
            self?.requestUserConfig()
            alertVC?.dismiss(animated: true, completion: nil)
        }
        
        HKDView.addBlock(for: .touchUpInside) {[weak self,weak alertVC] (_) in
            self?.requestUserConfig()
            alertVC?.dismiss(animated: true, completion: nil)
        }

        cancleView.addBlock(for: .touchUpInside) {[weak alertVC] (_) in
            alertVC?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    fileprivate func changeLanguages(){
        let sheet = YXSheetViewController.init(.zero)
        let language:[YXLanguageType] = [.CN,.HK,.EN,.ML,.TH]
        for (_,type) in language.enumerated() {
            var title = ""
            if type == .CN{
                title = YXLanguageUtility.kLang(key: "mine_simplified")
            }else if type == .EN{
                title =  YXLanguageUtility.kLang(key: "mine_english")
            }else if type == .HK{
                title =  YXLanguageUtility.kLang(key: "mine_traditional")
            }else if type == .ML {
                title =  YXLanguageUtility.kLang(key: "mine_malay")
            }else if type == .TH {
                title =  YXLanguageUtility.kLang(key: "mine_thai")
            }
            
            let view = UIView()
            let titlab = UILabel()
            titlab.text = title
            titlab.font = .systemFont(ofSize: 16)
            titlab.textColor = QMUITheme().textColorLevel1()
            view.addSubview(titlab)
            titlab.snp.makeConstraints { make in
                make.left.equalTo(24)
                make.right.equalTo(-50)
                make.top.bottom.equalToSuperview()
            }
            
            if YXUserManager.curLanguage() == type {
                let selectView = UIImageView.init(image: UIImage.init(named: "settings_select"))
                view.addSubview(selectView)
                selectView.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(-22)
                }
            }
            
            let languageAction = YXSheetAction.init(customView: view) {[weak self] in
                
                if YXUserManager.isLogin() {
                    self?.viewModel.configType = .languageHk
                    self?.viewModel.languageHk = type
                    self?.requestUserConfig()
                    if type == .EN{
                        self?.trackViewClickEvent(name: "English_tab")
                    }else if type == .CN{
                        self?.trackViewClickEvent(name: "Simplified Chinese_tab")
                    }
                } else {
                    //保存到本地，因为YXTargetType的headers中，语言就是取 YXUserHelper.currentLanguage()
                    let mmkv = MMKV.default()
                    mmkv.set(Int32(type.rawValue), forKey: YXUserManager.YXLanguage)
                    YXLanguageUtility.initUserLanguage()
                    YXOptionalDBManager.shareInstance().updateAllSecuName()
                    // 通知语言有更换
                    NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateLanguage), object: nil)
                    // 通知重置根视图
                    NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: nil)
                }
                self?.reloadFlashWindowImage()
            }
            sheet.addAction(languageAction)
        }
        
        
        let cancleAction = YXSheetAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancelStyle,hiddenLine: false,handel:{[weak self] in
            self?.trackViewClickEvent(name: "Cancel_tab")
        })
        
        sheet.addAction(cancleAction)
        sheet.showIn(self)
    }
    
    fileprivate func reloadFlashWindowImage() {
        MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
        MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
        if let splashScreenImageHasReadCodes:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray {

            YXUserManager.sg_getSplashscreenAdvertisement(hasRead: splashScreenImageHasReadCodes as! [String], pageId: 1) {
                    
            }
            
        } else {
            let recodeArray = NSMutableArray.init(capacity: 0)
            MMKV.default().set(recodeArray, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
            let splashScreenImageHasReadCodes:NSMutableArray? = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray
            YXUserManager.sg_getSplashscreenAdvertisement(hasRead: splashScreenImageHasReadCodes as! [String], pageId: 1) {
            }
        }
    }
    
    fileprivate func requestUserConfig() {
        var value: Int = 0
        switch self.viewModel.configType {
        case .languageHk:
            value = self.viewModel.languageHk.rawValue
        case .lineColorHk:
            value = self.viewModel.lineColorHk.rawValue
        case .sortHk:
            value = self.viewModel.sortHK.rawValue
        default:
            value = 0
        }
        self.viewModel.hudSubject.onNext(.loading("", false))
        self.viewModel.services.userService.request(.modifyUserConfig(self.viewModel.configType, value), response: self.viewModel.configResponse).disposed(by: self.disposeBag)
        self.viewModel.resultSubject.subscribe(onNext: { [weak self] (isSucceed, msg) in
            guard let `self` = self else {return}
            self.viewModel.hudSubject.onNext(.hide)
            if isSucceed {
            } else {
                self.viewModel.hudSubject.onNext(.error(msg, false))
            }
        }).disposed(by: self.disposeBag)
    }
}

extension YXSetViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var smartRow = 1
        if isHasSkinSet {
            smartRow = 2
        }
        if indexPath.section == 1 && indexPath.row == smartRow {
            //========= 智能排序
            let cell = YXPreferSetSmartTableViewCell(style: .default, reuseIdentifier: smartSortIndentifier)
            cell.lineView.isHidden = true
            //填充文案
            let model = dataSource[indexPath.section][indexPath.row]
            cell.reloadData(model.title ?? "", desc: model.describeStr ?? "")
            //开关的设置
            if self.viewModel.sortHK == .on {
                cell.switchView.setOn(true, animated: false)
            }else if self.viewModel.sortHK == .off {
                cell.switchView.setOn(false, animated: false)
            }
            //响应
            cell.switchView.rx.isOn.asObservable().subscribe(onNext: {[weak self] (isOn) in
                guard let `self` = self else { return }
                let sortType: YXSortHK = isOn ? .on : .off
                //FIXED: 解决一进来该页面就请求接口的问题；
                if self.viewModel.sortHK != sortType {
                    self.viewModel.sortHK = sortType
                    self.trackViewClickEvent(name: "Smart Sorting_tab")
                    if isOn {
                        YXSecuGroupManager.shareInstance().userSetSortflag(1)
                    } else {
                        YXSecuGroupManager.shareInstance().userSetSortflag(0)
                    }
                    if YXUserManager.isLogin() {
                        self.viewModel.configType = .sortHk
                        self.requestUserConfig()
                    }
                }
                
            }).disposed(by: disposeBag)
            return cell
        }
        else {
            let cell = YXMineCommonViewCell(style: .default, reuseIdentifier: "YXMineCommonViewCell")
            cell.cellModel = dataSource[indexPath.section][indexPath.row]
            cell.refreshUI()
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if !YXUserManager.isLogin() {
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                return
            }
            if indexPath.row == 0 { //账号与安全
                if (YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false) {
                    self.viewModel.navigator.push(YXModulePaths.orgAccount.url)
                } else {
                    
                    self.trackViewClickEvent(name: "Account&Security_tab")
                    self.viewModel.navigator.push(YXModulePaths.userCenterUserAccount.url)
                }
            }else if indexPath.row == 1{//个人信息
                self.trackViewClickEvent(name: "Personal Information_tab")
                self.viewModel.navigator.push(YXModulePaths.personalData.url)
            }
        case 1:
            if indexPath.row == 0 {
                self.viewModel.navigator.push(YXModulePaths.appPrivacy.url)
            }
            if isHasSkinSet {
                // 皮肤
                if indexPath.row == 1 {
                    self.viewModel.navigator.push(YXModulePaths.skin.url)
                }
            }
        case 2:
            if indexPath.row == 0 {//语言
                self.trackViewClickEvent(name: "Languages_tab")
                self.changeLanguages()
            }
        case 3:
//            if indexPath.row == 0 {//货币
//                self.changeCurrecy()
//            }else
            if indexPath.row == 0{//通知
                self.trackViewClickEvent(name: "Notification Settings_tab")
//                let context = YXNavigatable(viewModel: YXNotiViewModel())
//                self.viewModel.navigator.push(YXModulePaths.noti.url, context: context)                
                if YXUserManager.isLogin() {
                    let noticeViewModel = YXNoticeAppViewModel.init(services: self.viewModel.navigator, params: nil)
                    self.viewModel.navigator.push(noticeViewModel, animated: true)
                } else {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                    self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
                
            }else if indexPath.row == 1{//优惠通知
                self.trackViewClickEvent(name: "Promotional Notification Settings_tab")
                if !YXUserManager.isLogin() {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                    self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    return
                }
                let context = YXNavigatable(viewModel: YXPromotionMsgViewModel())
                self.viewModel.navigator.push(YXModulePaths.promotionMsg.url, context: context)
            }
            break
        case 4:
            self.trackViewClickEvent(name: "Clear Cache_tab")
            self.cleanChaceAlert()
        default:
            print("nothing")
        }
        
    }
    //row的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    //footer in section的高度
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 49
        }
        return 0.01
    }
    //footer insection
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        
        if section == 1 {
            //【自选股列表日间优先显示港股和新股，晚间优先显示美股】
            let lab = QMUILabel()
            lab.text = YXLanguageUtility.kLang(key: "initial_settings_smart_sorting_displayed_tip")
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.textColor = QMUITheme().textColorLevel4()
            lab.numberOfLines = 0
            v.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.left.equalTo(v).offset(16)
                make.top.equalTo(v).offset(0)
                make.right.equalTo(v).offset(-18)
            }
            
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().separatorLineColor()
            v.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(18)
                make.bottom.equalToSuperview()
                make.right.equalTo(-18)
                make.height.equalTo(0.5)
            }
        }

        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
  
}
