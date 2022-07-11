//
//  YXSignInView.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2021/3/31.
//

import UIKit
import RxCocoa
import RxSwift

enum YXSignUpType {
    case mobile
    case email
}

class YXSignUpView: UIView {

    let disposeBag = DisposeBag()
    
    var inviteSeletexSubject = PublishSubject<Bool>()

    typealias ClickService = ()->()
    typealias ClickPrivacy = ()->()
    typealias bannerBlock = (Int)->()
    
    var didClickService : ClickService?
    var didClickPrivacy: ClickService?
    
    var didCloseBlock : ClickService?
    var tapBannerBlock: bannerBlock?
    
//    lazy var passWordField : YXSecureTextField = {
//        let field = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "input_password"), placeholder: YXLanguageUtility.kLang(key: "signup_pwd_placeholder"))
//        field.needAnmitionSelect = false
//        field.tipsLable.isHidden = true
//        return field
//    }()
    
    var acountField:YXTipsTextField = YXTipsTextField()
    
    var signUpBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "sign_up"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "sign_up"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        return btn
    }()
    
//    var verifictionCodeField : YXTimeTextField = {
//        let field = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "verCode_placeholder"), placeholder: YXLanguageUtility.kLang(key: "verCode_placeholder"))
//        return field
//    }()
    
    
//    var helpBtn : QMUIButton = {
//       let btn = QMUIButton()
//        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
//        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
//        btn.sizeToFit()
//        return btn
//    }()
    
//    var errorTipLabel : UILabel = {
//        let lab = UILabel.init()
//        lab.textColor = QMUITheme().errorTextColor()
//        lab.font = .systemFont(ofSize: 12)
//        lab.text = YXLanguageUtility.kLang(key: "password_tip")
//        lab.isHidden = true
//        return lab
//    }()
    
    var accountErrorTipLable : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "wrong_mail_tip")
        lab.isHidden = true
        return lab
    }()
    
    var inviteBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.normalFont14()
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setImage(UIImage(named: "invite_unchecked"), for: .normal)
        btn.setImage(UIImage(named: "invite_checked"), for: .selected)
        btn.setTitle(YXLanguageUtility.kLang(key: "have_inviter_tip"), for: .normal)
        
        let insetAmount : CGFloat = 4.0
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        
        return btn
    }()
    
    var inviteField : YXTipsTextField = {
        let input = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "please_enter_invitation_code"), placeholder: "")
        input.selectStyle = .defult
        input.textField.keyboardType = .asciiCapable
        input.isHidden = true
        return input
    }()
    
    lazy var declareView : YXDeclareView = {
        let view = YXDeclareView.init(frame: .zero)
        return view
    }()
    
    lazy var bannerView: YXLoginAdvView = {
        let view = YXLoginAdvView()
        view.isHidden = true
        view.didCloseBlock = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showBanner(false)
            if let close = self?.didCloseBlock {
                close()
            }
        }
        view.tapBannerBlock = {[weak self] (index) in
            guard let strongSelf = self else { return }
            if let bannerBlock = strongSelf.tapBannerBlock {
                bannerBlock(index)
            }
        }
        return view
    }()


    var signUpIntype : YXSignUpType!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type:YXSignUpType) {
        self.init(frame: .zero)
        self.signUpIntype = type
        setupUI()
    }
    
    var mUsernameValid : Observable<Bool>?
    
    func bannerSizeHeight() -> CGFloat {
        if self.bannerView.isHidden {
            return 0
        } else {
            return (YXConstant.screenWidth - 24) * 70.0/350.0
        }
    }

    func setupUI()  {
        backgroundColor = QMUITheme().foregroundColor()
        if self.signUpIntype == YXSignUpType.mobile {
            acountField = YXPhoneTextField.init(defaultTip: YXLanguageUtility.kLang(key: "mobile_acount"), placeholder:"")
        }else {
            acountField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "email_placeholder"), placeholder: "")
        }
        
        
        addSubview(acountField)
        addSubview(accountErrorTipLable)
        //addSubview(passWordField)
        //addSubview(verifictionCodeField)
        addSubview(signUpBtn)
        //addSubview(errorTipLabel)
        addSubview(inviteBtn)
        addSubview(inviteField)
        
        addSubview(declareView)
        addSubview(bannerView)
        
        acountField.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(56)
            make.top.equalToSuperview()
        }
        
        accountErrorTipLable.snp.makeConstraints { (make) in
            make.left.equalTo(acountField)
            make.height.equalTo(0)
            make.top.equalTo(acountField.snp.bottom).offset(2)
        }
        
//        verifictionCodeField.snp.makeConstraints { (make) in
//            make.size.left.equalTo(acountField)
//            make.top.equalTo(acountField.snp.bottom).offset(24)
//
//        }
//
//        passWordField.snp.makeConstraints { (make) in
//            make.size.left.equalTo(verifictionCodeField)
//            make.top.equalTo(verifictionCodeField.snp.bottom).offset(24)
//
//        }
//
//        errorTipLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(passWordField)
//            make.top.equalTo(passWordField.snp.bottom).offset(2)
//            make.height.equalTo(17)
//        }
//
        
        inviteBtn.snp.makeConstraints { make in
            make.left.equalTo(acountField.snp.left)
            make.top.equalTo(acountField.snp.bottom).offset(24)
        }
        
        inviteField.snp.makeConstraints { make in
            make.top.equalTo(inviteBtn.snp.bottom).offset(0)
            make.height.equalTo(0)
            make.left.right.equalTo(acountField)
        }
        
        signUpBtn.snp.makeConstraints { (make) in
            make.top.equalTo(inviteField.snp.bottom).offset(44)
            make.height.equalTo(48)
            make.left.right.equalTo(acountField)
        }
        declareView.snp.makeConstraints { (make) in
            make.top.equalTo(signUpBtn.snp.bottom).offset(16)
            make.left.right.equalTo(acountField)
            make.height.equalTo(36.sacel375())
        }
        
       
        
//        addSubview(helpBtn)
//        helpBtn.snp.makeConstraints { (make) in
//            make.right.equalTo(signUpBtn.snp.right)
//            make.top.equalTo(declareView.snp.bottom).offset(12)
//        }

        bannerView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(12)
            make.right.equalTo(self.snp.right).offset(-12)
            make.top.equalTo(declareView.snp.bottom).offset(30)
            make.height.equalTo(self.bannerView.snp.width).multipliedBy(70.0/350.0)
        }
        
        inviteSeletexSubject.bind(to: inviteBtn.rx.isSelected).disposed(by: disposeBag)

        inviteBtn.rx.tap.subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            self.endEditing(true)
            self.inviteBtn.isSelected = !self.inviteBtn.isSelected;
            self.inviteSeletexSubject.onNext(self.inviteBtn.isSelected)
        }).disposed(by: disposeBag)
        

        inviteSeletexSubject.subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }

            if value {
                self.inviteField.isHidden = false
                self.inviteField.snp.updateConstraints({ make in
                    make.top.equalTo(self.inviteBtn.snp.bottom).offset(22)
                    make.height.equalTo(56)
                })
            } else {
                self.inviteField.isHidden = true
                self.inviteField.textField.text = ""
                self.inviteField.didEnd()
                self.inviteField.snp.updateConstraints({ make in
                    make.top.equalTo(self.inviteBtn.snp.bottom).offset(0)
                    make.height.equalTo(0)
                })
            }
        }).disposed(by: disposeBag)
        
        
                
        acountField.textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] (_) in
            if self?.signUpIntype == .email {
                if self?.acountField.textField.text?.isValidEmail() ?? false  ||
                    self?.acountField.textField.text?.count == 0 {

                }else{
                    self?.accountErrorTip(hidden: false)
                }
            }else{
                
            }
        }).disposed(by: disposeBag)
        
        acountField.textField.rx.controlEvent(.editingDidBegin).subscribe(onNext:{[weak self] in
            self?.accountErrorTip(hidden: true)
        }).disposed(by: disposeBag)
        
        
        declareView.didClickPrivacy = {[weak self]  in
            guard let `self` = self else { return }
            if let privacy = self.didClickPrivacy {
                privacy()
            }
        }
        declareView.didClickService = {[weak self] in
            guard let `self` = self else { return }
            if let service = self.didClickService {
                service()
            }

        }
        
        inviteField.textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: {[weak self] (text) in
                guard let `self` = self else {return}
                if text.isNotEmpty() {
                    //大于10个字符
                    if text.count > 10 {
                        self.inviteField.textField.text = (text as NSString?)?.substring(to: 10)
                    }
                    print("text_count: \(text.count)")
                }
            }).disposed(by: disposeBag)
    }
    
    func accountErrorTip(hidden:Bool){
        accountErrorTipLable.isHidden = hidden
        accountErrorTipLable.snp.updateConstraints { (make) in
            make.height.equalTo(hidden ? 0 : 17)
        }
        inviteBtn.snp.updateConstraints { (make) in
            make.top.equalTo(acountField.snp.bottom).offset(hidden ? 24 : 40)
        }
    }
    
    
    @objc func showBanner(_ show: Bool) {
        
        self.bannerView.isHidden = !show
        if show {
            bannerView.snp.remakeConstraints { make in
                make.left.equalTo(self.snp.left).offset(12)
                make.right.equalTo(self.snp.right).offset(-12)
                make.top.equalTo(declareView.snp.bottom).offset(30)
                make.height.equalTo(self.bannerView.snp.width).multipliedBy(70.0/350.0)
            }
            
        } else {
            bannerView.snp.remakeConstraints { make in
                make.left.equalTo(self.snp.left).offset(12)
                make.right.equalTo(self.snp.right).offset(-12)
                make.top.equalTo(declareView.snp.bottom).offset(0)
                make.height.equalTo(self.bannerView.snp.width).multipliedBy(0)
            }
        }
    }

}
