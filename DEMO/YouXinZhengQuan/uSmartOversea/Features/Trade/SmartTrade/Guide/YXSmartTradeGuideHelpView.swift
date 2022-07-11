//
//  YXSmartTradeGuideHelpView.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartTradeGuideHelpView: UIView {
    
    typealias ClosureClick = () -> Void
    
    //
    @objc var clickWhat: ClosureClick?
    
    // 
    @objc var clickHasTypes: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "smart_trade_tip")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    lazy var whatBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "what_smart_trade"), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            if let closure = self?.clickWhat {
                closure()
            }
        }).disposed(by: self.rx.disposeBag)
        return btn
    }()
    
    lazy var hasTypesBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "what_smart_trade_type"), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            if let closure = self?.clickHasTypes {
                closure()
            }
        }).disposed(by: self.rx.disposeBag)
        return btn
    }()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.markView)
        self.addSubview(self.titleLabel)
        
        self.addSubview(self.whatBtn)
        self.addSubview(self.hasTypesBtn)
        
        self.markView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(17)
            make.width.equalTo(4)
            make.height.equalTo(14)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.markView)
            make.left.equalTo(self.markView.snp.right).offset(5)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-8)
        }
        
        whatBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        
        let line1 = buildLineView()
        addSubview(line1)
        line1.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.top.equalTo(whatBtn.snp.bottom).offset(10)
        }
        
        hasTypesBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(line1.snp.bottom).offset(10)
        }
        
        let line2 = buildLineView()
        addSubview(line2)
        line2.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.top.equalTo(hasTypesBtn.snp.bottom).offset(10)
        }
        
    }
    
    private func buildLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().qmui_colorWithAlphaAdded(toWhite: 0.05)
        return view
    }
}
