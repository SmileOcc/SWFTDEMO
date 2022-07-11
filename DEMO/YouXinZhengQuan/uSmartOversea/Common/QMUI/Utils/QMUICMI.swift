//
//  QMUICMI.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

public func QMUITheme() -> YXThemeColor {
    YXThemeColor.sharedInstance()
}


extension UIView {
    
    @objc func yx_setOnlyLightStyle() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
        }
    }
}

extension UIImageView {
    
    @objc static func holdGradient(with size: CGSize = CGSize(width: 23, height: 58)) -> UIImageView {
        let imageView = self.init()
        var image = UIImage()
        if #available(iOS 13.0, *) {
            image.imageAsset?.register(UIImage(gradientColors: [.white, .white.withAlphaComponent(0)], size: size, isHorizontal: true), with: UITraitCollection.init(userInterfaceStyle: .light))
            image.imageAsset?.register(UIImage(gradientColors: [UIColor.qmui_color(withHexString: "#101014")!, UIColor.qmui_color(withHexString: "#101014")!.withAlphaComponent(0)], size: size, isHorizontal: true), with: UITraitCollection.init(userInterfaceStyle: .dark))
        } else {
            image = UIImage(gradientColors: [.white, .white.withAlphaComponent(0)], size: size, isHorizontal: true)
        }
        imageView.image = image
        return imageView
    }
}



extension String {
    var themeSuffix: String {
        if YXThemeTool.isDarkMode() {
            return self + "_dark"
        } else {
            return self
        }
    }
}

extension UIImage {
    
    /// tab的正常动态图片(例如社区的切换tab)
    @objc static func tabItemNoramalDynamicImage() -> UIImage? {
        return UIImage.yx_registDynamicImage(with: .white, darkColor: UIColor.qmui_color(withHexString: "#101014")!)
    }
    /// tab的选中动态图片(例如社区的切换tab)
    @objc static func tabItemSelectedDynamicImage() -> UIImage? {
        return UIImage.yx_registDynamicImage(with: UIColor.qmui_color(withHexString: "#414FFF")!.withAlphaComponent(0.1), darkColor: UIColor.qmui_color(withHexString: "#6671FF")!.withAlphaComponent(0.1))
    }
    
    @objc static func yx_registDynamicImage(with normalColorHex: String, darkColorHex: String) -> UIImage? {
        
        let image = UIImage()
        if #available(iOS 13.0, *) {
            image.imageAsset?.register(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: normalColorHex)) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .light))
            image.imageAsset?.register(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: darkColorHex)) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .dark))
            
            return image
        } else {
            return UIImage.qmui_image(with: UIColor.qmui_color(withHexString: normalColorHex))
        }
    }
    
    @objc static func yx_registDynamicImage(with normalColor: UIColor, darkColor: UIColor) -> UIImage? {
        let image = UIImage()
        if #available(iOS 13.0, *) {
            image.imageAsset?.register(UIImage.qmui_image(with: normalColor) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .light))
            image.imageAsset?.register(UIImage.qmui_image(with: darkColor) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .dark))
            
            return image
        } else {
            return UIImage.qmui_image(with: normalColor)
        }
    }
}
