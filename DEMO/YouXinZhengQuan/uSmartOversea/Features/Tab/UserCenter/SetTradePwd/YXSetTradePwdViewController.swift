//
//  YXYXFristSetTradePwdViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit


class YXSetTradePwdViewController:YXHKViewController, HUDViewModelBased {

  
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXSetTradePwdViewModel!
    
    
    var passWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_tpwd_placeHolder"))
        field.selectStyle = .none
        field.textField.keyboardType = .numberPad
        return field
    }()
    var rePassWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_tpwd_rePlaceHolder"))
        field.selectStyle = .none
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    var confirmBtn:QMUIButton = {
        let btn = QMUIButton()
         btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
         btn.setSubmmitTheme()
         return btn
    }()
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
        // Do any additional setup after loading the view.
    }
    

    func initUI()  {
        self.view.addSubview(scrollView)
        
        passWordTextField.textField.delegate = self
        rePassWordTextField.textField.delegate = self
        
        scrollView.addSubview(passWordTextField)
        scrollView.addSubview(rePassWordTextField)
        scrollView.addSubview(confirmBtn)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let titleLab = UILabel()
        titleLab.font = .systemFont(ofSize: 20)
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = self.viewModel.type.title()
        titleLab.numberOfLines = 2
        scrollView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.width.equalTo(YXConstant.screenWidth - 32)
            make.height.greaterThanOrEqualTo(24)
        }
        
        let descLab = UILabel()
        descLab.font = .systemFont(ofSize: 14)
        descLab.textColor = QMUITheme().textColorLevel3()
        descLab.text = YXLanguageUtility.kLang(key: "mine_tpwd_tip")
        descLab.numberOfLines = 2
        scrollView.addSubview(descLab)
        
        descLab.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.width.equalTo(YXConstant.screenWidth - 32)
            make.height.greaterThanOrEqualTo(16)

//            make.height.equalTo(16)
        }
        
        passWordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(descLab.snp.bottom).offset(40)
        }
        
        rePassWordTextField.snp.makeConstraints { (make) in
            make.left.size.equalTo(passWordTextField)
            make.top.equalTo(passWordTextField.snp.bottom).offset(24)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(rePassWordTextField.snp.bottom).offset(141)
            make.size.left.equalTo(passWordTextField)
        }
        
    }
    
    func bindViewModel()  {
        viewModel.passwordRelay.bind(to: passWordTextField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.rePasswordRelay.bind(to: rePassWordTextField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        
        passWordTextField.textField.rx.text.orEmpty.asObservable().bind(to: viewModel.passwordRelay).disposed(by: disposeBag)
        rePassWordTextField.textField.rx.text.orEmpty.asObservable().bind(to: viewModel.rePasswordRelay).disposed(by: disposeBag)
        
        viewModel.everythingValid?.bind(to: confirmBtn.rx.isEnabled).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe {[weak self] (_) in
            guard let `self` = self else { return }
            if self.viewModel.rePasswordRelay.value != self.viewModel.passwordRelay.value{
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "tpwd_not_match"), false))
                return
            }
            self.viewModel.hudSubject.onNext(.loading("", false))
            if self.viewModel.type == .reSet {
                let captcha = self.viewModel.captcha
                let pwd = YXUserManager.safeDecrypt(string:self.viewModel.rePasswordRelay.value)
                self.viewModel.services.userService.request(.resetTradePwd(pwd, captcha),response: self.viewModel.resetPwdResponse).disposed(by: self.disposeBag)
            }else if self.viewModel.type == .update {
                
                let oldPwd = YXUserManager.safeDecrypt(string: self.viewModel.oldPwd)
                let pwd = YXUserManager.safeDecrypt(string:self.viewModel.rePasswordRelay.value)
                self.viewModel.services.userService.request(.changeTradePwd(oldPwd, pwd), response: self.viewModel.changePwdResponse).disposed(by: self.disposeBag)
            }else if self.viewModel.type == .set {
                let pwd = YXUserManager.safeDecrypt(string:self.viewModel.rePasswordRelay.value)
                
                if let brokerNo =  self.viewModel.brokerNo {
                    self.viewModel.services.userService.request(.setTradePwd(pwd,brokerNo), response: self.viewModel.setTradePwdResponse).disposed(by: YXUserManager.shared().disposeBag)
                } else {
                    self.viewModel.services.userService.request(.setTradePwd(pwd, YXUserManager.shared().curBroker.brokerNo()), response: self.viewModel.setTradePwdResponse).disposed(by: YXUserManager.shared().disposeBag)
                }
            }
        }.disposed(by: disposeBag)

        viewModel.pwdSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            self.viewModel.successBlock?(self.viewModel.rePasswordRelay.value)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                if self.viewModel.sourceVC != nil {
                    self.navigationController?.popToViewController(self.viewModel.sourceVC!, animated: true)
                }else {
                    
                }
            }
        }).disposed(by: disposeBag)
        
    }
    
    func confimeAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "discard_modify_your_trade_password"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_no"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_yes"), style: .default, handler: {[weak alertView,weak self] action in
            alertView?.hide()
            guard let `self` = self else { return }
            self.back()
        }))
        alertView.showInWindow()
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        confimeAlert()
        return false
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension YXSetTradePwdViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text as NSString?
        let str2 = str?.replacingCharacters(in: range, with: string)
       
            if str2?.count ?? 0 > 6{
                return false
            }
            if string.count > 0 && !(str2?.isAllNumber() ?? false) {
                return false
            }
        return true
    }
}
