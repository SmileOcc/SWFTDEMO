//
//  UILabel+StockName.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/5/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

extension UILabel {
    func setStockName(_ text: String?) {
        if let string = text, string.characterLength() > 16 {
            self.text = string.subString(toCharacterIndex: 16) + "..."
        } else {
            self.text = text
        }
    }
}
