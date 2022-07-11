//
//  Digit+Scale.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/9.
//

import Foundation
import UIKit

//切换xcode12 或 13，有时候识别到 其他类ALAssetRepresentation  scale()
fileprivate func cscale() -> CGFloat {
    let smWidth = UIScreen.main.bounds.size.width
    let scale = smWidth / 375
    return scale
}

extension CGFloat{
    func sacel375()->CGFloat {
       return self*cscale()
    }
    
    func sacel375Font()->CGFloat{
        return floor(sacel375())
    }
}

extension Int{
    func sacel375()->Int {
        return self*Int(cscale())
    }
    func sacel375f()->CGFloat {
        return CGFloat(self)*cscale()
    }
    func sacel375Font()->CGFloat{
        return floor(sacel375f())
    }
}

extension Float{
    func sacel375()->Float {
       return self*Float(cscale())
    }
    func sacel375f()->CGFloat {
        return CGFloat(self)*cscale()
    }
    func sacel375Font()->CGFloat{
        return floor(sacel375f())
    }
}

extension Double{
    func sacel375()->Double {
       return self*Double(cscale())
    }
    func sacel375f()->CGFloat {
        return CGFloat(self)*cscale()
    }
    func sacel375Font()->CGFloat{
        return floor(sacel375f())
    }
    
}


