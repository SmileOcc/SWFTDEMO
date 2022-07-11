//
//  YXRecommendInputView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//请输入邀请码
import UIKit

import RxSwift
import RxCocoa

class YXRecommendInputView: UIView {
    private let disposeBag = DisposeBag()
    
    let selectSubject = PublishSubject<(Bool, String)>()
    
    //输入框
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textColor = QMUITheme().textColorLevel2()
        tf.font = UIFont.systemFont(ofSize: uniSize(18), weight: .regular)
        return tf
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, code: String) {
        self.init(frame: frame)
        initView(with: code)
    }
    
    fileprivate func initView(with code: String) {
        
        self.layer.cornerRadius = 24
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().foregroundColor()
        let horMargin: CGFloat = 43
        
        let titleLab = UILabel()
        titleLab.text = YXLanguageUtility.kLang(key: "invitation_code_enter")
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.font = UIFont.systemFont(ofSize: uniSize(20), weight: .regular)
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(uniVerLength(25))
            make.centerX.equalToSuperview()
            make.height.equalTo(uniVerLength(22))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            self?.textField.becomeFirstResponder()
        }
        textField.text = code
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(uniVerLength(25))
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(uniVerLength(25))
        }
        //横线
        let line1View = buildLineView(with: QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.2, backgroundColor: .clear))
        line1View.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.top.equalTo(textField.snp.bottom).offset(uniVerLength(10))
            make.height.equalTo(1)
        }
        
        let line2View = buildLineView(with: UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0))
        line2View.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(line1View.snp.bottom).offset(uniVerLength(39))
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelBtn.setTitleColor(QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.7, backgroundColor: .clear), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: uniSize(16), weight: .regular)
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(line2View.snp.bottom)
            make.height.equalTo(uniVerLength(48))
        }
        
        let line3View = buildLineView(with: UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0))
        line3View.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(uniVerLength(48))
            make.left.equalTo(cancelBtn.snp.right)
            make.top.equalTo(line2View.snp.bottom)
        }
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        sureBtn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        //sureBtn.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: uniSize(16), weight: .regular)
        addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(line2View.snp.bottom)
            make.left.equalTo(line3View.snp.right)
            make.height.equalTo(uniVerLength(48))
        }
        
        //MARK: Action
        textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: {[weak self] (text) in
                guard let `self` = self else {return}
                if text.isNotEmpty() {
                    //大于10个字符
                    if text.count > 10 {
                        self.textField.text = (text as NSString?)?.substring(to: 10)
                    }
                    print("text_count: \(text.count)")
                }
            }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else {return}
            self.selectSubject.onNext((false, ""))
            
        }).disposed(by: disposeBag)
        
        sureBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else {return}
            if let text = self.textField.text, !text.isEmpty {
                self.selectSubject.onNext((true, text))
            } else {
                self.selectSubject.onNext((false, ""))
            }
        }).disposed(by: disposeBag)
        
    }
    
    fileprivate func buildLineView(with bgColor: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = bgColor
        addSubview(v)
        return v
    }

}
