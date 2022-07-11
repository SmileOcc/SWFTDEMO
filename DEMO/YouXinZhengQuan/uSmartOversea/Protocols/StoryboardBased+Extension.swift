//
//  StoryboardBased+Extension.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Reusable

extension StoryboardBased {
    
    static func instantiate(withIdentifier identifier :String) -> Self {
        let viewController = sceneStoryboard.instantiateViewController(withIdentifier: identifier)
        guard let typedViewController = viewController as? Self else {
            fatalError("The initialViewController of '\(sceneStoryboard)' is not of class '\(self)'")
        }
        return typedViewController
    }
    
}
