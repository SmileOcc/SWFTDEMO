//
//  IncreaseGateTextField.swift
//  Adorawe
//
//  Created by fan wang on 2021/9/17.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class IncreaseGateTextField: UITextField {
    
    ///清除按钮与输入文本之间的间距
    var gate:CGFloat?

//    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        
//        if let gate = gate {
//            let width = bounds.width - gate
//            if OSSVSystemsConfigsUtils.isRightToLeftShow(){
//                return CGRect(x: bounds.minX + gate, y: bounds.minY, width: width, height: bounds.height)
//            }else{
//                return CGRect(x: bounds.minX, y: bounds.minY, width: width, height: bounds.height)
//            }
//        }
//        
//        return bounds
//        
//    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let gate = gate {
            let width = bounds.width - gate
            if OSSVSystemsConfigsUtils.isRightToLeftShow(){
                return CGRect(x: bounds.minX + gate, y: bounds.minY, width: width, height: bounds.height)
            }else{
                return CGRect(x: bounds.minX, y: bounds.minY, width: width, height: bounds.height)
            }
        }
        
        return bounds
    }

}
