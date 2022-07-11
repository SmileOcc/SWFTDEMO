//
//  YXSmartTradeGuideRiskView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/12/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXSmartTradeGuideRiskView: UIView {

    lazy var titleLab : UILabel={
       let lab = UILabel()
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.isUserInteractionEnabled = true
        lab.text = YXLanguageUtility.kLang(key: "usStock_subs_risk_tip")
        return lab
    }()
    
    @objc lazy var descLab : UILabel={
       let lab = UILabel()
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        lab.numberOfLines = 0
        lab.isHidden = true
        return lab
    }()
    
    
    lazy var moreBtton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "icon_drop_down"), for: .normal)
        btn.setImage(UIImage.init(named: "icon_drop_up"), for: .selected)
        return btn
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView.line()
        lineView.isHidden = true
        return lineView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private var titleLabBottom: Constraint?
    private var descBottom: Constraint?
    
    var isExpand : Bool = false
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(titleLab)
        addSubview(descLab)
        addSubview(moreBtton)
        addSubview(lineView)
        
        backgroundColor = QMUITheme().blockColor()
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(11)
            self.titleLabBottom = make.bottom.equalToSuperview().offset(-12).priority(.high).constraint
        }
        moreBtton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab.snp.centerY)
            make.right.equalTo(-12)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.right.equalTo(moreBtton)
            make.height.equalTo(0.5)
            make.top.equalTo(titleLab.snp.bottom).offset(10)
        }
        
        descLab.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.equalTo(titleLab)
            make.right.equalTo(moreBtton)
            self.descBottom = make.bottom.equalToSuperview().offset(-12).priority(.low).constraint
        }
        
        
        let topView = UIView()
        topView.isUserInteractionEnabled = true
        addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let tap = UITapGestureRecognizer()
        topView.addGestureRecognizer(tap)
        tap.addActionBlock {[weak self] _ in
            guard let `self` = self else { return }
            self.isExpand = !self.isExpand
            self.moreBtton.isSelected = self.isExpand
            if self.isExpand{
                self.titleLabBottom?.update(priority: .low)
                self.descBottom?.update(priority: .high)
                self.lineView.isHidden = false
                self.descLab.isHidden = false
            }else {
                self.titleLabBottom?.update(priority: .high)
                self.descBottom?.update(priority: .low)
                self.lineView.isHidden = true
                self.descLab.isHidden = true
            }
        }
    }
    
//    func setDesc(text:String) {
//        self.descLab.text = text
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
