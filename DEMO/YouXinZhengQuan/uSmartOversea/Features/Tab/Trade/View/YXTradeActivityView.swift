//
//  YXTradeActivityView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeActivityView: UIView {

    
    typealias ClosureClick = () -> Void
      
    
    // 活动中心
    @objc var onClickActivity: ClosureClick?
    
    fileprivate lazy var actRedDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    @objc var hideActRedDot: Bool = false {
        didSet {
            self.actRedDotView.isHidden = hideActRedDot
        }
    }
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "user_activity")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    lazy var activityCenterButton: YXTradeItemSubView = { //高级账户
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_activity", text: YXLanguageUtility.kLang(key: "user_activity"))
        return view
    }()
    
    lazy var placeholderButton: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var placeholderButton2: YXTradeItemSubView = {//占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var placeholderButton3: YXTradeItemSubView = {//占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var itemHeight: CGFloat = {
        return 50
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.markView)
        self.addSubview(self.titleLabel)
        
        self.markView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(17)
            make.width.equalTo(4)
            make.height.equalTo(14)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.markView)
            make.left.equalTo(self.markView.snp.right).offset(7)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-8)
        }
        
        self.addSubview(self.activityCenterButton)
        self.addSubview(self.placeholderButton)
        self.addSubview(self.placeholderButton2)
        self.addSubview(self.placeholderButton3)
        
        let firstBtns = [activityCenterButton, placeholderButton, placeholderButton2, placeholderButton3]
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(itemHeight)//50
        }
        
        addTapGestureWith(view: activityCenterButton, sel: #selector(activityCenterAction))
        
        addSubview(self.actRedDotView)
        let actImgView = activityCenterButton.imageView
        actRedDotView.snp.makeConstraints { (make) in
            make.left.equalTo(actImgView.snp.right)
            make.centerY.equalTo(actImgView.snp.top)
            make.width.height.equalTo(8)
        }
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func activityCenterAction() {
        if let closure = onClickActivity {
            closure()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
