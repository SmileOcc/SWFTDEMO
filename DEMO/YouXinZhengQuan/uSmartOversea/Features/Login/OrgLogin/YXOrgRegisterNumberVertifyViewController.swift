//
//  YXOrgRegisterNumberVertifyViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
class YXOrgRegisterNumberVertifyViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXOrgRegisterNumberVertifyViewModel!

    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var titleLabel: AccountTipLabel = {
        let label = AccountTipLabel()
        label.text = YXLanguageUtility.kLang(key: "mine_authenticate")
        label.font = UIFont.systemFont(ofSize: uniSize(24))
        label.numberOfLines = 0
        return label
    }()
    
    //证件号
    var idCodeTextField: YXTipsTextField = {
        let textField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "org_register_code_plachold"), placeholder:"")
        if YXLanguageUtility.kLang(key: "org_register_code_plachold").contains("\n") {
            textField.tipsNumber = 2
        }
        return textField
    }()
    
    var nextBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindHUD()
        bindViewModel()
        initUI()
    }
    
    func bindViewModel() {

        
        self.viewModel.idCode.bind(to: idCodeTextField.textField.rx.text).disposed(by: disposeBag)
        idCodeTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.idCode).disposed(by: disposeBag)
        self.viewModel.idCodeValid?.bind(to: self.nextBtn.rx.isEnabled).disposed(by: disposeBag)
        
        idCodeTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.idCode.accept("")
            self?.nextBtn.isEnabled = false
        }).disposed(by: disposeBag)

        
        //MARK: - viewModel的响应
        
        self.nextBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            self.viewModel.services.loginService.request(.checkOrgRegistNumber(self.idCodeTextField.textField.text ?? ""), response: self.viewModel.checkResultResponse)
                .disposed(by: `self`.disposeBag)
            
        }).disposed(by: disposeBag)
        
        self.viewModel.checkAccountSubject.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            //去验证邮箱
            let context = YXNavigatable(viewModel: YXOrgRegisterEmailVertifyViewModel(vc: self.viewModel.sourceVC))
            self.viewModel.navigator.push(YXModulePaths.orgCheckRegisterEmail.url, context: context)
            
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        
        self.idCodeTextField.textField.becomeFirstResponder()
        
        view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(idCodeTextField)
        scrollView.addSubview(nextBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(30)
        }
        
        idCodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(56)

        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(idCodeTextField.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.width.equalTo(YXConstant.screenWidth - 30 * 2)
            make.height.equalTo(48)
        }
    }

}
