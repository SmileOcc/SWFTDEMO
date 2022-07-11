//
//  YXPopImageView.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

class YXPopImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: uniVerLength(270), height: uniVerLength(370)))
        
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
