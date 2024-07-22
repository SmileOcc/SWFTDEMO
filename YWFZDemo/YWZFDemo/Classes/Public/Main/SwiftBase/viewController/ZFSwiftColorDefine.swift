//
//  ZFSwiftColorDefine.swift
//  ZZZZZ
//
//  Created by YW on 2019/7/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

import UIKit

class ZFSwiftColorDefine: NSObject {
    @inline(__always) public static func RGBColor(_red : CGFloat, _green : CGFloat, _blue : CGFloat, _alpha : CGFloat) -> UIColor {
        return UIColor.init(red: _red / 255.0, green: _green / 255.0, blue: _blue / 255.0, alpha: _alpha)
    }
}
