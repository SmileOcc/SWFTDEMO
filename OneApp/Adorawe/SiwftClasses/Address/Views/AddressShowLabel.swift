//
//  AddressShowLabel.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/22.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

class AddressShowLabel: UILabel {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.textColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
