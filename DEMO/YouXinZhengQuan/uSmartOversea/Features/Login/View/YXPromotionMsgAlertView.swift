//
//  YXPromotionMsgAlertView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

enum YXPromotionMsgType: Int {
    case phone = 1  //电话
    case sms    //短线
    case email  //电邮
    case post   //邮寄
}

class YXPromotionMsgAlertView: UIView {
    private let disposeBag = DisposeBag()
    
    var promotValue = YXPromotionValue()
    
    let selectSubject = PublishSubject<(Bool, YXPromotionValue)>()
    
    private var phoneBtn: QMUIButton!
    private var smsBtn: QMUIButton!
    private var emailBtn: QMUIButton!
    private var postBtn: QMUIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(frame: CGRect, _ title: String, _ titleHeight: CGFloat, _ tip: String,_ tipHeight: CGFloat,_ horMargin: CGFloat) {
        self.init(frame: frame)
        initView(with: title, titleHeight, tip, tipHeight, horMargin)
    }
    
    fileprivate func initView(with title: String, _ titleHeight: CGFloat, _ tip: String,_ tipHeight: CGFloat,_ horMargin: CGFloat) {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().foregroundColor()
        
        
        let titleLab = UILabel()
        titleLab.numberOfLines = 0
        titleLab.text = title
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.font = UIFont.systemFont(ofSize: uniSize(14), weight: .regular)
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(uniVerLength(20))
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            //make.height.equalTo(titleHeight)
        }
        
        
        phoneBtn = buildBtn(with: .phone)
        smsBtn = buildBtn(with: .sms)
        emailBtn = buildBtn(with: .email)
        postBtn = buildBtn(with: .post)
        
        let btnSize: CGFloat = 15 + 18
        
        phoneBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin - 9)
            make.top.equalTo(titleLab.snp.bottom).offset(uniSize(5))
            make.size.equalTo(CGSize(width: btnSize, height: btnSize))
        }
        smsBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin - 9)
            make.top.equalTo(phoneBtn.snp.bottom)//.offset(uniSize(4))
            make.size.equalTo(CGSize(width: btnSize, height: btnSize))
        }
        emailBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin - 9)
            make.top.equalTo(smsBtn.snp.bottom)//.offset(uniSize(4))
            make.size.equalTo(CGSize(width: btnSize, height: btnSize))
        }
        postBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin - 9)
            make.top.equalTo(emailBtn.snp.bottom)//.offset(uniSize(4))
            make.size.equalTo(CGSize(width: btnSize, height: btnSize))
        }
        
        let lab1 = buildLab(with: YXLanguageUtility.kLang(key: "privacy_permission_phone"))
        let lab2 = buildLab(with: YXLanguageUtility.kLang(key: "privacy_permission_sms"))
        let lab3 = buildLab(with: YXLanguageUtility.kLang(key: "privacy_permission_email"))
        let lab4 = buildLab(with: YXLanguageUtility.kLang(key: "privacy_permission_post"))
        lab1.snp.makeConstraints { (make) in
            make.left.equalTo(phoneBtn.snp.right)
            make.centerY.equalTo(phoneBtn)
        }
        lab2.snp.makeConstraints { (make) in
            make.left.equalTo(smsBtn.snp.right)
            make.centerY.equalTo(smsBtn)
        }
        lab3.snp.makeConstraints { (make) in
            make.left.equalTo(emailBtn.snp.right)
            make.centerY.equalTo(emailBtn)
        }
        lab4.snp.makeConstraints { (make) in
            make.left.equalTo(postBtn.snp.right)
            make.centerY.equalTo(postBtn)
        }
        
        
        let tipLab = UILabel()
        tipLab.numberOfLines = 0
        tipLab.text = tip
        tipLab.textColor = QMUITheme().textColorLevel4()
        tipLab.font = UIFont.systemFont(ofSize: uniSize(12), weight: .regular)
        addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.top.equalTo(postBtn.snp.bottom).offset(uniVerLength(14))
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(tipHeight)
        }
        
        let line2View = buildLineView(with: UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0))
        line2View.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(tipLab.snp.bottom).offset(uniVerLength(10))
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelBtn.setTitleColor(QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.7, backgroundColor: .clear), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: uniSize(16), weight: .regular)
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(line2View.snp.bottom)
            make.height.equalTo(48)
        }
        
        let line3View = buildLineView(with: UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0))
        line3View.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(48)
            make.left.equalTo(cancelBtn.snp.right)
            make.top.equalTo(line2View.snp.bottom)
        }
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        sureBtn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: uniSize(16), weight: .regular)
        addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(line2View.snp.bottom)
            make.left.equalTo(line3View.snp.right)
            make.height.equalTo(48)
        }
        
        
        //MARK: Action
        cancelBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            self.selectSubject.onNext((false, self.promotValue))
            
        }).disposed(by: disposeBag)
        
        sureBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            self.promotValue.phone = self.phoneBtn.isSelected
            self.promotValue.sms = self.smsBtn.isSelected
            self.promotValue.email = self.emailBtn.isSelected
            self.promotValue.mail = self.postBtn.isSelected
            
            self.selectSubject.onNext((true, self.promotValue))
        }).disposed(by: disposeBag)
    }
    
    
    fileprivate func buildBtn(with type: YXPromotionMsgType) -> QMUIButton {
        let btn = QMUIButton(type: .custom)
        btn.tag = type.rawValue
        btn.isSelected = true
        btn.setImage(UIImage(named: "register_pro_selected"), for: .normal)
        btn.adjustsButtonWhenHighlighted = false
        btn.rx.tap.subscribe(onNext: {
            btn.isSelected = !btn.isSelected
            if btn.isSelected {
                btn.setImage(UIImage(named: "register_pro_selected"), for: .normal)
            } else {
                btn.setImage(UIImage(named: "register_pro_unselect"), for: .normal)
            }
        }).disposed(by: disposeBag)
        addSubview(btn)
        return btn
    }

    fileprivate func buildLineView(with bgColor: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = bgColor
        addSubview(v)
        return v
    }
    
    fileprivate func buildLab(with text: String) -> UILabel {
        let tipLab = UILabel()
        tipLab.numberOfLines = 0
        tipLab.text = text
        tipLab.textColor = QMUITheme().textColorLevel1()
        tipLab.font = UIFont.systemFont(ofSize: uniSize(14), weight: .medium)
        addSubview(tipLab)
        return tipLab
    }
    
}
