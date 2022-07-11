//
//  YXAuthenticateViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：重置交易密码 第1步
 请验证身份 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
import TYAlertController

class YXAuthenticateViewController: YXHKViewController, HUDViewModelBased  {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXAuthenticateViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
  //  mine_certificate
    
//    var certificateInputView: YXInputView = {
//        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "mine_certificate"), type: .normal)
//        return inputView
//    }()
    
    var inputTextField : YXTipsTextField = {
        let field = YXTipsTextField(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_certificate"))
        field.selectStyle = .none
        return field
    }()
    
    var nextBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_next"), for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(nextBtn)
        scrollView.addSubview(inputTextField)
        scrollView.addSubview(nextBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        
        let titleLab = UILabel()
        titleLab.font = .systemFont(ofSize: 20)
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = YXLanguageUtility.kLang(key: "mine_authenticate")
        scrollView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(24)
        }
        
        let descLab = UILabel()
        descLab.font = .systemFont(ofSize: 14)
        descLab.numberOfLines = 2
        descLab.textColor = QMUITheme().textColorLevel3()
        descLab.text = YXLanguageUtility.kLang(key: "mine_account_certificate")
        scrollView.addSubview(descLab)
        
        descLab.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.right.equalTo(self.view.snp.right).offset(-16)
        }
        
        let tipLab = UILabel()
        tipLab.font = .systemFont(ofSize: 12)
        tipLab.textColor = QMUITheme().textColorLevel1()
        tipLab.text = YXLanguageUtility.kLang(key: "mine_id_Number_tip")
        scrollView.addSubview(tipLab)
        
        tipLab.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(inputTextField.snp.top).offset(-4)
        }
        inputTextField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(descLab.snp.bottom).offset(40)
        }
        
        
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(inputTextField.snp.bottom).offset(210)
            make.size.left.equalTo(inputTextField)
        }
        
        
//
//        let horSpace = uniHorLength(18)
//        //【请验证身份】
//        let tipLab = UILabel()
//        tipLab.text = YXLanguageUtility.kLang(key: "mine_authenticate")
//        tipLab.numberOfLines = 0
//        tipLab.font = UIFont.systemFont(ofSize: 28)
//        scrollView.addSubview(tipLab)
//        tipLab.snp.makeConstraints { [weak self](make) in
//            guard let strongSelf = self else {return}
//            make.top.equalTo(scrollView).offset(5)
//            make.left.equalTo(scrollView).offset(horSpace)
//            make.right.equalTo(strongSelf.view).offset(-horSpace)
//        }
//
//        let tipLab2 = UILabel()
//        tipLab2.text = YXLanguageUtility.kLang(key: "mine_account_certificate")
//        tipLab2.font = UIFont.systemFont(ofSize: 14)
//        tipLab2.textColor = QMUITheme().textColorLevel3()
//        tipLab2.numberOfLines = 0
//        scrollView.addSubview(tipLab2)
//        tipLab2.snp.makeConstraints { (make) in
//            make.top.equalTo(tipLab.snp.bottom).offset(4)
//            make.left.equalTo(scrollView).offset(horSpace)
//            make.right.equalTo(self.view).offset(-horSpace)
//        }
        
//        // 【大陆身份证】
//        let certificateLab = QMUILabel()
//        certificateLab.font = UIFont.systemFont(ofSize: 16)
//        //1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
//        switch self.viewModel.type {
//        case 1:
//            certificateLab.text = YXLanguageUtility.kLang(key: "mine_cn_idcard")
//        case 2:
//            certificateLab.text = YXLanguageUtility.kLang(key: "mine_hk_idcard")
//        case 3:
//            certificateLab.text = YXLanguageUtility.kLang(key: "mine_passport")
//        default:
//            certificateLab.text = YXLanguageUtility.kLang(key: "mine_hk_permanent_idcard")
//        }
//        scrollView.addSubview(certificateLab)
//        certificateLab.sizeToFit()
//        let w = certificateLab.qmui_width
//        certificateLab.snp.makeConstraints { (make) in
//            make.left.equalTo(scrollView).offset(horSpace)
//            make.top.equalTo(tipLab2.snp.bottom).offset(uniVerLength(60))
//            make.height.equalTo(22)
//            make.width.equalTo(w)
//        }
//
//        certificateInputView.snp.makeConstraints { (make) in
//            //make.left.equalTo(certificateLab.snp.right).offset(36)
//            make.leading.equalToSuperview().offset(horSpace)
//            //make.centerY.equalTo(certificateLab)
//            make.top.equalTo(certificateLab.snp.bottom).offset(uniVerLength(38))
//            make.trailing.equalTo(self.view).offset(-18)
//            make.height.equalTo(35)
//        }
//      //横线
//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().separatorLineColor()
//        scrollView.addSubview(lineView)
//
//        lineView.snp.makeConstraints { (make) in
//            make.trailing.equalTo(self.view).offset(-horSpace)
//            make.leading.equalToSuperview().offset(horSpace)
//            make.height.equalTo(1)
//            make.top.equalTo(certificateInputView.snp.bottom).offset(uniVerLength(10))
//        }
//
//        nextBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(certificateInputView.snp.bottom).offset(uniVerLength(70))
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalTo(self.view).offset(-20)
//            make.height.equalTo(44)
//        }
        
//        serviceBtn.snp.makeConstraints { (make) in
//            make.centerX.equalTo(nextBtn)
//            make.top.equalTo(scrollView).offset(YXConstant.screenHeight-YXConstant.navBarHeight()-90)
//            make.width.equalTo(110)
//            make.height.equalTo(40)
//        }
    }
    
    func bindViewModel() {
        //【下一步】的响应
        nextBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.loading("", false))
            /* 校验身份证
             verify-identify-id/v1 */
            let certificate:String = (strongSelf.inputTextField.textField.text ?? "").removePreAfterSpace()
            strongSelf.viewModel.services.userService.request(.checkId(certificate), response: strongSelf.viewModel.checkIdResponse).disposed(by: strongSelf.disposeBag)
            
        }).disposed(by: disposeBag)
        
        inputTextField.textField.rx.text.orEmpty
            .asDriver()
            .map{$0.count > 0}
            .drive(nextBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        /* 校验身份证
         verify-identify-id/v1  成功的处理: */
        viewModel.checkSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            //跳转到 【请验证手机号码】
            let context = YXNavigatable(viewModel: YXVerifyEmailViewModel(vc: strongSelf.viewModel.vc))
            strongSelf.viewModel.navigator.push(YXModulePaths.verifyEmail.url, context: context)
        }).disposed(by: disposeBag)
    }
    
    func backAlert() {
//        self.back()
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_giveup_forget"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_no"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_yes"), style: .default, handler: {[weak alertView, weak self] action in
            guard let `self` = self else { return }

            alertView?.hide()
            self.back()
        }))
        alertView.showInWindow()
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        backAlert()
        return false
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
//        for vc in self.navigationController?.viewControllers ?? [] {
//            if let viewController = vc as? YXChangeTradePwdViewController {
//                if viewController.viewModel.funType == YXTradePwdFunType.change {
//                    self.navigationController?.popToViewController(vc, animated: true)
//                    return
//                }
//            }
//        }
//
//        if self.viewModel.vc != nil && self.navigationController?.viewControllers.contains(self.viewModel.vc!) ?? false {
//            self.navigationController?.popToViewController(self.viewModel.vc!, animated: true)
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
}
