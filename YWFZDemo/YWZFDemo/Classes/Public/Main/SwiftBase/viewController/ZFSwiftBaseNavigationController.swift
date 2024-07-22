//
//  ZFSwiftBaseNavigationController.swift
//  ZZZZZ
//
//  Created by YW on 2019/7/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

import UIKit

class ZFSwiftBaseNavigationController: UINavigationController {

    private static let initialize: () = {
        let naviBar = UINavigationBar.appearance()
        naviBar.barTintColor = UIColor.white
        naviBar.tintColor = ZFSwiftColorDefine.RGBColor(_red: 0, _green: 0, _blue: 0, _alpha: 1.0)
        naviBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
                                       NSAttributedString.Key.foregroundColor : ZFSwiftColorDefine.RGBColor(_red: 51, _green: 51, _blue: 51, _alpha: 1.0)]
        
        let backImage = UIImage.init(named: "nav_arrow_left")
        naviBar.backIndicatorImage = backImage
        naviBar.backIndicatorTransitionMaskImage = backImage
        
        guard #available(iOS 11.0, *) else {
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: 0, vertical: 0), for: UIBarMetrics.default)
            return
        }
//        [navBar setBarTintColor:[UIColor whiteColor]];
//        [navBar setTintColor:ZFCOLOR(0, 0, 0, 1.0)];
//        [navBar setTitleTextAttributes:@{ NSFontAttributeName: ZFFontBoldSize(18),
//            NSForegroundColorAttributeName:ZFCOLOR(51, 51, 51, 1.0)
//            }];
//
//        UIImage *backImage = [UIImage imageNamed:([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
//        [navBar setBackIndicatorImage:backImage];
//        [navBar setBackIndicatorTransitionMaskImage:backImage];
//
//        if(kiOSSystemVersion < 11.0) {
//            // 将返回按钮的文字position设置不在屏幕上显示
//            [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
//        }
    }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        ZFSwiftBaseViewController.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
