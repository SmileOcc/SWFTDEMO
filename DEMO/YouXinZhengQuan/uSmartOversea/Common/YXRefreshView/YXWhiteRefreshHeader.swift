//
//  YXWhiteRefreshHeader.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/8/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXWhiteRefreshHeader: YXRefreshHeader {
    
    override func pullingAnimation() -> String {
        "refresh_pulling_white"
    }
    
    override func refreshAnimation() -> String {
        "refresh_refreshing_white"
    }
    
    override func tipLabelColor() -> UIColor {
        UIColor.white
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
