//
//  ZFSwiftBaseViewController.swift
//  ZZZZZ
//
//  Created by YW on 2019/7/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

import UIKit

class ZFSwiftBaseViewController: UIViewController {

    lazy var backButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.backgroundColor = UIColor.clear
        button.frame = CGRect.init(x: 0, y: 0, width: 64, height: 64)
        button.addTarget(self, action: #selector(ZFSwiftBaseViewController.goBackAction), for: UIControl.Event.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 30, left: -3, bottom: 0, right: 0)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white;
        if #available(iOS 7.0, *) {
            tabBarController?.tabBar.isTranslucent = false
            edgesForExtendedLayout = UIRectEdge.all
            extendedLayoutIncludesOpaqueBars = false
            automaticallyAdjustsScrollViewInsets = false;
        }
        view.addSubview(backButton)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
    
    @objc func goBackAction() -> Void {
        
    }
}
