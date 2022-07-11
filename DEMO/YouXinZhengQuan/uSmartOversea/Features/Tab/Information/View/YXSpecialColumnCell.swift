//
//  YXSpecialColumnCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSpecialColumnCell: UITableViewCell {
    
    var columnMoreCallBack: (() -> ())?
    
    var columnSingleCallBack: ((YXSpecialColumnModel) -> ())?
    
    var columnList: [YXSpecialColumnModel]? {
        didSet {
            
            guard let list = self.columnList, list.count > 0 else {
                return
            }
            
            for view in self.columnView.subviews {
                view.removeFromSuperview()
            }
        
            for index in 0..<list.count {
                var lineViewX: Int = 0
                let firstModel = list[index]
                                
                //左侧的三角形
                let leftImageView = UIImageView.init()
                leftImageView.image = UIImage(named: "icons_blue_pulldown")
                leftImageView.frame = CGRect.init(x: lineViewX, y: 30 * index + 8, width: 15, height: 15)
                self.columnView.addSubview(leftImageView)
                
                lineViewX = 15
                
                //文章分类（0专栏，1研选)
                if firstModel.newsType == 1 {
                    //pro标签
                    let proImgView = UIImageView(image: UIImage(named: "news_recommend_pro"))
                    proImgView.frame = CGRect(x: lineViewX + 4, y: 30 * index + 8, width: 40, height: 16)
                    self.columnView.addSubview(proImgView)
                    lineViewX = Int(proImgView.qmui_right)
                }
                                                
                //按钮文字
                let btn = QMUIButton.init(frame: CGRect.init(x: CGFloat(lineViewX + 4), y: CGFloat(30 * index), width: YXConstant.screenWidth - 70, height: 30))
                btn.setTitle(list[index].title, for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 14)
                btn.contentHorizontalAlignment = .left
                btn.setTitleColor(.black, for: .normal)
                btn.tag = index
                btn.addTarget(self, action: #selector(self.clickSingleColumn(_:)), for: .touchUpInside)
                btn.titleLabel?.lineBreakMode = .byTruncatingTail
                self.columnView.addSubview(btn)
            }
            
//            self.bgView.setNeedsDisplay()
        }
    }
    
    var titleLabel = UILabel.init(with: UIColor.qmui_color(withHexString: "#353547"), font: UIFont.systemFont(ofSize: 18, weight: .medium), text: YXLanguageUtility.kLang(key: "news_columns"))
    var iconView = UIImageView.init(image: UIImage(named: "icons_news_more"))
    
    var columnView = UIView.init()
    
    var topBgClick = UIControl.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let lineView = UIView.init()
        lineView.backgroundColor = QMUITheme().themeTextColor()
        
        topBgClick.addTarget(self, action: #selector(self.topClickColumn(_:)), for: .touchUpInside)
        
        contentView.addSubview(lineView)
        contentView.addSubview(self.titleLabel)
        contentView.addSubview(self.iconView)
        contentView.addSubview(self.columnView)
        contentView.addSubview(self.topBgClick)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(17)
            make.top.equalTo(self).offset(16)
        }
        
        topBgClick.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(47)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(lineView)
            make.height.equalTo(25)
            make.leading.equalToSuperview().offset(12)
        }
        
        self.iconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(-18)
        }
    
        self.columnView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(self).offset(57)
        }
    }
    
    @objc func clickSingleColumn(_ sender: UIButton) {
        
        if let model = self.columnList?[sender.tag] {
            self.columnSingleCallBack?(model)
        }
    }
    
    @objc func topClickColumn(_ sender: UIControl) {
        self.columnMoreCallBack?()
    }
}

