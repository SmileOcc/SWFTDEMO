//
//  HDConst.swift
//  SwiftStructure
//
//  Created by MountainZhu on 2019/8/21.
//  Copyright © 2019 Mountain. All rights reserved.
//

//使用说明
//使用HDConst.name
//

import Foundation
import UIKit
//import JPus

public struct HDConst {
    /// 服务器地址
    public static let BASE_URL = "http://api.dantangapp.com/"

    public static let isLogin = "isLogin"

    /// code 码 200 操作成功
    public static let RETURN_OK = 200
    /// 间距
    public static let kMargin: CGFloat = 10.0
    /// 圆角
    public static let kCornerRadius: CGFloat = 5.0
    /// 线宽
    public static let klineWidth: CGFloat = 1.0
    /// 首页顶部标签指示条的高度
    public static let kIndicatorViewH: CGFloat = 2.0
    /// 新特性界面图片数量
    public static let kNewFeatureCount = 4
    /// 顶部标题的高度
    public static let kTitlesViewH: CGFloat = 35
    /// 顶部标题的y
    public static let kTitlesViewY: CGFloat = 64
    /// 动画时长
    public static let kAnimationDuration = 0.25
    /// 屏幕的宽
    public static let SCREENW = UIScreen.main.bounds.size.width
    public static func ScreenWith(width:CGFloat) -> CGFloat {
        return (SCREENW/375.0)*width;
    }
    /// 屏幕的高
    public static let SCREENH = UIScreen.main.bounds.size.height
    public static func ScreenHeight(height:CGFloat) -> CGFloat {
        return (SCREENH/(isIPhoneX ? 812.0 : 667.0))*height;
    }
    /// iPhone 5
    public static let isIPhone5 = UIScreen.main.bounds.size.height == 568 ? true : false
    /// iPhone 6
    public static let isIPhone6 = UIScreen.main.bounds.size.height == 667 ? true : false
    /// iPhone 6P
    public static let isIPhone6P = UIScreen.main.bounds.size.height == 736 ? true : false
    /// iPhone X
    public static let isIPhoneX = UIScreen.main.bounds.size.height == 812 ? true : false
    /// iPhone 11
    public static let isIPhone11 = UIScreen.main.bounds.size.height == 896 ? true : false
    /// 刘海系列
    public static let isIPhoneX_type = UIScreen.main.bounds.size.height >= 812 ? true : false
    //默认底图名称
    public static let DEFUALTPICTURE = ""
    
    //一些固定的参数
    public static let HEIGHT_STATUSBAR = isIPhoneX_type ? CGFloat(44) : CGFloat(20)
    public static let HEIGHT_STATUSBAR_NAVBAR = isIPhoneX_type ? CGFloat(88) : CGFloat(64)
    public static let HEIGHT_NAVBAR = isIPhoneX_type ? CGFloat(66) : CGFloat(44)
    public static let HEIGHT_TABBAR = isIPhoneX_type ? CGFloat(83) : CGFloat(49)
    public static let HEIGHT_TABBAR_SECURITY = isIPhoneX_type ? CGFloat(34) : CGFloat(0) // iPhone X底部安全区域,34
    public static let HEIGHT_TABBAR_TOP = isIPhoneX_type ? CGFloat(0) : CGFloat(10)
    
    public static let MGJRouterParameterURL = "MGJRouterParameterURL"
    public static let MGJRouterParameterCompletion = "MGJRouterParameterCompletion"
    public static let MGJRouterParameterUserInfo = "MGJRouterParameterUserInfo"

    public static let MGJ_ROUTER_WILDCARD_CHARACTER = "~"
    public static let specialCharacters = "/?&."
    
    public static func ColorManager(_ colorName:NSString) -> UIColor {
        return HDColorManager.sharedInstance.onGetColorName(colorName);
    }
}

public enum HDTopicType: Int {
    case Selection = 4
}

