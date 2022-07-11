//
//  YXTradeSegmentView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import QuartzCore



class YXTradeSegmentView<E: EnumTextProtocol & Equatable>: UIView {
    
    lazy var leftBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.titleLabel?.numberOfLines = 2
        btn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.qmui_tapBlock = { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.selectedType = strongSelf.typeArr.first
            strongSelf.selectedBlock?(strongSelf.selectedType)
        }
        return btn
    }()

    lazy var rightBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.titleLabel?.numberOfLines = 2
        btn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.qmui_tapBlock = { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.selectedType = strongSelf.typeArr.last
            strongSelf.selectedBlock?(strongSelf.selectedType)
        }
        return btn
    }()
    
    lazy var subLayer: CAShapeLayer = {
        let layer = btnLayer(roundedRect: CGRect(origin: .zero, size: CGSize(width: itemSize.width * CGFloat(self.typeArr.count), height: itemSize.height)), byRoundingCorners: .allCorners)
        layer.strokeColor = QMUITheme().popSeparatorLineColor().cgColor
        return layer
    }()

    private var typeArr: [E]! {
        didSet {
            if oldValue != typeArr {
                updateUI()
            }
        }
    }
    
    private(set) var selectedType: E! {
        didSet {
            refreshLayer()
        }
    }

    var itemSize: CGSize = CGSize(width: 44, height: 20) {
        didSet {
            let roundedRect = CGRect(origin: CGPoint(x: itemSize.width * 2 - itemSize.width * CGFloat(self.typeArr.count), y: 0),
                                     size: CGSize(width: itemSize.width * CGFloat(self.typeArr.count), height: itemSize.height))
            subLayer.path = UIBezierPath(roundedRect: roundedRect,
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: 2, height: 2)).cgPath
            subLayer.frame = CGRect(origin: .zero, size: roundedRect.size)
            updateUI()
        }
    }

//    private var subLayers: [CAShapeLayer] = []
    private var subButtons: [UIButton] = []
    
    private var selectedBlock: ((E) -> Void)?
    convenience init(typeArr: [E], selected: E? = nil, selectedBlock:((E) -> Void)?) {
        self.init()
        
        self.typeArr = typeArr
        if typeArr.count > 1 {
            self.typeArr = [E](typeArr[0...1])
        }

        self.selectedBlock = selectedBlock
        
        if let type = selected, self.typeArr.contains(type) {
            self.selectedType = type
        } else {
            self.selectedType = typeArr.first
        }
        
        initUI()
        updateUI()
        
        DispatchQueue.main.async {
            self.selectedBlock?(self.selectedType)
        }
    }
    
    func updateType(_ typeArr: [E]? = nil, selected: E? = nil) {
        var array = typeArr ?? []
        if array.count > 1 {
            array = [E](array[0...1])
        }
        if self.typeArr != array, array != [] {
            self.typeArr = array
            
            if array.count > 0 {
                if let selected = selected {
                    self.selectedType = selected
                }
                if !self.typeArr.contains(self.selectedType) {
                    self.selectedType = array.first
                }

                selectedBlock?(self.selectedType)
            }
        } else {
            if let selected = selected, selected != self.selectedType {
                if self.typeArr.contains(selected) {
                    self.selectedType = selected
                }
                selectedBlock?(self.selectedType)
            }
        }
    }
    
    func initUI() {
        layer.addSublayer(subLayer)

        addSubview(rightBtn)
        addSubview(leftBtn)
        
        leftBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(itemSize.width)
            make.right.equalTo(rightBtn.snp.left)
        }

        rightBtn.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(itemSize.width)
        }
    }

    private var isNewStyle = false
    
    func useNewStyle() {
        isNewStyle = true

        leftBtn.backgroundColor = QMUITheme().blockColor()
        rightBtn.backgroundColor = QMUITheme().blockColor()

        layer.cornerRadius = 4
        layer.masksToBounds = true
        subLayer.removeFromSuperlayer()
        updateUI()
    }
    
    func updateUI() {
        leftBtn.snp.updateConstraints { make in
            make.width.equalTo(itemSize.width)
        }
        
        rightBtn.snp.updateConstraints { make in
            make.width.equalTo(itemSize.width)
        }
        
        leftBtn.isHidden = true
        rightBtn.isHidden = true
        
        if typeArr.count == 1 {
            rightBtn.isHidden = false
            rightBtn.isEnabled = false
            
            if isNewStyle {
                rightBtn.snp.updateConstraints { make in
                    make.width.equalTo(itemSize.width * 2)
                }
            }

            subButtons = [rightBtn]
        } else {
            rightBtn.isHidden = false
            leftBtn.isHidden = false
            rightBtn.isEnabled = true
            
            subButtons = [leftBtn, rightBtn]
        }
        
        leftBtn.setTitle(typeArr.first?.text, for: .normal)
        rightBtn.setTitle(typeArr.last?.text, for: .normal)
        
        refreshLayer()
    }
    
    func refreshLayer() {
        subButtons.forEach{
            $0.isSelected = false
            $0.layer.borderColor = nil
            $0.layer.borderWidth = 0
            if isNewStyle {
                $0.backgroundColor = QMUITheme().blockColor()
            }
        }
        
        if typeArr.count > 1, let index = typeArr.firstIndex(of: selectedType) {
            let subButton = subButtons[index]
            subButton.isSelected = true
            
            if isNewStyle {
                if YXThemeTool.isDarkMode() {
                    subButton.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.2)
                } else {
                    subButton.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
                }
            } else {
                let button = subButtons[index]
                button.layer.borderColor = QMUITheme().themeTextColor().cgColor
                button.layer.borderWidth = 1.0/UIScreen.main.scale
            }
        }
    }
    
    private func btnLayer(roundedRect: CGRect, byRoundingCorners corners: UIRectCorner) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: roundedRect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: 2, height: 2))
        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = 1.0/UIScreen.main.scale
        maskLayer.path = path.cgPath
        maskLayer.frame = roundedRect
        maskLayer.fillColor = UIColor.clear.cgColor
        return maskLayer
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshLayer()
    }

}
