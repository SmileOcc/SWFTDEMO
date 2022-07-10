//
//  UIFont+Extension.swift
//  MADBase
//
//  Created by MountainZhu on 2020/6/11.
//  Copyright © 2020 md. All rights reserved.
//

//使用说明
//使用UIFont.name()
//

import UIKit

public extension UIFont {
    private static let regularName = "Helvetica Neue"
    private static let boldName = "Helvetica Neue Bold"
    
    convenience init(font: CGFloat) {
        self.init(name: UIFont.regularName, size: font)!
    }
    
    static func NomalFont() -> UIFont {
        return UIFont(font: 15)
    }
}
