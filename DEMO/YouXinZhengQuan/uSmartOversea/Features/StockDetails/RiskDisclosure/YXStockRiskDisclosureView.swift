//
//  YXStockRiskDisclosureView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class YXStockRiskDisclosureView: UIView {
    
    var completed :(()->Void)?
    
    var cancel :(()->Void)?
    
    let disposeBag = DisposeBag()
    
    @objc lazy var scrollerView: UIScrollView = {
        let v = UIScrollView()
        return v
    }()
    //标题
    @objc lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures")
        return label
    }()
    //描述
    @objc lazy var describeLab: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures_tip")
        return label
    }()
    
    //复选框
    @objc lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "noSelectStockBg"), for: .normal)
        btn.setImage(UIImage(named: "selectStockBg"), for: .selected)
        return btn
    }()
    
    //选择提示
    @objc lazy var selLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures_sel")
        return label
    }()
    // 取消
    @objc lazy var cancelBtn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.qmui_color(withHexString: "#DADADA")
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = true
        
        return btn
    }()
    
    //确定
    @objc lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().themeTextColor(), size: CGSize(width: 50, height: 50), cornerRadius: 0), for: .normal)
        btn.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#DADADA"), size: CGSize(width: 50, height: 50), cornerRadius: 0), for: .disabled)
        btn.isEnabled = false //默认置灰
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = true
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialUI()
    }
    
    func initialUI() {
        layer.cornerRadius = 20
        clipsToBounds = true
        backgroundColor = UIColor.white
        
        
        self.addSubview(titleLab)
        
        addSubview(scrollerView)
        scrollerView.addSubview(describeLab)
        
        self.addSubview(selectBtn)
        self.addSubview(selLab)
        self.addSubview(cancelBtn)
        self.addSubview(confirmBtn)
        
        
        selectBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            self.selectBtn.isSelected = !self.selectBtn.isSelected
            self.confirmBtn.isEnabled = self.selectBtn.isSelected
        }).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe(onNext: {[weak self] (x) in
            self?.completed?()
        }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe(onNext: {[weak self] (x) in
            self?.cancel?()
        }).disposed(by: disposeBag)
        
    }
    
    func resizeUI() {
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview()
            //make.width.equalTo(self.frame.size.width - 48)
        }
        scrollerView.contentSize = CGSize(width: self.frame.size.width, height: 100 )
        scrollerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(titleLab.snp.bottom).offset(5)
        }
        
        
        
        describeLab.snp.makeConstraints { (make) in
            make.left.equalTo(scrollerView).offset(20)
            make.width.equalTo(self.frame.size.width - 40)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-22)
        }
        
        let selBtnWidth = 15 + 8 * 2
        selectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20 - 8)
            make.size.equalTo(CGSize(width: selBtnWidth, height: selBtnWidth))
            make.top.equalTo(scrollerView.snp.bottom).offset(5)
        }
        
        selLab.snp.makeConstraints { (make) in
            make.left.equalTo(selectBtn.snp.right)
            make.top.equalTo(selectBtn).offset(5)
            make.right.equalTo(self).offset(-18)
            make.bottom.lessThanOrEqualToSuperview().offset(-51)
        }
        //取消
        let w = (YXConstant.screenWidth-114)/2
        cancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(selLab.snp.bottom).offset(10)
            make.left.equalTo(self).offset(22)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(48)
            make.right.equalTo(confirmBtn.snp.left).offset(-30)
            make.width.equalTo(w)
        }
        //确定
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(48)
            make.right.equalTo(self).offset(-22)
            make.width.equalTo(w)
        }
        resetScrollerViewContentSize()
    }
    
    @objc func resetScrollerViewContentSize() {
        
        let h1 = heightForView(text: describeLab.text ?? "", font: describeLab.font, width: self.frame.size.width - 40)
        
        scrollerView.contentSize = CGSize(width: self.frame.size.width, height: h1 )
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        resizeUI()
    }
    

}
