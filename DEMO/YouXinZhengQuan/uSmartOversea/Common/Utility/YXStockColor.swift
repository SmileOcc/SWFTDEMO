//
//  YXStockColor.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockColor: NSObject {

    enum StockStatus {
        case up
        case down
        case flat
    }
    
    class func currentColor(_ colorType: StockStatus) -> UIColor {
        switch colorType {
        case .up:
            return QMUITheme().stockRedColor()
        case .down:
            return QMUITheme().stockGreenColor()
        default:
            return QMUITheme().stockGrayColor()
        }
    }
    
    class func currentColor(_ stockValue: Double) -> UIColor {
        if stockValue > 0 {
            return self.currentColor(.up)
        } else if stockValue < 0 {
            return self.currentColor(.down)
        } else {
            return self.currentColor(.flat)
        }
    }
}
