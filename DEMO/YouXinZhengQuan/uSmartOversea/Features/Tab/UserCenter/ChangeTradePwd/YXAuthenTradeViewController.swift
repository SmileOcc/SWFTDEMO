//
//  YXAuthenTradeViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAuthenTradeViewController: YXHKViewController, HUDViewModelBased{

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangeTradePwdViewModel!
    
    var passWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_tpwd_placeHolder"))
        field.selectStyle = .none
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    var confirmBtn:QMUIButton = {
        let btn = QMUIButton()
         btn.setTitle(YXLanguageUtility.kLang(key: "common_next"), for: .normal)
         btn.setSubmmitTheme()
         return btn
    }()
    
    var forgotBtn:QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_forgetPwd"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
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
        
        scrollView.addSubview(passWordTextField)
        scrollView.addSubview(confirmBtn)
        scrollView.addSubview(forgotBtn)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let titleLab = UILabel()
        titleLab.font = .systemFont(ofSize: 20)
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = YXLanguageUtility.kLang(key: "mine_retpwd_title")
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
            //make.height.equalTo(16)
        }
        
        passWordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(descLab.snp.bottom).offset(40)
        }
        
        forgotBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-16)
            make.top.equalTo(passWordTextField.snp.bottom).offset(20)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(forgotBtn.snp.bottom).offset(177)
            make.size.left.equalTo(passWordTextField)
        }
        
    }
    
    func bindViewModel()  {
        
        forgotBtn.rx.tap.subscribe {[weak self] (_) in
            
            if YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false {
                let context = YXNavigatable(viewModel: YXOrgRegisterNumberVertifyViewModel(vc: self?.viewModel.vc))
                self?.viewModel.navigator.push(YXModulePaths.orgCheckRegisterNumber.url, context: context)

            } else {
                
                let context = YXNavigatable(viewModel: YXAuthenticateViewModel(type: 1, vc: self?.viewModel.vc))
                self?.viewModel.navigator.push(YXModulePaths.authenticate.url, context: context)
            }
        }.disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe {[weak self] (_) in
            self?.viewModel.hudSubject.onNext(.loading("", false))
            let pwd = YXUserManager.safeDecrypt(string: self?.viewModel.pwdRelay.value ?? "")
            self?.viewModel.services.userService.request(.checkTradePwd(pwd), response: self?.viewModel.checkPwdResponse).disposed(by: self!.disposeBag)
        }.disposed(by: disposeBag)
        
        passWordTextField.textField.rx.text.orEmpty.asObservable()
            .map { $0.count > 0 }
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        passWordTextField.textField.rx.text.orEmpty
            .asObservable()
            .bind(to: self.viewModel.pwdRelay)
            .disposed(by: disposeBag)
        
        self.viewModel.pwdRelay
            .bind(to: passWordTextField.textField.rx.text.orEmpty)
            .disposed(by: disposeBag)
        
        passWordTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.pwdRelay.accept("")
            self?.confirmBtn.isEnabled = false
        }).disposed(by: disposeBag)

        
        viewModel.checkSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            let pwd = self.viewModel.pwdRelay.value
            let context = YXNavigatable(viewModel:YXSetTradePwdViewModel(.update, oldPwd: pwd, captcha: "", sourceVC: self.viewModel.vc,successBlock: nil))
            self.viewModel.navigator.push(YXModulePaths.setTradePwd.url, context: context)
        }).disposed(by: disposeBag)
        
        viewModel.pwdLockSubject.subscribe { [weak self] msg in
            self?.alert(msg: msg.element ?? "")
        }.disposed(by: disposeBag)
        viewModel.pwdErrorSubject.subscribe {[weak self] msg in
            self?.alert(msg: msg.element ?? "")
        }.disposed(by: disposeBag)

    }
    
    func alert(msg:String) {
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
            
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
}

extension YXAuthenTradeViewController:UITextFieldDelegate{
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
