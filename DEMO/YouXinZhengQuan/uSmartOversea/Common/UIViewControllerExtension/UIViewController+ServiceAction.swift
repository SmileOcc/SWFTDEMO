//
//  UIViewController+ServiceAction.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import TYAlertController

var kServiceVCKey = 888
//MARK: 联系客服
extension UIViewController {
    
    fileprivate var serviceVC: TYAlertController? {
        set {
            objc_setAssociatedObject(self, &kServiceVCKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &kServiceVCKey) as? TYAlertController {
                return rs
            }
            return TYAlertController()
        }
    }
    
    func serviceAction() {
        let customerModel = YXGlobalConfigManager.shareInstance.customerModel
        switch customerModel?.showType {
        case 1://只展示电话
            self.servicePhoneAction()
        case 2://只展示在线客服
            self.serviceOnlineAction()
        case 3://都展示
            self.serviceVC = getServiceVC()
            if let vc = self.serviceVC {
                self.present(vc, animated: true, completion: nil)
            }
        default:
            if YXUserManager.curLanguage() == .HK {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_failed"))
            } else {
                self.serviceOnlineAction()
            }
        }
    }
    
    
    @objc fileprivate func servicePhoneAction() {
        let customer = YXGlobalConfigManager.shareInstance.customerModel
        if customer?.showType == 3 {
//            serviceVC?.dismiss(animated: true) {
//                self.serviceVC = nil
//            }
            self.serviceVC?.dismissViewController(animated: true)
            self.serviceVC?.dismissComplete = { [weak self] in
                self?.serviceVC = nil
            }
        }
        
        let telephoneNumber = customer?.customerTel ?? ""
        let str = "tel:\(telephoneNumber)"
        let application = UIApplication.shared
        let URL = NSURL(string: str)
        
        if let URL = URL {
            application.open(URL as URL, options: [:], completionHandler: { success in
                //OpenSuccess=选择 呼叫 为 1  选择 取消 为0
            })
        }
    }
    
    
    @objc fileprivate func serviceOnlineAction() {
        let callBack: ()-> Void = {
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                if root.window?.rootViewController == nil {
                    root.initRootViewController(navigator: navigator)
                }
                let context = YXNavigatable(viewModel: YXOnlineServiceViewModel(dictionary: [:]))
                navigator.push(YXModulePaths.onlineService.url, context: context)
            }
        }
        
        let customer = YXGlobalConfigManager.shareInstance.customerModel
        if customer?.showType == 3 {
            self.serviceVC?.dismiss(animated: true, completion: {[weak self] in
                self?.serviceVC?.dismissComplete()
                callBack()
            })
        } else {
            callBack()
        }
    }
    
    @objc fileprivate func getServiceVC() -> TYAlertController {
        let width:CGFloat = YXConstant.screenWidth - 40
        let left:CGFloat = 20
        let backgroundView = UIView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 121 + 34))
        
        let serviceView = UIView.init(frame: CGRect(x: left, y: 0, width: width, height: 121))
        serviceView.backgroundColor = UIColor.white
        serviceView.layer.cornerRadius = 30
        serviceView.clipsToBounds = true
        backgroundView.addSubview(serviceView)
        
        let customerModel = YXGlobalConfigManager.shareInstance.customerModel
        //联系电话
        let phone = UILabel()
        phone.text = YXLanguageUtility.kLang(key: "mine_service_phone")
        phone.font = UIFont.systemFont(ofSize: 16)
        phone.textColor  = QMUITheme().themeTextColor()
        phone.frame = CGRect(x: 0, y: 10, width: width, height: 22)
        phone.textAlignment = NSTextAlignment.center
        serviceView.addSubview(phone)
        
        let phoneTime = UILabel()
        phoneTime.text = customerModel?.telTime
        phoneTime.font = UIFont.systemFont(ofSize: 12)
        phoneTime.textColor  = QMUITheme().themeTintColor().qmui_color(withAlpha: 0.4, backgroundColor: UIColor.clear)
        phoneTime.frame = CGRect(x: 0, y: 35, width: width, height: 17)
        phoneTime.textAlignment = NSTextAlignment.center
        serviceView.addSubview(phoneTime)
        
        let phoneBtn = UIButton(type: .custom)
        phoneBtn.frame = CGRect(x: 0, y: 0, width: width, height: 60)
        phoneBtn.backgroundColor = UIColor.clear
        phoneBtn.addTarget(self, action: #selector(servicePhoneAction), for: .touchUpInside)
        serviceView.addSubview(phoneBtn)
        
        let lineView = UIView.init(frame: CGRect(x: 0, y: 60, width: width, height: 1))
        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#979797")?.qmui_color(withAlpha: 0.2, backgroundColor: UIColor.clear)
        serviceView.addSubview(lineView)
        //联系在线客服
        let onLineService = UILabel()
        onLineService.text = YXLanguageUtility.kLang(key: "mine_contact_online_service")
        onLineService.font = UIFont.systemFont(ofSize: 16)
        onLineService.textColor  = QMUITheme().themeTextColor()
        onLineService.frame = CGRect(x: 0, y: 70, width: width, height: 22)
        onLineService.textAlignment = NSTextAlignment.center
        serviceView.addSubview(onLineService)
        
        let onLineServiceTime = UILabel()
        onLineServiceTime.text = customerModel?.onlineTime
        onLineServiceTime.font = UIFont.systemFont(ofSize: 12)
        onLineServiceTime.textColor  = QMUITheme().themeTintColor().qmui_color(withAlpha: 0.4, backgroundColor: UIColor.clear)
        onLineServiceTime.frame = CGRect(x: 0, y: 95, width: width, height: 17)
        onLineServiceTime.textAlignment = NSTextAlignment.center
        serviceView.addSubview(onLineServiceTime)
        
        let onLineServiceBtn = UIButton(type: .custom)
        onLineServiceBtn.frame = CGRect(x: 0, y: 61, width: width, height: 60)
        onLineServiceBtn.backgroundColor = UIColor.clear
        onLineServiceBtn.addTarget(self, action: #selector(serviceOnlineAction), for: .touchUpInside)
        serviceView.addSubview(onLineServiceBtn)
        
        guard let serviceVC = TYAlertController(alert: backgroundView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade) else {
            return TYAlertController()
        }
        serviceVC.backgoundTapDismissEnable = true
        serviceVC.dismissComplete = { [weak self] in
            print("serviceVC dismissComplete")
            self?.serviceVC = nil
        }
        return serviceVC
    }
}
