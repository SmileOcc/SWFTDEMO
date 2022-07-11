//
//  YXSecondRefreshHeader.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/8/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSecondRefreshHeader: YXRefreshHeader {

    override func pullingAnimation() -> String {
        return "refresh_pulling_second"
    }
    
    override func refreshAnimation() -> String {
        return "refresh_refreshing_second"
    }
    
    override func tipLabelColor() -> UIColor {
        return QMUITheme().textColorLevel2()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
