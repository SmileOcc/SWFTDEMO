//
//  HDColorManager.swift
//  HDBaseProject
//
//  Created by 航电 on 2020/7/20.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class HDColorManager: NSObject {
    
    private var dayColorDic:NSDictionary?;
    private var nightColorDic:NSDictionary?;
    
    static let sharedInstance = HDColorManager.init();
    
    override init() {
        super.init();
        self.dayColorDic = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "DayColor", ofType: "plist")!);
        self.nightColorDic = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "NightColor", ofType: "plist")!);
    }
    
    public func onGetColorName(_ colorName:NSString) -> UIColor {
        if colorName.length == 0 {
            return .white;
        }

        if #available(iOS 13.0, *) {
            let color = UIColor.init { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return self.onShowColorFromString(self.dayColorDic![colorName] as! NSString);
                }
                else if traitCollection.userInterfaceStyle == .dark {
                    return self.onShowColorFromString(self.nightColorDic![colorName] as! NSString);
                }
                return self.onShowColorFromString(self.dayColorDic![colorName] as! NSString);
            }
            return color;
        }
        return self.onShowColorFromString(self.dayColorDic![colorName] as! NSString);
    }
    
    private func onShowColorFromString(_ colorName:NSString) -> UIColor {
        var selectName = colorName;
        if selectName.hasPrefix("#") {
            selectName = selectName.substring(from: 1) as NSString;
        }
        
        if selectName.length > 6 {
            selectName = selectName.substring(with: NSRange(location: 0, length: 6)) as NSString;
        }
        
        let scaner:Scanner = Scanner(string: selectName as String);
        var hexNum:UInt32 = 0;
        if scaner.scanHexInt32(&hexNum) {
            return UIColor(hex:Int(hexNum));
        }
        
        return .white;
    }
}

/*
    1. VC_Main_Bg_Color 所有试图的灰色底图
    2. VC_White_To_Black 白色和黑色
    3. WC_Title_Black 字体是黑色的 000000
    4. WC_Title_DarkLightGray 字体是666666
    5. WC_Title_LightGray 字体是浅灰色 999999
    6. WC_Title_DarkGray 字体是深灰色 333333
    7. WC_Main_Message_Bg 首页消息背景
    8. WC_Main_Message_Line_Bg 首页消息线条背景
    9. WC_Main_Header_Title1,WC_Main_Header_Title2,WC_Main_Header_Title3,WC_Main_Header_Title4 首页头部4个字体颜色
    10. WC_Search_Cancel_Title 搜索框取消按钮颜色
    11. WC_Tabbar_Title_Normal tabbar 默认字体
    12. WC_Tabbar_Title_Select tabbar选中字体
    13. WC_Application_Red 工作台红色字体
 */
