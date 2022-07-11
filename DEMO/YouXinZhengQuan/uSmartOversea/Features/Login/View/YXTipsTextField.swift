//
//  YXTipsTextField.swift
//  OpenSourceStd
//
//  Created by usmart on 2021/3/30.
//

import UIKit


enum YXTipsTextFieldSelectStyle {
    case defult
    case none
}

class YXTipsTextField: UIView {

    var selectStyle:YXTipsTextFieldSelectStyle = .defult
    
    //多行内容显示，约束位置、高度调整
    var tipsNumber: Int = 1 {
        didSet {
            self.tipsLable.numberOfLines = tipsNumber
        }
    }
    
    var needAnmitionSelect = true
    lazy var textField : UITextField = {
        let textField = UITextField.init()
        textField.textColor = QMUITheme().textColorLevel1()
        textField.font = .systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(didChanaged), for: .editingChanged)
        textField.addTarget(self, action: #selector(didBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEnd), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(didEndOnExit), for: .editingDidEndOnExit)
        return textField
    }()
    
    lazy var tipsLable : QMUILabel = {
        let lab = QMUILabel.init()
        lab.textAlignment = .center
        lab.backgroundColor = QMUITheme().foregroundColor()
        lab.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)
        lab.textColor = QMUITheme().textColorLevel4()
        lab.font = .systemFont(ofSize: 14)
        return lab
    }()
    
    lazy var containerView : UIView = {
        let view = UIView.init()
        view.layer.borderWidth = 1
        view.layer.borderColor = QMUITheme().textColorLevel1().cgColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    
    lazy var clearBtn : QMUIButton = {
        let btn = QMUIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_close_clear"), for: .normal)
        btn.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    
    var defaultTip:String = ""
    
    func attrPlaceholder(_ text:String)->NSMutableAttributedString{
        let attrString = NSMutableAttributedString(string: text)
        attrString.yy_font = UIFont.systemFont(ofSize: 14)
        attrString.yy_color = QMUITheme().textColorLevel4()
        return attrString
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(defaultTip:String,placeholder:String) {
        self.init(frame: .zero)
        self.defaultTip = defaultTip
        self.textField.attributedPlaceholder = attrPlaceholder(placeholder)
        setupUI()
        hiddenTip()
    }
    
   private var isShowed = false
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI()  {
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        tipsLable.text = defaultTip
        
        self.addSubview(containerView)
        self.addSubview(textField)
        self.addSubview(tipsLable)
        self.addSubview(clearBtn)
        
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.right.equalTo(clearBtn.snp.left)
            make.height.equalToSuperview()
            make.left.equalTo(16)
            make.top.equalToSuperview()
        }
        
        
        tipsLable.snp.remakeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(2)
            make.bottom.equalTo(-2)
        }
        
        clearBtn.snp.makeConstraints { (mark) in
            mark.top.bottom.equalToSuperview()
            mark.width.equalTo(50)
            mark.right.equalTo(0)
        }
        if defaultTip.count <= 0{
            tipsLable.isHidden = true
        }
    }
    
    func showErrorTip(_ tip:String) {
        tipsLable.text = tip
        tipsLable.textColor = QMUITheme().errorTextColor()
        containerView.layer.borderColor = tipsLable.textColor.cgColor
    }
    
    
    func showDefaultTip()  {
        isShowed = true
        let defaultColor = QMUITheme().textColorLevel1()
    
        if self.selectStyle == .defult {
            containerView.layer.borderColor = defaultColor.cgColor
        }else {
            containerView.layer.borderColor = QMUITheme().pointColor().cgColor
        }
        tipsLable.textColor = defaultColor
        textField.textColor = defaultColor
        if self.textField.isEnabled == false{
            textField.textColor = QMUITheme().textColorLevel4()
        }
        if defaultTip.count > 0{
            tipsLable.text = defaultTip
            tipsLable.isHidden = false
        }
    }
    
    func hiddenTip()  {
        isShowed = false
        containerView.layer.borderColor = QMUITheme().pointColor().cgColor
        tipsLable.textColor = QMUITheme().textColorLevel4()
        if needAnmitionSelect == false {
            tipsLable.isHidden = true
        }
    }
    
    fileprivate func showTipAnmition(){
        guard isShowed == false else {return}
        if needAnmitionSelect == false {
            if self.tipsNumber > 1 {
                self.tipsLable.snp.remakeConstraints { (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(-9 * self.tipsNumber)
                }
            } else {
                self.tipsLable.snp.remakeConstraints { (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(-9)
                }
            }
           
            self.tipsLable.isHidden = false
            self.tipsLable.font = .systemFont(ofSize: 12)
            self.tipsLable.textColor = QMUITheme().textColorLevel1()
            self.showDefaultTip()
            return
        }
        let scale = self.tipsLable.frame.size.width * 0.15 * 0.5
        UIView.animate(withDuration: 0.2) { [weak self] in
            
            if let tipNum = self?.tipsNumber, tipNum > 1 {
                self?.tipsLable.snp.remakeConstraints { (make) in
                    make.height.equalTo(18 * tipNum)
                    make.left.equalTo(16-scale)
                    make.top.equalTo(-9 * tipNum)
                }
            } else {
                self?.tipsLable.snp.remakeConstraints { (make) in
                    make.height.equalTo(18)
                    make.left.equalTo(16-scale)
                    make.top.equalTo(-9)
                }
            }
            
            self?.tipsLable.transform  = CGAffineTransform.init(scaleX:0.85,y: 0.85)
            self?.layoutIfNeeded()
        } completion: { [weak self](_) in
            self?.showDefaultTip()
        }
    }
    
    fileprivate func hiddenTipAnmition(){
        
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.tipsLable.snp.remakeConstraints { (make) in
                make.left.equalTo(10)
                make.top.equalTo(2)
                make.bottom.equalTo(-2)
            }
            self?.tipsLable.transform  = CGAffineTransform.init(scaleX:1.0,y: 1.0)
            self?.layoutIfNeeded()
        }
        self.hiddenTip()
    }
   
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension YXTipsTextField{
    
   private func canShowClearBtn() {
        if self.textField.text?.count ?? 0 > 0 {
            clearBtn.isHidden = false
        }else{
            clearBtn.isHidden = true
        }
    }

    
    @objc func clearTextField(){
        self.clearBtn.isHidden = true
        self.textField.text = ""
    }
    
    
    @objc func didChanaged(){
        self.canShowClearBtn()
    }
    
    @objc func didBegin(){
        self.canShowClearBtn()
        showTipAnmition()
    }
    
    @objc func didEnd(){
        self.canShowClearBtn()
        if textField.text?.count ?? 0 <= 0  {
            hiddenTipAnmition()
         }
    }
    
    @objc func didEndOnExit(){
        self.canShowClearBtn()
        if textField.text?.count ?? 0 <= 0  {
             hiddenTipAnmition()
         }
    }
    
    //登录注册邀请码用
    @objc func didBeginOnAnmition(){
        self.canShowClearBtn()
        
        if needAnmitionSelect == false {
            if self.tipsNumber > 1 {
                self.tipsLable.snp.remakeConstraints { (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(-9 * self.tipsNumber)
                }
            } else {
                self.tipsLable.snp.remakeConstraints { (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(-9)
                }
            }
           
            self.tipsLable.isHidden = false
            self.tipsLable.font = .systemFont(ofSize: 12)
            self.tipsLable.textColor = QMUITheme().textColorLevel1()
            self.showDefaultTip()
            return
        }
        let scale = self.tipsLable.frame.size.width * 0.15 * 0.5
        if self.tipsNumber > 1 {
            self.tipsLable.snp.remakeConstraints { (make) in
                make.height.equalTo(18 * self.tipsNumber)
                make.left.equalTo(16-scale)
                make.top.equalTo(-9 * self.tipsNumber)
            }
        } else {
            self.tipsLable.snp.remakeConstraints { (make) in
                make.height.equalTo(18)
                make.left.equalTo(16-scale)
                make.top.equalTo(-9)
            }
        }
        
        self.tipsLable.transform  = CGAffineTransform.init(scaleX:0.85,y: 0.85)
        self.layoutIfNeeded()
        self.showDefaultTip()
        
    }
    
    @objc func didEndNoAnmition(){
        self.canShowClearBtn()
        if textField.text?.count ?? 0 <= 0  {
            
            self.tipsLable.snp.remakeConstraints { (make) in
                make.left.equalTo(10)
                make.top.equalTo(2)
                make.bottom.equalTo(-2)
            }
            self.tipsLable.transform  = CGAffineTransform.init(scaleX:1.0,y: 1.0)
            self.layoutIfNeeded()
            self.hiddenTip()
         }
    }
    
}


class YXPhoneTextField: YXTipsTextField ,UITextFieldDelegate{
    
    typealias AreaClick = (String)->()
    
    var didClickAreaCode : AreaClick?
    
    lazy var areaCodeLale : UILabel = {
        let labl = UILabel()
        labl.text = "+1"
        labl.textAlignment = .left
        labl.textColor = QMUITheme().textColorLevel1()
        labl.font = .systemFont(ofSize: 16, weight: .regular)
        return labl
    }()
    
    lazy var logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "icon_more_login")
        return imageView
    }()
    
    lazy var areaCodeBtn : QMUIButton = {
        let btn = QMUIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(areaCodeTap), for: .touchUpInside)
        return btn
    }()
    
    override func setupUI() {
        super.setupUI()
        textField.keyboardType = .numberPad
        textField.delegate = self
        addSubview(areaCodeBtn)
        areaCodeBtn.addSubview(areaCodeLale)
        areaCodeBtn.addSubview(logoImageView)
        
        areaCodeLale.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(0)
            make.width.height.equalTo(12)
        }
        
        areaCodeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        textField.snp.updateConstraints { (make) in
            make.left.equalTo(92)
        }
        
        tipsLable.snp.remakeConstraints { (make) in
            make.left.equalTo(92)
            make.top.equalTo(2)
            make.bottom.equalTo(-2)
        }

    }
    
    @objc func areaCodeTap(){
        didClickAreaCode?(areaCodeLale.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text as NSString?
        let str2 = str?.replacingCharacters(in: range, with: string)
       
            if str2?.count ?? 0 > 11{
                return false
            }
            if string.count > 0 && !(str2?.isAllNumber() ?? false) {
                return false
            }
        return true
    }
    
    override func hiddenTipAnmition() {
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.tipsLable.snp.remakeConstraints { (make) in
                make.left.equalTo(92)
                make.top.equalTo(2)
                make.bottom.equalTo(-2)
            }
            self?.tipsLable.transform  = CGAffineTransform.init(scaleX:1.0,y: 1.0)
            self?.layoutIfNeeded()
        }
        self.hiddenTip()
    }
}


class YXSecureTextField: YXTipsTextField {
    
    lazy var secureBtn : QMUIButton = {
        let btn = QMUIButton.init()
        btn.addTarget(self, action: #selector(secureTap), for: .touchUpInside)
        btn.setImage(UIImage.init(named: "icon_close_login"), for: .selected)
        btn.setImage(UIImage.init(named: "icon_show_login"), for: .normal)
        btn.isSelected = true
        return btn
    }()
    
    override func setupUI() {
        super.setupUI()
        textField.isSecureTextEntry = true
        textField.keyboardType = .asciiCapable
        addSubview(secureBtn)
        
        secureBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(0)
            make.width.equalTo(50)
        }
      
        
        clearBtn.snp.updateConstraints { (make) in
            make.width.equalTo(16)
            make.right.equalTo(-45)
        }
    }
    
    @objc func secureTap(){
        secureBtn.isSelected = !secureBtn.isSelected
        textField.isSecureTextEntry = secureBtn.isSelected
    }
}

class YXTimeTextField: YXTipsTextField,UITextFieldDelegate {
    
    typealias SendTap = ()->()
    
    var sendBtnClick : SendTap?
    
    lazy var sendBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "send_code"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "send_code"), for: .disabled)
        btn.setTitleColor(QMUITheme().textColorLevel4(), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
       // btn.addTarget(self, action: #selector(send), for: .touchUpInside)
        return btn
    }()
    
    lazy var countDownLable : UILabel = {
        let labe = UILabel()
        labe.textAlignment = .center
        labe.textColor = QMUITheme().textColorLevel3()
        labe.font = .systemFont(ofSize: 14, weight: .regular)
        labe.backgroundColor = QMUITheme().foregroundColor()
        return labe
    }()
    
    lazy var timer : Timer = {
        let timer = Timer.init(timeInterval: 1, target: self, selector: #selector(timeDown), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }()
    
    @objc func timeDown(){
        self.count = self.count - 1
        if self.count > 0{
            if YXUserManager.isENMode() {
                self.countDownLable.text = "\(YXLanguageUtility.kLang(key: "time_down")) \(self.count)s"
            }else {
                self.countDownLable.text = "\(self.count)s\(YXLanguageUtility.kLang(key: "time_down"))"
            }
        }else {
            self.countDownLable.isHidden = true
            self.sendBtn.isHidden = false
            self.sendBtn.setTitle(YXLanguageUtility.kLang(key: "captcha_resend"), for: .normal)
            timer.fireDate = NSDate.distantFuture
       }
    }
    
    var count : Int = 60
    
    
    override func setupUI() {
        super.setupUI()
        textField.keyboardType = .numberPad
        textField.delegate = self
        addSubview(sendBtn)
        addSubview(countDownLable)
        
        sendBtn.snp.makeConstraints { (make) in
            make.width.equalTo(95)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(0)
        }
        
        countDownLable.snp.makeConstraints { (make) in
            make.width.equalTo(147)
            make.top.equalToSuperview().offset(2)
            make.bottom.right.equalToSuperview().offset(-2)
           // make.right.equalTo(0)
        }
        
        clearBtn.snp.updateConstraints { (make) in
            make.width.equalTo(0)
            make.right.equalTo(-95)
        }
        self.countDownLable.isHidden = true
    }
    
    @objc func send() {
        sendBtnClick?()
        startCountDown()
    }
    
    func startCountDown(){
        timer.fireDate = NSDate.init() as Date
        timer.fireDate = Date.distantPast
        self.count = 60
        sendBtn.isHidden = true
        countDownLable.isHidden = false
    }
    
    deinit {
        timer.invalidate()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        timer.invalidate()
    }
    
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
