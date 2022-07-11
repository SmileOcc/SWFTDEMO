//
//  YXPreferenceSetViewController.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
///个人设置
import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import TYAlertController

// 此类功能没有使用，若使用，需要完善选择语言
class YXPreferenceSetViewController: YXHKTableViewController, HUDViewModelBased {

    let disposeBag = DisposeBag()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXPreferenceSetViewModel!
    
    var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = QMUITheme().themeTextColor()
        btn.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 47)
        
        // fillCode
        btn.setBackgroundImage(btnBgImageGradientBlue, for: .normal)
        
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#EBEBEB"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    let commonIndentifier = "commonIndentifier"
    let smartSortIndentifier = "smartSortIndentifier"
    let quoteIdentifier = "quoteIdentifier"
        
    var kTableHeaderHeight: CGFloat {
        143
    }
    
    var kCellHeight: CGFloat {
        60
    }
    var kSmartSortHeight: CGFloat {
        82
    }
    
    var kSectionFooterHeight: CGFloat {
        466
    }
    
    let titleLab = UILabel()
    let descLab = UILabel()
    
    var dataSource: [CommonCellData] = {
        let languageCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "initial_settings_language"), describeStr: "", showArrow: true, showLine: true)
        let colorCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "initial_settings_quote_color"), describeStr: "", showArrow: true, showLine: true)
        return [languageCell, colorCell]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化 语言和涨跌颜色
        self.viewModel.languageHk = YXUserManager.curLanguage()
        let mmkv = MMKV.default()
        self.viewModel.lineColorHk = YXLineColorType(rawValue: Int(mmkv.int32(forKey: YXUserManager.YXColor, defaultValue: Int32(YXLineColorType.gRaiseRFall.rawValue)))) ?? .gRaiseRFall
        
        initUI()
        bindHUD()
        bindViewModel()
    }
    //重写tableView布局
    override func layoutTableView() {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }
    func initUI() {
        tableView.separatorStyle = .none
        
        // ====== tableHeaderView
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: kTableHeaderHeight))
        headerView.backgroundColor = QMUITheme().foregroundColor()
        
        let titleTop = 50 - YXConstant.statusBarHeight()
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        headerView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(titleTop)
            make.height.equalTo(40)
        }
        
        
        descLab.textColor = QMUITheme().textColorLevel2()
        descLab.numberOfLines = 2
        descLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        headerView.addSubview(descLab)
        descLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        self.tableView.tableHeaderView = headerView
        
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        
        self.tableView.register(YXMineCommonViewCell.self, forCellReuseIdentifier: commonIndentifier)
        self.tableView.register(YXPreferSetSmartTableViewCell.self, forCellReuseIdentifier: smartSortIndentifier)
        self.tableView.register(YXPreferSetQuoteTableViewCell.self, forCellReuseIdentifier: quoteIdentifier)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.backgroundColor = QMUITheme().foregroundColor()
        tableView.snp.remakeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.left.right.equalTo(strongSelf.view)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding() - confirmBtn.qmui_height)
            make.top.equalTo(strongSelf.view).offset(YXConstant.statusBarHeight())
        }
        
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(confirmBtn.qmui_height)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
        }
        
        reloadData()
    }
    
    func bindViewModel() {
        let defaultLanguage = YXUserManager.curLanguage()
        
        confirmBtn.rx.tap.bind {[weak self] in
            guard let `self` = self else {return}
            
            if defaultLanguage != self.viewModel.languageHk {
                // 通知重置根视图
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateResetRootView), object: ["preferenceSet": YXLanguageUtility.kLang(key: "mine_set_success")])
            } else {
                
                self.viewModel.finishClosure()
            }
        }.disposed(by: disposeBag)
    }
    
    func reloadData() {
        
        titleLab.text = YXLanguageUtility.kLang(key: "initial_settings_title")
        descLab.text = YXLanguageUtility.kLang(key: "initial_settings_tips")
        confirmBtn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        //语言
        var language: String
        switch self.viewModel.languageHk {
        case .CN:
            language = YXLanguageUtility.kLang(key: "initial_settings_language_sc")
        case .EN:
            language = YXLanguageUtility.kLang(key: "initial_settings_language_en")
        default:
            language = YXLanguageUtility.kLang(key: "initial_settings_language_tc")
        }
        let languageCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "initial_settings_language"), describeStr: language, showArrow: true, showLine: true)
        self.dataSource[0] = languageCell
        //涨跌颜色
        var color = ""
        var image = UIImage()
        if self.viewModel.lineColorHk == .rRaiseGFall {
            color = YXLanguageUtility.kLang(key: "initial_settings_red_up")
            image = UIImage(named: "user_hongzhang") ?? UIImage()
        }else {
            color = YXLanguageUtility.kLang(key: "initial_settings_green_up")
            image = UIImage(named: "user_lvzhang") ?? UIImage()
        }
        let colorCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "initial_settings_quote_color"), describeStr: color, showArrow: true, showLine: true, describeImage: image)
        self.dataSource[1] = colorCell
        
        self.tableView.reloadData()
    }
    
    
    func showLanguageAlert() {
        
        let languageView = YXLanguageView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-40, height: 182), curLanguage: self.viewModel.languageHk)
        
        let backgroudView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: languageView.frame.height + 34))
        backgroudView.addSubview(languageView)
        
        let alertVc = TYAlertController(alert: backgroudView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade)
        alertVc!.backgoundTapDismissEnable = true
        languageView.didSelected = { [weak alertVc, weak self] index in
            guard let `self` = self else {return}
            switch index {
            case 2:
                self.viewModel.languageHk = .EN
            case 1:
                self.viewModel.languageHk = .CN
            default:
                self.viewModel.languageHk = .HK
            }
            self.viewModel.configType = .languageHk
            //存储和更新
            MMKV.default().set(Int32(self.viewModel.languageHk.rawValue), forKey: YXUserManager.YXLanguage)
            if YXUserManager.isLogin() {
                self.requestUserConfig()
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateLanguage), object: nil)
                YXLanguageUtility.resetUserLanguage(self.viewModel.languageHk)
                self.reloadData()
            }
            alertVc?.dismissViewController(animated: true)
        }
        self.present(alertVc!, animated: true, completion: nil)
        
    }
    
    func showColorAlert() {
        
        let colorView = YXColorView(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-40, height: 121), curLineColor: self.viewModel.lineColorHk)
        
        let backgroudView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: colorView.frame.height + 34))
        backgroudView.addSubview(colorView)
        
        let alertVc = TYAlertController(alert: backgroudView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade)
        alertVc!.backgoundTapDismissEnable = true
        colorView.didSelected = { [weak alertVc, weak self] index in
            guard let `self` = self else {return}
            // 以前1是红涨绿跌, 2是绿涨红跌
            if index == 0 {
                self.viewModel.lineColorHk = .gRaiseRFall
            }else {
                self.viewModel.lineColorHk = .rRaiseGFall
            }
            //存储和更新
            MMKV.default().set(Int32(self.viewModel.lineColorHk.rawValue), forKey: YXUserManager.YXColor)
            self.viewModel.configType = .lineColorHk
            if YXUserManager.isLogin() {
                self.requestUserConfig()
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateColor), object: nil)
                
                self.reloadData()
            }
            alertVc?.dismissViewController(animated: true)
        }
        self.present(alertVc!, animated: true, completion: nil)
        
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
            if isSucceed {
                self.reloadData()
            } else {
                self.viewModel.hudSubject.onNext(.error(msg, false))
            }
        }).disposed(by: self.disposeBag)
    }
}

extension YXPreferenceSetViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count + 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataSource.count {
            let cell = YXMineCommonViewCell(style: .default, reuseIdentifier: commonIndentifier)
            cell.cellModel = dataSource[indexPath.row]
            cell.refreshUI()
            return cell
        }
        //else if indexPath.row == dataSource.count {
        else {
            let cell = YXPreferSetSmartTableViewCell(style: .default, reuseIdentifier: smartSortIndentifier)
            cell.reloadData(YXLanguageUtility.kLang(key: "initial_settings_smart_sorting"), desc: YXLanguageUtility.kLang(key: "initial_settings_smart_sorting_desc"))
            
            //开关的设置
            if self.viewModel.sortHK == .on {
                cell.switchView.setOn(true, animated: false)
            }else if self.viewModel.sortHK == .off {
                cell.switchView.setOn(false, animated: false)
            }
            
            cell.switchView.rx.isOn.asObservable().subscribe(onNext: {[weak self] (isOn) in
                guard let `self` = self else {return}
                let sortType: YXSortHK = isOn ? .on : .off
                //FIXED: 解决一进来该页面就请求接口的问题；
                if self.viewModel.sortHK != sortType {
                    self.viewModel.sortHK = sortType
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            showLanguageAlert()
        } else if indexPath.row == 1{
            showColorAlert()
        }
    }
    //row的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < dataSource.count {
            return kCellHeight
        }
//        else if indexPath.row == dataSource.count {
        else {
            return tableView.qmui_heightForCell(withIdentifier: self.smartSortIndentifier, cacheBy: indexPath, configuration: { (cell) in
                if let cell = cell as? YXPreferSetSmartTableViewCell {
                    cell.reloadData(YXLanguageUtility.kLang(key: "initial_settings_smart_sorting"), desc: YXLanguageUtility.kLang(key: "initial_settings_smart_sorting_desc"))
                }
            })
        }
//        else {
//            return tableView.qmui_heightForCell(withIdentifier: self.quoteIdentifier, cacheBy: indexPath, configuration: {[weak self] (cell) in
//                guard let `self` = self else {return}
//                if let cell = cell as? YXPreferSetQuoteTableViewCell {
//                    cell.reloadData(self.quoteChartHK)
//                }
//            })
//        }
    }
}
