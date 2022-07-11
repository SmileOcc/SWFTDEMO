//
//  YXNotiViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
///消息通知设置
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXNotiViewController: YXHKTableViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXNotiViewModel!
    
    var dataSource: [[CommonCellData]] = {
        
        var cellArr = [CommonCellData]()
        var notiCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "mine_message_switch"), describeStr: "", showArrow: true, showLine: false)
        cellArr.append(notiCell)
        
        return [cellArr]
    }()
    
    var isOpen: Bool = {
        //get方法
        let setting = UIApplication.shared.currentUserNotificationSettings
        return UIUserNotificationType.init(rawValue: 0) != setting?.types
    }()
    
    var tipLab: UILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().textColorLevel4()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.numberOfLines = 0
        return lab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        reloadData()
    }
    override var pageName: String {
        return "Notification Settings"
    }
    func initUI() {
        
        tableView.separatorStyle = .none

//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 55))
//        headerView.backgroundColor = QMUITheme().foregroundColor()
//        let titleLab = UILabel(frame: CGRect(x: 18, y: 5, width: YXConstant.screenWidth - 18, height: 40))
//        titleLab.textColor = QMUITheme().textColorLevel1()
//        titleLab.text = YXLanguageUtility.kLang(key: "user_notice")
//        titleLab.font = UIFont.systemFont(ofSize: 28, weight: .medium)
//        headerView.addSubview(titleLab)
//        self.tableView.tableHeaderView = headerView
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.title = YXLanguageUtility.kLang(key: "user_notice")
    }
    
    func bindViewModel() {
        //绑定 didBecomeActiveNotification
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.reloadData()
            })
    }
    
    func reloadData() {
        
        let setting = UIApplication.shared.currentUserNotificationSettings
        self.isOpen = UIUserNotificationType.init(rawValue: 0) != setting?.types
        
        var describeStr = ""
        var describeColor: UIColor?
        if isOpen {
            describeStr = YXLanguageUtility.kLang(key: "mine_opened")
            describeColor = QMUITheme().textColorLevel1()
        } else {
            describeStr = YXLanguageUtility.kLang(key: "mine_go_open")
            describeColor = QMUITheme().themeTextColor()
        }
        let notiCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "mine_message_switch"), describeStr: describeStr, showArrow: !isOpen, showLine: false, describeColor: describeColor)
        self.dataSource[0][0] = notiCell
        self.tableView.reloadData()
    }
    
    func showNotiAlert() {
        self.jumpToSettingNotific()
//        let alertController = UIAlertController(title: YXLanguageUtility.kLang(key: "mine_send_noti"), message: YXLanguageUtility.kLang(key: "mine_noti"), preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: YXLanguageUtility.kLang(key: "mine_no_allow"), style: .cancel, handler: { action in
//
//
//        })
//
//        let okAction = UIAlertAction(title: YXLanguageUtility.kLang(key: "mine_allow"), style: .default, handler: {[weak self] action in
//            self?.jumpToSettingNotific()
//        })
//
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
//        present(alertController, animated: true)
    }
    //跳到设置的通知页面
    private func jumpToSettingNotific() {
        let application = UIApplication.shared
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url {
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }

}

extension YXNotiViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = YXMineCommonViewCell(style: .default, reuseIdentifier: "YXMineCommonViewCell")
        cell.cellModel = dataSource[indexPath.section][indexPath.row]
        cell.refreshUI()
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isOpen {
            showNotiAlert()
        } else {
            self.jumpToSettingNotific()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        50
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        v.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.left.equalTo(v).offset(14)
            make.right.equalTo(v).offset(-14)
            make.top.equalTo(10)
        }
        tipLab.text = YXLanguageUtility.kLang(key: "mine_noti_close")
//        if !isOpen {
//            tipLab.text = YXLanguageUtility.kLang(key: "mine_noti_close")
//        }else {
//            tipLab.text = ""
//        }
        return v
    }
    
    
}

