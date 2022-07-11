//
//  YXShortcutTopView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShortcutTopView: UIView {
    
    var selectBtn: UIButton?
    
    var orderBtn: UIButton?
    
    var clickCallBack: ( (_ tag: NSInteger) -> () )?

    let kBaseTag = 1000

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.backgroundColor = QMUITheme().foregroundColor()
        let titles = [YXLanguageUtility.kLang(key: "hold_trade_title"), YXLanguageUtility.kLang(key: "trading_hold_warehouse"), YXLanguageUtility.kLang(key: "trading_today_order")]
        let images = ["s_trade", "s_hold", "s_today"]
        let height: CGFloat = 48
        let width: CGFloat = 106
        let margin = (YXConstant.screenWidth - 7 * 2 - width * 3) / 2;
        for i in 0..<titles.count {
            let btn = QMUIButton.init(frame: CGRect.init(x: 7 + (margin + width) * CGFloat(i), y: 0, width: width, height: height))
            btn.tag = i + kBaseTag
            btn.setImage(UIImage(named: images[i] + "_close"), for: .normal)
            btn.setImage(UIImage(named: images[i] + "_open"), for: .selected)
            btn.setTitle(titles[i], for: .normal)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.3
            btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
            btn.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
            btn.imagePosition = .left
            btn.spacingBetweenImageAndTitle = 6
            if YXConstant.deviceScaleEqualTo4S {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            } else {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
            btn.addTarget(self, action: #selector(self.btnDidClick(_:)), for: .touchUpInside)
            self.addSubview(btn)
            if i == 2 {
                self.orderBtn = btn
            }
        }
    }
    
    
    @objc func btnDidClick(_ sender: UIButton) {
        if let btn = self.selectBtn {
            if btn == sender {
                clickCallBack?(0)
                self.selectBtn?.isSelected = false
                self.selectBtn = nil
            } else {
                btn.isSelected = false
                self.selectBtn = sender
                sender.isSelected = true
                clickCallBack?(sender.tag + 1 - kBaseTag)
            }
        } else {
            self.selectBtn = sender
            sender.isSelected = true
            clickCallBack?(sender.tag + 1 - kBaseTag)
        }
    }
}

class YXShortcutView: YXStockDetailBaseView {
    
    var refreshHeightCallBack: ( (_ height: CGFloat) -> () )?
    
    var views = [UIView]()
    
    let topView = YXShortcutTopView.init()
    let bottomView = UIView.init()
    
    var shortcutIndex: NSInteger = 0
    
    var shortTradeHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.clipsToBounds = true
        self.addSubview(topView)
        self.addSubview(bottomView)
        
        topView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.trailing.equalToSuperview()
        }
        
        
        topView.clickCallBack = { [weak self] tag  in
            
            var height: CGFloat = 0
            if tag == 0 {
                height = 0
            } else if tag == 1 {
                height = self?.shortTradeHeight ?? 0
            } else if tag == 2 {
                height = 200
            } else if tag == 3 {
                height = 200
            }
            
            self?.shortcutIndex = tag
            self?.refreshShortcut()
            self?.refreshHeightCallBack?(height + 48)

        }
        
    }
    
    
    func refreshShortcut() {
        for i in 0..<self.views.count {
            let view = self.views[i]
            if i == self.shortcutIndex - 1 {
                if view.superview == nil {
                    self.bottomView.addSubview(view)
                    view.snp.makeConstraints { (make) in
                        make.top.bottom.leading.equalToSuperview()
                        make.trailing.equalToSuperview().offset(-1)
                    }
                }
            } else {
                view.removeFromSuperview()
            }
        }
    }
}
