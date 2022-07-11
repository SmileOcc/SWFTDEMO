//
//  YXNavigationController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXNavigationController: QMUINavigationController {
    
    override func qmui_didInitialize() {
        super.qmui_didInitialize()
        
        self.modalPresentationStyle = .fullScreen
        navigationBar.backIndicatorImage = UIImage.init(named: "nav_back")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        } else {
            
        }
        self.view.backgroundColor = QMUITheme().foregroundColor()
    }
    
    override func didShowViewController(_ viewController: UIViewController, animated: Bool) {
        super.didShowViewController(viewController, animated: animated)
        if self.viewControllers.count > 1 {
            self.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
