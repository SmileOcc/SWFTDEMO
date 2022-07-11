//
//  YXLiveBeginCutdownView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveBeginCutdownView: UIView {

    @objc var cutEndCallBack: (()->())?
    
    let label = UILabel.init(text: "", textColor: UIColor.white, textFont: UIFont.systemFont(ofSize: 60, weight: .medium))!
    
    var count: Int = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        label.textAlignment = .center
        label.backgroundColor = UIColor.qmui_color(withHexString: "#666666")?.withAlphaComponent(0.8)
        label.layer.cornerRadius = 60
        label.clipsToBounds = true
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(120)
        }
    }
    
    @objc func begin() {
        self.isHidden = true
        self.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(self)
        
        YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
            self?.isHidden = false
            self?.label.text = "\(self?.count ?? 0)"
            self?.count -= 1
            if (self?.count ?? 0) < 0 {
                self?.cutEndCallBack?()
                self?.removeFromSuperview()
            }
        }, timeInterval: 1, repeatTimes: 4, atOnce: false)
    }
    
    
}
