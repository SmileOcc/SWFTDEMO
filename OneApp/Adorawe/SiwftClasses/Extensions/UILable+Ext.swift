//
//  UILable+Ext.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import UIKit


extension UILabel{
    ///文本不可压缩
    func setTextWidthPriorityMax(){
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
