//
//  YXDateFilterButton.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDateFilterButton: QMUIButton {
    public enum DateFilterButtonStyle {
        case white, dark
    }
    
    var style: DateFilterButtonStyle = .white
    
    /*
     Begin : 不同风格的配色、字体大小、文案配置
     */
    fileprivate var normalBgColor: UIColor? {
        get {
            self.style == .white
                ? QMUITheme().foregroundColor()
                : UIColor(red: 0.04, green: 0.07, blue: 0.12, alpha: 1)
        }
    }
    
    fileprivate var selectedBgColor: UIColor? {
        get {
            self.style == .white
                ? QMUITheme().foregroundColor()
                : UIColor(red: 0.13, green: 0.2, blue: 0.38, alpha: 0.8)
        }
    }
    
    fileprivate var normalBorderColor: CGColor? {
        get {
            self.style == .white
                ? QMUITheme().pointColor().cgColor
                : UIColor(red: 0.62, green: 0.69, blue: 0.79, alpha: 0.1973).cgColor
        }
    }
    
    fileprivate var selectedBorderColor: CGColor? {
        get {
            self.style == .white
                ? QMUITheme().themeTextColor().cgColor
                : QMUITheme().textColorLevel1().withAlphaComponent(0.8).cgColor
        }
    }
    /*
     End : 不同风格的配色、字体大小、文案配置
     */
    
    required init(style: DateFilterButtonStyle) {
        self.style = style
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.backgroundColor = self.normalBgColor
        self.layer.cornerRadius = 4.0
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.layer.borderColor = self.normalBorderColor
        self.layer.borderWidth = QMUIHelper.pixelOne
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = self.selectedBorderColor
                self.backgroundColor = self.selectedBgColor
            } else {
                self.layer.borderColor = self.normalBorderColor
                self.backgroundColor = self.normalBgColor
            }
        }
    }
}
