//
//  YXDoubleLoginAuthSetVC.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/15.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

class YXDoubleLoginAuthSetVC: YXHKViewController,HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXDoubleLoginSetViewModel!

    
    lazy var openSwitch : UISwitch = {
       let switchView = UISwitch()
        switchView.onTintColor = QMUITheme().mainThemeColor()
//        switchView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
       return switchView
    }()
    
    lazy var openBtn : QMUIButton = {
       let btn = QMUIButton()
       return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI(){
        
        title = YXLanguageUtility.kLang(key: "mine_auth_login_set_title")
        
        let tipsLab = UILabel()
        tipsLab.text = YXLanguageUtility.kLang(key: "mine_auth_login_set_tips")
        tipsLab.textColor = QMUITheme().textColorLevel1()
        tipsLab.font = .systemFont(ofSize: 14)
        tipsLab.textAlignment = .left
        view.addSubview(tipsLab)
        
        view.addSubview(openSwitch)
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        view.addSubview(lineView)
        
        let descLab = UILabel()
        descLab.text = YXLanguageUtility.kLang(key: "mine_auth_login_set_desc")
        descLab.font = .systemFont(ofSize: 14)
        descLab.textAlignment = .left
        descLab.numberOfLines = 0
        descLab.textColor = QMUITheme().textColorLevel3()
        view.addSubview(descLab)
        
        tipsLab.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(25 + YXConstant.navBarHeight())
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        
        openSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(tipsLab)
            make.right.equalToSuperview().offset(-16)
        }
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(openSwitch.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(0.5)
            make.right.equalToSuperview().offset(-16)
        }
        descLab.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(12)
            make.left.right.equalTo(lineView)
        }
        
        view.addSubview(openBtn)
        openBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(tipsLab)
            make.right.left.equalTo(openSwitch)
            make.height.equalTo(50)
        }
        
    }
    
    func bindViewModel(){
    
//        openSwitch.rx.isOn.subscribe{[weak self] _ in
//            self.alertConfirm()
//        }.disposed(by:disposeBag)
        
        let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
        let isOpen = (extendStatusBit & YXExtendStatusBitType.auth2login.rawValue) == YXExtendStatusBitType.auth2login.rawValue
        openSwitch.isOn = isOpen
        self.viewModel.optionTyp = isOpen ? 0 : 1
        openBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            if self.viewModel.optionTyp == 0 {
                self.viewModel.switch2FARequest()
            }else {
                self.alertConfirm()
            }
        }
        
        self.viewModel.didSetSubject.subscribe(onNext: { [weak self] res in
            guard let `self` = self else { return }
            if res == true {
                self.openSwitch.isOn = !self.openSwitch.isOn
                self.viewModel.optionTyp = self.openSwitch.isOn ? 0 : 1
                YXUserManager.getUserInfo(complete: nil)
            }
        }).disposed(by: disposeBag)

    }
    
    func alertConfirm() {
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "mine_auth_login_set_alter_titel"), message: YXLanguageUtility.kLang(key: "mine_auth_login_set_alter"))
        let cancleAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) {[weak alertView] _ in
            alertView?.hideInController()
        }
        let confirmAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .fullDefault) {[weak self,weak alertView] _ in
            alertView?.hideInController()
            self?.viewModel.switch2FARequest()
        }
        alertView.addAction(cancleAction)
        alertView.addAction(confirmAction)
        alertView.show(in: self)
    }
}
