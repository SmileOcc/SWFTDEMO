//
//  UINavigationBar+Extension.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    func resetBackBarButton() {
                
        backIndicatorImage = UIImage(named: "icon_backbarbtn")
        backIndicatorTransitionMaskImage = UIImage(named: "icon_backbarbtn")
    }
}
