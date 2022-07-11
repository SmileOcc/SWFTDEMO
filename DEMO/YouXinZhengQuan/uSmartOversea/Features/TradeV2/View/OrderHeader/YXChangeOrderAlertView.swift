//
//  YXChangeOrderAlertView.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


class YXChangeOrderAlertView: UIView {
    
    let disposeBag = DisposeBag()
    
    @objc var confirmBlock :((Bool)->Void)?
    
    @objc var cancelBlock :(()->Void)?

    @objc lazy var contentLab:UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = QMUITheme().textColorLevel1().qmui_colorWithAlphaAdded(toWhite: 0.65)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()
    
    @objc lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        return btn
    }()
    
    @objc lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().alertButtonLayerColor().cgColor
        btn.setTitleColor(UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel3()), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().popupLayerColor()
        
        
        let titleLab = UILabel()
        titleLab.font = .systemFont(ofSize: 16, weight: .medium)
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.text = YXLanguageUtility.kLang(key: "commom_description")
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }
        
        addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLab.snp.bottom).offset(19)
        }
        
        let descTipLab = UILabel()
        descTipLab.font = .systemFont(ofSize: 14)
        descTipLab.textColor = QMUITheme().textColorLevel1()
        descTipLab.text = YXLanguageUtility.kLang(key: "trading_confirm_continue_change_tip")
        descTipLab.textAlignment = .center
        descTipLab.numberOfLines = 0
        addSubview(descTipLab)
        descTipLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(contentLab.snp.bottom).offset(4)
        }
        
        let changeTipBtn = QMUIButton(type: .custom)
        changeTipBtn.setImage(UIImage(named: "noSelectStockBg"), for: .normal)
        changeTipBtn.setImage(UIImage(named: "selectStockBg"), for: .selected)
        changeTipBtn.setTitle(YXLanguageUtility.kLang(key: "trading_no_longer_remind"), for: .normal)
        changeTipBtn.setTitle(YXLanguageUtility.kLang(key: "trading_no_longer_remind"), for: .selected)
        changeTipBtn.titleLabel?.font = .systemFont(ofSize: 14)
        changeTipBtn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        changeTipBtn.imagePosition = .left
        changeTipBtn.spacingBetweenImageAndTitle = 4.0
        changeTipBtn.showsTouchWhenHighlighted = false
        addSubview(changeTipBtn)
        changeTipBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(descTipLab.snp.bottom).offset(20)
        }
        
        
        self.addSubview(confirmBtn)
        self.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(14)
            make.right.equalTo(confirmBtn.snp.left).offset(-21)
            make.top.equalTo(changeTipBtn.snp.bottom).offset(18)
            make.height.equalTo(40)
            make.width.equalTo(confirmBtn)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-14)
            make.top.equalTo(changeTipBtn.snp.bottom).offset(18)
            make.height.equalTo(40)
        }
        
        
        changeTipBtn.rx.tap.subscribe(onNext: {[weak changeTipBtn] (_) in
            guard let strongBtn = changeTipBtn else { return }
            strongBtn.isSelected = !strongBtn.isSelected
        }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else {return}
            if let cancel = self.cancelBlock {
                cancel()
            }
            
        }).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe(onNext: {[weak self,weak changeTipBtn] (_) in
            guard let `self` = self else {return}
            if let confirm = self.confirmBlock,let btn = changeTipBtn {
                confirm(btn.isSelected)
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate func buildLineView(with bgColor: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = bgColor
        addSubview(v)
        return v
    }
    
    @objc func updateContent(with text:String) {
        self.contentLab.text = text
    }
}
