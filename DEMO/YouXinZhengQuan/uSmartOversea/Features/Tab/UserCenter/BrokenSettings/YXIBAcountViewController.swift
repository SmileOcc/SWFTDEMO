//
//  YXIBAcountViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class YXIBAcountViewController: YXHKViewController ,HUDViewModelBased{

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXIBAcountViewModel!
    let accountView = YXIBAcountView()
    let pwdView = YXIBAcountView()
    
    lazy var selectBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("Select", for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    var sendCaptchaView : YXIBCaptchaView = {
        let view = YXIBCaptchaView(frame: UIScreen.main.bounds)
        view.titleLabel.text = "Enter Verification Code"
        view.descLabel.text = "The verification code has been sent to \(YXUserManager.shared().curLoginUser?.email ?? "")"
        return view
    }()
    
    var sendAlertVC:TYAlertController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindView()
        bindHUD()
        // Do any additional setup after loading the view.
    }
    
    func initUI()  {
        
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.title = "IB Account"
        
        accountView.setText("Account", detail: "")
        pwdView.setText("Initial Password", detail: "")
        
        
        view.addSubview(scrollView)
      
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        scrollView.addSubview(accountView)
        scrollView.addSubview(pwdView)
        scrollView.addSubview(selectBtn)
        
        accountView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.height.equalTo(50)
            make.right.equalTo(self.view)
        }
        
        pwdView.snp.makeConstraints { (make) in
            make.top.equalTo(accountView.snp.bottom)
            make.left.equalTo(0)
            make.size.equalTo(accountView)
        }
        
        selectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(pwdView.snp.bottom).offset(24)
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(50)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        scrollView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view.snp.right).offset(-16)
            make.height.equalTo(0.5)
            make.top.equalTo(selectBtn.snp.bottom).offset(33)
        }
        
      //  Friendly reminder：
        let reminLabel = UILabel()
        reminLabel.text = "Friendly reminder："
        reminLabel.font = .systemFont(ofSize: 16)
        reminLabel.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(reminLabel)
        reminLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(lineView.snp.bottom).offset(23)
            make.size.equalTo(CGSize.init(width: 140, height: 22))
        }
        
        let paragraphView1 = YXParagraphView()
        paragraphView1.numLabel.text = "1."
        let text = "Click the link https://www.ibkr.com.cn/sso/Login to access the login page. If you are unable to click it, please copy and paste the link into your browser’s address bar. "
        let websit = "https://www.ibkr.com.cn/sso/Login"
        let arrt = NSMutableAttributedString.init(string: text)
        arrt.yy_font = .systemFont(ofSize: 14)
        arrt.yy_color = QMUITheme().textColorLevel3()
        let rang = NSRange.init(text.range(of: websit)!, in: text)
        
        arrt.yy_setTextHighlight(rang, color: QMUITheme().mainThemeColor(), backgroundColor: nil) {[weak self] (v, str, rang, rect) in
            guard let `self` = self else { return }
            let context = YXWebViewModel.init(dictionary: [YXWebViewModel.kWebViewModelUrl:websit])
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: context)
        }
        paragraphView1.paragraphLabel.attributedText = arrt
        scrollView.addSubview(paragraphView1)
        paragraphView1.snp.makeConstraints { (make) in
            make.top.equalTo(reminLabel.snp.bottom).offset(12)
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
        }
        
        let paragraphView2 = YXParagraphView()
        paragraphView2.numLabel.text = "2."
        paragraphView2.paragraphLabel.text = "If you already changed your initial password after opening an account, please use the new password to login into the Interactive Broker's backstage system."
        scrollView.addSubview(paragraphView2)
        paragraphView2.snp.makeConstraints { (make) in
            make.top.equalTo(paragraphView1.snp.bottom).offset(12)
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
        }
       NSObject.addClassNames(toWhitelist: [NSStringFromClass(TYAlertController.self)])
       sendAlertVC = TYAlertController(alert: sendCaptchaView, preferredStyle: .alert, transitionAnimation: .scaleFade)
    }
    
    func bindView()  {
        selectBtn.rx.tap.subscribe {[weak self] (_) in
            self?.alertSendCaptch()
            self?.sendCaptchaView.inputTextField.textField.becomeFirstResponder()
        }.disposed(by: disposeBag)


        viewModel.checkSubject.subscribe(onNext: { [weak self] (pwd,uid) in
            guard let `self` = self else { return }
            self.accountView.setText("Account", detail: uid)
            self.pwdView.setText("Initial Password", detail: pwd)
            self.accountView.showSecure(false)
            self.pwdView.showSecure(false)
            self.sendAlertVC?.dismiss(animated: true, completion:nil)
            self.selectBtn.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }).disposed(by: disposeBag)
        
        sendCaptchaView.rightBtn.rx.tap.subscribe {[weak self] (_) in
            self?.getIBIAccountInfo()
        }.disposed(by: disposeBag)

        sendCaptchaView.leftBtn.rx.tap.subscribe {[weak self] (_) in
            self?.sendAlertVC?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)


        sendCaptchaView.inputTextField.sendBtn.rx.tap.subscribe {[weak self] (_) in
            self?.sendCaptcha()
            self?.sendCaptchaView.updateError("")
        }.disposed(by: disposeBag)

        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }

            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captcha.accept(captcha)
            }
            self.sendCaptchaView.inputTextField.startCountDown()
        }).disposed(by: disposeBag)

        viewModel.codeErrorSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else { return }
            self.sendCaptchaView.updateError(msg)
        }).disposed(by: disposeBag)
        


        viewModel.captcha.bind(to: sendCaptchaView.inputTextField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        sendCaptchaView.inputTextField.textField.rx.text.orEmpty.bind(to: viewModel.captcha).disposed(by: disposeBag)
        
    }

    fileprivate func alertSendCaptch(){
        self.present(sendAlertVC!, animated: true, completion: nil)
        self.sendCaptcha()
    }
    
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading("", false))
        self.viewModel.services.userService.request(.sendEmailInputCaptcha(YXUserManager.shared().curLoginUser?.email ?? "", .type20001), response:  self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
    
    func getIBIAccountInfo() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        self.viewModel.services.userService.request(.getIBAccountInfo(self.viewModel.captcha.value),response: self.viewModel.checkCaptchaResponse).disposed(by: disposeBag)
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
