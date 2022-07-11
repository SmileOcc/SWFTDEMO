//
//  YXPrivatelyView.swift
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/9/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXPrivatelyView: UIView {
    
    @objc lazy var scrollerView: UIScrollView = {
        let v = UIScrollView()
        return v
    }()
    
    @objc lazy var titleLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures")
        label.numberOfLines = 0
        return label
    }()
    
    @objc lazy var describeLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures_tip")
        return label
    }()
    
    @objc lazy var chooseLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = YXLanguageUtility.kLang(key: "grey_mkt_risk_disclosures_sel")
        return label
    }()
    
    @objc lazy var chooseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("", for: .normal)
        btn.setTitleColor( QMUITheme().textColorLevel3(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        btn.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .selected)
        return btn
    }()
    
    @objc lazy var chooseLabBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    
    @objc lazy var cancelBtn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.backgroundColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = true
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        
        return btn
    }()
    
    @objc lazy var confirmBtn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        btn.setBackgroundImage(UIImage(color: QMUITheme().themeTintColor()), for: .normal)
        btn.setBackgroundImage(UIImage(color: UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.2) ?? .white), for: .disabled)
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = true
        btn.isEnabled = false
        
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        
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
        
        layer.cornerRadius = 20
        backgroundColor = UIColor.white
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        
        addSubview(scrollerView)
        scrollerView.addSubview(titleLab)
        scrollerView.addSubview(describeLab)
        
        let chooseContainerView = UIView()
        addSubview(chooseContainerView)
        
        chooseContainerView.addSubview(chooseLab)
        chooseContainerView.addSubview(chooseBtn)
        chooseContainerView.addSubview(chooseLabBtn)
        
        addSubview(confirmBtn)
        addSubview(cancelBtn)
        
        let h2 = heightForView(text: chooseLab.text ?? "", font: chooseLab.font, width: self.size.width-44-5-20)

        scrollerView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(self).offset(-75 - h2)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(scrollerView).offset(24)
        }
        
        describeLab.snp.makeConstraints { (make) in
            make.left.equalTo(scrollerView).offset(22)
            make.width.equalTo(self.size.width - 44)
            make.top.equalTo(titleLab.snp.bottom).offset(20)
        }
        
        chooseContainerView.snp.makeConstraints { (make) in
            make.height.equalTo(h2)
            make.bottom.equalTo(self).offset(-76)
            make.leading.equalTo(self).offset(30)
            make.trailing.equalTo(self).offset(-30)
        }
        
        chooseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(chooseContainerView)
            make.top.equalTo(chooseContainerView)
            make.height.equalTo(20)
        }
        
        chooseLab.snp.makeConstraints { (make) in
            make.left.equalTo(chooseBtn.snp.right).offset(5)
            make.width.equalTo(self.size.width - 44 - 5 - 20)
            make.top.equalTo(chooseBtn)
        }
        
        chooseLabBtn.snp.makeConstraints { (make) in
            make.top.left.equalTo(chooseBtn)
            make.right.bottom.equalTo(chooseLab)
        }
        
        let w = (YXConstant.screenWidth - 114)/2
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(22)
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(48)
            make.right.equalTo(confirmBtn.snp.left).offset(-30)
            make.width.equalTo(w)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-20)
            make.height.equalTo(48)
            make.right.equalTo(self).offset(-22)
            make.width.equalTo(confirmBtn)
        }
        
        chooseBtn.rac_signal(for: .touchUpInside).subscribeNext {[weak self] (x) in
            x?.isSelected = !(x?.isSelected ?? false)
            if x?.isSelected ?? false{
                self?.confirmBtn.isEnabled = true
            }else {
                self?.confirmBtn.isEnabled = false
            }
        }
        
        chooseLabBtn.rac_signal(for: .touchUpInside).subscribeNext {[weak self] (x) in
            self?.chooseBtn.isSelected = !(self?.chooseBtn.isSelected ?? true)
            if self?.chooseBtn.isSelected ?? false{
                self?.confirmBtn.isEnabled = true
            } else {
                self?.confirmBtn.isEnabled = false
            }
        }
        
        resetScrollerViewContentSize()
    }
    
    @objc func resetScrollerViewContentSize() {
        
        let h1 = heightForView(text: describeLab.text ?? "", font: describeLab.font, width: self.size.width - 44)
        
        scrollerView.contentSize = CGSize(width: self.size.width, height: h1 + 96)
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

}
