//
//  YXAccountViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//賬戶與安全
import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXOrgAccountViewController: YXHKTableViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXOrgAccountViewModel!
    
    lazy var dataSource: [[CommonCellData]] = {
        //section = 0
        var cellArr = [CommonCellData]()
        //手机号
        
        var title = ""
        let phone = YXUserManager.shared().curLoginUser?.phoneNumber ?? ""
        if phone.count > 0 {
            title = String(format: "%@ %@","+\(YXUserManager.shared().curLoginUser?.areaCode ?? "")", YXUserManager.secretPhone())
        } else {
            title = YXLanguageUtility.kLang(key: "mine_unbind")
        }
        //暂时不能修改 2.2
        var phoneCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_phoneTip"), describeStr: title, showArrow: false, showLine: YXUserManager.canTrade())
        cellArr.append(phoneCell)
        //是否开户
        if YXUserManager.canTrade() {
            //邮箱 //暂时不能修改 2.2
            var emailCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_emailTip"), describeStr: String(format: "%@", YXUserManager.secretEmail()), showArrow: false, showLine: false)
            cellArr.append(emailCell)
        }
        //section = 1
        var cellArr2 = [CommonCellData]()
        
        let pwdCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_changePwdTip"), describeStr: "", showArrow: true, showLine: YXUserManager.canTrade())
        cellArr2.append(pwdCell)
        //是否开户
        if YXUserManager.canTrade() {
            //修改交易密码
            let tradeCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_tradePwdTip"), describeStr: "", showArrow: true, showLine: false)
            cellArr2.append(tradeCell)
        }
                
        return [cellArr, cellArr2]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
        
        tableView.separatorStyle = .none
        //账户与安全
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 55))
        headerView.backgroundColor = QMUITheme().foregroundColor()
        let titleLab = UILabel(frame: CGRect(x: 18, y: 5, width: YXConstant.screenWidth - 18, height: 40))
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = YXLanguageUtility.kLang(key: "user_accountSafe")
        titleLab.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        headerView.addSubview(titleLab)
        self.tableView.tableHeaderView = headerView
        
        reloadData()
    }
    
    func bindViewModel() {
        //更新用户信息 通知
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })

    }
    
    func reloadData() {
        //手机号
        var phoneCell = self.dataSource[0][0]
        var title = ""
        let phone = YXUserManager.shared().curLoginUser?.phoneNumber ?? ""
        if phone.count > 0 {
            title = String(format: "%@ %@","+\(YXUserManager.shared().curLoginUser?.areaCode ?? "")", YXUserManager.secretPhone())
        } else {
            title = YXLanguageUtility.kLang(key: "mine_unbind")
        }
        //暂时不能修改 2.2
        phoneCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_phoneTip"), describeStr: title, showArrow: false, showLine: YXUserManager.canTrade())
        self.dataSource[0][0] = phoneCell
        //是否开户
        if YXUserManager.canTrade() {
            //邮箱 //暂时不能修改 2.2
            var emailCell = self.dataSource[0][1]
            emailCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_emailTip"), describeStr: String(format: "%@", YXUserManager.secretEmail()), showArrow: false, showLine: false)
            self.dataSource[0][1] = emailCell
        }
        self.tableView.reloadData()
    }

    
    //设置登录密码 的弹框
    func setLoginPwdAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_setLoginPwdAlertTip"))
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_toSet"), style: .default, handler: { [weak alertView, weak self] action in
            guard let `self` = self else { return }
            
            alertView?.hide()
            //跳到 设置登录密码
            let context = YXNavigatable(viewModel: YXSetLoginPwdViewModel())
            self.viewModel.navigator.push(YXModulePaths.setLoginPwd.url, context: context)
        }))
        alertView.showInWindow()
    }
    
    //设置登录密码 的弹框
    func Alert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_setLoginPwdAlertTip"))
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_toSet"), style: .default, handler: { [weak alertView, weak self] action in
            guard let `self` = self else { return }
            
            alertView?.hide()
            //跳到 设置登录密码
            let context = YXNavigatable(viewModel: YXSetLoginPwdViewModel())
            self.viewModel.navigator.push(YXModulePaths.setLoginPwd.url, context: context)
        }))
        alertView.showInWindow()
    }
}

extension YXOrgAccountViewController {
    
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
        
        if indexPath.section == 0 && indexPath.row == 0 { //更改手机号
            //2.2 暂时不能修改
            return
            if YXUserManager.isBindPhone() {
//                //是否设置登录密码
//                let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
//                let loginPwd = (extendStatusBit & YXExtendStatusBitType.loginPwd.rawValue) == YXExtendStatusBitType.loginPwd.rawValue
//                if loginPwd {
//                    //修改旧手机号码【請验证原来的手机号码】
//                    self.viewModel.navigator.push(YXModulePaths.changePhoneOld.url, context: nil)
//                } else {
//                    //设置登录密码
//                    setLoginPwdAlert()
//                }
                //修改旧手机号码【請验证原来的手机号码】
                self.viewModel.navigator.push(YXModulePaths.changePhoneOld.url, context: nil)
            } else {
                let context = YXNavigatable(viewModel: YXCheckPhoneViewModel(sourceVC: self, callback: nil))
                self.viewModel.navigator.push(YXModulePaths.bindCheckPhone.url, context: context)
            }
        } else if indexPath.section == 0 && indexPath.row == 1 { //更改邮箱 开户必填邮箱的
            //2.2 暂时不能修改
            return
            let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.change, sourceVC: self, callBack: nil))
            self.viewModel.navigator.push(YXModulePaths.changeEmail.url, context: context)
                                    
        } else if indexPath.section == 1 && indexPath.row == 0 { //更改密码
                //是否设置登录密码
            let context = YXNavigatable(viewModel: YXChangePwdViewModel())
            self.viewModel.navigator.push(YXModulePaths.changePwd.url, context: context)
            
        }  else if indexPath.section == 1 && indexPath.row == 1 { //更改交易密码
            
            YXTradePwdManager.shared().checkSetTradePwd(nil) { b in
                YXUserManager.shared().curLoginUser?.tradePassword = b
                
                if YXUserManager.shared().tradePassword() {
                    let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .old, funType: .change, oldPwd: "", pwd: "", captcha: "", vc: self))
                    self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
                } else {
                    //第一次设置交易密码 弹框形式
                    YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: nil, failureBlock: nil, isToastFailedMessage: nil, autoLogin: false, needToken: false)
                }
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        61
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let _ = YXUserManager.shared().curLoginUser?.email , section == 0, YXUserManager.canTrade() {
            return 70
        }
        if section == 1 {
            return 50
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.clear
        //section == 0 有邮箱
        if let _ = YXUserManager.shared().curLoginUser?.email, section == 0, YXUserManager.canTrade() {
            //【邮箱用于接收交易结单、找回密码等操作，请确保能正常接收邮件】
            let lab = QMUILabel()
            lab.text = YXLanguageUtility.kLang(key: "mine_email_tip")
            lab.font = UIFont.systemFont(ofSize: 14)
            lab.textColor = QMUITheme().textColorLevel3()
            lab.numberOfLines = 0
            v.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.left.equalTo(v).offset(18)
                make.top.equalTo(v).offset(10)
                make.right.equalTo(v).offset(-18)
            }
        }
        if section == 1 {
            //【第三方帐号登录】
            let lab = QMUILabel()
            lab.text = ""
            lab.font = UIFont.systemFont(ofSize: 14)
            lab.textColor = QMUITheme().textColorLevel3()
            lab.numberOfLines = 0
            v.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.left.equalTo(v).offset(18)
                make.top.equalTo(v).offset(20)
                make.right.equalTo(v).offset(-18)
            }
        }
        
        return v
    }
    
    
}
