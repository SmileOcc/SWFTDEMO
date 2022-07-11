//
//  YXTapButtonView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTapButtonView: UIView {
    
    @objc var tapAction: ((_ index: Int) -> Void)?

    @objc private(set) var selectIndex: Int = 0
    
    var buttonArray: [YXTapButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc init(titles: [String]) {
        super.init(frame: CGRect.zero)

//        let borderColor = QMUITheme().pointColor()
//        self.layer.borderWidth = 1
//        self.layer.borderColor = borderColor?.cgColor
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        let count = titles.count
        for (index, title) in titles.enumerated() {
            let button = YXTapButton()
            button.setTitle(title, for: .normal)
            button.setTitle(title, for: .selected)
            
            if index == 0 {
                button.isSelected = true
                button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                button.layer.cornerRadius = 4.0
            } else {
                button.isSelected = false
            }
            
            if index == count - 1 {
                button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                button.layer.cornerRadius = 4.0
            }
            
            button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] in
                guard let `self` = self else { return }
                for button in self.buttonArray {
                    button.isSelected = false
                }
                button?.isSelected = true
                self.selectIndex = index
                self.tapAction?(index)
            }).disposed(by: rx.disposeBag)
            
            self.addSubview(button)
            buttonArray.append(button)
        }
        
        var preView: UIView?
        for button in buttonArray {
            button.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                if let view = preView {
                    make.left.equalTo(view.snp.right).offset(-1)
                    make.width.equalToSuperview().multipliedBy(1.0 / CGFloat(count)).offset(1)
                } else {
                    make.left.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(1.0 / CGFloat(count))
                }
            }
            preView = button
        }

    
    }

    @objc func resetSelectIndex(_ index: Int) {
        for (i, button) in self.buttonArray.enumerated() {
            button.isSelected = false
            if i == index {
                button.isSelected = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXTapButton: UIButton {
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
                self.layer.borderColor = UIColor.themeColor(withNormalHex: "#ECEDFF", andDarkColor: "#3E3E4D").cgColor
            } else {
                titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
                self.layer.borderColor = UIColor.themeColor(withNormalHex: "#EAEAEA", andDarkColor: "#212129").cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        //self.backgroundColor = QMUITheme().foregroundColor()
        
        setTitleColor(QMUITheme().textColorLevel3(), for: .normal)

        let selectedTitleColor = UIColor.themeColor(withNormalHex: "#414FFF", andDarkColor: "#D3D4E6")
        setTitleColor(selectedTitleColor, for: .selected)
        setTitleColor(selectedTitleColor, for: [.selected, .highlighted])

        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        

        self.layer.borderWidth = 1.0
        
        setBackgroundImage(UIImage.yx_registDynamicImage(with: .white, darkColor: UIColor.qmui_color(withHexString: "#101014")!), for: .normal)

        let selectedBackgroudImg = UIImage.yx_registDynamicImage(with: "#ECEDFF", darkColorHex: "#3E3E4D")
        setBackgroundImage(selectedBackgroudImg, for: .selected)
        setBackgroundImage(selectedBackgroudImg, for: [.selected, .highlighted])
        
        adjustsImageWhenHighlighted = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.isSelected = self.isSelected
    }
    
}
