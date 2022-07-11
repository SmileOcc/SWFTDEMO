//
//  YXChangePwdViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：修改登录密码
 修改登录密码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXChangePwdViewController: YXHKViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    var viewModel: YXChangePwdViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    

    var oldPassWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "user_oldPwdPlaceHolder"))
        field.selectStyle = .none
        return field
    }()
    
    var newPassWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "login_pwd_placeHolder"))
        field.selectStyle = .none
        return field
    }()
    
    var rePassWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "reset_pwd_placeholder"))
        field.selectStyle = .none
        return field
    }()
    
    lazy var subErrorTipLabel : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "not_match")
        return lab
    }()

    
    var confirmBtn:QMUIButton = {
        let btn = QMUIButton()
         btn.setTitle(YXLanguageUtility.kLang(key: "login_change_pwd"), for: .normal)
         btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
         btn.setSubmmitTheme()
         return btn
    }()
   
    
    var fogotLabel: UILabel = {
        let lab = UILabel.init()
        lab.text = YXLanguageUtility.kLang(key: "fogot_pwd")
        lab.textAlignment = .right
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    var fogotBtn:QMUIButton = {
        let btn = QMUIButton()
//         btn.setTitle(YXLanguageUtility.kLang(key: "fogot_pwd"), for: .normal)
//         btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//         btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
//         btn.sizeToFit()
         return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
        
        let titleLab = UILabel(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 200, height: 40))
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = YXLanguageUtility.kLang(key: "user_changePwdTip")
        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.textAlignment = .center
        self.navigationItem.titleView = titleLab
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(oldPassWordTextField)
        scrollView.addSubview(newPassWordTextField)
        scrollView.addSubview(rePassWordTextField)
        scrollView.addSubview(confirmBtn)
        scrollView.addSubview(subErrorTipLabel)
        scrollView.addSubview(fogotLabel)
        scrollView.addSubview(fogotBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        //当前密码
        let oldPwdLab = UILabel()
        oldPwdLab.text = YXLanguageUtility.kLang(key: "login_curPwd_tip")
        oldPwdLab.font = UIFont.systemFont(ofSize: 12)
        oldPwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(oldPwdLab)
        oldPwdLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        oldPassWordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(oldPwdLab.snp.bottom).offset(4)
            make.width.equalTo(YXConstant.screenWidth - 32)
            make.height.equalTo(48)
        }
        
        //新密码
        let newPwdLab = UILabel()
        newPwdLab.text = YXLanguageUtility.kLang(key: "login_newPwd_tip")
        newPwdLab.font = UIFont.systemFont(ofSize: 12)
        newPwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(newPwdLab)
        newPwdLab.snp.makeConstraints { (make) in
            make.top.equalTo(oldPassWordTextField.snp.bottom).offset(14)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        newPassWordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(newPwdLab.snp.bottom).offset(4)
            make.width.equalTo(YXConstant.screenWidth - 32)
            make.height.equalTo(48)
        }
        
        //再次新密码
        let rePwdLab = UILabel()
        rePwdLab.text = YXLanguageUtility.kLang(key: "login_rePwd_tip")
        rePwdLab.font = UIFont.systemFont(ofSize: 12)
        rePwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(rePwdLab)
        rePwdLab.snp.makeConstraints { (make) in
            make.top.equalTo(newPassWordTextField.snp.bottom).offset(14)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        rePassWordTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(rePwdLab.snp.bottom).offset(4)
            make.width.equalTo(YXConstant.screenWidth - 32)
            make.height.equalTo(48)
        }
        
        subErrorTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rePassWordTextField.snp.left)
            make.top.equalTo(rePassWordTextField.snp.bottom).offset(4)
        }
        
        fogotLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(200)
            make.top.equalTo(rePassWordTextField.snp.bottom).offset(16)
            make.right.equalTo(rePassWordTextField)
        }
        
        fogotBtn.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(120)
            make.top.equalTo(rePassWordTextField.snp.bottom).offset(16)
            make.right.equalTo(rePassWordTextField)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.centerX.size.equalTo(rePassWordTextField)
            make.top.equalTo(fogotBtn.snp.bottom).offset(32)
        }
    }

    func bindViewModel() {
        

        oldPassWordTextField.textField.rx.controlEvent(.editingDidEnd).subscribe(onNext:{ (_) in
            //self?.oldPassWordTextField.hiddenTip()
        }).disposed(by: disposeBag)
        
        oldPassWordTextField.textField.rx.text.orEmpty.asObservable().bind(to: self.viewModel.oldPassword).disposed(by: disposeBag)
        rePassWordTextField.textField.rx.text.orEmpty.asObservable().bind(to: self.viewModel.password).disposed(by: disposeBag)
        
        self.viewModel.handleInput(oldPassword:oldPassWordTextField.textField.rx.text.orEmpty.asObservable(),
                                   passWord:newPassWordTextField.textField.rx.text.orEmpty.asObservable(),
                                   subPassword:rePassWordTextField.textField.rx.text.orEmpty.asObservable())
        
        self.viewModel.everythingValid?.bind(to: confirmBtn.rx.isEnabled).disposed(by: disposeBag)
//        self.viewModel.passWordValid?.bind(to: resetView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.equePassWordValid?.bind(to:subErrorTipLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.resetSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.resetSuccess()
        }).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.viewModel.resetPwdRequest()
        }).disposed(by: disposeBag)
        
        fogotBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.viewModel.gotoFogetPwd()
        }).disposed(by: disposeBag)
        
    }
    
    func resetSuccess()  {
        
        self.view.endEditing(true)
        
        let alerVC = YXAlertViewFactory.changePwdSuccessAlert { [weak self] in
            for vc in self?.navigationController?.viewControllers ?? [] {
                if vc is YXUserCenterViewController {
                    self?.navigationController?.popToViewController(vc, animated: true)
                }
            }
        } relogin: { [weak self] in
            self?.navigationController?.popToRootViewController(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name("goLogin"), object: nil)
        }

        self.present(alerVC, animated: true, completion: nil)
    }
}
