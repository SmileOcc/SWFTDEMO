//
//  YXStatementTipAlterView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementTipAlterView: UIView {
    
    let sumString:String = YXLanguageUtility.kLang(key: "statementPop")
    
    typealias ClickBlock = () -> Void
    var okBlock:ClickBlock?
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        return view
    }()

    lazy var textView:UITextView = {
        let view = UITextView()
        var attribute:NSMutableAttributedString = NSMutableAttributedString.init(string: sumString, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.normalFont14()])
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        paragraph.paragraphSpacing = 1
        attribute.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: sumString.count))
        view.attributedText = attribute
        return view
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    var okBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .normalFont16()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.addTarget(self, action: #selector(okAction(_ :)), for: .touchUpInside)
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(contentView)
        contentView.addSubview(textView)
        contentView.addSubview(lineView)
        contentView.addSubview(okBtn)
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(284)
            make.height.equalTo(339)
            make.center.equalToSuperview()
        }
        
        okBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalTo(okBtn.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(1)
        }
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(lineView.snp.top).offset(-21)
        }
    }
    
    
    @objc func okAction(_ sender:QMUIButton) {
        self.okBlock?()
    }

}
