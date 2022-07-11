//
//  YXDerivativeView2.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/5/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDerivativeInfoRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/user-account-server-sg/api/get-customer-derivatives-trade-info/v1"
    }
    
    override func yx_baseUrl() -> String {
        YXUrlRouterConstant.jyBaseUrl()
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

@objcMembers class YXDerivativeView: UIView {

    var clickDerivativeBlock: (() -> ())?
    var confirmBlock: (() -> ())?
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        return v
    }()
    
    private lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = YXLanguageUtility.kLang(key: "derivative_alert_title")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var describeLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = YXLanguageUtility.kLang(key: "derivative_alert_content")
        return label
    }()
    
    lazy var chooseLabel: YYLabel = {
        let label = YYLabel()
        let string = YXLanguageUtility.kLang(key: "trade_read_derivatives")
        
        let attributeString = NSMutableAttributedString(string: string,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                     .foregroundColor: QMUITheme().textColorLevel2()])
        attributeString.yy_setTextHighlight((string as NSString).range(of: YXLanguageUtility.kLang(key: "trade_derivatives_transactions")), color: QMUITheme().themeTintColor(), backgroundColor: nil) { [weak self] _, _, _, _ in
            self?.clickDerivativeBlock?()
        }
        label.textVerticalAlignment = .top
        label.numberOfLines = 0
        label.attributedText = attributeString
        return label
    }()
    
    lazy var chooseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        btn.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .selected)
        return btn
    }()
    
    lazy var confirmBtn: UIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setBackgroundImage(UIImage(color: QMUITheme().themeTintColor().withAlphaComponent(0.4)), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.chooseBtn.isSelected {
                strongSelf.confirmBlock?()
            } else {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "trade_check_derivatives"))
            }
        }
        
        return btn
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().pointColor().cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            self?.hide()
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 286, height: 467))
        
        initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialUI() {
        
        layer.cornerRadius = 6
        backgroundColor = UIColor.white
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        
        addSubview(titleLab)
        addSubview(confirmBtn)
        addSubview(cancelBtn)
        addSubview(scrollView)
        scrollView.addSubview(describeLab)
        scrollView.addSubview(chooseLabel)
        scrollView.addSubview(chooseBtn)
        
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.width.equalTo(200)
        }
                
        let btnWidth = (self.width - 52) / 2
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(36)
            make.width.equalTo(btnWidth)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(36)
            make.right.equalTo(self).offset(-16)
            make.width.equalTo(confirmBtn)
            make.width.equalTo(btnWidth)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top).offset(-20)
        }
        
        describeLab.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(16)
            make.width.equalTo(self.size.width - 32)
            make.top.equalToSuperview()
        }
        
        let line = UIView.line()
        scrollView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(16)
            make.width.equalTo(self.size.width - 32)
            make.top.equalTo(describeLab.snp.bottom).offset(20)
            make.height.equalTo(0.5)
        }
        
        let chooseHeight = chooseLabel.attributedText?.height(limitWidth: self.width - 60) ?? 0
        chooseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.width.equalTo(self.width - 60)
            make.bottom.equalToSuperview()
            make.top.equalTo(line.snp.bottom).offset(16)
            make.height.equalTo(chooseHeight)
        }
        
        chooseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(16)
            make.top.equalTo(chooseLabel)
        }
        
        chooseBtn.rac_signal(for: .touchUpInside).subscribeNext {[weak self] (x) in
            x?.isSelected = !(x?.isSelected ?? false)
            if x?.isSelected ?? false {
                self?.confirmBtn.setBackgroundImage(UIImage(color: QMUITheme().themeTintColor()), for: .normal)
            } else {
                self?.confirmBtn.setBackgroundImage(UIImage(color: QMUITheme().themeTintColor().withAlphaComponent(0.4)), for: .normal)
            }
        }
        
      }
}

extension YXDerivativeView {
    private static var DerivativeKey: String {
        "\(YXUserManager.userUUID())" + "Derivative_showed"
    }
    private static var TodayDerivativeKey: String {
        let dateFormatter = DateFormatter.en_US_POSIX()
        dateFormatter.dateFormat = "yyyyMMdd"
        return "\(YXUserManager.userUUID())" + dateFormatter.string(from: Date()) + "Derivative_showed"
    }
    
    static var needShow: Bool {
        set {
            MMKV.default().set(newValue, forKey: DerivativeKey)
        }
        get {
            return MMKV.default().bool(forKey: DerivativeKey, defaultValue: true)
        }
    }
    
    static var todayNeedShow: Bool {
        set {
            MMKV.default().set(newValue, forKey: TodayDerivativeKey)
        }
        get {
            return MMKV.default().bool(forKey: TodayDerivativeKey, defaultValue: true)
        }
    }
}
