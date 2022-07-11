//
//  YXCourseDetailInfoView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import SnapKit
import RxCocoa
import RxSwift

class YXCourseDetailInfoView: UIView {
    
    ///简介
    lazy var expandBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.titleLabel?.textColor = QMUITheme().mainThemeColor()
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_see_more"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_see_less"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        btn.imagePosition = .right
        return btn
    }()
    
    ///标题
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        return label
    }()
    
    private var isExplanded = false
    
    //描述
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 1
        return label
    }()
    
//    //收藏
//    lazy var favoriteBtn: UIButton = {
//        let btn = UIButton()
//        btn.adjustsImageWhenHighlighted = false
//        btn.setImage(UIImage(named: "course_uncollect_icon"), for: .normal)
//        btn.setImage(UIImage(named: "course_collected_icon"), for: .selected)
//        return btn
//    }()
    
    var explandBottom: Constraint?
    var descBottom: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func needHideExpandBtn(lessonDesc:String) -> Bool {
        self.expandBtn.isSelected = false
        let att = NSMutableAttributedString.init(string: lessonDesc, attributes: [.font:UIFont.systemFont(ofSize: 12),.foregroundColor:QMUITheme().textColorLevel2()])
        let layout = YYTextLayout.init(containerSize: CGSize.init(width: Int(YXConstant.screenWidth) - 32, height: Int.max), text: att)
        let height = layout?.textBoundingSize.height ?? 13
        if height >= 20 {
            self.explandBottom?.update(priority: .high)
            self.descBottom?.update(priority: .low)
            self.expandBtn.isHidden = false
            return false
        }else {
            self.expandBtn.isHidden = true
            self.explandBottom?.update(priority: .low)
            self.descBottom?.update(priority: .high)
            return true
        }
       
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(titleLabel)
        addSubview(expandBtn)
       // addSubview(favoriteBtn)
        addSubview(descLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-22)
        }
//
//        favoriteBtn.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.right.equalToSuperview().offset(-16)
//            make.size.equalTo(40)
//        }
        
        expandBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(descLabel.snp.bottom).offset(4)
            self.explandBottom = make.bottom.equalToSuperview().offset(-20).priority(.high).constraint
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            self.descBottom = make.bottom.equalToSuperview().offset(-20).priority(.low).constraint
        }
       // self.descLabel.isHidden = true
        _ = expandBtn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            self.isExplanded = !self.isExplanded
            self.expandBtn.isSelected = !self.expandBtn.isSelected
            if self.isExplanded {
                self.descLabel.numberOfLines = 0
            } else {
                self.descLabel.numberOfLines = 1
            }
            
        })
    }
}
