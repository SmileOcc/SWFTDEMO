//
//  YXCourseDetailBottomView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit

class YXCourseDetailBottomView: UIView {
        
    lazy var shareBtn: UIButton = {
        let btn = UIButton()
        btn.adjustsImageWhenHighlighted = false
        btn.setImage(UIImage(named: "course_share_icon"), for: .normal)
        return btn
    }()
    
    lazy var commentView: QMUIButton = {
        let view = QMUIButton()
        view.adjustsButtonWhenHighlighted = false
        view.backgroundColor = QMUITheme().foregroundColor()
        let imageView = UIImageView(image: UIImage(named: "comment_write"))
                
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel4()
        label.text = YXLanguageUtility.kLang(key: "nbb_saysomething")
        
        let grayBackView = UIView()
        grayBackView.isUserInteractionEnabled = false
        grayBackView.backgroundColor = QMUITheme().blockColor()
        grayBackView.layer.cornerRadius = 6
        grayBackView.layer.masksToBounds = true
        
        let line = UIView()
        line.backgroundColor = QMUITheme().blockColor()
        
        view.addSubview(grayBackView)
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(line)
        
        grayBackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(6)
        }
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(grayBackView).offset(16)
            make.centerY.equalTo(grayBackView)
            
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.centerY.equalTo(grayBackView)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        
        addSubview(commentView)
        addSubview(shareBtn)
        addSubview(line)
        
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        commentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalTo(shareBtn.snp.left)
            make.height.equalTo(56)
        }
//
        shareBtn.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
        }
        
    }
}
