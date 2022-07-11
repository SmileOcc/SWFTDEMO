//
//  YXBrokerDetailTitleView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBrokerDetailTitleView: UIView {


    @objc var clickCallBack: ((_ index: NSInteger) -> ())?
    
    var leftBtn: UIButton
    var rightBtn: UIButton
    var titleLabel: UILabel
    
    @objc var selectIndex: NSInteger = 0 {
        didSet {
            if let list = self.list, list.count > 0 {
                let model = list[self.selectIndex]
                titleLabel.text = model.name
                
                if self.selectIndex == 0 {
                    self.leftBtn.isEnabled = false
                } else {
                    self.leftBtn.isEnabled = true
                }
                
                if self.selectIndex == list.count - 1 {
                    self.rightBtn.isEnabled = false
                } else {
                    self.rightBtn.isEnabled = true
                }
            }
        }
    }
    
    @objc var list: [YXStockAnalyzeBrokerStockInfo]?
    
    override init(frame: CGRect) {
        leftBtn = YXExpandAreaButton.init()

        leftBtn.setImage(UIImage(named: "market_more_arrow")?.qmui_image(with: .leftMirrored), for: .normal)
        
        rightBtn = YXExpandAreaButton.init()
        rightBtn.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        
        titleLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: .systemFont(ofSize: 20))
        
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


extension YXBrokerDetailTitleView {
    func initUI() {
        
        leftBtn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 12 / 16.0
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(20)
            make.width.equalTo(140)
        }
        leftBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-16)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if sender == self.leftBtn {
            self.selectIndex = self.selectIndex - 1
        } else if sender == self.rightBtn {
            self.selectIndex = self.selectIndex + 1
        }
        
        clickCallBack?(self.selectIndex)
    }
}
