//
//  YXHistoryFilterButton.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHistoryFilterButton: QMUIButton {
    override func didInitialize() {
        super.didInitialize()
        self.imagePosition = .right
        self.spacingBetweenImageAndTitle = 6
        self.backgroundColor = QMUITheme().foregroundColor()
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
}
