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
import Firebase
import GoogleSignIn
import AuthenticationServices

class YXAccountViewController: YXHKTableViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXAccountViewModel!
    
    lazy var dataSource: [[CommonCellData]] = {
        //section = 0
        var cellArr = [CommonCellData]()
        
        let phoneDesc = YXUserManager.isBindPhone() == true ? String(format: "%@ %@","+\(YXUserManager.shared().curLoginUser?.areaCode ?? "")", YXUserManager.secretPhone()) : YXLanguageUtility.kLang(key: "mine_unverified")
        var redImage = YXUserManager.isBindPhone() == false ? UIImage.init(named: "mine_redDot") : nil
        //手机号
        var phoneCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_phoneTip"), describeStr: phoneDesc, showArrow: true, showLine: false,describeColor: QMUITheme().textColorLevel3())
        phoneCell.describeImage = redImage
        cellArr.append(phoneCell)
        //邮箱
        let emailDesc = YXUserManager.isBindEmail() == true ? String(format: "%@", YXUserManager.secretEmail()) : YXLanguageUtility.kLang(key: "mine_unverified")
        redImage = YXUserManager.isBindEmail() == false ? UIImage.init(named: "mine_redDot") : nil
        var emailCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_emailTip"), describeStr:emailDesc, showArrow: true, showLine: false,describeColor: QMUITheme().textColorLevel3())
        emailCell.describeImage = redImage
        cellArr.append(emailCell)

        //section = 1
        var cellArr2 = [CommonCellData]()
        
        let pwdCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_changePwdTip"), describeStr: "", showArrow: true, showLine: false)
        cellArr2.append(pwdCell)
        //是否开户
        if YXUserManager.canTrade() {
            //修改交易密码
            let title = YXUserManager.shared().tradePassword() == true ? YXLanguageUtility.kLang(key: "mine_change_trade_pwd") :  YXLanguageUtility.kLang(key: "mine_set_trade_pwd")
            let tradeCell = CommonCellData(image: nil, title: title, describeStr: "", showArrow: true, showLine: false)
            cellArr2.append(tradeCell)
            //管理双重验证
            let auth2LoginCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "mine_auth_login_set_title"), describeStr: "", showArrow: true, showLine: false)
            cellArr2.append(auth2LoginCell)
        }
        
        //可以注销账号
        let tradeCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "cancel_your_account"), describeStr: "", showArrow: true, showLine: false)
        cellArr2.append(tradeCell)
        
        
        var cellArr3 = [CommonCellData]()
        //facebook
        let faceBookCell = CommonCellData(image: UIImage(named: "Facebook"), title: YXLanguageUtility.kLang(key: "common_facebook"), describeStr: YXUserManager.isBindFaceBook() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
        //google
        let googleCell = CommonCellData(image: UIImage(named: "Google"), title: YXLanguageUtility.kLang(key: "common_google"), describeStr: YXUserManager.isBindGoogle() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
        //微信

        
        cellArr3.append(faceBookCell)
        cellArr3.append(googleCell)
        
        if #available(iOS 13.0, *) {
            let weChatCell = CommonCellData(image: UIImage(named: "WeChat"), title: YXLanguageUtility.kLang(key: "common_weChat"), describeStr: YXUserManager.isBindWechat() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
            cellArr3.append(weChatCell)
            let appleCell = CommonCellData(image: UIImage(named: "Apple"), title: "Apple ID", describeStr: YXUserManager.isBindApple() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
            
            cellArr3.append(appleCell)
        } else {
            let weChatCell = CommonCellData(image: UIImage(named: "WeChat"), title: YXLanguageUtility.kLang(key: "common_weChat"), describeStr: YXUserManager.isBindWechat() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
            cellArr3.append(weChatCell)
        }
        
        let lineCell = CommonCellData(image: UIImage(named: "Line"), title: "Line", describeStr: YXUserManager.isBindWechat() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false)
        cellArr3.append(lineCell)
//        if !(YXUserManager.shared().curLoginUser?.openedAccount ?? false) {
//            let cell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "delete_account"), describeStr: nil, showArrow: true, showLine: false)
//            return [cellArr, cellArr2, cellArr3, [cell]]
//        }
        ///提审需要,暂时隐藏第三方入口
        return [cellArr, cellArr2]
        return [cellArr, cellArr2, cellArr3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    override var pageName: String {
            return "Account&Security"
    }
    
    func initUI() {
        
        tableView.separatorStyle = .none
        //账户与安全
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        
        self.title = YXLanguageUtility.kLang(key: "user_accountSafe")
        
        reloadData()
    }
    
    func bindViewModel() {
        //MARK: 谷歌登录  通知
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiGoogleLogin))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                //成功
                let success = noti.userInfo?["success"] as? NSNumber ?? 0
                if success.boolValue == true {
                    //隐藏转圈
                    strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                    strongSelf.viewModel.bindPlatformType = .typeGooglePlus //存储绑定的平台类型
                    //绑定谷歌 请求
                    let code = noti.userInfo?["code"] as? String ?? ""
                    self?.viewModel.services.userService.request(.bindGoogle(code), response: self?.viewModel.bindingResponse).disposed(by: strongSelf.disposeBag)
                }else {
                    let msg = noti.userInfo?["msg"] as? String ?? ""
                    strongSelf.viewModel.hudSubject.onNext(.message(msg, false))
                }
            })
        //更新用户信息 通知
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })

        self.viewModel.unBindSubject.subscribe(onNext: { [weak self] result in
            guard let `self` = self else { return }
            if self.viewModel.unBindType == .typeWechat {
                self.viewModel.services.userService.request(.unBindWechatPushSingal, response: self.viewModel.unBindingWechatSignalResponse).disposed(by: self.disposeBag)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func reloadData() {
        //手机号
        let phoneDesc = YXUserManager.isBindPhone() == true ? String(format: "%@ %@","+\(YXUserManager.shared().curLoginUser?.areaCode ?? "")", YXUserManager.secretPhone()) : YXLanguageUtility.kLang(key: "mine_unverified")
        var redImage = YXUserManager.isBindPhone() == false ? UIImage.init(named: "mine_redDot") : nil
        
        var phoneCell = self.dataSource[0][0]
        phoneCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_phoneTip"), describeStr: phoneDesc, showArrow: true, showLine: false,describeColor:QMUITheme().textColorLevel3())
        phoneCell.describeImage = redImage
        self.dataSource[0][0] = phoneCell
        //邮箱
        let emailDesc = YXUserManager.isBindEmail() == true ? String(format: "%@", YXUserManager.secretEmail()) : YXLanguageUtility.kLang(key: "mine_unverified")
        redImage = YXUserManager.isBindEmail() == false ? UIImage.init(named: "mine_redDot") : nil
        var emailCell = self.dataSource[0][1]
        emailCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_emailTip"), describeStr: emailDesc, showArrow: true, showLine: false,describeColor: QMUITheme().textColorLevel3())
        emailCell.describeImage = redImage
        self.dataSource[0][1] = emailCell

        ///提审需要,暂时隐藏第三方入口
        /*
        //facebook
        var faceBookCell = self.dataSource[2][0]
        var facebookImage: UIImage?
        let facebookColor: UIColor = QMUITheme().textColorLevel3()
        if YXUserManager.isBindFaceBook() {
            facebookImage = UIImage(named: "Facebook")
        }else {
            facebookImage = UIImage(named: "no_Facebook")
        }
        faceBookCell = CommonCellData(image: facebookImage, title: YXLanguageUtility.kLang(key: "common_facebook"), describeStr: YXUserManager.isBindFaceBook() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: facebookColor)
        self.dataSource[2][0] = faceBookCell
        //google
        var googleCell = self.dataSource[2][1]
        var googleImage: UIImage?
        let googleColor: UIColor = QMUITheme().textColorLevel3()
        if YXUserManager.isBindGoogle() {
            googleImage = UIImage(named: "Google")
        }else {
            googleImage = UIImage(named: "no_Google")
        }
        googleCell = CommonCellData(image: googleImage, title: YXLanguageUtility.kLang(key: "common_google"), describeStr: YXUserManager.isBindGoogle() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: googleColor)
        self.dataSource[2][1] = googleCell
        //微信
        var weChatCell = self.dataSource[2][2]
        var weChatImage: UIImage?
        let weChatColor: UIColor = QMUITheme().textColorLevel3()
        if YXUserManager.isBindWechat() {
            weChatImage = UIImage(named: "WeChat")
        }else {
            weChatImage = UIImage(named: "no_WeChat")
        }

        //Line
        var lineCell = self.dataSource[2].last
        var lineImage: UIImage?
        let lineColor: UIColor = QMUITheme().textColorLevel3()
        if YXUserManager.isBindLine() {
            lineImage = UIImage(named: "Line")
        }else {
            lineImage = UIImage(named: "no_Line")
        }
        
        if #available(iOS 13.0, *) {
            weChatCell = CommonCellData(image: weChatImage, title: YXLanguageUtility.kLang(key: "common_weChat"), describeStr: YXUserManager.isBindWechat() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: weChatColor)
            self.dataSource[2][2] = weChatCell
            //Apple
            var appleCell = self.dataSource[2][3]
            var appleImage: UIImage?
            let appleColor: UIColor = QMUITheme().textColorLevel3()
            if YXUserManager.isBindApple() {
                appleImage = UIImage(named: "Apple")
            }else {
                appleImage = UIImage(named: "no_Apple")
            }
            appleCell = CommonCellData(image: appleImage, title: "Apple ID", describeStr: YXUserManager.isBindApple() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: appleColor)
            self.dataSource[2][3] = appleCell
            lineCell = CommonCellData(image: lineImage, title:"Line", describeStr: YXUserManager.isBindLine() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: lineColor)
            self.dataSource[2][4] = lineCell!
        } else {
            weChatCell = CommonCellData(image: weChatImage, title: YXLanguageUtility.kLang(key: "common_weChat"), describeStr: YXUserManager.isBindWechat() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: weChatColor)
            self.dataSource[2][2] = weChatCell
            lineCell = CommonCellData(image: lineImage, title:"Line", describeStr: YXUserManager.isBindLine() ? YXLanguageUtility.kLang(key: "mine_bind") : YXLanguageUtility.kLang(key: "mine_unbind"), showArrow: true, showLine: false, describeColor: lineColor)
            self.dataSource[2][3] = lineCell!
        }
      */

        self.tableView.reloadData()
    }
    
    //绑定微信，谷歌，微信。已绑定点击则弹框提示 是否解绑
    func selectWithType(type: SSDKPlatformType) {
        
        var title = ""
        let okBtnTitle = YXLanguageUtility.kLang(key: "mine_confirm_unbind")
        switch type {
        case .typeFacebook:
            if YXUserManager.isBindFaceBook() {
                title = YXLanguageUtility.kLang(key: "mine_faceBook_unbindling_tip")
            }else {
                bindWithType(type: type)
                return
            }
            break
        case .typeGooglePlus:
            if YXUserManager.isBindGoogle() {
                title = YXLanguageUtility.kLang(key: "mine_googlo_unbundling_tip")
            }else {
                bindWithType(type: type)
                return
            }
            break
        case .typeWechat:
            if YXUserManager.isBindWechat() {
                title = YXLanguageUtility.kLang(key: "mine_wechat_unbindling_tip")
            }else {
                bindWithType(type: type)
                return
            }
            break
        case .typeAppleAccount:
            if YXUserManager.isBindApple() {
                title = YXLanguageUtility.kLang(key: "mine_appleid_unbindling_tip")
            }else {
                bindWithType(type: type)
                return
            }
            break
        case .typeLine:
            if YXUserManager.isBindLine() {
                title = YXLanguageUtility.kLang(key: "mine_line_unbindling_tip")
            }else {
                bindWithType(type: type)
                return
            }
        default:
            break
        }
        self.viewModel.unBindType = type
        //解绑的弹框
        let alertView = YXAlertView(message: title)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: okBtnTitle, style: .default, handler: {[weak alertView] action in

            alertView?.hide()
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            switch type {
            case .typeWechat:
                self.viewModel.services.userService.request(.unBindWechat, response: self.viewModel.unBindingResponse).disposed(by: self.disposeBag)
                break
            case .typeFacebook:
                self.viewModel.services.userService.request(.unBindFacebook, response: self.viewModel.unBindingResponse).disposed(by: self.disposeBag)
                break
            case .typeGooglePlus:
                self.viewModel.services.userService.request(.unBindGoogle, response: self.viewModel.unBindingResponse).disposed(by: self .disposeBag)
                break
            case .typeAppleAccount:
                self.viewModel.services.userService.request(.unBindApple, response: self.viewModel.unBindingResponse).disposed(by: self .disposeBag)
                break
            case .typeLine:
                self.viewModel.services.userService.request(.unBindLine, response: self.viewModel.unBindingResponse).disposed(by: self .disposeBag)
                break
            default:
                break
            }
        }))
        alertView.showInWindow()
    }
    
   
    //绑定微信，谷歌，facebook 的处理
    func bindWithType(type: SSDKPlatformType) {
        if type == .typeAppleAccount {
            if #available(iOS 13.0, *) {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let appleIDRequest = appleIDProvider.createRequest()
                appleIDRequest.requestedScopes = [.fullName, .email]
                let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDRequest])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self
                authorizationController.performRequests()
            } else {
                // Fallback on earlier versions
            }
        } else if type == .typeGooglePlus {
            self.viewModel.hudSubject.onNext(.loading("", false))
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance().signIn()
        }else {
            //调起ShareSDK
            YXShareSDKHelper.shareInstance()?.authorize(type, withCallback: {[weak self](success, userInfo, _) in
                guard let strongSelf = self else { return }
                if success {//成功
                    //隐藏转圈
                    strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                    //开始绑定
                    
                    strongSelf.viewModel.bindPlatformType = type //存储绑定的平台类型
                    if let credential = userInfo?["credential"] as? [AnyHashable : Any],
                        let rawData = credential["rawData"] as? [AnyHashable : Any],
                        let uid = credential["uid"] as? String,
                        let access_token = rawData["accessToken"] as? String,
                        type == .typeLine {
                        strongSelf.viewModel.services.userService.request(.bindLine(access_token, uid ), response: self?.viewModel.bindingResponse).disposed(by: strongSelf.disposeBag)
                    }
                  
                    
                    if let credential = userInfo?["credential"] as? [AnyHashable : Any],
                        let rawData = credential["rawData"] as? [AnyHashable : Any],
                        let accessToken = rawData["access_token"] as? String{
                        if type == .typeWechat {//微信
                            //绑定 微信
                            let openId = rawData["openid"] as? String
                            strongSelf.viewModel.services.userService.request(.bindWechat(accessToken, openId ?? ""), response: self?.viewModel.bindingResponse).disposed(by: strongSelf.disposeBag)
                        } else if type == .typeFacebook {
                            //facebook
                            //绑定facebook
                            strongSelf.viewModel.services.userService.request(.bindFacebook(accessToken), response: self?.viewModel.bindingResponse).disposed(by: strongSelf.disposeBag)
                        }
                    }
                }else {
                   
                    if let _ = userInfo?["error"] {
                        strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_failure"), false))
                    }else {
                        strongSelf.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "login_auth_cancel"), false))
                    }
                }
            })
        }
    }
    
    func unBindWithType(type: SSDKPlatformType) {
        
        
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
    func alertBindPhone(_ isEmail:Bool=false) {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_first_phone_bind"))
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_bind"), style: .default, handler: { [weak alertView, weak self] action in
            guard let `self` = self else { return }

            alertView?.hide()
            
            //绑定手机号
            let context = YXNavigatable(viewModel: YXFirstBindPhoneViewModel(withCode:"", phone: "", sourceVC: self, callback: {[weak self] (_) in
                if isEmail == true{
                    if YXUserManager.isBindEmail() {
                        let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.change, sourceVC: self, callBack: nil))
                        self?.viewModel.navigator.push(YXModulePaths.changeEmail.url, context: context)
                    }else {
                        let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.bind, sourceVC: self, callBack: nil))
                        self?.viewModel.navigator.push(YXModulePaths.bindEmail.url, context:context)
                    }
                }else {
                    self?.navigationController?.popToViewController(self!, animated: true)
                }
            }))
            self.viewModel.navigator.push(YXModulePaths.bindPhone.url, context: context)
//
//            //跳到 绑定手机
//            let context = YXNavigatable(viewModel: YXCheckPhoneViewModel(sourceVC: self, callback: nil))
//            self.viewModel.navigator.push(YXModulePaths.bindCheckPhone.url, context: context)
        }))
        alertView.showInWindow()
    }
    
    func alertDeletAccount() {
        
        if YXUserManager.canTrade() {//已经开户提示
            
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "delete_account_had_opened_tip"))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in
                
            }))
            alertView.showInWindow()
            
            return
        }
        
        //没有开户
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "confirm_delete_account_tip"))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "confirm_delete_account"), style: .cancel, handler: { action in
            
            let requestModel = YXCancelAccountRequestModel.init()
            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { (respond) in
                if respond.code == .success {
                    
                    if YXUserManager.isLogin() {
                        YXUserManager.loginOut(request: false)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.viewModel.navigator.popViewModel(animated: true)
                            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "login_failure_normal"))
                        }
                    }
                    
                } else {
                    let subAlertView = YXAlertView(message: respond.msg ?? "")
                    //common_iknow
                    subAlertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in

                    }))
                    subAlertView.showInWindow()
                }
            }, failure: { (request) in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            })
        }))
        //confirm_delete_account
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "think_again"), style: .default, handler: { action in
            
            
            
        }))
        alertView.showInWindow()
    }
}

extension YXAccountViewController {
    
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
            if YXUserManager.isBindPhone() {
                //是否设置登录密码
                let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
                let loginPwd = (extendStatusBit & YXExtendStatusBitType.loginPwd.rawValue) == YXExtendStatusBitType.loginPwd.rawValue
                if loginPwd {
                    //修改旧手机号码【請验证原来的手机号码】
                    let context = YXNavigatable(viewModel:YXChangeVertifViewModel(.phone))
                    self.viewModel.navigator.push(YXModulePaths.verifyChange.url, context: context)
                } else {
                    //设置登录密码
                    setLoginPwdAlert()
                }
            } else {
                alertBindPhone()
            }
        } else if indexPath.section == 0 && indexPath.row == 1 { //更改邮箱

            //更改邮箱，不需要判断手机
            if YXUserManager.isBindEmail() {
                let context = YXNavigatable(viewModel:YXChangeVertifViewModel(.email))
                self.viewModel.navigator.push(YXModulePaths.verifyChange.url, context: context)
            }else {
                let context = YXNavigatable(viewModel: YXChangeEmailViewModel(.bind, sourceVC: self, callBack: nil))
                self.viewModel.navigator.push(YXModulePaths.bindEmail.url, context:context)
            }
            
        } else if indexPath.section == 1 && indexPath.row == 0 { //更改密码
                //是否设置登录密码
            let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
            let loginPwd = (extendStatusBit & YXExtendStatusBitType.loginPwd.rawValue) == YXExtendStatusBitType.loginPwd.rawValue
            if loginPwd {
                let context = YXNavigatable(viewModel: YXChangePwdViewModel())
                //self.viewModel.navigator.push(YXModulePaths.changePwd.url, contex)
                self.viewModel.navigator.push(YXModulePaths.changePwd.url, context: context)
            } else {
                //设置登录密码
                setLoginPwdAlert()
            }
        }  else if indexPath.section == 1 && indexPath.row == 1 { //更改交易密码 //或注销账号
            if YXUserManager.canTrade() {
                if YXUserManager.shared().tradePassword() {
                    let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .old, funType: .change, oldPwd: "", pwd: "", captcha: "", vc: self))
                    self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
                }else {
                    YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { (_) in
                    }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: false, needToken: false)
                }
            } else {
                alertDeletAccount()
            }
           
            
        } else if indexPath.section == 1 && indexPath.row == 2 {//双重认证管理
            let context = YXNavigatable(viewModel: YXDoubleLoginSetViewModel())
            self.viewModel.navigator.push(YXModulePaths.doubleLoginSet.url, context: context)

        } else if indexPath.section == 1 && indexPath.row == 3 { //注销账号
            alertDeletAccount()

        } else if indexPath.section == 2 && indexPath.row == 0 { // facebook
            
            selectWithType(type: .typeFacebook)
            
        } else if indexPath.section == 2 && indexPath.row == 1 { //google
            
            selectWithType(type: .typeGooglePlus)
            
        } else if indexPath.section == 2 && indexPath.row == 2 {//wechat
            
            selectWithType(type: .typeWechat)
        } else if indexPath.section == 2 && indexPath.row == 3 {//apple
            
            selectWithType(type: .typeAppleAccount)
        } else if indexPath.section == 2 && indexPath.row == 4{
            selectWithType(type: .typeLine)
        }else if indexPath.section == 3 {
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "confirm_delete_account_tip"))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "confirm_delete_account"), style: .cancel, handler: { action in
                let requestModel = YXCancelAccountRequestModel.init()
                let request = YXRequest.init(request: requestModel)
                request.startWithBlock(success: { (respond) in
                    if respond.code == .success {
                        YXUserManager.shared().tokenFailureAction()
                    } else {
                        let subAlertView = YXAlertView(message: respond.msg ?? "")
                        subAlertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in
                            
                        }))
                        subAlertView.showInWindow()
                    }
                }, failure: { (request) in
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                })
            }))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "think_again"), style: .default, handler: { action in
                
                
                
            }))
            alertView.showInWindow()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0,indexPath.row == 1 {
            return 45
        }else  {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 49
        }
        if section == 1 {
            return 49
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.clipsToBounds = false
        v.backgroundColor = UIColor.clear
        //section == 0 有邮箱
        if section == 0{
            //【邮箱用于接收交易结单、找回密码等操作，请确保能正常接收邮件】
            let lab = QMUILabel()
            lab.text = YXLanguageUtility.kLang(key: "mine_email_tip")
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
                make.left.equalTo(12)
                make.bottom.equalToSuperview()
                make.right.equalTo(-12)
                make.height.equalTo(0.5)
            }
            
        }
        
        ///提审需要,暂时隐藏第三方入口
        /*
        if section == 1 {
            //【第三方帐号登录】
            let lab = QMUILabel()
            lab.text = YXLanguageUtility.kLang(key: "mine_login_tip")
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.textColor = QMUITheme().textColorLevel4()
            lab.numberOfLines = 0
            v.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.left.equalTo(v).offset(12)
                make.top.equalTo(v).offset(20)
                make.right.equalTo(v).offset(-18)
            }
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().separatorLineColor()
            v.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(12)
                make.top.equalToSuperview()
                make.right.equalTo(-12)
                make.height.equalTo(0.25)
            }
        }
         */
        
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

extension YXAccountViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.last ?? ASPresentationAnchor()
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = appleIDCredential.user
            var nickName: String = ""
            if let familyName = appleIDCredential.fullName?.familyName, let givenName = appleIDCredential.fullName?.givenName {
                nickName = givenName + familyName
                if (familyName as NSString).includeChinese() || (givenName as NSString).includeChinese() {
                    nickName = familyName + givenName
                }
            }
            let email = appleIDCredential.email ?? ""
             
            guard let identityToken = appleIDCredential.identityToken else { return }
            guard let authorizationCode = appleIDCredential.authorizationCode else { return }
            guard let identityTokenStr = String(data: identityToken, encoding: .utf8) else { return }
            guard let authorizationCodeStr = String(data: authorizationCode, encoding: .utf8) else { return }
            
            appleIDBind(identityTokenStr, user, authorizationCodeStr, email, nickName)
        }
    }
    
    func appleIDBind(_ identifyToken: String, _ appleUserId: String, _ appleCode: String, _ email: String, _ nickName: String) {
        let params = ["appleUserID": appleUserId, "appleCode": appleCode, "email": email, "identityToken": identifyToken, "nickName": nickName]
        viewModel.services.userService.request(.bindApple(params), response: viewModel.bindingResponse).disposed(by: disposeBag)
    }
}
