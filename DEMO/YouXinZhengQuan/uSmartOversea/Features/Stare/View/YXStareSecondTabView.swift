//
//  YXStareSecondTabView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStareSecondTabPushView: UIView {
    
    var industryBtn: QMUIButton
    
    var st: UISwitch
    
    // 行业列表
    var industryDic: [String: Any]?
    // 指数列表
    var indexDic: [String: Any]?
    
    var popOver: YXStockPopover
    
    var meneView: YXStareIndustryListView?
    
    var rightView: UIView
    
    // 是否是指数
    var isIndex: Bool = false {
        didSet {
            self.rightView.isHidden = self.isIndex
        }
    }
    
    var type: Int = 0
    
    var pushList: [YXStarePushSettingModel]? {
        didSet {
            
        }
    }

    lazy var indexKey: String = {
        if YXUserManager.isENMode() {
            return "index_en"
        } else if YXUserManager.curLanguage() == .CN {
            return "index_cn"
        } else {
            return "index_tc"
        }
    }()
    
    var selectIndustryDic: [String: Any]? {
        didSet {
            if let title = self.selectIndustryDic?["industry_name"] as? String {
                self.industryBtn.setTitle(title, for: .normal)
            }
        }
    }
    
    var selectIndexDic: [String: Any]? {
        didSet {
            if let title = self.selectIndexDic?[self.indexKey] as? String {
                self.industryBtn.setTitle(title, for: .normal)
            }
        }
    }
            
    @objc var clickIndustryCallBack: ((_ dic: [String: Any]) -> ())?
    
    @objc var stValueCallBack: ((_ on: Bool) -> ())?
    
    override init(frame: CGRect) {
        
        industryBtn = QMUIButton.init(type: .custom)
        st = UISwitch.init()
        rightView = UIView.init()
        
        popOver = YXStockPopover.init()
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        industryBtn.setTitle("", for: .normal)
        industryBtn.setImage(UIImage(named: "check_icon_WhiteSkin"), for: .normal)
        industryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        industryBtn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        industryBtn.adjustsButtonWhenDisabled = false
        industryBtn.imagePosition = .right
        industryBtn.spacingBetweenImageAndTitle = 4
        industryBtn.addTarget(self, action: #selector(self.industryBtnDidClick(_:)), for: .touchUpInside)
        
        st.onTintColor = QMUITheme().themeTintColor()
        st.addTarget(self, action: #selector(self.stValueChange(_:)), for: .valueChanged)
        
        let infoBtn = UIButton.init()
        infoBtn.setImage(UIImage(named: "icon_parameter_info_WhiteSkin"), for: .normal)
        infoBtn.addTarget(self, action: #selector(self.infoBtnDidClick(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "receive_push"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        
        addSubview(rightView)
        addSubview(industryBtn)
        rightView.addSubview(st)
        rightView.addSubview(titleLabel)
        rightView.addSubview(infoBtn)
        
        rightView.snp.makeConstraints { (make) in
            make.trailing.bottom.top.equalToSuperview()
            make.width.equalTo(180)
        }
        
        industryBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        st.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-3)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-43)
            make.centerY.equalToSuperview()
        }
        
        infoBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(titleLabel.snp.leading).offset(-2)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        
//        st.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
    }
    
    @objc func industryBtnDidClick(_ sender: UIButton) {
        
        if let view = self.meneView {
            self.popOver.show(view, from: sender)
        } else {
            self.meneView = YXStareIndustryListView.init(frame: CGRect.init(x: 0, y: 0, width: 217, height: 430))
            self.popOver.show(self.meneView!, from: sender)
            
            self.meneView?.clickIndustryCallBack = { [weak self] dic in
                guard let strongSelf = self else { return }
                if self?.isIndex ?? false {
                    self?.selectIndexDic = dic
                    self?.clickIndustryCallBack?(dic)
                    if let title = dic[strongSelf.indexKey] as? String {
                        self?.industryBtn.setTitle(title, for: .normal)
                        self?.industryBtn.sizeToFit()
                    }
                } else {
                    self?.selectIndustryDic = dic
                    self?.clickIndustryCallBack?(dic)
                    if let title = dic["industry_name"] as? String {
                        self?.industryBtn.setTitle(title, for: .normal)
                        self?.industryBtn.sizeToFit()
                    }
                }

                self?.popOver.dismiss()
            }
        }
        self.meneView?.isIndex = self.isIndex
        if self.isIndex {
            self.meneView?.indexDic = self.indexDic
        } else {
            self.meneView?.industryDic = self.industryDic
        }
    }
    
    @objc func infoBtnDidClick(_ sender: UIButton) {
        
        var title = ""
        if self.industryBtn.currentTitle == YXLanguageUtility.kLang(key: "common_all") {
            title = YXLanguageUtility.kLang(key: "monitor_hold_push_tips")
        } else {
            title = YXLanguageUtility.kLang(key: "monitor_industry_push_tips")
        }
        let alert = YXAlertView.init(message: title)
        let sure = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default) { (action) in
            
        }
        alert.addAction(sure)
        alert.showInWindow()
    }
    
    @objc func stValueChange(_ sender: UISwitch) {
        if sender.isOn {
            
            var canPush = true
            if self.type != 3 {
                // 判断是否有权限
                var market = "hk"
                if self.type == 0 {
                    market = "hk"
                } else if self.type == 1 {
                    market = "us"
                } else {
                    market = "sh"
                }
                let level = YXUserManager.shared().getLevel(with: market)
                if level == .bmp || level == .delay {
                    canPush = false
                }
            }

            if canPush {
                // 打开
                let alert = YXAlertView.init(message: YXLanguageUtility.kLang(key: "monitor_industry_push_open_tips"))
                let cancel = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { (action) in
                    sender.setOn(false, animated: true)
                }
                let sure = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default) { (action) in
                    self.stValueCallBack?(sender.isOn)
                }
                alert.addAction(cancel)
                alert.addAction(sure)
                alert.showInWindow()
            } else {
                let alert = YXAlertView.init(message: YXLanguageUtility.kLang(key: "monitor_quote_permission_describe_tips"))

                let sure = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm2"), style: .default) { (action) in
                }
                sender.setOn(false, animated: true)
                
                alert.addAction(sure)
                alert.showInWindow()
            }

        } else {
            stValueCallBack?(sender.isOn)
        }
        
    }
}

class YXStareSecondTabView: UIView {
    
    // 0 港股 1 美股 2 沪深 3 自选
    var type: Int = 0
    
    @objc var selectIndex: Int = 0 {
        didSet {
            for btn in self.btns {
                if btn.tag == self.selectIndex + 1000 {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
            }
            self.updatePushView()
        }
    }
    
    @objc var pushList: [YXStarePushSettingModel]? {
        didSet {
            self.pushView.pushList = self.pushList
            self.updateStValue()
        }
    }
    
    @objc var clickBtnCallBack: ((_ tag: Int) -> ())?
    
    @objc var stValueCallBack: ((_ on: Bool) -> ())? {
        didSet {
            self.pushView.stValueCallBack = self.stValueCallBack
        }
    }
    
    @objc var clickIndustryCallBack: ((_ dic: [String: Any]) -> ())?
    
    var pushView: YXStareSecondTabPushView
    // 行业列表
    @objc var industryDic: [String: Any]? {
        didSet {
            self.pushView.industryDic = self.industryDic
        }
    }
    // 指数列表
    @objc var indexDic: [String: Any]? {
        didSet {
            self.pushView.indexDic = self.indexDic
        }
    }
    
    @objc var selectIndustryDic: [String: Any]? {
        didSet {
            self.pushView.selectIndustryDic = self.selectIndustryDic
        }
    }
    
    @objc var selectIndexDic: [String: Any]? {
        didSet {
            self.pushView.selectIndexDic = self.selectIndexDic
        }
    }
    
    var btns = [UIButton]()
        
    @objc convenience init(frame: CGRect, type: Int) {
        self.init(frame: frame)
        self.type = type
        initUI()
    }

    override init(frame: CGRect) {
        pushView = YXStareSecondTabPushView.init()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXStareSecondTabView {
    
    func initUI() {
        
        self.clipsToBounds = true
        addSubview(pushView)
        
        pushView.type = type
        pushView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(48)
        }
        
        pushView.clickIndustryCallBack = { [weak self] dic in
            let value = YXStareUtility.getStareType(withType: self?.type ?? 0, andSubType: self?.selectIndex ?? 0)
            if value == .index {
                self?.selectIndexDic = dic
            } else {
                self?.selectIndustryDic = dic
            }
            
            self?.clickIndustryCallBack?(dic)
            self?.updateStValue()
        }
        
        var titles = [""]
        if type == 0 {
            titles = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "new_stock"), YXLanguageUtility.kLang(key: "industry"), YXLanguageUtility.kLang(key: "index")]
        } else if type == 1 {
            titles = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "new_stock"), YXLanguageUtility.kLang(key: "industry"), YXLanguageUtility.kLang(key: "index")]
        } else if type == 2 {
            titles = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "industry"), YXLanguageUtility.kLang(key: "index")]
        } else {
            titles = [YXLanguageUtility.kLang(key: "news_watchlist"), YXLanguageUtility.kLang(key: "hold_holds")]
            self.pushView.industryBtn.setTitle(YXLanguageUtility.kLang(key: "common_all"), for: .normal)
            self.pushView.industryBtn.isEnabled = false
            self.pushView.industryBtn.setImage(nil, for: .normal)
        }
        
        let count = titles.count
        var left: CGFloat = 12
        let width: CGFloat = 72
        let height: CGFloat = 28
        var margin: CGFloat = (UIScreen.main.bounds.size.width - CGFloat(count) * width - left * 2) / CGFloat(count - 1)
        
        if titles.count == 2 {
            margin = 22
            left = (UIScreen.main.bounds.size.width - CGFloat(count) * width - margin) * 0.5
        }
        
        for i in 0..<count {
            let btn = UIButton.init(frame: CGRect.init(x: left + (margin + width) * CGFloat(i), y: 10, width: width, height: height))
            btn.setTitle(titles[i], for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
            btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
            if i == selectIndex {
                btn.isSelected = true
            }
            btn.layer.cornerRadius = 14
            btn.clipsToBounds = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.3
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            btn.tag = i + 1000
            if self.type == 2 {
                // a股
                if i == 1 {
                    btn.tag = 2 + 1000
                } else if (i == 2) {
                    btn.tag = 3 + 1000
                }
            }
            addSubview(btn)
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
            btn.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "F4F4F4")), for: .normal)
            btn.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "2F79FF")?.withAlphaComponent(0.1)), for: .selected)
            btns.append(btn)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        selectIndex = sender.tag - 1000
    }
    
    func updatePushView() {
        
        let value = YXStareUtility.getStareType(withType: self.type, andSubType: self.selectIndex)
        
        switch value {
        case .newStock:
            // 新股
            self.pushView.industryBtn.setTitle(YXLanguageUtility.kLang(key: "common_all"), for: .normal)
            self.pushView.industryBtn.setImage(nil, for: .normal)
            self.pushView.isIndex = false
            self.pushView.industryBtn.isEnabled = false
        case .index:
            // 指数
            self.pushView.industryBtn.setImage(UIImage(named: "check_icon_WhiteSkin"), for: .normal)
            self.pushView.selectIndexDic = self.selectIndexDic
            self.pushView.isIndex = true
            self.pushView.industryBtn.isEnabled = true
        case .industry:
            // 行业
            self.pushView.selectIndustryDic = self.selectIndustryDic
            self.pushView.industryBtn.setImage(UIImage(named: "check_icon_WhiteSkin"), for: .normal)
            self.pushView.isIndex = false
            self.pushView.industryBtn.isEnabled = true
        default:
            // 自选和持仓
            self.pushView.industryBtn.setTitle(YXLanguageUtility.kLang(key: "common_all"), for: .normal)
            self.pushView.industryBtn.setImage(nil, for: .normal)
            self.pushView.isIndex = false
        }

        self.pushView.industryBtn.sizeToFit()
        self.updateStValue()
        clickBtnCallBack?(selectIndex)
    }
    
    func updateStValue() {
        //推送设置类型，0：自选股，1：行业列表，2：智能筛选，3：次新股，4：微信，5：持仓
        func check(_ type: NSInteger) {
            if let list = self.pushList {
                var on = false
                for model in list {
                    // 行业
                    guard type == model.type else {
                        continue
                    }
                    if type == 0 {
                        let subModel = model.list.last
                        on = subModel?.status ?? false
                    } else if type == 5 {
                        let subModel = model.list.last
                        on = subModel?.status ?? false
                    } else if type == 3 {
                        var market = ""
                        // 判断市场
                        if self.type == 0 {
                            // hk
                            market = "hk"
                        } else if self.type == 1 {
                            // us
                            market = "us"
                        } else {
                            // hs
                            market = "hs"
                        }
                        for subModel in model.list {
                            if subModel.identifier == market {
                                on = subModel.status
                                break
                            }
                        }
                    } else {
                        if let code = self.selectIndustryDic?["industry_code_yx"] as? String {
                            for subModel in model.list {
                                if subModel.identifier == code {
                                    on = subModel.status
                                    break
                                }
                            }
                        }
                    }
                }
                self.pushView.st.setOn(on, animated: true)
            }
        }
        
        let value = YXStareUtility.getStareType(withType: self.type, andSubType: self.selectIndex)
        
        switch value {
        case .newStock:
            // 新股
//            check(3)
            print("")
        case .optional:
            // 自选
            check(0)
        case .hold:
            // 持仓
            check(5)
        case .industry:
            // 行业
            check(1)
        default:
            break
            
        }
    }
}



