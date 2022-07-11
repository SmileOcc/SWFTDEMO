//
//  YXCommunityHeaderView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/10.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXCommunityHeaderView: UIView {


    @objc var selectCallBack: ((_ selectIndex: Int) -> ())?
    @objc let titles: [String] = [YXLanguageUtility.kLang(key: "community_global"),
                                  YXLanguageUtility.kLang(key: "community_singapore")]
    @objc var selectIndex: Int = YXUserManager.shared().curDiscussionTab.rawValue
    
    var selectBtn: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    init(selectIndex: Int) {
        super.init(frame: CGRect.zero)
        self.selectIndex = selectIndex
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        let count = titles.count
        let height: CGFloat = 28
        let margin: CGFloat = 14
        var lastBtn:UIButton?
        for i in 0..<count {
            let btn = UIButton.init(frame: .zero)
            btn.setTitle(titles[i], for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
            if i == selectIndex {
                btn.isSelected = true
                selectBtn = btn
                selectBtn?.isSelected = true
            }
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.tag = i + 1000
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
                            
            btn.setBackgroundImage(UIImage.tabItemNoramalDynamicImage(), for: .normal)
            
            btn.setBackgroundImage(UIImage.tabItemSelectedDynamicImage(), for: .selected)

            
            let titleWidth = (self.titles[i] as String).boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : btn.titleLabel?.font], context: nil).width
            
            
            
            addSubview(btn)
            if let lastBtn = lastBtn {
                btn.snp.makeConstraints { make in
                    make.width.equalTo(titleWidth+20)
                    make.height.equalTo(height)
                    make.left.equalTo(lastBtn.snp.right).offset(margin)
                    make.centerY.equalToSuperview()
                }
            } else {
                btn.snp.makeConstraints { make in
                    make.width.equalTo(titleWidth+20)
                    make.height.equalTo(height)
                    make.left.equalToSuperview().offset(margin)
                    make.centerY.equalToSuperview()
                }
            }
            lastBtn = btn
        }
        
    }
    
    @objc func btnClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        selectIndex = sender.tag - 1000
        selectBtn?.isSelected = false
        
        sender.isSelected = true
        selectBtn = sender
        
        selectCallBack?(selectIndex)
    }

}


class YXCommunityHeaderView1: UICollectionReusableView {


    @objc var selectCallBack: ((_ selectIndex: Int) -> ())?
    @objc let titles: [String] = [YXLanguageUtility.kLang(key: "community_global"),
                                  YXLanguageUtility.kLang(key: "community_singapore")]
    @objc var selectIndex: Int = YXUserManager.shared().curDiscussionTab.rawValue
    
    var selectBtn: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth , height: 45))
        initUI()
    }
    
    init(selectIndex: Int) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth , height: 45))
        self.selectIndex = selectIndex
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        let count = titles.count
        let height: CGFloat = 28
        let margin: CGFloat = 14
        var lastBtn:UIButton?
        for i in 0..<count {
            let btn = UIButton.init(frame: .zero)
            btn.setTitle(titles[i], for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
            if i == selectIndex {
                btn.isSelected = true
                selectBtn = btn
                selectBtn?.isSelected = true
            }
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.tag = i + 1000
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
                            
            btn.setBackgroundImage(UIImage.tabItemNoramalDynamicImage(), for: .normal)
            
            btn.setBackgroundImage(UIImage.tabItemSelectedDynamicImage(), for: .selected)

            
            let titleWidth = (self.titles[i] as String).boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : btn.titleLabel?.font], context: nil).width
            
            
            
            addSubview(btn)
            if let lastBtn = lastBtn {
                btn.snp.makeConstraints { make in
                    make.width.equalTo(titleWidth+20)
                    make.height.equalTo(height)
                    make.left.equalTo(lastBtn.snp.right).offset(margin)
                    make.centerY.equalToSuperview()
                }
            } else {
                btn.snp.makeConstraints { make in
                    make.width.equalTo(titleWidth+20)
                    make.height.equalTo(height)
                    make.left.equalToSuperview().offset(margin)
                    make.centerY.equalToSuperview()
                }
            }
            lastBtn = btn
        }
        
    }
    
    @objc func btnClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        selectIndex = sender.tag - 1000
        selectBtn?.isSelected = false
        
        sender.isSelected = true
        selectBtn = sender
        
        selectCallBack?(selectIndex)
    }

}
