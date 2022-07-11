//
//  YXCheckPhoneViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

/*模块：绑定手机号  第1步
 请输入手机号码 */
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import YXKit
import TYAlertController

class YXCheckPhoneViewController: YXHKViewController, HUDViewModelBased,YXAreaCodeBtnProtocol {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXCheckPhoneViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    //地区手机码
    lazy var areaBtn: UIButton = self.buildAreaBtn()
    
    var phoneInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "login_phonePlaceHolder"), type: .phone)
        inputView.textField.font = .systemFont(ofSize: 18)
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        return inputView
    }()
    
    var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_next"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:16)
        btn.setDisabledTheme()
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func bindViewModel() {
        //phoneInputView.textField 绑定到 viewModel.phone
        phoneInputView.textField.rx.text.orEmpty.bind(to: self.viewModel.phone).disposed(by: disposeBag)
        //【下一步】响应
        nextBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject.onNext(.loading(nil, false))
            
            let areaCode = strongSelf.viewModel.code
            var phoneNumber = strongSelf.viewModel.phone.value as String
            phoneNumber = YXUserManager.safeDecrypt(string: phoneNumber.removePreAfterSpace())
            /*验证手机号是否注册
             check-phone/v1
             YXLoginAPI.checkPhone */
            strongSelf.viewModel.services.loginService.request(.checkPhone(areaCode, phoneNumber), response: strongSelf.viewModel.checkPhoneResponse).disposed(by: strongSelf.disposeBag)
            
            
        }).disposed(by: disposeBag)
        
        
        phoneInputView.textField.rx.text.orEmpty
            .asDriver()
            .map{$0.count > 0}
            .drive(nextBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        //点击cleanBtn，nextBtn不可操作
        phoneInputView.cleanBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.nextBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        areaBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.showAreaAlert()
        }).disposed(by: disposeBag)
        //已注册，已激活
        self.viewModel.registeredSubject.subscribe(onNext: { [weak self] _ in
            self?.phoneRegisteredAlert()
        }).disposed(by: disposeBag)
        
    }
    
    func initUI() {
        
        self.phoneInputView.textField.becomeFirstResponder()
        self.phoneInputView.textField.text = self.viewModel.phone.value
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(areaBtn)
        scrollView.addSubview(phoneInputView)
        scrollView.addSubview(nextBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        /// 【请输入手机号码】
        let tipLab = UILabel()
        tipLab.text = YXLanguageUtility.kLang(key: "login_inputPhoneTip")
        tipLab.numberOfLines = 0
        tipLab.font = UIFont.systemFont(ofSize: 28)
        tipLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { [weak self](make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(scrollView).offset(6)
            make.left.equalTo(scrollView).offset(18)
            make.right.equalTo(strongSelf.view).offset(-18)
            //make.height.equalTo(40)
        }
        //区号
        areaBtn.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(20)
            make.top.equalTo(tipLab.snp.bottom).offset(60)//20
            make.height.equalTo(35)
            make.width.equalTo(55)
        }
        //手机号 输入框
        phoneInputView.snp.makeConstraints { (make) in
            make.left.equalTo(areaBtn.snp.right).offset(8)
            make.centerY.equalTo(areaBtn)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(35)
        }
        //下一步
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(phoneInputView.snp.bottom).offset(65)
            make.left.equalTo(scrollView).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(44)
        }
        
        areaBtn.setTitle(String(format: "+%@", self.viewModel.code), for: .normal)
        //设置文字在左，图片在右
        setImageEdgeInsets()
        //横线
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        scrollView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-20)
            make.left.equalTo(scrollView).offset(20)
            make.height.equalTo(1)
            make.top.equalTo(phoneInputView.snp.bottom).offset(22)//10
        }
        
    }
    
    
    //【该手机号码已经注册\n是否登录？】弹框
    func phoneRegisteredAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_bindRegisterTip"))//login_phoneRegistered
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: { [weak alertView, weak self] action in
            
            alertView?.hide()
            self?.serviceAction()//展示 【联系客服】 弹框
        }))
        alertView.showInWindow()
    }
}

extension YXCheckPhoneViewController {
    //区号 弹框
    func showAreaAlert() {
        let hotAreaCount = YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry?.count ?? 0
        let viewHeight: CGFloat = CGFloat(hotAreaCount + 1) * 48.0
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: YXConstant.screenWidth, height: viewHeight + 34.0 ))
        
        let areaCodeView = YXAreaCodeAlertView(frame: CGRect(x: 20, y: 0, width: YXConstant.screenWidth - 40, height: viewHeight), selectCode: self.viewModel.code)
        bgView.addSubview(areaCodeView)
        
        let alertVc = TYAlertController(alert: bgView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade)
        alertVc!.backgoundTapDismissEnable = true
        areaCodeView.didSelected = { [weak alertVc, weak self, weak bgView] code in
            guard let `self` = self else { return }
            if code.count > 0 {
                self.phoneInputView.textField.becomeFirstResponder()
                self.viewModel.code = code
                self.areaBtn.setTitle(String(format: "+%@", code), for: .normal)
                self.setImageEdgeInsets()
                alertVc?.dismissViewController(animated: true)
            } else {
                
                //alertVc?.dismissViewController(animated: false)
                alertVc?.dismissComplete = {[weak self] in
                    self?.showMoreAreaAlert()
                }
                bgView?.hide()
            }
            
        }
        
        self.present(alertVc!, animated: true, completion: nil)
        
    }
    
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            self.phoneInputView.textField.becomeFirstResponder()
            self.viewModel.code = code
            self.areaBtn.setTitle(String(format: "+%@", code), for: .normal)
            self.setImageEdgeInsets()
                        
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.push(YXModulePaths.areaCodeSelection.url, context: context)
    }
}
