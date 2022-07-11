//
//  STLUtilitySwift.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

func kKeyWindow() -> UIWindow? {
    var  window: UIWindow? = nil
    if #available(iOS 13.0, *) {
        for windowScene:UIWindowScene in (UIApplication.shared.connectedScenes as? Set<UIWindowScene>)! {
            if windowScene.activationState == .foregroundActive {
                window = windowScene.windows.first
            }
            break
        }
    } else {
        window = UIApplication.shared.keyWindow
    }
    return window
}

class STLUtilitySwift {

    class func classNameAsString(_ obj: Any) -> String {
        //prints more readable results for dictionaries, arrays, Int, etc
        return String(describing: type(of: obj))
    }
    
    class func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}

//临时
extension UIColor {
    static func colorWithHexString(_ hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        } else if (cString.hasPrefix("0x") || cString.hasPrefix("0X")) {
            cString = (cString as NSString).substring(from: 2)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r: UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0;
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    static func kRGBColorFromHex(_ value: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((value & 0xFF0000 >> 16)) / 255.0), green: ((CGFloat)((value & 0xFF00 >> 8)) / 255.0), blue: ((CGFloat)((value & 0xFF)) / 255.0), alpha: 1.0)
    }
}
