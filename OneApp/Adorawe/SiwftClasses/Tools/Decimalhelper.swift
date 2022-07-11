//
//  Decimalhelper.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

class Decimalhandler:NSObject{
    ///四舍五入/向上取整
    @objc static func decimal(value:Float,num:Int16)->NSDecimalNumber{
        let roundDehavior = NSDecimalNumberHandler(roundingMode: .up, scale: num, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let de = NSDecimalNumber(value: value)
        let result = de.rounding(accordingToBehavior: roundDehavior)
        return result
        
    }
}


