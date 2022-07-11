//
//  UIButton+Theme.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

/*按钮的高亮背景色图片*/

let btnBgImageGradientBlue: UIImage = {
    //#0EC0F1   --> 14,192,241  --> UIColor(red: 14/255.0, green: 192/255.0, blue: 241/255.0, alpha: 1)
    //#535AF0   --> 83,90,240   --> UIColor(red: 83/255.0, green: 90/255.0, blue: 240/255.0, alpha: 1)
    if let color1 = UIColor.qmui_color(withHexString: "#0EC0F1"), let color2 = UIColor.qmui_color(withHexString: "#535AF0") {
        return UIImage.init(gradientColors: [color1, color2])
    }
    return UIImage.init(gradientColors: [UIColor(red: 14/255.0, green: 192/255.0, blue: 241/255.0, alpha: 1), UIColor(red: 83/255.0, green: 90/255.0, blue: 240/255.0, alpha: 1)])
}()
    

let btnBgImageGradientOrange: UIImage = {
    // #FAD961 --> 250,217,97
    // #F76B1C --> 247,107,28
    if let color1 = UIColor.qmui_color(withHexString: "#FAD961"), let color2 = UIColor.qmui_color(withHexString: "#F76B1C") {
        return UIImage.init(gradientColors: [color1, color2])
    }
    return UIImage.init(gradientColors: [UIColor(red: 250/255.0, green: 217/255.0, blue: 97/255.0, alpha: 1), UIColor(red: 247/255.0, green: 107/255.0, blue: 28/255.0, alpha: 1)])
}()

extension UIButton {
    
    //設置按鈕是否可點擊
    @objc func setDisabledTheme(_ corner: CGFloat = 24) {
        self.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().mainThemeColor()), for: .normal)
        self.setTitleColor(.white, for: .normal)
//        self.setBackgroundImage(btnBgImageGradientBlue, for: .highlighted)
//        self.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#E2E2E2")), for: .disabled)
        if corner > 0 {
            self.layer.cornerRadius = corner
            self.clipsToBounds = true
        }
    }
    
    //渐变背景色
//    func gradientBgColor(with frame: CGRect) {
//        let bgLayer1 = CAGradientLayer()
//        bgLayer1.colors = [UIColor(red: 0.05, green: 0.75, blue: 0.95, alpha: 1).cgColor,
//                           UIColor(red: 0.33, green: 0.35, blue: 0.94, alpha: 1).cgColor]
//        bgLayer1.locations = [0, 1]
//        bgLayer1.frame = frame
//        bgLayer1.startPoint = CGPoint(x: 0, y: 0)
//        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
//        self.layer.addSublayer(bgLayer1)
//    }
    
    //设置按钮背景图片渐变蓝
    @objc open func setBtnBgImageGradientBlue() {
        self.setBackgroundImage(btnBgImageGradientBlue, for: .normal)
        self.setBackgroundImage(btnBgImageGradientBlue, for: .highlighted)
        self.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#D1D1D1")), for: .disabled)
        
        self.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        self.setTitleColor(UIColor.white, for: .normal)
        
        self.makeCorners(with: 6)
    }
    //设置按钮背景图片渐变橙色
    @objc open func setBtnBgImageGradientOrange() {
        self.setBackgroundImage(btnBgImageGradientOrange, for: .normal)
        self.setBackgroundImage(btnBgImageGradientOrange, for: .highlighted)
        self.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#D1D1D1")), for: .disabled)
        
        self.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        self.setTitleColor(UIColor.white, for: .normal)
        
        self.makeCorners(with: 6)
    }
    
    func makeCorners(with corners: CGFloat) {
        self.layer.cornerRadius = corners
        self.layer.masksToBounds = true
    }
    
    //設置按鈕
    @objc func setSubmmitTheme(_ corner: CGFloat = 4) {
        self.layer.cornerRadius = corner
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().mainThemeColor()
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
}
