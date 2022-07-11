//
//  YXSquareSelectView.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


protocol EnumSquareTextProtocol {
    var text: String { get }
}

@objc enum YXSquareMarketType: Int {
    case hongKong
    case unitedStates
    case china
}

extension YXSquareMarketType: EnumSquareTextProtocol {
    var text: String {
        switch self {
        case .hongKong:
            return YXLanguageUtility.kLang(key: "community_hk_stock")
        case .unitedStates:
            return YXLanguageUtility.kLang(key: "community_us_stock")
        case .china:
            return YXLanguageUtility.kLang(key: "community_cn_stock")
        }
    }
    
    var marketString: String {
        switch self {
        case .hongKong:
            return "hk"
        case .unitedStates:
            return "us"
        case .china:
            return "hs"
        }
    }
}



class YXSquareSelectView<E: EnumSquareTextProtocol & Equatable>: UIView {
    
    typealias Closure = ((E)->())
    
    var selectedType: E! {
        
        didSet {
            guard typeArr.count > 0 else { return }
            for btn in btnArr {
                btn.isSelected = self.selectedType == typeArr[btn.tag]
            }
        }
    }
    
    var typeArr: [E]
    
    var clickCallBack: Closure?
    
    var btnArr = [UIButton]()
    
    init(list: [E], selected: E? = nil, clickCallBack: Closure?) {
        self.typeArr = list
        self.clickCallBack = clickCallBack
        
        if let type = selected, self.typeArr.contains(type) {
            self.selectedType = type
        } else {
            self.selectedType = typeArr.first
        }
        super.init(frame: .zero)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        guard typeArr.count > 0 else { return }
                
        updateUI()
    }
    
    
    func updateUI() {
                
        func getLineView() -> UIView {
            
            let view = UIView.init()
            let lineView = UIView.line()
            view.addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(1)
                make.height.equalTo(14)
            }
            return view
        }
        
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        btnArr.removeAll()
        for i in 0..<typeArr.count {
            let btn = UIButton.init()
            btn.setTitle(typeArr[i].text, for: .normal)
            btn.setTitleColor(QMUITheme().mainThemeColor(), for: .selected)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setBackgroundImage(UIImage.qmui_image(with: UIColor.clear), for: .normal)
            btn.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().mainThemeColor().withAlphaComponent(0.1)), for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.layer.cornerRadius = 4
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
            if typeArr[i] == selectedType {
                btn.isSelected = true
            }
            btn.tag = i
            
            addSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.equalTo(48)
                make.left.equalToSuperview().offset((48 + 12) * CGFloat(i))
                make.height.equalTo(24)
                make.centerY.equalToSuperview()
            }
            btnArr.append(btn)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        self.selectedType = typeArr[sender.tag]
        self.clickCallBack?(self.selectedType)
    }
    
    func updateType(_ typeArr: [E]? = nil, selected: E? = nil) {
        if let array = typeArr, self.typeArr != array {
            self.typeArr = array
            
            if array.count > 0 {
                if let selected = selected {
                    self.selectedType = selected
                }
                if !self.typeArr.contains(self.selectedType) {
                    self.selectedType = array.first
                }
                updateUI()
                
                
//                selectedBlock?(self.selectedType)
            }
        } else {
            if let selected = selected, selected != self.selectedType {
                self.selectedType = selected
//                selectedBlock?(self.selectedType)
            }
        }
    }
}
