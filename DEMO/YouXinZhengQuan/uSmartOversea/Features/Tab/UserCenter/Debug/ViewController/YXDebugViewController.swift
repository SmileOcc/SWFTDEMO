//
//  YXDebugViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa
import RxDataSources

// 点击20次，即可在生产环境下显示调试配置
let DEBUG_COUNTER_MAX = 20

class YXDebugViewController: YXHKTableViewController, ViewModelBased {
    // 点击计数器
    public static var debugCounter: Int = 0
    
    var viewModel: YXDebugViewModel!
    
    var envMode: YXTargetMode = YXConstant.targetMode()
    var autofillCaptcha: Bool = false
    var globalConfigSwitch: Bool = false
    var appsFlyerEnable: Bool = false
    var backupConfigSwitch: Bool = false
    var httpDnsEnable: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // 恢复计数器
        YXDebugViewController.debugCounter = 0
        
        self.envMode = YXConstant.envMode()
        
        self.autofillCaptcha = YXConstant.isAutoFillCaptcha()
        self.globalConfigSwitch = YXConstant.isGlobalConfig()
        self.appsFlyerEnable = YXToolUtility.appsFlyerEnable()
        self.backupConfigSwitch = YXConstant.isBackupEnv()
        self.httpDnsEnable = YXConstant.httpDnsEnable()
        
        // QMUITableView会默认设置delegate，导致和RxDataSource冲突
        // 所以在此先置为空
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 55))
        headerView.backgroundColor = QMUITheme().foregroundColor()
        let titleLab = UILabel(frame: CGRect(x: 18, y: 5, width: 120, height: 40))
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = "调试配置"
        titleLab.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        headerView.addSubview(titleLab)
        self.tableView.tableHeaderView = headerView

        let dataItem = [
            CommonCellData(image: nil, title: "当前环境", describeStr: "开发环境(DEV)", showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "js调试配置", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "用户UUID", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "用户token", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "自动填充短信验证码", describeStr: nil, showArrow: false, showLine: true),
            CommonCellData(image: nil, title: "测试崩溃上报", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "全局配置", describeStr: nil, showArrow: false, showLine: true),
            CommonCellData(image: nil, title: "用户权限", describeStr: nil, showArrow: false, showLine: true),
            CommonCellData(image: nil, title: "版本信息", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "AppsFlyer初始化", describeStr: nil, showArrow: false, showLine: true),
            CommonCellData(image: nil, title: "苹果推送DeviceToken", describeStr: nil, showArrow: true, showLine: true),
            CommonCellData(image: nil, title: "备份机房", describeStr: nil, showArrow: false, showLine: true),
            CommonCellData(image: nil, title: "腾讯云HTTP DNS", describeStr: nil, showArrow: false, showLine: true),
        ]

        
        let items = Observable.just([SectionModel(model: "",
                                                  items: dataItem)])
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CommonCellData>> (configureCell:{ [weak self](dataSouece, tableView, indexPath, element) -> UITableViewCell in
            guard let strongSelf = self else { return UITableViewCell() }
            
            if element.title == "自动填充短信验证码" || element.title == "全局配置" || element.title == "AppsFlyer初始化" || element.title == "自建推送服务" || element.title == "备份机房" || element.title == "腾讯云HTTP DNS" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "switch_identifier",
                                                         for: indexPath) as! YXMineCommonViewCell
                cell.cellModel = element
                cell.refreshUI()
                
                let switchView = UISwitch(frame: .zero)
                switchView.onTintColor = QMUITheme().switchOnTintColor()
                if element.title == "自动填充短信验证码" {
                    switchView.setOn(strongSelf.autofillCaptcha, animated: true)
                } else if element.title == "全局配置" {
                    switchView.setOn(strongSelf.globalConfigSwitch, animated: true)
                } else if element.title == "AppsFlyer初始化" {
                    switchView.setOn(strongSelf.appsFlyerEnable, animated: true)
                } else if element.title == "备份机房" {
                    switchView.setOn(strongSelf.backupConfigSwitch, animated: true)
                } else if element.title == "腾讯云HTTP DNS" {
                    switchView.setOn(strongSelf.httpDnsEnable, animated: true)
                }
                switchView.tag = indexPath.row
                switchView.addTarget(strongSelf, action: #selector(strongSelf.switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "normal_identifier", for: indexPath) as! YXMineCommonViewCell
                cell.cellModel = element
                cell.refreshUI()
                if indexPath.row == 0 {
                    switch strongSelf.envMode {
                    case .dev:
                        cell.describeLab.text = "开发环境(DEV)"
                    case .sit:
                        cell.describeLab.text = "测试环境(SIT)"
                    case .uat:
                        cell.describeLab.text = "测试环境(UAT)"
                    case .mock:
                        cell.describeLab.text = "测试环境(Mock)"
                    case .prd:
                        cell.describeLab.text = "生产环境(PRD)"
                    case .prd_hk:
                        cell.describeLab.text = "生产环境(PRD HK)"
                    }
                } else {
                    cell.describeLab.text = element.describeStr
                }
                return cell
            }
        })
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tableView.register(YXMineCommonViewCell.self, forCellReuseIdentifier: "normal_identifier")
        self.tableView.register(YXMineCommonViewCell.self, forCellReuseIdentifier: "switch_identifier")
        tableView.tableFooterView = UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if YXConstant.targetMode() != .prd && YXConstant.targetMode() != .prd_hk {
                self.setEnvMode()
            } else {
                self.showEnvParams()
            }
        } else if indexPath.row == 1 {
            self.viewModel.jsEntrance()
        } else if indexPath.row == 2 {
            QMUITips.showInfo("用户UUID", detailText: "userUUID: \(YXUserManager.userUUID())\n已复制到剪贴板", in: self.view, hideAfterDelay:5.0)
            UIPasteboard.general.string = "\(YXUserManager.userUUID())"
        } else if indexPath.row == 3 {
            if let token = YXUserManager.shared().curLoginUser?.token {
                QMUITips.showInfo("用户token", detailText: "token: \(token)\n已复制到剪贴板", in: self.view, hideAfterDelay:5.0)
                UIPasteboard.general.string = "\(token)"
            } else {
                QMUITips.show(withText: "token为空,请检查登录状态", in: self.view, hideAfterDelay: 1.5)
            }
        } else if indexPath.row == 4 || indexPath.row == 6 || indexPath.row == 9 || indexPath.row == 11 || indexPath.row == 12 {

        } else if indexPath.row == 5 {
            if YXConstant.targetMode() != .prd_hk && YXConstant.targetMode() != .prd {
                fatalError()
            } else {
                QMUITips.show(withText: "生产环境已屏蔽该崩溃", in: self.view, hideAfterDelay: 1.5)
            }
        }
        else if indexPath.row == 7 {
            if YXUserManager.isLogin() {
                let hkLevel = YXUserManager.hkLevel().rawValue - 2
                let hsLevel = YXUserManager.hsLevel().rawValue - 6
                let text = String(format: "当前用户HK权限为%d，当前用户US权限为%d，当前用户沪深权限为%d", hkLevel,YXUserManager.usLevel().rawValue, hsLevel)
                QMUITips.show(withText: text, in: self.view, hideAfterDelay: 1.5)
            }
        } else if indexPath.row == 8 {
            let message = "版本号：\(YXConstant.appVersion ?? "")\n构建版本：\(YXConstant.appBuild ?? "")\n当前targe模式：\(YXConstant.targetModeName() ?? "")"
            let confirm = QMUIAlertAction(title: "确定", style: .default, handler: nil)
            let alertController = QMUIAlertController(title: "版本信息", message: message, preferredStyle: .alert)
            alertController.addAction(confirm)
            alertController.showWith(animated: true)
        } else if indexPath.row == 10 {
            let deviceTokenString: String? = YXPushService.pushToken
            
            if let deviceTokenString = deviceTokenString {
                QMUITips.showInfo("苹果推送DeviceToken", detailText: "deviceToken: \(deviceTokenString)\n已复制到剪贴板", in: self.view, hideAfterDelay:5.0)
                UIPasteboard.general.string = "\(deviceTokenString)"
            } else {
                QMUITips.show(withText: "deviceToken为空, 请稍后再试", in: self.view, hideAfterDelay: 1.5)
            }
        } 
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        if YXConstant.targetMode() != .prd_hk && YXConstant.targetMode() != .prd {
            if sender.tag == 4 {
                YXConstant.saveAutoFillCaptcha(fillCaptcha: sender.isOn)
            } else if sender.tag == 6 {
                YXConstant.saveGlobalConfigStatus(status: sender.isOn)
            } else if sender.tag == 9 {
                YXToolUtility.setAppsFlyerEnable(sender.isOn)
                QMUITips.show(withText: "设置成功,重启应用后生效", in: self.view, hideAfterDelay: 1.5)
            } else if sender.tag == 11 {
                QMUITips.show(withText: "备份机房开关仅在生产环境下生效", in: self.view, hideAfterDelay: 1.5)
            } else if sender.tag == 12 {
                YXConstant.saveHttpDnsEnable(enable: sender.isOn)
            }
        } else if sender.tag == 11 {
            YXConstant.saveBackupEnvStatus(status: sender.isOn)
        } else {
            QMUITips.show(withText: "生产环境已屏蔽该操作", in: self.view, hideAfterDelay: 1.5)
        }
    }
    
    fileprivate func setEnvMode() -> Void {
        let alertController = UIAlertController.init(title: "环境设置", message: "选择不同的环境切换网络主机", preferredStyle: .actionSheet)
        let devEnvAction = UIAlertAction.init(title: "开发环境(DEV)", style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.updateEnvMode(mode: .dev)
        }
        
        let sitEnvAction = UIAlertAction.init(title: "测试环境(SIT)", style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.updateEnvMode(mode: .sit)
        }
        
        let uatEnvAction = UIAlertAction.init(title: "测试环境(UAT)", style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.updateEnvMode(mode: .uat)
        }
        
        let mockEnvAction = UIAlertAction.init(title: "测试环境(Mock)", style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.updateEnvMode(mode: .mock)
        }
        
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        
        alertController.addAction(devEnvAction)
        alertController.addAction(sitEnvAction)
        alertController.addAction(uatEnvAction)
        alertController.addAction(mockEnvAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func updateEnvMode(mode: YXTargetMode) -> Void {
        let lastMode = self.envMode
        YXConstant.saveEnvMode(targeMode: mode)
        self.envMode = mode
        self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
        let detailText = "行情资讯：\(YXUrlRouterConstant.hzBaseUrl())\n交易开发：\(YXUrlRouterConstant.jyBaseUrl())\n静态资源：\(YXUrlRouterConstant.staticResourceBaseUrl())\n图片资源：\(YXUrlRouterConstant.imgResourceBaseUrl())\n文件服务：\(YXUrlRouterConstant.wjBaseUrl())\n资讯服务：\(YXUrlRouterConstant.zxBaseUrl())"
        QMUITips.showInfo("环境配置", detailText: detailText, in: self.view, hideAfterDelay: 5.0)
        if lastMode != self.envMode {
            // 切换了环境，需要把重新进行一次dns解析
            YXDNSResolver.shareInstance().resolveAllHost()
            if YXUserManager.isLogin() {
                YXUserManager.loginOut(request: true)
            }
        }
    }
    
    fileprivate func showEnvParams() {
        let detailText = "行情资讯：\(YXUrlRouterConstant.hzBaseUrl())\n交易开发：\(YXUrlRouterConstant.jyBaseUrl())\n静态资源：\(YXUrlRouterConstant.staticResourceBaseUrl())\n图片资源：\(YXUrlRouterConstant.imgResourceBaseUrl())\n文件服务：\(YXUrlRouterConstant.wjBaseUrl())\n资讯服务：\(YXUrlRouterConstant.zxBaseUrl())"
        YXProgressHUD.showMessage(detailText, in: YXConstant.sharedAppDelegate?.window ?? self.view, hideAfterDelay: 5.0)
    }
}
