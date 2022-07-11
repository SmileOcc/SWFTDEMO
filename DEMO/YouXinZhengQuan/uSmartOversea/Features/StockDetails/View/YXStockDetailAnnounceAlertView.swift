//
//  YXStockDetailAnnounceAlertView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailAnnounceAlertBtn: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        self.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
    }
}

class YXStockDetailAnnounceAlertView: UIView {

    
    var selectCallBack: ((_ index: NSInteger, _ title: String?) -> ())?
    var dismissCallBack:(() -> ())?
    var bgControl: UIControl
    var selectView: UIView
    
    var titles = [String]() {
        
        didSet {
            for view in self.selectView.subviews {
                view.removeFromSuperview()
            }
            
            for i in 0..<self.titles.count {
                let str = self.titles[i]
                let frame = CGRect.init(x: 0, y: 20 + i * 53, width: Int(YXConstant.screenWidth), height: 53)
                let btn = YXStockDetailAnnounceAlertBtn.init(frame: frame)
                btn.addTarget(self, action: #selector(self.btnDidClick(_:)), for: .touchUpInside)
                btn.setTitle(str, for: .normal)
                if i == 0 {
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
                btn.tag = 1000 + i
                let bottomView = UIView.init()
                bottomView.backgroundColor = QMUITheme().separatorLineColor()
                let lineframe = CGRect.init(x: 10, y: 20 + i * 53, width: Int(YXConstant.screenWidth) - 20, height: 1)
                bottomView.frame = lineframe
                self.selectView.addSubview(btn)
                self.selectView.addSubview(bottomView)
            }
        
            self.selectView.snp.updateConstraints { (make) in
                make.height.equalTo(53 * self.titles.count + 20)
            }
            
        }
    }
    
    var selectIndex: NSInteger = 0 {
        
        didSet {
            for view in self.selectView.subviews {
                if let btn = view as? YXStockDetailAnnounceAlertBtn {
                    if btn.tag == 1000 + self.selectIndex {
                        btn.isSelected = true
                    } else {
                        btn.isSelected = false
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        
        self.bgControl = UIControl.init()
        self.bgControl.backgroundColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.3)
        self.selectView = UIView.init()
        self.selectView.backgroundColor = QMUITheme().foregroundColor()
        self.selectView.layer.cornerRadius = 20
        self.selectView.clipsToBounds = true
        
        super.init(frame: frame)
        
        self.bgControl.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        addSubview(bgControl)
        addSubview(selectView)
        
        bgControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
    }
    
    func showInView(with view: UIView) {
        view.addSubview(self)
    }
    
    @objc func dismiss() {
        self.removeFromSuperview()
        self.dismissCallBack?()
    }
    
    @objc func btnDidClick(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        let index = sender.tag - 1000
        self.selectIndex = index
        self.dismiss()
        self.selectCallBack?(index, sender.currentTitle)
    }
    
}
