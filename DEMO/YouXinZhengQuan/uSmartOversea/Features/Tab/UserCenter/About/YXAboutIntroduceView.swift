//
//  YXAboutIntroduceView.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/11.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxGesture
import Moya
import Lottie


class YXAboutIntroduceView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var items: [[String: String]] = [[:]]
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        lab.textAlignment = .left
        lab.numberOfLines = 0
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(config:[[String: String]]) {
        self.init(frame: .zero)
        items = config
        initSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   

    func initSubview() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        var lastView:UIView = titleLabel
        for item in items {
            let rowView = creatRowView(image: item["image"], title: item["title"], desc: item["desc"])
            addSubview(rowView)
            rowView.snp.makeConstraints { make in
                if item == items.first {
                    make.top.equalTo(lastView.snp.bottom).offset(26)
                }else {
                    make.top.equalTo(lastView.snp.bottom)
                }
                if item == items.last {
                    make.bottom.equalToSuperview()
                }
                make.width.equalToSuperview()
               
            }
            
            if item != items.last{
                let lineView = UIView()
                addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.right.equalToSuperview().offset(-16)
                    make.left.equalToSuperview().offset(16)
                    make.height.equalTo(0.5)
                    make.top.equalTo(rowView.snp.bottom)
                }
                lineView.backgroundColor = QMUITheme().separatorLineColor()
            }
            lastView = rowView
        }
    }
    
    func creatRowView(image:String?,title:String?,desc:String?) -> View{
        let containerView = UIView()
        let iconView = UIImageView()
        iconView.image = UIImage.init(named: image ?? "")
        
        let titLab = UILabel()
        if YXUserManager.isENMode() {
            titLab.font = .systemFont(ofSize: 14, weight: .medium)
        }else {
            titLab.font = .systemFont(ofSize: 14, weight: .regular)
        }
        titLab.textColor = QMUITheme().textColorLevel1()
        titLab.text = title
        
        let descLab = UILabel()
        descLab.font = .systemFont(ofSize: 12)
        descLab.textColor = QMUITheme().textColorLevel3()
        descLab.text = desc
        descLab.numberOfLines = 0
        
        containerView.addSubview(iconView)
        containerView.addSubview(titLab)
        containerView.addSubview(descLab)
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 47, height: 45))
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(16)
            make.bottom.greaterThanOrEqualToSuperview().offset(-16).priority(.low)
        }
        
        titLab.snp.makeConstraints { make in
            make.top.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        descLab.snp.makeConstraints { make in
            make.top.equalTo(titLab.snp.bottom).offset(4)
            make.left.equalTo(titLab)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16).priority(.high)
        }
        
        return containerView
    }
    
    func setTitleText(_ text:String) {
        let attrString = NSMutableAttributedString(string: text)
        attrString.yy_lineSpacing = 2
        attrString.yy_color = QMUITheme().textColorLevel2()
        attrString.yy_lineBreakMode = .byWordWrapping
        attrString.yy_alignment = .left
        attrString.yy_font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.titleLabel.attributedText = attrString
    }
}
